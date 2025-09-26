class Termino {
  final int id;
  final String nombre;
  final String definicion;
  final String ejemplo;
  final String categoria;

  Termino({
    required this.id,
    required this.nombre,
    required this.definicion,
    required this.ejemplo,
    required this.categoria,
  });

  factory Termino.fromJson(Map<String, dynamic> json) {
    return Termino(
      id: json['id'],
      nombre: json['nombre'],
      definicion: json['definicion'],
      ejemplo: json['ejemplo'],
      categoria: json['categoria'],
    );
  }
}