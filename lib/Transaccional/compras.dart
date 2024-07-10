import 'package:flutter/material.dart';

class compras extends StatelessWidget {
  const compras({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Compras',
          style: TextStyle(
            color: Color(0xff881736),
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}