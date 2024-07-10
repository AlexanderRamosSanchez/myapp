import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SaleFormPage extends StatefulWidget {
  final Map<String, dynamic>? saleData;

  SaleFormPage({this.saleData});

  @override
  _SaleFormPageState createState() => _SaleFormPageState();
}

class _SaleFormPageState extends State<SaleFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedPersonId;
  String? _selectedSellerId;
  String? _selectedProductId;
  String? _selectedTipoVenta;
  String? _selectedMetodoPago;
  List<Map<String, dynamic>> _saleDetails = [];

  List<dynamic> _persons = [];
  List<dynamic> _sellers = [];
  List<dynamic> _products = [];
  List<String> _tipoVentaOptions = ['Online', 'Fisica'];

  @override
  void initState() {
    super.initState();
    _fetchPersons();
    _fetchProducts();
    _fetchSeller();

    if (widget.saleData != null) {
      _selectedPersonId = widget.saleData!['clientId'].toString();
      _selectedSellerId = widget.saleData!['sellerId'].toString();
      _selectedTipoVenta = widget.saleData!['salesType'];
      _selectedMetodoPago = widget.saleData!['payment'];
      _saleDetails = (widget.saleData!['saleDetails'] as List)
          .map((detail) => {
                'productId': detail['productId'].toString(),
                'amount': detail['amount'],
              })
          .toList();
    }
  }

  Future<void> _fetchPersons() async {
    try {
      final response = await http.get(
          Uri.parse('https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api/persons/clients'));
      if (response.statusCode == 200) {
        setState(() {
          _persons = jsonDecode(response.body);
        });
      } else {
        print('Failed to load persons: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading persons: $e');
    }
  }

  Future<void> _fetchSeller() async {
    try {
      final response = await http.get(
          Uri.parse('https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api/persons/seller'));
      if (response.statusCode == 200) {
        setState(() {
          _sellers = jsonDecode(response.body);
        });
      } else {
        print('Failed to load sellers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading sellers: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse('https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api/products/productAc'));
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _agregarDetalleVenta() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _saleDetails.add({
          'productId': _selectedProductId!,
          'amount': int.parse(_amountController.text),
        });
        _selectedProductId = null;
        _amountController.clear();
      });
    }
  }

  void _eliminarDetalleVenta(int index) {
    setState(() {
      _saleDetails.removeAt(index);
    });
  }

  void _enviarDatos() {
    if (_formKey.currentState!.validate() && _saleDetails.isNotEmpty) {
      Map<String, dynamic> ventaData = {
        'clientId': int.parse(_selectedPersonId!),
        'sellerId': int.parse(_selectedSellerId!),
        'salesType': _selectedTipoVenta!,
        'payment': _selectedMetodoPago!,
        'saleDetails': _saleDetails.map((detail) {
          return {
            'productId': int.parse(detail['productId']),
            'amount': detail['amount'],
          };
        }).toList(),
      };

      // Print data for debugging
      print('Datos a enviar:');
      print(jsonEncode(ventaData));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor, complete todos los campos y agregue al menos un detalle de venta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saleData == null
            ? 'Nuevo Registro de Venta'
            : 'Editar Registro de Venta', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
                value: _persons.isNotEmpty &&
                        _selectedPersonId != null &&
                        _persons.any((person) =>
                            person['id'].toString() == _selectedPersonId)
                    ? _selectedPersonId
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPersonId = newValue;
                  });
                },
                items: _persons.map<DropdownMenuItem<String>>((person) {
                  return DropdownMenuItem<String>(
                    value: person['id'].toString(),
                    child: Text('${person['names']} ${person['lastNames']}'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Venta',
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                value: _selectedTipoVenta,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTipoVenta = newValue;
                  });
                },
                items: _tipoVentaOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Vendedor',
                  prefixIcon: Icon(Icons.person),
                ),
                value: _sellers.isNotEmpty &&
                        _selectedSellerId != null &&
                        _sellers.any((seller) =>
                            seller['id'].toString() == _selectedSellerId)
                    ? _selectedSellerId
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSellerId = newValue;
                  });
                },
                items: _sellers.map<DropdownMenuItem<String>>((seller) {
                  return DropdownMenuItem<String>(
                    value: seller['id'].toString(),
                    child: Text('${seller['names']} ${seller['lastNames']}'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: Icon(Icons.payment),
                ),
                value: _selectedMetodoPago,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMetodoPago = newValue;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'Tarjeta',
                    child: Text('Tarjeta'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Efectivo',
                    child: Text('Efectivo'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Detalles de la Venta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Producto',
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
                value: _products.isNotEmpty &&
                        _selectedProductId != null &&
                        _products.any((product) =>
                            product['id'].toString() == _selectedProductId)
                    ? _selectedProductId
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProductId = newValue;
                  });
                },
                items: _products.map<DropdownMenuItem<String>>((product) {
                  return DropdownMenuItem<String>(
                    value: product['id'].toString(),
                    child: Text('${product['names']}'),
                  );
                }).toList(),
                validator: (value) {
                  if (_saleDetails.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _agregarDetalleVenta,
                child: Text('Agregar Detalle de Venta'),
              ),
              SizedBox(height: 20),
              _saleDetails.isEmpty
                  ? SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles Agregados:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _saleDetails.length,
                          itemBuilder: (context, index) {
                            final detail = _saleDetails[index];
                            return ListTile(
                              title: Text(
                                  'Producto ID: ${detail['productId']} - Cantidad: ${detail['amount']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _eliminarDetalleVenta(index),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _enviarDatos,
                  child: Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
