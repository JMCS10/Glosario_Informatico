// test/glosario_mock_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/logica/termino.dart';

void main() {
  group('Tests de Modelo Termino', () {
    test('Termino.fromJson crea objeto correctamente', () {
      final json = {
        'id': 1,
        'nombretermino': 'API',
        'definicion': 'Interfaz de programación',
        'ejemplo': 'REST API',
        'imagen_url': null,
      };

      final termino = Termino.fromJson(json);

      expect(termino.idTermino, 1);
      expect(termino.nombreTermino, 'API');
      expect(termino.definicion, 'Interfaz de programación');
      expect(termino.ejemplo, 'REST API');
    });

    test('Termino maneja imagen_url null correctamente', () {
      final json = {
        'id': 2,
        'nombretermino': 'JSON',
        'definicion': 'Formato de datos',
        'ejemplo': '{"clave": "valor"}',
      };

      final termino = Termino.fromJson(json);

      expect(termino.idTermino, 2);
      expect(termino.nombreTermino, 'JSON');
    });

    test('Termino con imagen_url válida', () {
      final json = {
        'id': 3,
        'nombretermino': 'HTTP',
        'definicion': 'Protocolo',
        'ejemplo': 'GET, POST',
        'imagen_url': 'https://example.com/http.png',
      };

      final termino = Termino.fromJson(json);

      expect(termino.imagenUrl, 'https://example.com/http.png');
    });
  });

}