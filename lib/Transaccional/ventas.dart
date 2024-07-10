import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/Forms/sale_form.dart';

class ventas extends StatefulWidget {
  const ventas({Key? key}) : super(key: key);

  @override
  _ventasState createState() => _ventasState();
}

class _ventasState extends State<ventas> {
  List<dynamic> _ventas = [];
  bool _isLoading = true;

  final String urlApi = 'https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api/sales';

  @override
  void initState() {
    super.initState();
    _fetchVentas();
  }

  @override
  void dispose() {
    super.dispose();
    // Cancelar cualquier operación asíncrona pendiente
  }

  Future<void> _fetchVentas() async {
    try {
      final response = await http.get(Uri.parse(urlApi));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _ventas = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Error al cargar las ventas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ventas.isEmpty
              ? Center(child: Text('No se encontraron ventas'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: _ventas.length,
                    itemBuilder: (context, index) {
                      final venta = _ventas[index];
                      final client = venta['client'];
                      final seller = venta['seller'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SaleFormPage(saleData: venta),
                            ),
                          ).then((value) {
                            if (value == true) {
                              _fetchVentas(); // Actualizar la lista si es necesario
                            }
                          });
                        },
                        child: Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4.0,
                          shadowColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xff881736),
                              child: Icon(Icons.shopping_cart, color: Colors.white),
                            ),
                            title: Text(
                              'Venta ${venta['id']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha: ${venta['saleDate']} - Tipo: ${venta['salesType']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Cliente: ${client['names']} ${client['lastNames']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Email: ${client['email']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Vendedor: ${seller['names']} ${seller['lastNames']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff881736),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 245, 239, 239)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SaleFormPage(),
            ),
          ).then((value) {
            if (value == true) {
              _fetchVentas(); // Actualizar la lista si es necesario
            }
          });
        },
      ),
    );
  }
}
