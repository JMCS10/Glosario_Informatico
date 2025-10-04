import 'package:flutter/material.dart';
import 'baseDeDatos/conexion.dart';
import 'pantallas/pantalla_inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar conexión a Supabase
  await SupabaseConexion.init();
  
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glosario Informático',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const PantallaInicio(), 
    );
  }
}