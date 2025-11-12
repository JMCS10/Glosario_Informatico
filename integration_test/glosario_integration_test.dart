// integration_test/glosario_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application/baseDeDatos/conexion.dart';
import 'package:flutter_application/logica/glosario.dart';
//import 'package:flutter_application/logica/termino.dart';
import '../test/test_aux.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SupabaseConexion.init();
    await TestHelper.setup();
  });

  tearDownAll(() async {
    await TestHelper.limpiarTodo();
  });

  group('Tests de Términos', () {
    testWidgets('obtenerTodosLosNombres retorna lista', (tester) async {
      final resultado = await Glosario.obtenerTodosLosNombres();
      
      expect(resultado, isNotEmpty);
      expect(resultado, isList);
      expect(resultado.first.containsKey('id'), isTrue);
    });

    testWidgets('buscarTerminoPorId retorna término existente', (tester) async {
      final termino = await Glosario.buscarTerminoPorId(TestHelper.terminoPrueba1!);
      
      expect(termino, isNotNull);
      expect(termino!.nombreTermino, 'TEST_API');
    });

    testWidgets('buscarTerminoPorId retorna null para ID inexistente', (tester) async {
      final termino = await Glosario.buscarTerminoPorId(999999);
      expect(termino, isNull);
    });

    testWidgets('obtenerTerminosPorIds retorna múltiples términos', (tester) async {
      final ids = [TestHelper.terminoPrueba1!, TestHelper.terminoPrueba2!];
      final terminos = await Glosario.obtenerTerminosPorIds(ids);
      
      expect(terminos.length, 2);
    });
  });

  group('Tests de Favoritos', () {
    testWidgets('esFavorito retorna false inicialmente', (tester) async {
      final esFav = await Glosario.esFavorito(
        TestHelper.terminoPrueba1!,
        TestHelper.dispositivoPrueba,
      );
      
      expect(esFav, isFalse);
    });

    testWidgets('cambiarEstadoFavorito agrega favorito', (tester) async {
      await Glosario.cambiarEstadoFavorito(
        idTermino: TestHelper.terminoPrueba1!,
        idDispositivo: TestHelper.dispositivoPrueba,
        esFavActual: false,
      );

      final esFav = await Glosario.esFavorito(
        TestHelper.terminoPrueba1!,
        TestHelper.dispositivoPrueba,
      );
      
      expect(esFav, isTrue);
    });

    testWidgets('obtenerFavoritos retorna favoritos', (tester) async {
      final favoritos = await Glosario.obtenerFavoritos(TestHelper.dispositivoPrueba);
      expect(favoritos, isNotEmpty);
    });
  });

  group('Tests de Historial', () {
    testWidgets('registrarEnHistorial inserta correctamente', (tester) async {
      await Glosario.registrarEnHistorial(
        idTermino: TestHelper.terminoPrueba1!,
        idDispositivo: TestHelper.dispositivoPrueba,
      );

      final historial = await Glosario.obtenerHistorial(TestHelper.dispositivoPrueba);
      expect(historial, isNotEmpty);
    });

    testWidgets('eliminarHistorialCompleto funciona', (tester) async {
      final resultado = await Glosario.eliminarHistorialCompleto(
        TestHelper.dispositivoPrueba,
      );
      expect(resultado, isTrue);
    });
  });

  group('Tests de Sugerencias', () {
    testWidgets('guardarSugerencia funciona', (tester) async {
      await Glosario.guardarSugerencia(
        'TEST_BLOCKCHAIN',
        TestHelper.dispositivoPrueba,
      );

      final sugerencias = await Glosario.obtenerSugerencias(
        TestHelper.dispositivoPrueba,
      );

      expect(sugerencias, isNotEmpty);
    });
  });

  group('Tests de Términos Relacionados', () {
    testWidgets('obtenerRelacionadosDe funciona', (tester) async {
      await TestHelper.crearRelacion(
        TestHelper.terminoPrueba1!,
        TestHelper.terminoPrueba2!,
      );

      final relacionados = await Glosario.obtenerRelacionadosDe(
        TestHelper.terminoPrueba1!,
      );

      expect(relacionados.length, lessThanOrEqualTo(5));
    });
  });
}