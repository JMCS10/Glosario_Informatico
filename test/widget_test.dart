// Test básico para el Glosario Informático

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/main.dart';

void main() {
  testWidgets('App carga correctamente con pantalla de inicio', (WidgetTester tester) async {
    // Construir la app y renderizar el primer frame
    await tester.pumpWidget(const MiApp());

    // Verificar que el título principal aparece
    expect(find.text('GLOSARIO\nINFORMÁTICO'), findsOneWidget);

    // Verificar que el botón de FAVORITOS existe
    expect(find.text('FAVORITOS'), findsOneWidget);

    // Verificar que el botón de HISTORIAL existe
    expect(find.text('HISTORIAL'), findsOneWidget);

    // Verificar que el botón de SUGERIR PALABRA existe
    expect(find.text('SUGERIR PALABRA'), findsOneWidget);

    // Verificar que el campo de búsqueda existe
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Navegación a pantalla de búsqueda funciona', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const MiApp());

    // Tocar el campo de búsqueda
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle(); // Esperar a que termine la animación

    // Verificar que aparece el botón de regresar
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}