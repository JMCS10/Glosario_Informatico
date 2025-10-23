import 'package:flutter/material.dart';

class TerminoRaiz with ChangeNotifier {
  // Variable para almacenar la palabra raíz
  String? _palabraRaiz;

  // Getter para obtener la palabra raíz
  String? get palabraRaiz => _palabraRaiz;

  // Setter para actualizar la palabra raíz
  void establecerPalabraRaiz(String raiz) {
    _palabraRaiz = raiz;
    notifyListeners();  // Notificar a todos los que escuchan esta clase
  }

  // Método para resetear la palabra raíz
  void resetearPalabraRaiz() {
    _palabraRaiz = null;
    notifyListeners();
  }
}
