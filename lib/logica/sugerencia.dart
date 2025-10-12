class Sugerencia {
  final int idSugerencia;       
  final String terminoSugerido; 
  final int dispositivoId;      
  final DateTime fechaCreacion; 

  Sugerencia({
    required this.idSugerencia,
    required this.terminoSugerido,
    required this.dispositivoId,
    required this.fechaCreacion,
  });

  factory Sugerencia.fromJson(Map<String, dynamic> json) {
    return Sugerencia(
      idSugerencia: json['id'] as int,
      terminoSugerido: json['termino_sugerido'] as String,
      dispositivoId: json['dispositivo_id'] as int,
      fechaCreacion: DateTime.parse(json['creado_en'] as String),
    );
  }
}