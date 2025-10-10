import 'package:flutter/material.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  // Lista temporal (luego se conectará con la BD)
  List<String> historial = [
    "API",
    "Array",
    "Algoritmo",
    "Base de Datos",
    "Compilador",
    "Arquitectura de computadoras",
  ];

  void _eliminarHistorial() {
    setState(() {
      historial.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Historial eliminado.")));
  }

  void _eliminarElemento(int index) {
    final eliminado = historial[index];
    setState(() {
      historial.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Se eliminó '$eliminado' del historial.")),
    );
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
                  "HISTORIAL",
                  style: TextStyle(
                    fontFamily: 'Angkor',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Lista de términos
              Expanded(
                child: historial.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay términos en el historial.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: historial.length,
                        itemBuilder: (context, index) {
                          final termino = historial[index];
                          return ListTile(
                            title: Text(
                              termino,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                              ),
                            ),
                            leading: const Icon(
                              Icons.history,
                              color: Colors.black54,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black54,
                              ),
                              onPressed: () => _eliminarElemento(index),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 10),

              // 🔹 Botón para eliminar todo el historial
              if (historial.isNotEmpty)
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
                    onPressed: _eliminarHistorial,
                    child: const Text(
                      "Eliminar historial",
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
