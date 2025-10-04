import 'package:flutter/material.dart';
import 'pantalla_terminos.dart';
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
      body: SafeArea(
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _filtrar,
                      decoration: InputDecoration(
                        hintText: "Buscar",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _controller.clear();
                                  _filtrar('');
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

            // Lista de resultados
            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : filtrados.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron resultados',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtrados.length,
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
                              onTap: () {
                                // Navegar a la pantalla de término
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PantallaTermino(
                                      nombreTermino: termino,
                                      esRaiz: true,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}