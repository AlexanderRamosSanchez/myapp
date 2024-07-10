import 'package:myapp/Maestros/clientes.dart';
import 'package:myapp/Transaccional/ventas.dart';
import 'package:myapp/Transaccional/compras.dart';
import 'package:myapp/Maestros/productos.dart';
import 'package:myapp/main.dart';
import 'package:flutter/material.dart';

class Routes extends StatelessWidget {
  final int index;
  const Routes({Key? key, required this.index}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    List<Widget> myList = [
      const HomePage(),
      const clientes(),
      const productos(),
      const ventas(),
      const compras()
    ];
    return myList[index];
  }
}