import 'package:flutter/material.dart';
import 'package:flutter_application/logica/glosario.dart';
import 'package:flutter_application/logica/info_dispositivo.dart';
import 'package:flutter_application/logica/termino.dart';
import 'package:flutter_application/pantallas/pantalla_resultado.dart';
import 'package:flutter_application/provider/dispositivo_provider.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  List<Termino> _todosLosHistoriales = [];
  bool _cargar = true;
  late InfoDispositivo _dispositivo;

  int _paginaActual = 1;
  final int _itemsPorPagina = 20;

  int get _totalPaginas {
    if (_todosLosHistoriales.isEmpty) return 0;
    final paginas = (_todosLosHistoriales.length / _itemsPorPagina).ceil();
    return paginas > 5 ? 5 : paginas;
  }

  List<Termino> get _terminosPaginaActual {
    final inicio = (_paginaActual - 1) * _itemsPorPagina;
    final fin = inicio + _itemsPorPagina;
    
    if (inicio >= _todosLosHistoriales.length) return [];
    
    final finReal = fin > _todosLosHistoriales.length 
        ? _todosLosHistoriales.length 
        : fin;
    
    return _todosLosHistoriales.sublist(inicio, finReal);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dispositivo = ProveedorDispositivo.of(context);
    print('Dispositivo ID: ${_dispositivo.id}');
    print('Dispositivo código: ${_dispositivo.codigo}');
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    setState(() => _cargar = true);
    
    final historial = await Glosario.obtenerHistorial(_dispositivo.id);
    
    if (!mounted) return;

    setState(() {
      _todosLosHistoriales = historial;
      _cargar = false;
      
      if (_paginaActual > _totalPaginas && _totalPaginas > 0) {
        _paginaActual = _totalPaginas;
      }
      if (_paginaActual < 1) _paginaActual = 1;
    });
  }

  Future<void> _eliminarElemento(int idTermino) async {
    final ok = await Glosario.eliminarDelHistorialPorTermino(
      idTermino: idTermino,
      idDispositivo: _dispositivo.id,
    );
    
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Se eliminó del historial.")),
      );
      await cargarHistorial();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar.")),
      );
    }
  }

  Future<void> _eliminarHistorialCompleto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar todo el historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final ok = await Glosario.eliminarHistorialCompleto(_dispositivo.id);
      
      if (ok) {
        setState(() {
          _todosLosHistoriales.clear();
          _paginaActual = 1;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Historial eliminado.")),
          );
        }
      }
    }
  }

  void _irAPagina(int numero) {
    if (numero >= 1 && numero <= _totalPaginas && numero != _paginaActual) {
      setState(() {
        _paginaActual = numero;
      });
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
                  "HISTORIAL",
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
                    : _todosLosHistoriales.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay términos en el historial.",
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _terminosPaginaActual.length,
                            itemBuilder: (context, index) {
                              final termino = _terminosPaginaActual[index];
                              
                              return ListTile(
                                leading: const Icon(
                                  Icons.history,
                                  color: Colors.black54,
                                  size: 26,
                                ),
                                title: Text(
                                  termino.nombreTermino,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () => _eliminarElemento(termino.idTermino),
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

              if (_totalPaginas > 1)
                Wrap(
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$numero',
                          style: TextStyle(
                            color: esActual ? Colors.black : Colors.grey[600],
                            fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 10),

              if (_todosLosHistoriales.isNotEmpty)
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
                    onPressed: _eliminarHistorialCompleto,
                    child: const Text(
                      "Eliminar historial",
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