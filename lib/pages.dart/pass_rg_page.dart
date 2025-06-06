import 'package:clipboard/clipboard.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassRGPage extends StatefulWidget {
  const PassRGPage({super.key});

  @override
  State<PassRGPage> createState() => _PassRGPageState();
}

class _PassRGPageState extends State<PassRGPage> {
  List<Map<String, String>> passRG = [];
  List<Map<String, String>> filteredPassRG = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPassRG();
    searchController.addListener(_filterPassRG);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterPassRG);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPassRG() async {
    try {
      ByteData data = await rootBundle.load('assets/bd_local/BD_TEST.xlsx');
      final bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(bytes);

      print("📄 Hojas disponibles: ${excel.sheets.keys}");

      final sheetName = excel.sheets.keys.firstWhere(
        (name) => name.trim().toUpperCase() == 'RG_EQUIPOS',
        orElse: () => '',
      );

      if (sheetName.isEmpty) {
        throw Exception("❌ Hoja 'RG_EQUIPOS' no encontrada");
      }

      final sheet = excel[sheetName];

      // Leer encabezados normalizados
      final headerRow = sheet.row(0).map((cell) {
        return cell?.value.toString().trim().toUpperCase() ?? '';
      }).toList();

      print("🧾 Encabezados encontrados: $headerRow");

      final idIndex = headerRow.indexWhere((val) => val == 'ID');
      final ciudadIndex = headerRow.indexWhere((val) => val == 'CIUDAD');
      final passIndex = headerRow.indexWhere((val) => val == 'PASS');

      if (idIndex == -1 || ciudadIndex == -1 || passIndex == -1) {
        throw Exception(
            "❌ Encabezados requeridos no encontrados: ID, CIUDAD, PASS");
      }

      final List<Map<String, String>> tempList = [];

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);

        final id = row.length > idIndex
            ? row[idIndex]?.value.toString().trim() ?? ''
            : '';
        final ciudad = row.length > ciudadIndex
            ? row[ciudadIndex]?.value.toString().trim() ?? ''
            : '';
        final pass = row.length > passIndex
            ? row[passIndex]?.value.toString().trim() ?? ''
            : '';

        if (id.isNotEmpty && ciudad.isNotEmpty && pass.isNotEmpty) {
          tempList.add({'ID': id, 'CIUDAD': ciudad, 'PASS': pass});
        }
      }

      setState(() {
        passRG = tempList;
        filteredPassRG = List.from(passRG);
      });
    } catch (e) {
      print('❌ Error al cargar datos: $e');
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cargar la hoja RG_EQUIPOS")),
        );
      });
    }
  }

  void _filterPassRG() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPassRG = passRG
          .where((entry) => entry['CIUDAD']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _copyToClipboard(BuildContext context, String id, String pass) {
    // final String copyText = 'ID: $id - Contraseña: $pass';
    final String copyText = pass;
    FlutterClipboard.copy(copyText).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña copiada")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Buscar Ciudad',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredPassRG.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredPassRG.length,
                  itemBuilder: (context, index) {
                    final ciudad = filteredPassRG[index]['CIUDAD']!;
                    final pass = filteredPassRG[index]['PASS']!;
                    final id = filteredPassRG[index]['ID']!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          ciudad,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Contraseña: $pass'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(context, id, pass),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
