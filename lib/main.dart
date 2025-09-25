import 'package:flutter/material.dart';//sssssss
import 'conexion.dart'; //para importar la conexion
import 'pantallas/pantalla_inicio.dart'; // Importamos la pantalla de inicio

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 🔹 Necesario para inicializar antes de runApp
  await SupabaseConexion.init(); // 🔹 Inicializa Supabase
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
