import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientFormPage extends StatefulWidget {
  final Map<String, dynamic>? client;

  ClientFormPage({this.client});

  @override
  _ClientFormPageState createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final tipoDocumento = TextEditingController();
  final numeroDocumento = TextEditingController();
  final nombres = TextEditingController();
  final apellidos = TextEditingController();
  final fechaCumple = TextEditingController();
  final numeroTelefono = TextEditingController();
  final correoElectronico = TextEditingController();
  int? clienteId;

  final urlApi = 'https://ideal-goggles-jx54jvpxvpjc5r59-8080.app.github.dev/api';

  final _formKey = GlobalKey<FormState>();

  Map<String, String?> errors = {
    'tipoDocumento': null,
    'numeroDocumento': null,
    'nombres': null,
    'apellidos': null,
    'numeroTelefono': null,
    'correoElectronico': null,
  };

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      clienteId = widget.client!['id'];
      tipoDocumento.text = widget.client!['typeDocument'] ?? '';
      numeroDocumento.text = widget.client!['numberDocument'] ?? '';
      nombres.text = widget.client!['names'] ?? '';
      apellidos.text = widget.client!['lastNames'] ?? '';
      fechaCumple.text = _formatDateForDisplay(widget.client!['birthdayDate'] ?? '');
      numeroTelefono.text = widget.client!['cellPhone'] ?? '';
      correoElectronico.text = widget.client!['email'] ?? '';
    } else {
      // Establecer un valor predeterminado para tipoDocumento
      tipoDocumento.text = 'DNI'; // Valor predeterminado, puedes cambiarlo si es necesario
    }
  }

  void updateError(String fieldName, String? error) {
    setState(() {
      errors[fieldName] = error;
    });
  }

  Future<void> saveCliente() async {
    if (_formKey.currentState!.validate()) {
      final person = {
        "typeDocument": tipoDocumento.text,
        "numberDocument": numeroDocumento.text,
        "names": nombres.text,
        "lastNames": apellidos.text,
        "birthdayDate": fechaCumple.text,
        "cellPhone": numeroTelefono.text,
        "email": correoElectronico.text
      };

      final response = clienteId == null
          ? await http.post(
              Uri.parse('$urlApi/persons/crearClient'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(person),
            )
          : await http.put(
              Uri.parse('$urlApi/persons/$clienteId'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(person),
            );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).pop(true); // Indicate that the form was saved successfully
      } else {
        throw Exception('Error al guardar el cliente');
      }
    }
  }

  void cancel() {
    Navigator.of(context).pop(false); // Indicate that the form was cancelled
  }

  String? validateField(String? value, String fieldName, {required String regex}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }

    final RegExp regExp = RegExp(regex);
    if (!regExp.hasMatch(value)) {
      return 'Ingrese un $fieldName válido';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Correo electrónico es obligatorio';
    }
    // Validación de formato de correo electrónico usando expresión regular
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Fecha de nacimiento es obligatoria';
    }
    // Validación de formato de fecha YYYY-MM-DD
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Ingrese una fecha válida en formato YYYY-MM-DD';
    }
    return null;
  }

  String _formatDateForDisplay(String date) {
    if (date.isEmpty) return '';
    // Convertir fecha de YYYY-MM-DD a formato legible
    List<String> parts = date.split('-');
    return '${parts[0]}-${_mapMonthToSpanish(parts[1])}-${parts[2]}';
  }

  String _mapMonthToSpanish(String month) {
    switch (month) {
      case '01':
        return 'Ene';
      case '02':
        return 'Feb';
      case '03':
        return 'Mar';
      case '04':
        return 'Abr';
      case '05':
        return 'May';
      case '06':
        return 'Jun';
      case '07':
        return 'Jul';
      case '08':
        return 'Ago';
      case '09':
        return 'Sep';
      case '10':
        return 'Oct';
      case '11':
        return 'Nov';
      case '12':
        return 'Dic';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          clienteId == null ? "Agregar Cliente" : "Editar Cliente",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled, // Desactivar validación automática global
          child: Column(
            children: [
              _buildDropdownFormField(
                value: tipoDocumento.text.isEmpty ? 'DNI' : tipoDocumento.text, // Valor predeterminado
                label: 'Tipo Documento',
                items: ['DNI', 'CNE'],
                onChanged: (value) {
                  setState(() {
                    tipoDocumento.text = value.toString();
                  });
                },
              ),
              SizedBox(height: 15.0),
              _buildTextFormField(
                controller: numeroDocumento,
                label: 'Numero Documento',
                icon: Icons.insert_drive_file,
                validator: (value) => validateField(
                  value,
                  'Numero Documento',
                  regex: r'^[0-9]+$',
                ),
                keyboardType: TextInputType.number,
                errorText: errors['numeroDocumento'],
                onChanged: (value) {
                  updateError('numeroDocumento', validateField(
                    value,
                    'Numero Documento',
                    regex: r'^[0-9]+$',
                  ));
                },
              ),
              SizedBox(height: 15.0),
              _buildTextFormField(
                controller: nombres,
                label: 'Nombres Completos',
                icon: Icons.person,
                validator: (value) => validateField(
                  value,
                  'Nombres Completos',
                  regex: r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$',
                ),
                errorText: errors['nombres'],
                onChanged: (value) {
                  updateError('nombres', validateField(
                    value,
                    'Nombres Completos',
                    regex: r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$',
                  ));
                },
              ),
              SizedBox(height: 15.0),
              _buildTextFormField(
                controller: apellidos,
                label: 'Apellidos Completos',
                icon: Icons.person_outline,
                validator: (value) => validateField(
                  value,
                  'Apellidos Completos',
                  regex: r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$',
                ),
                errorText: errors['apellidos'],
                onChanged: (value) {
                  updateError('apellidos', validateField(
                    value,
                    'Apellidos Completos',
                    regex: r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]+$',
                  ));
                },
              ),
              SizedBox(height: 15.0),
              _buildTextFormField(
                controller: fechaCumple,
                label: 'Fecha de Nacimiento',
                icon: Icons.date_range,
                validator: validateDateOfBirth,
                errorText: errors['birthdayDate'],
                onChanged: (value) {
                  updateError('birthdayDate', validateDateOfBirth(value));
                },
              ),
              SizedBox(height: 15.0),
              _buildTextFormField(
                controller: numeroTelefono,
                label: 'Numero de Telefono',
                icon: Icons.phone,
                validator: (value) => validateField(
                  value,
                  'Numero de Telefono',
                  regex: r'^\d{9}$',
                ),
                keyboardType: TextInputType.phone,
                errorText: errors['numeroTelefono'],
                onChanged: (value) {
                  updateError('numeroTelefono', validateField(
                    value,
                    'Numero de Telefono',
                    regex: r'^\d{9}$',
                  ));
                },
              ),
              SizedBox(height: 15.0),
              _buildTextFormField(
                controller: correoElectronico,
                label: 'Correo Electronico',
                icon: Icons.email,
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
                errorText: errors['correoElectronico'],
                onChanged: (value) {
                  updateError('correoElectronico', validateEmail(value));
                },
              ),
              SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: saveCliente,
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: cancel,
                    child: Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.badge, color: Color(0xff881736)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xff881736)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xff881736)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xff881736)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      isEmpty: value == '',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? 'DNI' : value, // Asegurar que haya un valor predeterminado
          isDense: true,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xff881736)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xff881736)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xff881736)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xff881736)),
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: errorText,
      ),
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
