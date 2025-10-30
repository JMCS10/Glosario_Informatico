import 'package:flutter/material.dart';
import 'package:flutter_application/logica/glosario.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';
import 'package:provider/provider.dart';

class PantallaSugerir extends StatefulWidget {
  const PantallaSugerir({super.key});

  @override
  State<PantallaSugerir> createState() => _PantallaSugerirState();
}

class _PantallaSugerirState extends State<PantallaSugerir> {
  final TextEditingController _controller = TextEditingController();

  bool _enviando = false;

  Future<void> _enviarSugerencia() async {
    FocusScope.of(context).unfocus();
    final sugerencia = _controller.text.trim();

    if (sugerencia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, escribe una palabra.")),
      );
      return;
    }

    final dispositivo = Provider.of<ProveedorDispositivo>(context, listen: false).dispositivo;
    final idDispositivo = dispositivo.id;

    setState(() => _enviando = true);

    try {
      await Glosario.guardarSugerencia(sugerencia, idDispositivo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Sugerencia enviada correctamente.")),
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al enviar sugerencia: $e")),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // 👈 Evita que el teclado cause overflow visual
      body: SafeArea(
        child: SingleChildScrollView(
          // 👈 Permite desplazar si el teclado cubre contenido
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Flecha atrás
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  FocusScope.of(context).unfocus(); // 👈 Cierra el teclado
                  // Espera un breve instante antes de volver atrás
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pop(context);
                  });
                },
              ),

              const SizedBox(height: 10),

              // 🔹 Título principal
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

              // 🔹 Campo de texto
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

              // 🔹 Botón Enviar
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
                  onPressed: _enviando ? null : _enviarSugerencia,
                  child: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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

              // 🔹 Nota aclaratoria
              const Center(
                child: Text(
                  "Sugiere una palabra que desees que aparezca próximamente en el glosario.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 40), // Espacio extra inferior
            ],
          ),
        ),
      ),
    );
  }
}
