class Historial {
  final int idHistorial; 
  final int terminoId; 
  final int dispositivoId; 
  final DateTime fechaConsulta;

  Historial({
    required this.idHistorial, 
    required this.terminoId,
    required this.dispositivoId,
    required this.fechaConsulta,
  });
  factory Historial.fromJson(Map<String, dynamic> json) {
    return Historial(
      idHistorial: json['id'],
      terminoId: json['termino_id'],
      dispositivoId: json['dispositivo_id'],
      fechaConsulta: DateTime.parse(json['visto_en']), 
    );
  }
}