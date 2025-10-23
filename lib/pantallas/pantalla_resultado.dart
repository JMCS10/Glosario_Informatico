import 'package:flutter/material.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';
import '../logica/glosario.dart';
import '../logica/termino.dart';

class PantallaResultado extends StatefulWidget {
  final String nombreTermino;
  final String? terminoRaiz;
  final bool volvioDesdePalabraRaiz;
  
  const PantallaResultado({
    super.key,
    required this.nombreTermino,
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
    final terminoEncontrado = await Glosario.buscarTermino(widget.nombreTermino);
    
    if (terminoEncontrado != null) {
      await Glosario.registrarEnHistorial(
        idTermino: terminoEncontrado.idTermino,
        idDispositivo: _dispositivo.id,
      );

      final esFav = await Glosario.esFavorito(
        terminoEncontrado.idTermino,
        _dispositivo.id,
      );

      final relacionados = await Glosario.obtenerTerminosPorIds([1, 2, 3, 4, 5]);
      
      setState(() {
        termino = terminoEncontrado;
        terminosRelacionados = relacionados.take(5).toList();
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
    final raizActual = widget.terminoRaiz ?? widget.nombreTermino;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaResultado(
          nombreTermino: raizActual,
          terminoRaiz: null,
          volvioDesdePalabraRaiz: true,
        ),
      ),
    );
  }

  void manejarRetroceso() {
    if (widget.volvioDesdePalabraRaiz) {
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 2;
      });
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
                child:                   Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: manejarRetroceso,
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('Término no encontrado'),
                ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
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

                        ...terminosRelacionados.map((t) => 
                          _construirTerminoRelacionado(t.nombreTermino)
                        ),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _construirTerminoRelacionado(String nombre) {
    final raizActual = widget.terminoRaiz ?? widget.nombreTermino;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultado(
              nombreTermino: nombre,
              terminoRaiz: raizActual,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}