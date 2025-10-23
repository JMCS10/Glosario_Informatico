import 'package:flutter/material.dart';
import 'package:flutter_application/logica/glosario.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/logica/termino.dart';
import 'package:flutter_application/pantallas/pantalla_resultado.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';

class PantallaFavoritos extends StatefulWidget {
  const PantallaFavoritos({super.key});

  @override
  State<PantallaFavoritos> createState() => _PantallaFavoritosState();
}

class _PantallaFavoritosState extends State<PantallaFavoritos> {
  List<Termino> _todosLosFavoritos = const <Termino>[];
  bool _cargar = true;
  late InfoDispositivo _dispositivo;

  Future<void> cargarFavoritos() async {
    setState(() {
      _cargar = true;
    });
    final List<Termino> favoritos = await Glosario.obtenerFavoritos(_dispositivo.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _todosLosFavoritos = favoritos;
      _cargar = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dispositivo = ProveedorDispositivo.of(context);
    print(_dispositivo.codigo);
    print(_dispositivo.id);
    cargarFavoritos();
  }

  void _eliminarFavorito(int idFavorito) {
    Glosario.eliminarFavoritoPorId(idFavorito);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Se eliminó de favoritos.")),
    );
    cargarFavoritos();
  }

  void _eliminarTodos() {
    setState(() {
      _todosLosFavoritos = [];
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Favoritos eliminados.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "FAVORITOS",
                  style: TextStyle(
                    fontFamily: 'Angkor',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: _cargar
                    ? const Center(child: CircularProgressIndicator())
                    : _todosLosFavoritos.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay términos en favoritos.",
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _todosLosFavoritos.length,
                            itemBuilder: (context, index) {
                              final termino = _todosLosFavoritos[index];
                              return ListTile(
                                title: Text(
                                  termino.nombreTermino,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 26,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () => _eliminarFavorito(termino.idTermino),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaResultado(
                                        nombreTermino: termino.nombreTermino,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),

              const SizedBox(height: 10),

              if (_todosLosFavoritos.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _eliminarTodos,
                    child: const Text(
                      "Eliminar favoritos",
                      style: TextStyle(
                        fontFamily: 'Angkor',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}