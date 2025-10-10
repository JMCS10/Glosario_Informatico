import 'package:flutter/material.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';
import 'package:flutter_application/services/dispositivos_services.dart';
import 'baseDeDatos/conexion.dart';
import 'pantallas/pantalla_inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar conexión a Supabase
  await SupabaseConexion.init();
  final DispositivoService servicioDispositivo =
      DispositivoService(SupabaseConexion.client);
  final InfoDispositivo dispositivo = await servicioDispositivo.obtenerORegistrar();
  runApp( MiApp(dispositivo: dispositivo));
}

class MiApp extends StatelessWidget {
  const MiApp({super.key, required this.dispositivo});
  final InfoDispositivo dispositivo;
  @override
  Widget build(BuildContext context) {
    return ProveedorDispositivo(
      dispositivo: dispositivo,
      child: MaterialApp(
        title: 'Glosario Informático',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
        ),
        home: const PantallaInicio(), 
      ),
    );
  }
}

