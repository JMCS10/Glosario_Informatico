import '../conexion.dart';
import 'termino.dart';

class Glosario {
  static const String _tabla = 'terminos';
  
  static Future<List<String>> obtenerTodosLosNombres() async {
    try {
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select('nombretermino');
      
      return (response as List)
          .map((item) => item['nombretermino'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  static Future<Termino?> buscarTermino(String palabra) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select()
          .ilike('nombretermino', '%$palabra%')
          .limit(1);
      
      if (response.isEmpty) return null;
      
      return Termino.fromJson(response[0]);
    } catch (e) {
      return null;
    }
  }
}