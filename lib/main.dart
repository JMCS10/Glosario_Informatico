import 'package:flutter/material.dart';
import 'conexion.dart';
//import 'pantallas/pantalla_inicio.dart';
//import 'logica/termino.dart';
import 'pantallas/pantalla_pruebas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConexion.init();
  runApp(const GlosarioApp());
}

class GlosarioApp extends StatelessWidget {
  const GlosarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glosario Informático',
      home: PantallaPruebas(),
    );
  }
}
