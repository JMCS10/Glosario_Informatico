// test/test_aux.dart
import 'package:flutter_application/baseDeDatos/conexion.dart';
class TestHelper {
  // ID de dispositivo para tests (fácil de identificar y limpiar)
  static const int dispositivoPrueba = 99999;
  
  // IDs de términos de prueba que crearemos
  static int? terminoPrueba1;
  static int? terminoPrueba2;
  static int? terminoPrueba3;

  /// Limpia TODOS los datos de prueba de la BD
  static Future<void> limpiarTodo() async {
    try {
      // Limpiar en orden por foreign keys
      await SupabaseConexion.client
          .from('favoritos')
          .delete()
          .eq('dispositivo_id', dispositivoPrueba);

      await SupabaseConexion.client
          .from('historial')
          .delete()
          .eq('dispositivo_id', dispositivoPrueba);

      await SupabaseConexion.client
          .from('sugerencias')
          .delete()
          .eq('dispositivo_id', dispositivoPrueba);

      // Limpiar términos relacionados de nuestros términos de prueba
      if (terminoPrueba1 != null) {
        await SupabaseConexion.client
            .from('terminos_relacionados')
            .delete()
            .eq('termino_id', terminoPrueba1!);
      }

      // Limpiar términos de prueba (tienen prefijo TEST_)
      await SupabaseConexion.client
          .from('terminos')
          .delete()
          .like('nombretermino', 'TEST_%');

      // Limpiar dispositivo de prueba
      await SupabaseConexion.client
          .from('dispositivos')
          .delete()
          .eq('id', dispositivoPrueba);

      print('✅ Limpieza completada');
    } catch (e) {
      print('⚠️ Error en limpieza: $e');
    }
  }

  /// Crea términos de prueba en la BD
  static Future<void> crearTerminosPrueba() async {
    try {
      // Crear término 1
      final resp1 = await SupabaseConexion.client
          .from('terminos')
          .insert({
            'nombretermino': 'TEST_API',
            'definicion': 'Interfaz de programación de aplicaciones',
            'ejemplo': 'REST API permite comunicación entre sistemas',
          })
          .select('id')
          .single();
      terminoPrueba1 = resp1['id'] as int;

      // Crear término 2
      final resp2 = await SupabaseConexion.client
          .from('terminos')
          .insert({
            'nombretermino': 'TEST_JSON',
            'definicion': 'Formato de intercambio de datos',
            'ejemplo': '{"nombre": "valor"}',
          })
          .select('id')
          .single();
      terminoPrueba2 = resp2['id'] as int;

      // Crear término 3
      final resp3 = await SupabaseConexion.client
          .from('terminos')
          .insert({
            'nombretermino': 'TEST_HTTP',
            'definicion': 'Protocolo de transferencia de hipertexto',
            'ejemplo': 'GET, POST, PUT, DELETE',
          })
          .select('id')
          .single();
      terminoPrueba3 = resp3['id'] as int;

      print('✅ Términos de prueba creados: $terminoPrueba1, $terminoPrueba2, $terminoPrueba3');
    } catch (e) {
      print('❌ Error creando términos: $e');
      rethrow;
    }
  }

  /// Crea el dispositivo de prueba
  static Future<void> crearDispositivoPrueba() async {
    try {
      await SupabaseConexion.client.from('dispositivos').insert({
        'id': dispositivoPrueba,
        'codigo_dispositivo': 'TEST_DEVICE_99999',
        'creado_en': DateTime.now().toIso8601String(),
      });
      print('✅ Dispositivo de prueba creado: $dispositivoPrueba');
    } catch (e) {
      // Si ya existe, no problema
      print('⚠️ Dispositivo ya existe o error: $e');
    }
  }

  /// Crea relación entre dos términos de prueba
  static Future<void> crearRelacion(int terminoId, int relacionadoId) async {
    try {
      await SupabaseConexion.client.from('terminos_relacionados').insert({
        'termino_id': terminoId,
        'relacionado_id': relacionadoId,
        'creado_en': DateTime.now().toIso8601String(),
      });
      print('✅ Relación creada: $terminoId -> $relacionadoId');
    } catch (e) {
      print('❌ Error creando relación: $e');
    }
  }

  /// Setup completo: limpia + crea datos
  static Future<void> setup() async {
    await limpiarTodo();
    await crearDispositivoPrueba();
    await crearTerminosPrueba();
  }
}