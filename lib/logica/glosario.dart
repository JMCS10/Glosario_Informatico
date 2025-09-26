import '../conexion.dart';
import 'termino.dart';

class Glosario{
  static const String _tabla = 'terminos';

  static Future<List<Termino>> obtenerTodos() async{
    try{
      final response = await SupabaseConexion.client
          .from(_tabla)
          .select();
          
      //print('Términos obtenidos: ${response.length}');
      
      return (response as List)
          .map((json) => Termino.fromJson(json))
          .toList();
    }catch (e){
      //print('Error: $e');
      return [];
    }
  }
}