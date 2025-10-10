import 'package:flutter/material.dart';

class PantallaFavoritos extends StatefulWidget {
  const PantallaFavoritos({super.key});

  @override
  State<PantallaFavoritos> createState() => _PantallaFavoritosState();
}

class _PantallaFavoritosState extends State<PantallaFavoritos> {
  // Lista temporal de ejemplo
  List<String> favoritos = [
    "Algoritmo",
    "Array",
    "Compilador",
    "Encapsulamiento",
  ];

  void _eliminarFavorito(int index) {
    final eliminado = favoritos[index];
    setState(() {
      favoritos.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Se eliminó '$eliminado' de favoritos.")),
    );
  }

  void _eliminarTodos() {
    setState(() {
      favoritos.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Favoritos eliminados.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Flecha para volver
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              // 🔹 Título centrado
              const Center(
                child: Text(
                  "FAVORITOS",
                  style: TextStyle(
                    fontFamily: 'Angkor',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Lista de términos favoritos
              Expanded(
                child: favoritos.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay términos en favoritos.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: favoritos.length,
                        itemBuilder: (context, index) {
                          final termino = favoritos[index];
                          return ListTile(
                            title: Text(
                              termino,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                              ),
                            ),
                            leading: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 26,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black54,
                              ),
                              onPressed: () => _eliminarFavorito(index),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 10),

              // 🔹 Botón para eliminar todos los favoritos
              if (favoritos.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _eliminarTodos,
                    child: const Text(
                      "Eliminar favoritos",
                      style: TextStyle(
                        fontFamily: 'Angkor',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
