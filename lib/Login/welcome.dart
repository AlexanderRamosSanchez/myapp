import 'package:myapp/main.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Login/login.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_floreria.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      // Sombreado semitransparente
      Container(
        color: Colors.black.withOpacity(0.5),
      ),
      Container(
        padding: const EdgeInsets.only(left: 40.0, right: 30),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(top: 200.0),
          ),
          const SizedBox(
            height: 100,
          ),
          const Text(
            'Welcome Back',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'SIGN IN',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Login with Social Media',
            style: TextStyle(fontSize: 17, color: Colors.white),
          ), //
          const SizedBox(
            height: 12,
          ),
        ]),
      ),
    ]));
  }
}
