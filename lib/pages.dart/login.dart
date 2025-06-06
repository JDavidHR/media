import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'package:mc_dashboard/core/components/mcButton.dart';
import 'package:mc_dashboard/core/components/mcTextfield.dart';
import 'package:mc_dashboard/dashboard/dashboard_base_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cedulaController = TextEditingController();
  bool _isLoggedIn = false;
  String _userName = "";
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      ByteData data = await rootBundle.load('assets/bd_local/BD_TEST.xlsx');
      final bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(bytes);

      if (!excel.sheets.keys.contains('USER')) {
        throw Exception("Hoja 'USER' no encontrada");
      }

      final Sheet sheet = excel['USER'];
      final List<Map<String, dynamic>> tempUsers = [];

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        tempUsers.add({
          "id": row[0]?.value.toString() ?? '',
          "user": row[1]?.value.toString() ?? '',
          "name": row[2]?.value.toString() ?? '',
          "email": row[3]?.value.toString() ?? '',
        });
      }

      setState(() {
        _users = tempUsers;
      });
    } catch (e) {
      // Error: se maneja desde main.dart
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Ocurrió un error al cargar la información")),
        );
      });
    }
  }

  void _login() {
    var user = _users.firstWhere(
      (u) => u["user"] == _cedulaController.text.trim(),
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
        _userName = user['name'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no encontrado")),
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
                                    builder: (context) =>
                                        const DashboardBasePage()),
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
                            controller: _cedulaController,
                            labelText: "Ingrese su cédula",
                            keyboardType: TextInputType.number,
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
