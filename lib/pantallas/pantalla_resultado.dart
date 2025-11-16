import 'package:flutter/material.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/pantallas/pantalla_busqueda.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';
import '../logica/glosario.dart';
import '../logica/termino.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PantallaResultado extends StatefulWidget {
  final int terminoId;
  final String nombreTermino;
  final int? terminoRaizId;
  final String? terminoRaiz;
  final bool volvioDesdePalabraRaiz;

  const PantallaResultado({
    super.key,
    required this.terminoId,
    required this.nombreTermino,
    this.terminoRaizId,
    this.terminoRaiz,
    this.volvioDesdePalabraRaiz = false,
  });

  @override
  State<PantallaResultado> createState() => _PantallaResultado();
}

class _PantallaResultado extends State<PantallaResultado> {
  Termino? termino;
  List<Termino> terminosRelacionados = [];
  bool cargando = true;
  bool esFavorito = false;
  late InfoDispositivo _dispositivo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dispositivo = ProveedorDispositivo.of(context);

    if (cargando) {
      cargarDatos();
    }
  }

  Future<void> cargarDatos() async {
    final terminoEncontrado = await Glosario.buscarTerminoPorId(
      widget.terminoId,
    );

    if (terminoEncontrado != null) {
      await Glosario.registrarEnHistorial(
        idTermino: terminoEncontrado.idTermino,
        idDispositivo: _dispositivo.id,
      );

      final esFav = await Glosario.esFavorito(
        terminoEncontrado.idTermino,
        _dispositivo.id,
      );

      final relacionados = await Glosario.obtenerRelacionadosDe(widget.terminoId);

      setState(() {
        termino = terminoEncontrado;
        terminosRelacionados = relacionados;
        esFavorito = esFav;
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> toggleFavorito() async {
    if (termino == null) return;

    await Glosario.cambiarEstadoFavorito(
      idTermino: termino!.idTermino,
      idDispositivo: _dispositivo.id,
      esFavActual: esFavorito,
    );

    setState(() {
      esFavorito = !esFavorito;
    });
  }


  Future<void> compartirComoPDF() async {
    if (termino == null) return;

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Crear el PDF
      final pdf = pw.Document();

      // Descargar la imagen si existe
      pw.ImageProvider? imagenPdf;
      if (termino!.imagenUrl != null && termino!.imagenUrl!.isNotEmpty) {
        try {
          imagenPdf = await networkImage(termino!.imagenUrl!);
        } catch (e) {
          // Si falla la carga de la imagen, continuamos sin ella
          print('Error al cargar imagen: $e');
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
                    termino!.nombreTermino,
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
                    termino!.definicion,
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
                    termino!.ejemplo,
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

      // Guardar el PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${termino!.nombreTermino}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Cerrar el indicador de carga
      if (mounted) {
        Navigator.pop(context);
      }

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Definición de: ${termino!.nombreTermino}',
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
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void volverAPalabraRaiz() {
    final raizNombre =
        widget.terminoRaiz ?? (termino?.nombreTermino ?? widget.nombreTermino);
    final raizId = widget.terminoRaizId ?? widget.terminoId;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaResultado(
          terminoId: raizId,
          nombreTermino: raizNombre,
          terminoRaizId: null,
          terminoRaiz: null,
          volvioDesdePalabraRaiz: true,
        ),
      ),
    );
  }

  void manejarRetroceso() {
    if (widget.volvioDesdePalabraRaiz) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PantallaBusqueda()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (termino == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: manejarRetroceso,
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(child: Text('Término no encontrado')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: manejarRetroceso,
                  ),
                  Row(
                    children: [
                      // Botón de compartir
                      IconButton(
                        icon: const Icon(Icons.share, size: 28),
                        onPressed: compartirComoPDF,
                      ),
                      IconButton(
                        icon: Icon(
                          esFavorito ? Icons.star : Icons.star_border,
                          size: 28,
                          color: esFavorito ? Colors.amber : Colors.black,
                        ),
                        onPressed: toggleFavorito,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          termino!.nombreTermino,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        'Definición',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termino!.definicion,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Ejemplo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termino!.ejemplo,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),

                      // IMAGEN DEL EJEMPLO
                      if (termino!.imagenUrl != null && termino!.imagenUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            termino!.imagenUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'No se pudo cargar la imagen',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 32),

                      if (terminosRelacionados.isNotEmpty) ...[
                        const Text(
                          'Términos relacionados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...terminosRelacionados
                            .map((t) => _construirTerminoRelacionado(t))
                            .toList(),
                      ],

                      const SizedBox(height: 32),

                      if (widget.terminoRaiz != null)
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: volverAPalabraRaiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Volver a "${widget.terminoRaiz}"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTerminoRelacionado(Termino relacionado) {
    final raizNombre =
        widget.terminoRaiz ?? (termino?.nombreTermino ?? widget.nombreTermino);
    final raizId = widget.terminoRaizId ?? widget.terminoId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultado(
              terminoId: relacionado.idTermino,
              nombreTermino: relacionado.nombreTermino,
              terminoRaizId: raizId,
              terminoRaiz: raizNombre,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              relacionado.nombreTermino,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}