import '../baseDeDatos/conexion.dart';
import 'termino.dart';

class Glosario{
  static const String _tabla = 'terminos';
  static const String _tablaFavoritos = 'favoritos';
  
  static Future<List<String>> obtenerTodosLosNombres() async{
    try{
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select('nombretermino');
      
      return (response as List)
          .map((item) => item['nombretermino'] as String)
          .toList();
    }catch (e){
      return [];
    }
  }

  static Future<Termino?> buscarTermino(String palabra) async{
    try{
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select()
          .ilike('nombretermino', '%$palabra%');
      
      if(response.isEmpty) return null;
      
      return Termino.fromJson(response.first);
    }catch (e){
      return null;
    }
  }
  static Future<List<Termino>> obtenerTerminosPorIds(List<int> ids) async{
    try{
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select()
          .inFilter('id', ids);
      return (response as List)
          .map((item) => Termino.fromJson(item))
          .toList();
    }catch (e){
      return [];
    }
  }
  static Future<bool> esFavorito(int idTermino, int idDispositivo) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tablaFavoritos)
          .select('termino_id') 
          .eq('termino_id', idTermino) 
          .eq('dispositivo_id', idDispositivo) 
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  static Future<void> cambiarEstadoFavorito({ 
    required int idTermino, 
    required int idDispositivo, 
    required bool esFavActual,
  }) async {
    try {
      if (esFavActual) {
        await SupabaseConexion.client
            .from(_tablaFavoritos)
            .delete()
            .eq('termino_id', idTermino)
            .eq('dispositivo_id', idDispositivo);
      } else {
        await SupabaseConexion.client.from(_tablaFavoritos).insert({
          'termino_id': idTermino,
          'dispositivo_id': idDispositivo,
          'creado_en': DateTime.now().toIso8601String(), 
        });
      }
    } catch (e) {
    }
  }
  static Future<List<int>> obtenerIdsDeFavoritos(int idDispositivo) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tablaFavoritos)
          .select('termino_id') 
          .eq('dispositivo_id', idDispositivo) 
          .order('creado_en', ascending: false); 

      return (response as List)
          .map((item) => item['termino_id'] as int)
          .toList();
    } catch (e) {
      return [];
    }
  }
}