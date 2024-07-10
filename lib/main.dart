import 'package:myapp/BNavigation/bottom_nav.dart';
import 'package:myapp/BNavigation/routes.dart';
import 'package:myapp/Login/welcome.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Welcome(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  void _onSummaryCardTap(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  void _onBottomNavTap(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Florería Manu',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff881736),
                Color(0xff281537),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BNavigator(
        currentIndex: _onBottomNavTap,
        selectedIndex: index, // Pasar el índice actual
      ),
      body: IndexedStack(
        index: index,
        children: [
          _buildDashboard(),
          Routes(index: 1), // Página de ventas
          Routes(index: 2), // Página de clientes
          Routes(index: 3),
          Routes(index: 4), // Página de inventario
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de datos:',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff881736),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () => _onSummaryCardTap(3),
            child: _buildSummaryCard(
              title: 'Total Ventas',
              value: 'Lista de ventas realizadas',
              icon: Icons.shopping_cart,
              color: const Color.fromARGB(255, 7, 109, 192),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _onSummaryCardTap(1),
            child: _buildSummaryCard(
              title: 'Total Clientes',
              value: 'Clientes comunes',
              icon: Icons.people,
              color: Color.fromARGB(255, 18, 20, 172),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _onSummaryCardTap(2),
            child: _buildSummaryCard(
              title: 'Productos en Inventario',
              value: 'Productos disponibles para la venta',
              icon: Icons.inventory,
              color: Color.fromARGB(255, 209, 17, 17),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Estadísticas de Ventas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff881736),
            ),
          ),
          SizedBox(height: 20),
          _buildSalesChart(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Gráfico de Ventas Aquí',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
