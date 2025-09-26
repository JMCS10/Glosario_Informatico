class Termino{
  final int idTermino;
  final String nombreTermino;
  final String definicion;
  final String ejemplo;
  final String? imagenUrl;

  Termino({
    required this.idTermino,
    required this.nombreTermino,
    required this.definicion,
    required this.ejemplo,
    this.imagenUrl,
  });

  factory Termino.fromJson(Map<String, dynamic> json){
    return Termino(
      idTermino: json['idTerminos'],
      nombreTermino: json['nombreTermino'],
      definicion: json['definicion'],
      ejemplo: json['ejemplo'],
      imagenUrl: json['imagenUrl'],
    );
  }
}