import 'package:flutter/material.dart';
import 'pantalla_resultado.dart';
import '../logica/glosario.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  final TextEditingController _controller = TextEditingController();
  List<String> todosLosTerminos = [];
  List<String> filtrados = [];
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
      return termino.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filtrados = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 👈 Evita overflow con teclado
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Barra superior con flecha + buscador
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
                        // 👇 Cierra el teclado si está abierto
                        FocusScope.of(context).unfocus();

                        // 👇 Espera que termine la animación del teclado (Android/iOS)
                        await Future.delayed(const Duration(milliseconds: 300));

                        // 👇 Luego vuelve atrás sin franja amarilla
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: _filtrar,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) =>
                            FocusScope.of(context).unfocus(), // cierra teclado
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

              // Contenido / resultados
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
                  physics:
                      const NeverScrollableScrollPhysics(), // Evita conflicto de scroll
                  itemBuilder: (context, index) {
                    final termino = filtrados[index];
                    return ListTile(
                      title: Text(
                        termino,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                        ),
                      ),
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaResultado(
                                nombreTermino: termino,
                                esRaiz: true,
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
