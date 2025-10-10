import '../baseDeDatos/conexion.dart';
import 'termino.dart';
import 'sugerencia.dart';

class Glosario{
  static const String _tabla = 'terminos';
  static const String _tablaFavoritos = 'favoritos';
  static const String _tablaHistorial = 'historial'; 
  static const String _tablaSugerencias = 'sugerencias';
  
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
  static Future<List<Termino>> obtenerFavoritos(int dispositivoId) async {
    final List<dynamic> data = await SupabaseConexion.client
        .from('favoritos')
        .select(
          'termino_id, creado_en, terminos:termino_id (id, nombretermino, definicion, ejemplo, imagen_url)',
        )
        .eq('dispositivo_id', dispositivoId)
        .order('creado_en', ascending: false);

    return data.whereType<Map<String, dynamic>>().map((
      Map<String, dynamic> row,
    ) {
      final Map<String, dynamic>? terminoJson =
          row['terminos'] as Map<String, dynamic>?;
      if (terminoJson == null) {
        return Termino.fromJson(<String, dynamic>{
          'id': row['termino_id'],
          'nombretermino': 'Término desconocido',
          'definicion': '',
        });
      }
      return Termino.fromJson(terminoJson);
    }).toList();
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

  /// Elimina un favorito por su idFavorito
  static Future<bool> eliminarFavoritoPorId(int idFavorito) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tablaFavoritos)
          .delete()
          .eq('termino_id', idFavorito);
      // Si response es una lista y tiene elementos, se eliminó algo
      return response != null;
    } catch (e) {
      return false;
    }
  }
  static Future<void> guardarEnHistorial(int idTermino, int idDispositivo) async {
    try {
      await SupabaseConexion.client.from(_tablaHistorial).insert({
        'termino_id': idTermino,
        'dispositivo_id': idDispositivo,
        'visto_en': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
  static Future<List<Termino>> obtenerHistorial(int idDispositivo) async {
    try {
      final resp = await SupabaseConexion.client
          .from(_tablaHistorial)
          .select('visto_en, terminos(id, nombretermino, definicion, ejemplo, imagen_url)')
          .eq('dispositivo_id', idDispositivo)
          .order('visto_en', ascending: false);

      // mapea el embed "terminos"
      final lista = (resp as List)
          .map((row) => (row['terminos'] as Map<String, dynamic>))
          .where((t) => t != null)
          .map<Termino>((t) => Termino.fromJson(t))
          .toList();

      return lista;
    } catch (_) {
      return [];
    }
  }
  static Future<void> eliminarTodoHistorial(int idDispositivo) async {
    try {
      await SupabaseConexion.client
          .from(_tablaHistorial)
          .delete()
          .eq('dispositivo_id', idDispositivo);
    } catch (_) {}
  }
  static Future<void> eliminarDelHistorial(int idHistorial) async {
    try {
      await SupabaseConexion.client
          .from(_tablaHistorial)
          .delete()
          .eq('id', idHistorial);
    } catch (_) {}
  }
 static Future<void> guardarSugerencia(String palabra, int idDispositivo) async {
    try {
      await SupabaseConexion.client.from(_tablaSugerencias).insert({
        'termino_sugerido': palabra,
        'dispositivo_id': idDispositivo,
        'creado_en': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
 static Future<List<Sugerencia>> obtenerSugerencias(int idDispositivo) async {
    try {
      final resp = await SupabaseConexion.client
          .from(_tablaSugerencias)
          .select()
          .eq('dispositivo_id', idDispositivo)
          .order('creado_en', ascending: false);

      return (resp as List)
          .map((item) => Sugerencia.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }
 static Future<void> eliminarTodasSugerencias(int idDispositivo) async {
    try {
      await SupabaseConexion.client
          .from(_tablaSugerencias)
          .delete()
          .eq('dispositivo_id', idDispositivo);
    } catch (_) {}
  }
}