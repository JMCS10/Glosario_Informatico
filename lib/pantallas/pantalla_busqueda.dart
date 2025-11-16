import 'package:flutter/material.dart';
import 'pantalla_resultado.dart';
import '../logica/glosario.dart';
import '../logica/termino.dart';
import 'pantalla_inicio.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> todosLosTerminos = [];
  List<Map<String, dynamic>> filtrados = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarTerminos();
  }

  Future<void> cargarTerminos() async {
    final terminos = await Glosario.obtenerTodosLosNombres();
    setState(() {
      todosLosTerminos = terminos;
      filtrados = terminos;
      cargando = false;
    });
  }

  void _filtrar(String query) {
    if (query.isEmpty) {
      setState(() {
        filtrados = todosLosTerminos;
      });
      return;
    }

    final resultados = todosLosTerminos.where((termino) {
      final nombre = termino['nombretermino'] as String;
      return nombre.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filtrados = resultados;
    });
  }

  Future<void> compartirGlosarioCompleto() async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generando PDF del glosario completo...'),
            ],
          ),
        ),
      );

      // Obtener todos los términos completos
      final terminosCompletos = <Termino>[];
      for (var terminoMap in todosLosTerminos) {
        final termino = await Glosario.buscarTerminoPorId(terminoMap['id']);
        if (termino != null) {
          terminosCompletos.add(termino);
        }
      }

      // Ordenar alfabéticamente
      terminosCompletos.sort((a, b) => 
        a.nombreTermino.toLowerCase().compareTo(b.nombreTermino.toLowerCase())
      );

      // Crear el PDF
      final pdf = pw.Document();

      // Página de portada
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'GLOSARIO',
                    style: pw.TextStyle(
                      fontSize: 48,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'INFORMÁTICO',
                    style: pw.TextStyle(
                      fontSize: 48,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    '${terminosCompletos.length} términos',
                    style: pw.TextStyle(
                      fontSize: 18,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Una página por cada término
      for (var termino in terminosCompletos) {
        // Descargar la imagen si existe
        pw.ImageProvider? imagenPdf;
        if (termino.imagenUrl != null && termino.imagenUrl!.isNotEmpty) {
          try {
            imagenPdf = await networkImage(termino.imagenUrl!);
          } catch (e) {
            print('Error al cargar imagen para ${termino.nombreTermino}: $e');
          }
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header pequeño
                    pw.Text(
                      'Glosario Informático',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Divider(thickness: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 25),

                    // Nombre del término
                    pw.Text(
                      termino.nombreTermino,
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 30),

                    // Definición
                    pw.Text(
                      'Definición',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      termino.definicion,
                      style: const pw.TextStyle(
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                      textAlign: pw.TextAlign.justify,
                    ),
                    pw.SizedBox(height: 25),

                    // Ejemplo
                    pw.Text(
                      'Ejemplo',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      termino.ejemplo,
                      style: const pw.TextStyle(
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                      textAlign: pw.TextAlign.justify,
                    ),

                    // Imagen si existe
                    if (imagenPdf != null) ...[
                      pw.SizedBox(height: 25),
                      pw.Container(
                        width: double.infinity,
                        constraints: const pw.BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: pw.Image(
                          imagenPdf,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }

      // Guardar el PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/Glosario_Informatico_Completo.pdf');
      await file.writeAsBytes(await pdf.save());

      // Cerrar el indicador de carga
      if (mounted) {
        Navigator.pop(context);
      }

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Glosario Informático Completo - ${terminosCompletos.length} términos',
      );
    } catch (e) {
      // Cerrar el indicador de carga si hay error
      if (mounted) {
        Navigator.pop(context);
      }

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el glosario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void manejarRetroceso() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaInicio(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header con búsqueda y botón de compartir
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) {
                        manejarRetroceso();
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _filtrar,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: "Buscar",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _controller.clear();
                                  _filtrar('');
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                      ),
                    ),
                  ),
                  // Botón para compartir todo el glosario
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Compartir glosario completo',
                    onPressed: compartirGlosarioCompleto,
                  ),
                ],
              ),
            ),

            // Lista de resultados
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: cargando
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : filtrados.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'No se encontraron resultados',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtrados.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final termino = filtrados[index];
                              final nombre = termino['nombretermino'] as String;
                              final imagenUrl = termino['imagen_url'] as String?;
                              
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: imagenUrl != null && imagenUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imagenUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.article,
                                                size: 30,
                                                color: Colors.grey,
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.article,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                ),
                                title: Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PantallaResultado(
                                          terminoId: termino['id'] as int,
                                          nombreTermino: nombre,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}