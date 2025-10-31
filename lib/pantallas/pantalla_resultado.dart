import 'package:flutter/material.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/pantallas/pantalla_busqueda.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';
import '../logica/glosario.dart';
import '../logica/termino.dart';

class PantallaResultado extends StatefulWidget {
  final int terminoId;
  final String nombreTermino;
  final int? terminoRaizId;
  final String? terminoRaiz;
  final bool volvioDesdePalabraRaiz;

  const PantallaResultado({
    super.key,
    required this.terminoId,
    required this.nombreTermino,
    this.terminoRaizId,
    this.terminoRaiz,
    this.volvioDesdePalabraRaiz = false,
  });

  @override
  State<PantallaResultado> createState() => _PantallaResultado();
}

class _PantallaResultado extends State<PantallaResultado> {
  Termino? termino;
  List<Termino> terminosRelacionados = [];
  bool cargando = true;
  bool esFavorito = false;
  late InfoDispositivo _dispositivo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dispositivo = ProveedorDispositivo.of(context);

    if (cargando) {
      cargarDatos();
    }
  }

  Future<void> cargarDatos() async {
    final terminoEncontrado = await Glosario.buscarTerminoPorId(
      widget.terminoId,
    );

    if (terminoEncontrado != null) {
      await Glosario.registrarEnHistorial(
        idTermino: terminoEncontrado.idTermino,
        idDispositivo: _dispositivo.id,
      );

      final esFav = await Glosario.esFavorito(
        terminoEncontrado.idTermino,
        _dispositivo.id,
      );

      final relacionados = await Glosario.obtenerRelacionadosDe(widget.terminoId);

      setState(() {
        termino = terminoEncontrado;
        terminosRelacionados = relacionados;
        esFavorito = esFav;
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> toggleFavorito() async {
    if (termino == null) return;

    await Glosario.cambiarEstadoFavorito(
      idTermino: termino!.idTermino,
      idDispositivo: _dispositivo.id,
      esFavActual: esFavorito,
    );

    setState(() {
      esFavorito = !esFavorito;
    });
  }

  void volverAPalabraRaiz() {
    final raizNombre =
        widget.terminoRaiz ?? (termino?.nombreTermino ?? widget.nombreTermino);
    final raizId = widget.terminoRaizId ?? widget.terminoId;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaResultado(
          terminoId: raizId,
          nombreTermino: raizNombre,
          terminoRaizId: null,
          terminoRaiz: null,
          volvioDesdePalabraRaiz: true,
        ),
      ),
    );
  }

  void manejarRetroceso() {
    if (widget.volvioDesdePalabraRaiz) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PantallaBusqueda()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (termino == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: manejarRetroceso,
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(child: Text('Término no encontrado')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: manejarRetroceso,
                  ),
                  IconButton(
                    icon: Icon(
                      esFavorito ? Icons.star : Icons.star_border,
                      size: 28,
                      color: esFavorito ? Colors.amber : Colors.black,
                    ),
                    onPressed: toggleFavorito,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          termino!.nombreTermino,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        'Definición',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termino!.definicion,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Ejemplo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termino!.ejemplo,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      if (terminosRelacionados.isNotEmpty) ...[
                        const Text(
                          'Términos relacionados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...terminosRelacionados
                            .map((t) => _construirTerminoRelacionado(t))
                            .toList(),
                      ],

                      const SizedBox(height: 32),

                      if (widget.terminoRaiz != null)
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: volverAPalabraRaiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Volver a "${widget.terminoRaiz}"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTerminoRelacionado(Termino relacionado) {
    final raizNombre =
        widget.terminoRaiz ?? (termino?.nombreTermino ?? widget.nombreTermino);
    final raizId = widget.terminoRaizId ?? widget.terminoId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultado(
              terminoId: relacionado.idTermino,
              nombreTermino: relacionado.nombreTermino,
              terminoRaizId: raizId,
              terminoRaiz: raizNombre,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              relacionado.nombreTermino,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
