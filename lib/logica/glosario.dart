import '../baseDeDatos/conexion.dart';
import 'termino.dart';
import 'sugerencia.dart';

class Glosario {
  static const String _tabla = 'terminos';
  static const String _tablaFavoritos = 'favoritos';
  static const String _tablaHistorial = 'historial';
  static const String _tablaSugerencias = 'sugerencias';

  static Future<List<Map<String, dynamic>>> obtenerTodosLosNombres() async {
    try {
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select('id, nombretermino')
          .order('nombretermino',ascending: true);

      return (response as List)
          .map(
            (item) => {
              'id': item['id'] as int,
              'nombretermino': item['nombretermino'] as String,
            },
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Termino?> buscarTerminoPorId(int id) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) return null;

      return Termino.fromJson(response.first);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Termino>> obtenerTerminosPorIds(List<int> ids) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select()
          .inFilter('id', ids);
      return (response as List).map((item) => Termino.fromJson(item)).toList();
    } catch (e) {
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
      print('Error al cambiar favorito: $e');
    }
  }

  static Future<List<Termino>> obtenerFavoritos(int dispositivoId) async {
    try {
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
            'ejemplo': '',
          });
        }
        return Termino.fromJson(terminoJson);
      }).toList();
    } catch (e) {
      print('Error al obtener favoritos: $e');
      return [];
    }
  }

  static Future<bool> eliminarFavoritoPorId(int idTermino) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tablaFavoritos)
          .delete()
          .eq('termino_id', idTermino);
      return response != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> registrarEnHistorial({
    required int idTermino,
    required int idDispositivo,
  }) async {
    try {
      await SupabaseConexion.client.from(_tablaHistorial).insert({
        'termino_id': idTermino,
        'dispositivo_id': idDispositivo,
        'visto_en': DateTime.now().toIso8601String(),
      });

      final response = await SupabaseConexion.client
          .from(_tablaHistorial)
          .select('id')
          .eq('dispositivo_id', idDispositivo)
          .order('visto_en', ascending: false);

      final historial = response as List;

      if (historial.length > 100) {
        final idsAEliminar = historial
            .skip(100)
            .map((item) => item['id'] as int)
            .toList();

        await SupabaseConexion.client
            .from(_tablaHistorial)
            .delete()
            .inFilter('id', idsAEliminar);
      }
    } catch (e) {
      print('Error al registrar historial: $e');
    }
  }

  static Future<List<Termino>> obtenerHistorial(int dispositivoId) async {
    try {
      final List<dynamic> data = await SupabaseConexion.client
          .from(_tablaHistorial)
          .select(
            'termino_id, visto_en, terminos:termino_id (id, nombretermino, definicion, ejemplo, imagen_url)',
          )
          .eq('dispositivo_id', dispositivoId)
          .order('visto_en', ascending: false)
          .limit(100);

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
            'ejemplo': '',
          });
        }
        return Termino.fromJson(terminoJson);
      }).toList();
    } catch (e) {
      print('Error al obtener historial: $e');
      return [];
    }
  }

  static Future<bool> eliminarHistorialCompleto(int idDispositivo) async {
    try {
      await SupabaseConexion.client
          .from(_tablaHistorial)
          .delete()
          .eq('dispositivo_id', idDispositivo);
      return true;
    } catch (e) {
      print('Error al eliminar historial: $e');
      return false;
    }
  }

  static Future<bool> eliminarDelHistorialPorTermino({
    required int idTermino,
    required int idDispositivo,
  }) async {
    try {
      final response = await SupabaseConexion.client
          .from(_tablaHistorial)
          .select('id')
          .eq('termino_id', idTermino)
          .eq('dispositivo_id', idDispositivo)
          .order('visto_en', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final idHistorial = response.first['id'];
        await SupabaseConexion.client
            .from(_tablaHistorial)
            .delete()
            .eq('id', idHistorial);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al eliminar del historial: $e');
      return false;
    }
  }

  static Future<void> guardarSugerencia(
    String palabra,
    int idDispositivo,
  ) async {
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

      return (resp as List).map((item) => Sugerencia.fromJson(item)).toList();
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