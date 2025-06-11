import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:mc_dashboard/core/components/mcButton.dart';
import 'package:mc_dashboard/core/components/mcTextfield.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';

import 'package:mc_dashboard/pages.dart/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggedIn = false;
  String _userName = "";

  Future<void> _login() async {
    final userInput = _userController.text.trim();
    final passwordInput = _passwordController.text.trim();

    if (userInput.isEmpty || passwordInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debe ingresar usuario y contraseña"),
        ),
      );
      return;
    }

    try {
      final user = await MongoDatabase.userCollection.findOne({
        'user': userInput,
        'password': passwordInput,
      });

      if (user != null) {
        setState(() {
          _isLoggedIn = true;
          _userName = user['name'] ?? 'Usuario';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario o contraseña incorrectos")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con la base de datos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isLoggedIn
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/lottie/check.json',
                          width: 150,
                          height: 150,
                          repeat: false,
                          onLoaded: (composition) {
                            Future.delayed(composition.duration, () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MinimalMenuPage(),
                                ),
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Bienvenido $_userName",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logos/MC_logo.png',
                          width: 200,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: McTextField(
                            controller: _userController,
                            labelText: "Usuario",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: McTextField(
                            controller: _passwordController,
                            labelText: "Contraseña",
                            //obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: MCButton(
                            text: "Ingresar",
                            onPressed: _login,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
