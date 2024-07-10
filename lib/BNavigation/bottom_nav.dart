import 'package:flutter/material.dart';

class BNavigator extends StatefulWidget {
  final Function(int) currentIndex;
  final int selectedIndex; // Añadir esta línea

  const BNavigator({Key? key, required this.currentIndex, this.selectedIndex = 0}) : super(key: key); // Modificar esta línea

  @override
  _BNavigatorState createState() => _BNavigatorState();
}

class _BNavigatorState extends State<BNavigator> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex, // Usar el índice pasado
      onTap: (int i) {
        widget.currentIndex(i); // Llama al método currentIndex del padre
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xff881736),
      iconSize: 25.0,
      selectedFontSize: 14.0,
      unselectedFontSize: 12.0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified_user),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Ventas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Compras',
        ),
      ],
    );
  }
}
