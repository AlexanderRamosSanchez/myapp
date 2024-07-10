import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class productos extends StatefulWidget {
  const productos({Key? key}) : super(key: key);

  @override
  State<productos> createState() => _productosState();
}

class _productosState extends State<productos> {
  List<dynamic> _products = [];
  bool _showActiveProducts = true;

  final tipo = TextEditingController();
  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  final precio = TextEditingController();
  final cantidad = TextEditingController();
  int? productsId;

  @override
  void initState() {
    super.initState();
    // Llamada a la API para obtener la lista de clientes
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {

    // Aquí debes reemplazar la URL con la dirección de tu API
    final response = await http
        .get(Uri.parse('https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api/products/productAc'));
    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
      setState(() {
        _products = jsonDecode(response.body);
      });
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  Future<void> _fetchProductsIn() async {
    // Aquí debes reemplazar la URL con la dirección de tu API
    final response = await http
        .get(Uri.parse('https://b357-200-60-18-106.ngrok-free.app/api/products/productIn'));
    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
      setState(() {
        _products = jsonDecode(response.body);
      });
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  Future<void> deleteProducts(int id) async {
    final response = await http.delete(
      Uri.parse('https://b357-200-60-18-106.ngrok-free.app/api/products/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (!mounted)
      return; // Verificar si el widget está montado antes de llamar a setState()

    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        _products.removeWhere((products) => products['id'] == id);
      });
    } else {
      throw Exception(
          'Error al eliminar el cliente: ${response.statusCode} ${response.body}');
    }
  }

  //Boton para listar activos e inactivos
  void _toggleProduct() {
    if (_showActiveProducts) {
      _fetchProductsIn();
    } else {
      _fetchProducts();
    }
    setState(() {
      _showActiveProducts = !_showActiveProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _showActiveProducts ? _fetchProducts : _fetchProductsIn,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar producto...',
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _toggleProduct,
                    child: Text(_showActiveProducts ? 'Inactivos' : 'Activos'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final products = _products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 4.0,
                    child: ListTile(
                      title: Text('${products['names']}'),
                      subtitle: Text(products['description']),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xff881736),
                        child: Text(
                          products['names'].substring(0, 1),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'editar') {
                            showForm(products);
                          } else if (value == 'eliminar') {
                            deleteProducts(products['id']);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text('Editar'),
                              value: 'editar',
                            ),
                            PopupMenuItem(
                              child: Text('Eliminar'),
                              value: 'eliminar',
                            ),
                          ];
                        },
                      ),
                      onTap: () {
                        showForm(products);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff881736),
        child: const Icon(Icons.add, color: Color.fromARGB(255, 180, 133, 133)),
        onPressed: () {
          showForm(null);
        },
      ),
    );
  }

  void showForm(Map<String, dynamic>? products) {
    // Set client data if editing, or clear if adding new
    productsId = products?['id'];
    tipo.text = products?['type'] ?? '';
    nombre.text = products?['names'] ?? '';
    descripcion.text = products?['description'] ?? '';
    precio.text = products?['price']?.toString() ?? ''; // Convertir a String
    cantidad.text = products?['stock']?.toString() ?? ''; // Convertir a String

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(products == null ? "Agregar Produtos :" : "Editar Productos :"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo del producto :',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                  ),
                ),
                SizedBox(height: 15.0),
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                    labelText: 'Nombre del producto :',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                  ),
                ),
                SizedBox(height: 15.0),
                TextField(
                  controller: descripcion,
                  decoration: InputDecoration(
                    labelText: 'Descripcion del producto :',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                  ),
                ),
                SizedBox(height: 15.0),
                TextField(
                  controller: precio,
                  decoration: InputDecoration(
                    labelText: 'Precio del producto :',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                  ),
                ),
                SizedBox(height: 15.0),
                TextField(
                  controller: cantidad,
                  decoration: InputDecoration(
                    labelText: 'Cantidad del producto :',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar")),
            TextButton(
                onPressed: () {
                  saveProduct();
                  Navigator.of(context).pop();
                },
                child: const Text("Guardar")),
          ],
        );
      },
    );
  }

  void saveProduct() async {
    final products = {
    // Set client data if editing, or clear if adding new
    "type": tipo.text,
    "names": nombre.text,
    "description": descripcion.text,
    "price": double.parse(precio.text),  // Convertir precio a double
    "stock": int.parse(cantidad.text)
  };

    final response = productsId == null
        ? await http.post(
            Uri.parse('https://b357-200-60-18-106.ngrok-free.app/api/products/crear'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(products),
          )
        : await http.put(
            Uri.parse('https://b357-200-60-18-106.ngrok-free.app/api/products/$productsId'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(products),
          );

    tipo.clear();
    nombre.clear();
    descripcion.clear();
    precio.clear();
    cantidad.clear();

    if (response.statusCode == 201 || response.statusCode == 200) {
      _fetchProducts();
    } else {
      throw Exception('Error al guardar el cliente');
    }
  }
}