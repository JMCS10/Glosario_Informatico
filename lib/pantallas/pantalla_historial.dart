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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dispositivo = ProveedorDispositivo.of(context);
    print('Dispositivo ID: ${_dispositivo.id}');
    print('Dispositivo código: ${_dispositivo.codigo}');
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    setState(() {
      _cargar = true;
    });

    final List<Termino> historial = await Glosario.obtenerHistorial(_dispositivo.id);
    
    if (!mounted) {
      return;
    }

    setState(() {
      _todosLosHistoriales = historial;
      _cargar = false;
    });
  }

  // Elimina un término específico del historial
  Future<void> _eliminarElemento(int idTermino) async {
    final bool eliminado = await Glosario.eliminarDelHistorialPorTermino(
      idTermino: idTermino,
      idDispositivo: _dispositivo.id,
    );

    if (eliminado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Se eliminó del historial.")),
      );
      cargarHistorial(); // Recargar la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar.")),
      );
    }
  }

  Future<void> _eliminarHistorialCompleto() async {
    final bool eliminado = await Glosario.eliminarHistorialCompleto(_dispositivo.id);

    if (eliminado) {
      setState(() {
        _todosLosHistoriales.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Historial eliminado.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar el historial.")),
      );
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
                            itemCount: _todosLosHistoriales.length,
                            itemBuilder: (context, index) {
                              final termino = _todosLosHistoriales[index];
                              return ListTile(
                                title: Text(
                                  termino.nombreTermino,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.history,
                                  color: Colors.black54,
                                  size: 26,
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
                                        nombreTermino: termino.nombreTermino,
                                        esRaiz: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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