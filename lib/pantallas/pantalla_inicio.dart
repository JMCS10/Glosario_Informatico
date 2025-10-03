import 'package:flutter/material.dart';
import 'pantalla_busqueda.dart'; // 👉 Importa la pantalla 2
import 'pantalla_sugerir.dart'; // 👉 Importa la pantalla de sugerir

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  "GLOSARIO\nINFORMATICO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Angkor',
                    fontSize: 32.5,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 👉 Al tocar este campo se navega a la pantalla de búsqueda
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaBusqueda(),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botón Favoritos
              botonInicio("FAVORITOS", Colors.black, context, () {
                // Aquí luego enlazamos con PantallaFavoritos
              }),

              const SizedBox(height: 20),

              // Botón Historial
              botonInicio("HISTORIAL", Colors.black, context, () {
                // Aquí luego enlazamos con PantallaHistorial
              }),

              const SizedBox(height: 20),

              // Botón Sugerir Palabra
              botonInicio("SUGERIR PALABRA", Colors.black, context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaSugerir(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Botón reutilizable
  Widget botonInicio(
    String texto,
    Color color,
    BuildContext context,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          texto,
          style: const TextStyle(
            fontFamily: 'Angkor',
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
