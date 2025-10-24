import 'package:flutter/material.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';
import '../logica/glosario.dart';
import '../logica/termino.dart';

class PantallaResultado extends StatefulWidget {
  final String nombreTermino;
  final bool esRaiz;
  
  const PantallaResultado({
    super.key,
    required this.nombreTermino,
    this.esRaiz = true,
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
    print('Dispositivo código: ${_dispositivo.codigo}');
    print('Dispositivo ID: ${_dispositivo.id}');
    
    // Cargar datos después de obtener el dispositivo
    if (cargando) {
      cargarDatos();
    }
  }

  Future<void> cargarDatos() async {
    final terminoEncontrado = await Glosario.buscarTermino(widget.nombreTermino);
    
    if (terminoEncontrado != null) {
      // 🔥 REGISTRAR EN HISTORIAL automáticamente
      await Glosario.registrarEnHistorial(
        idTermino: terminoEncontrado.idTermino,
        idDispositivo: _dispositivo.id,
      );

      // Verificar si ya es favorito
      final esFav = await Glosario.esFavorito(
        terminoEncontrado.idTermino,
        _dispositivo.id,
      );

      // Cargar términos relacionados (ejemplo con IDs fijos)
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
                      onPressed: () => Navigator.pop(context),
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
            // Header con flecha de regreso y estrella
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
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

            // Contenido en la Pantalla
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del término
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

                      // Sección Definición
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

                      // Sección Ejemplo
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

                      // Sección Términos relacionados
                      if (terminosRelacionados.isNotEmpty) ...[
                        const Text(
                          'Términos relacionados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de términos relacionados
                        ...terminosRelacionados.map((t) => 
                          _construirTerminoRelacionado(t.nombreTermino)
                        ),
                      ],
                      
                      const SizedBox(height: 32),

                      // Botón para volver a la raíz
                      if (!widget.esRaiz)
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Palabra Raíz',
                                style: TextStyle(
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaResultado(
              nombreTermino: nombre,
              esRaiz: false,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              nombre,
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