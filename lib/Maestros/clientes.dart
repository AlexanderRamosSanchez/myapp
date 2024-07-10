import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:myapp/Forms/client_form.dart'; // Import the new form page

class clientes extends StatefulWidget {
  const clientes({Key? key}) : super(key: key);

  @override
  State<clientes> createState() => _clientesState();
}

class _clientesState extends State<clientes> {
  List<dynamic> _clientes = [];
  List<dynamic> _filteredClientes = [];
  bool _showActiveClients = true;
  int _selectedIndex = -1; // Track selected index for shading effect

  final urlApi =
      'https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api';

  @override
  void initState() {
    super.initState();
    _fetchClientes();
  }

  Future<void> _fetchClientes() async {
    final response = await http.get(Uri.parse('$urlApi/persons/clients'));
    if (response.statusCode == 200) {
      setState(() {
        _clientes = jsonDecode(response.body);
        _clientes.sort(
            (a, b) => a['names'].compareTo(b['names'])); // Ordenar por nombre
        _filteredClientes = _clientes;
      });
    } else {
      throw Exception('Error al cargar los clientes');
    }
  }

  Future<void> _fetchClientesInac() async {
    final response = await http.get(Uri.parse('$urlApi/persons/clientsInac'));
    if (response.statusCode == 200) {
      setState(() {
        _clientes = jsonDecode(response.body);
        _clientes.sort(
            (a, b) => a['names'].compareTo(b['names'])); // Ordenar por nombre
        _filteredClientes = _clientes;
      });
    } else {
      throw Exception('Error al cargar los clientes inactivos');
    }
  }

  Future<void> deleteCliente(int id) async {
    final response = await http.delete(
      Uri.parse('$urlApi/persons/delete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        _clientes.removeWhere((client) => client['id'] == id);
        _filteredClientes = _clientes;
      });
    } else {
      throw Exception(
          'Error al eliminar el cliente: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> activarCliente(int id) async {
    final response = await http.put(
      Uri.parse('$urlApi/persons/active/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      setState(() {
        _clientes.removeWhere((client) => client['id'] == id);
        _filteredClientes = _clientes;
      });
      _fetchClientes(); // Reload the inactive clients list
    } else {
      throw Exception(
          'Error al activar el cliente: ${response.statusCode} ${response.body}');
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro que quieres $action este cliente?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancel
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _toggleClients() {
    if (_showActiveClients) {
      _fetchClientesInac();
    } else {
      _fetchClientes();
    }
    setState(() {
      _showActiveClients = !_showActiveClients;
    });
  }

  void _filterClientes(String query) {
    final filtered = _clientes.where((client) {
      final name = client['names']?.toLowerCase() ?? '';
      final lastNames = client['lastNames']?.toLowerCase() ?? '';
      final email = client['email']?.toLowerCase() ?? '';
      final typeDocument = client['typeDocument']?.toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return name.contains(searchLower) ||
          lastNames.contains(searchLower) ||
          email.contains(searchLower) ||
          typeDocument.contains(searchLower);
    }).toList();

    setState(() {
      _filteredClientes = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _showActiveClients ? _fetchClientes : _fetchClientesInac,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        _filterClientes(value);
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _toggleClients,
                    child: Text(_showActiveClients ? 'Inactivos' : 'Activos'),
                    style: ElevatedButton.styleFrom(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredClientes.length,
                itemBuilder: (context, index) {
                  final client = _filteredClientes[index];
                  return Material(
                    color: _selectedIndex == index
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ClientFormPage(client: client),
                          ),
                        )
                            .then((value) {
                          if (value == true)
                            _fetchClientes(); // Refresh list if needed
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4.0,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10.0),
                          title: Text(
                            '${client['names']} ${client['lastNames']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipo de documento: ${client['typeDocument']}',
                              ),
                              Text(
                                'Correo: ${client['email']}',
                              ),
                            ],
                          ),
                          leading: Icon(
                            Icons.people,
                            color: Color(0xff881736),
                            size: 40.0,
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) async {
                              if (value == 'editar') {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ClientFormPage(client: client),
                                  ),
                                )
                                    .then((value) {
                                  if (value == true)
                                    _fetchClientes(); // Refresh list if needed
                                });
                              } else if (value == 'eliminar') {
                                final confirmed = await _showConfirmationDialog(
                                    context, 'eliminar');
                                if (confirmed == true) {
                                  if (_showActiveClients) {
                                    deleteCliente(client['id']);
                                  } else {
                                    activarCliente(client['id']);
                                  }
                                }
                              } else if (value == 'activar') {
                                final confirmed = await _showConfirmationDialog(
                                    context, 'activar');
                                if (confirmed == true) {
                                  activarCliente(client['id']);
                                }
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text('Editar'),
                                  value: 'editar',
                                ),
                                PopupMenuItem(
                                  child: Text(_showActiveClients
                                      ? 'Eliminar'
                                      : 'Activar'),
                                  value: _showActiveClients
                                      ? 'eliminar'
                                      : 'activar',
                                ),
                              ];
                            },
                          ),
                        ),
                      ),
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
        child: const Icon(Icons.add, color: Color.fromARGB(255, 245, 239, 239)),
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => ClientFormPage(),
            ),
          )
              .then((value) {
            if (value == true) _fetchClientes(); // Refresh list if needed
          });
        },
      ),
    );
  }
}
