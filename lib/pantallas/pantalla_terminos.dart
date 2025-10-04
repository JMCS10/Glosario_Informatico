import 'package:flutter/material.dart';
import '../logica/glosario.dart';
import '../logica/termino.dart';

class PantallaTermino extends StatefulWidget {
  final bool esRaiz; //true si es el término inicial, false si viene de otro término
  
  const PantallaTermino({
    super.key,
    this.esRaiz = true, //Por defecto será raíz
  });

  @override
  State<PantallaTermino> createState() => _PantallaTerminoState();
}

class _PantallaTerminoState extends State<PantallaTermino> {
  Termino? termino;
  List<Termino> terminosRelacionados = [];
  bool cargando = true;
  bool esFavorito = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final terminoEncontrado = await Glosario.buscarTermino('API RESTful');
    final relacionados = await Glosario.obtenerTerminosPorIds([5, 6, 7, 8, 9]);
    
    setState(() {
      termino = terminoEncontrado;
      terminosRelacionados = relacionados;
      cargando = false;
    });
  }

  Future<void> toggleFavorito() async {
    if (termino == null) return;
    
    setState(() {
      esFavorito = !esFavorito;
    });
    
    //Implementar la lógica para guardar/eliminar de la tabla favoritos
    //Ejemplo:
    //if(esFavorito){
    //   código
    //}else{
    //  código
    //}
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
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Término no encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //Header con flecha de regreso y estrella
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

            //Contenido en la Pantalla
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Título del término
                      Center(
                        child: Text(
                          termino!.nombreTermino,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30), //Cambiar si el espacio entre el título y "Definición" no les convence

                      //Sección Definición
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

                      //Sección Ejemplo
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

                      //Sección Términos relacionados
                      const Text(
                        'Términos relacionados',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      //Lista de términos relacionados
                      ...terminosRelacionados.map((t) => 
                        _construirTerminoRelacionado(t.nombreTermino)
                      ),
                      
                      const SizedBox(height: 32),

                      if (!widget.esRaiz)
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); //Volver al término raíz
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
            builder: (context) => const PantallaTermino(esRaiz: false),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          nombre,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}