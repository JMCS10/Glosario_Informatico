import 'package:flutter/material.dart';
import 'pantallas/pantalla_inicio.dart'; // Importamos la pantalla de inicio

void main() {
  runApp(const GlosarioApp());
}

class GlosarioApp extends StatelessWidget {
  const GlosarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glosario Informático',
      home: PantallaInicio(), // Usamos la clase que viene del otro archivo
    );
  }
}
