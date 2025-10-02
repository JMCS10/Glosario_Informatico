import '../conexion.dart';
import 'termino.dart';

class Glosario{
  static const String _tabla = 'terminos';
  
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
}