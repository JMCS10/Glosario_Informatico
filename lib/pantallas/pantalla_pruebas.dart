import 'package:flutter/material.dart';
import '../logica/glosario.dart';
//import '../logica/termino.dart';

class PantallaPruebas extends StatefulWidget{
  const PantallaPruebas({super.key});

  @override
  State<PantallaPruebas> createState() => _PantallaPruebasState();
}

class _PantallaPruebasState extends State<PantallaPruebas>{
  String resultado = "Esperando resultados...";

  @override
  void initState(){
    super.initState();
    probarConsultas();
  }

  Future<void> probarConsultas() async{
    setState(() => resultado = "Cargando...");

    final todos = await Glosario.obtenerTodosLosNombres();
    String textoTodos = "BÚSQUEDA DE TODOS LOS TÉRMINOS\n";
    for(var nombre in todos){
      textoTodos += "- $nombre\n";
    }

    final termino = await Glosario.buscarTermino("API");
    String textoBusqueda = "\nBÚSQUEDA: API\n";
    if(termino != null){
      textoBusqueda += "Nombre: ${termino.nombreTermino}\n";
      textoBusqueda += "Definición: ${termino.definicion}\n";
      textoBusqueda += "Ejemplo: ${termino.ejemplo}\n";
    }else{
      textoBusqueda += "No encontrado\n";
    }

    setState(() => resultado = textoTodos + textoBusqueda);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas BD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(resultado),
      ),
    );
  }
}