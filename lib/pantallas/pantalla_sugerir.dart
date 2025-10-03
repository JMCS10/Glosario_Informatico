import 'package:flutter/material.dart';

class PantallaSugerir extends StatefulWidget {
  const PantallaSugerir({super.key});

  @override
  State<PantallaSugerir> createState() => _PantallaSugerirState();
}

class _PantallaSugerirState extends State<PantallaSugerir> {
  final TextEditingController _controller = TextEditingController();

  void _enviarSugerencia() {
    final sugerencia = _controller.text.trim();
    if (sugerencia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, escribe una palabra.")),
      );
      return;
    }

    // Aquí más adelante conectaremos con la BD
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Sugerencia enviada: $sugerencia")));
    _controller.clear();
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
              // Flechita atrás
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              // Título (debajo de la flecha)
              const Center(
                child: Text(
                  "SUGERIR PALABRA",
                  style: TextStyle(
                    fontFamily: 'Angkor',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de texto
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Escribe la palabra...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón Enviar
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
                  onPressed: _enviarSugerencia,
                  child: const Text(
                    "Enviar",
                    style: TextStyle(
                      fontFamily: 'Angkor',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nota aclaratoria
              const Center(
                child: Text(
                  "Nota: Sugiere una palabra que crees que debería aparecer en el glosario.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
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
