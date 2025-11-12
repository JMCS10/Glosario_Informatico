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
/*
  group('Tests de Lógica de Búsqueda (Simulados)', () {
    final terminosMock = [
      {'id': 1, 'nombretermino': 'API'},
      {'id': 2, 'nombretermino': 'JSON'},
      {'id': 3, 'nombretermino': 'HTTP'},
      {'id': 4, 'nombretermino': 'REST'},
      {'id': 5, 'nombretermino': 'SQL'},
    ];

    test('Búsqueda case-insensitive funciona', () {
      final query = 'api';
      final resultado = terminosMock.where((t) {
        return t['nombretermino']!
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();

      expect(resultado.length, 1);
      expect(resultado.first['nombretermino'], 'API');
    });

    test('Búsqueda con múltiples resultados', () {
      final query = 's';
      final resultado = terminosMock.where((t) {
        return t['nombretermino']!
            //.toLowerCase()
            .contains(query.toLowerCase());
      }).toList();

      expect(resultado.length, 3); // JSON, REST, SQL
    });

    test('Búsqueda sin resultados', () {
      final query = 'xyz123';
      final resultado = terminosMock.where((t) {
        return t['nombretermino']!
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();

      expect(resultado.isEmpty, true);
    });

    test('Búsqueda con query vacío retorna todos', () {
      final query = '';
      final resultado = terminosMock.where((t) {
        return t['nombretermino']!
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();

      expect(resultado.length, 5);
    });
  });
*/
  group('Tests de Lógica de Favoritos (Simulados)', () {
    final favoritosMock = <int>{};

    test('Agregar favorito funciona', () {
      favoritosMock.add(1);
      expect(favoritosMock.contains(1), true);
    });

    test('Verificar favorito inexistente retorna false', () {
      expect(favoritosMock.contains(999), false);
    });

    test('Eliminar favorito funciona', () {
      favoritosMock.add(2);
      expect(favoritosMock.contains(2), true);
      
      favoritosMock.remove(2);
      expect(favoritosMock.contains(2), false);
    });

    test('Toggle favorito funciona correctamente', () {
      final idTermino = 3;
      
      // Primera vez: agregar
      if (favoritosMock.contains(idTermino)) {
        favoritosMock.remove(idTermino);
      } else {
        favoritosMock.add(idTermino);
      }
      expect(favoritosMock.contains(idTermino), true);
      
      // Segunda vez: quitar
      if (favoritosMock.contains(idTermino)) {
        favoritosMock.remove(idTermino);
      } else {
        favoritosMock.add(idTermino);
      }
      expect(favoritosMock.contains(idTermino), false);
    });

    test('Obtener lista de favoritos funciona', () {
      favoritosMock.clear();
      favoritosMock.addAll([1, 3, 5]);
      
      expect(favoritosMock.length, 3);
      expect(favoritosMock.contains(1), true);
      expect(favoritosMock.contains(2), false);
    });
  });

  group('Tests de Lógica de Historial (Simulados)', () {
    final historialMock = <Map<String, dynamic>>[];

    test('Registrar en historial funciona', () {
      historialMock.add({
        'termino_id': 1,
        'visto_en': DateTime.now().toIso8601String(),
      });

      expect(historialMock.length, 1);
      expect(historialMock.first['termino_id'], 1);
    });

    test('Historial mantiene orden cronológico', () {
      historialMock.clear();
      
      historialMock.add({
        'termino_id': 1,
        'visto_en': DateTime(2024, 1, 1).toIso8601String(),
      });
      historialMock.add({
        'termino_id': 2,
        'visto_en': DateTime(2024, 1, 2).toIso8601String(),
      });
      historialMock.add({
        'termino_id': 3,
        'visto_en': DateTime(2024, 1, 3).toIso8601String(),
      });

      // Ordenar descendente (más reciente primero)
      historialMock.sort((a, b) => 
        b['visto_en'].compareTo(a['visto_en'])
      );

      expect(historialMock.first['termino_id'], 3);
      expect(historialMock.last['termino_id'], 1);
    });

    test('Limitar historial a 100 entradas funciona', () {
      historialMock.clear();
      
      // Agregar 105 entradas
      for (int i = 0; i < 105; i++) {
        historialMock.add({
          'termino_id': i,
          'visto_en': DateTime.now().toIso8601String(),
        });
      }

      // Limitar a 100
      if (historialMock.length > 100) {
        historialMock.removeRange(100, historialMock.length);
      }

      expect(historialMock.length, 100);
    });

    test('Eliminar entrada específica del historial', () {
      historialMock.clear();
      historialMock.add({'termino_id': 1, 'visto_en': '2024-01-01'});
      historialMock.add({'termino_id': 2, 'visto_en': '2024-01-02'});

      historialMock.removeWhere((h) => h['termino_id'] == 1);

      expect(historialMock.length, 1);
      expect(historialMock.first['termino_id'], 2);
    });

    test('Limpiar historial completo', () {
      historialMock.clear();
      expect(historialMock.isEmpty, true);
    });
  });

  group('Tests de Lógica de Sugerencias (Simulados)', () {
    final sugerenciasMock = <Map<String, dynamic>>[];

    test('Guardar sugerencia funciona', () {
      sugerenciasMock.add({
        'termino_sugerido': 'Blockchain',
        'dispositivo_id': 99999,
        'creado_en': DateTime.now().toIso8601String(),
      });

      expect(sugerenciasMock.length, 1);
      expect(sugerenciasMock.first['termino_sugerido'], 'Blockchain');
    });

    test('Obtener sugerencias por dispositivo', () {
      sugerenciasMock.clear();
      sugerenciasMock.addAll([
        {'termino_sugerido': 'Docker', 'dispositivo_id': 1},
        {'termino_sugerido': 'Kubernetes', 'dispositivo_id': 1},
        {'termino_sugerido': 'GraphQL', 'dispositivo_id': 2},
      ]);

      final sugerenciasDispositivo1 = sugerenciasMock
          .where((s) => s['dispositivo_id'] == 1)
          .toList();

      expect(sugerenciasDispositivo1.length, 2);
    });

    test('Eliminar todas las sugerencias de un dispositivo', () {
      sugerenciasMock.removeWhere((s) => s['dispositivo_id'] == 1);
      expect(sugerenciasMock.length, 1);
      expect(sugerenciasMock.first['termino_sugerido'], 'GraphQL');
    });
  });

  group('Tests de Términos Relacionados (Simulados)', () {
    final relacionesMock = {
      1: [2, 3], // API relacionado con JSON, HTTP
      2: [1, 4], // JSON relacionado con API, REST
      3: [1],    // HTTP relacionado con API
    };

    test('Obtener términos relacionados funciona', () {
      final relacionados = relacionesMock[1] ?? [];
      expect(relacionados.length, 2);
      expect(relacionados, contains(2));
      expect(relacionados, contains(3));
    });

    test('Término sin relaciones retorna lista vacía', () {
      final relacionados = relacionesMock[999] ?? [];
      expect(relacionados.isEmpty, true);
    });

    test('Limitar términos relacionados a 5 máximo', () {
      final relacionadosSimulados = [1, 2, 3, 4, 5, 6, 7];
      final limitados = relacionadosSimulados.take(5).toList();
      
      expect(limitados.length, 5);
    });
  });

  group('Tests de Validación de Datos', () {
    test('Validar que término no esté vacío', () {
      final nombreValido = 'API';
      final nombreInvalido = '';

      expect(nombreValido.isNotEmpty, true);
      expect(nombreInvalido.isEmpty, true);
    });

    test('Validar formato de timestamp ISO8601', () {
      final timestamp = DateTime.now().toIso8601String();
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}');
      
      expect(regex.hasMatch(timestamp), true);
    });

    test('Validar ID de dispositivo es número positivo', () {
      final idValido = 99999;
      final idInvalido = -1;

      expect(idValido > 0, true);
      expect(idInvalido > 0, false);
    });
  });

  group('Tests de Manejo de Errores (Simulados)', () {
    test('Manejar respuesta vacía de BD', () {
      final List<dynamic> respuestaVacia = [];
      final terminos = respuestaVacia
          .map((item) => Termino.fromJson(item))
          .toList();

      expect(terminos.isEmpty, true);
    });

    test('Manejar término con campos faltantes', () {
      final jsonIncompleto = {
        'id': 1,
        'nombretermino': 'API',
        // falta definicion y ejemplo
      };

      expect(() => Termino.fromJson(jsonIncompleto), 
        throwsA(isA<TypeError>()));
    });
  });
}