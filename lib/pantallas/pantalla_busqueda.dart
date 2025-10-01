import 'package:flutter/material.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  final TextEditingController _controller = TextEditingController();

  // 🔹 Datos de prueba (mock)
  final List<Map<String, String>> terminos = [
    {"nombretermino": "API"},
    {"nombretermino": "Array"},
    {"nombretermino": "Algoritmo"},
    {"nombretermino": "Aplicación"},
    {"nombretermino": "Autenticación"},
    {"nombretermino": "Archivo"},
  ];

  List<Map<String, String>> filtrados = [];

  @override
  void initState() {
    super.initState();
    filtrados = terminos; // al inicio muestra todo
  }

  void _filtrar(String query) {
    final resultados = terminos.where((t) {
      final nombre = t['nombretermino']!.toLowerCase();
      return nombre.startsWith(query.toLowerCase());
    }).toList();

    setState(() {
      filtrados = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
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

            // Lista de resultados (mock)
            Expanded(
              child: ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final termino = filtrados[index];
                  return ListTile(
                    title: Text(
                      termino['nombretermino']!,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 18),
                    ),
                    onTap: () {
                      // Aquí luego abriremos la Pantalla de Resultado
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
