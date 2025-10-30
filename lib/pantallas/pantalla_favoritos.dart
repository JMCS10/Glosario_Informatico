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

  // ---- Paginación ----
  int _paginaActual = 1;
  final int _itemsPorPagina = 10;

  int get _totalPaginas {
    if (_todosLosFavoritos.isEmpty) return 0;
    return (_todosLosFavoritos.length / _itemsPorPagina).ceil();
  }

  List<Termino> get _favoritosPaginaActual {
    final inicio = (_paginaActual - 1) * _itemsPorPagina;
    final fin = inicio + _itemsPorPagina;

    if (inicio >= _todosLosFavoritos.length) return [];

    final finReal = fin > _todosLosFavoritos.length
        ? _todosLosFavoritos.length
        : fin;

    return _todosLosFavoritos.sublist(inicio, finReal);
  }
  // ---------------------

  Future<void> cargarFavoritos() async {
    setState(() {
      _cargar = true;
    });
    final List<Termino> favoritos =
        await Glosario.obtenerFavoritos(_dispositivo.id);
    if (!mounted) return;
    setState(() {
      _todosLosFavoritos = favoritos;
      _cargar = false;

      // Ajuste de página en caso de cambios
      if (_totalPaginas == 0) {
        _paginaActual = 1;
      } else if (_paginaActual > _totalPaginas) {
        _paginaActual = _totalPaginas;
      } else if (_paginaActual < 1) {
        _paginaActual = 1;
      }
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

  Future<void> _eliminarFavorito(int idFavorito) async {
    await Glosario.eliminarFavoritoPorId(idFavorito);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Se eliminó de favoritos.")),
    );
    await cargarFavoritos();
  }

  void _eliminarTodos() {
    setState(() {
      _todosLosFavoritos = [];
      _paginaActual = 1; // reset paginación
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Favoritos eliminados.")));
    // Si tienes un método para eliminar todo en BD, podrías llamarlo y luego recargar.
    // await Glosario.eliminarFavoritosCompleto(_dispositivo.id);
    // await cargarFavoritos();
  }

  void _irAPagina(int numero) {
    if (numero >= 1 && numero <= _totalPaginas && numero != _paginaActual) {
      setState(() => _paginaActual = numero);
    }
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
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _favoritosPaginaActual.length,
                            itemBuilder: (context, index) {
                              final termino = _favoritosPaginaActual[index];
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
                                  onPressed: () =>
                                      _eliminarFavorito(termino.idTermino),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaResultado(
                                        terminoId: termino.idTermino,
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

              // ---- Paginado centrado ----
              if (_totalPaginas > 1)
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_totalPaginas, (index) {
                      final numero = index + 1;
                      final esActual = numero == _paginaActual;
                      return GestureDetector(
                        onTap: () => _irAPagina(numero),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                esActual ? Colors.black : Colors.transparent,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$numero',
                            style: TextStyle(
                              color:
                                  esActual ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),
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
