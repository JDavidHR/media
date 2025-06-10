import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:mc_dashboard/pages.dart/login.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(960, 540);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DownloadPage(), // <- Página inicial
    );
  }
}

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool _isError = false;
  bool _isDownloading = true;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isError = false;
      _isDownloading = true;
    });

    try {
      final fileId = '1XAYxIiOiffZcI1xpsA8_XDyJs3q5Oq6t';
      final url =
          'https://docs.google.com/spreadsheets/d/$fileId/export?format=xlsx';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/mi_archivo.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Navegar a LoginPage cuando termine la descarga
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        throw Exception('Error al descargar: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Descargando datos..."),
            ],
          ),
        ),
      );
    }

    if (_isError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 10),
              const Text(
                'Error al descargar la información.\nPor favor, reinténtelo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startDownload,
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox(); // Nunca debería llegar aquí
  }
}
