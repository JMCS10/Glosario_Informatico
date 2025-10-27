import 'package:flutter/material.dart';
import 'pantalla_resultado.dart';
import '../logica/glosario.dart';
import 'pantalla_inicio.dart';
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

  //prueba
  void manejarRetroceso() {
  // Aquí realizamos la navegación hacia PantallaInicio cuando se presiona el botón de retroceso
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PantallaInicio(), // Aquí navegas hacia PantallaInicio
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
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
                  ],
                ),
              ),
              
              if (cargando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filtrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No se encontraron resultados',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  itemCount: filtrados.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final termino = filtrados[index];
                    final nombre = termino['nombretermino'] as String;
                    return ListTile(
                      title: Text(
                        nombre,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}