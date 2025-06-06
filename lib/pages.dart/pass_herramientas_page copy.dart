import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import 'package:excel/excel.dart';

class PassToolsPage extends StatefulWidget {
  const PassToolsPage({super.key});

  @override
  State<PassToolsPage> createState() => _PassToolsPageState();
}

class _PassToolsPageState extends State<PassToolsPage> {
  Map<String, List<Map<String, dynamic>>> passwordsData = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExcel();
  }

  Future<void> _loadExcel() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/bd_local/BD_TEST.xlsx');
      final bytes = data.buffer.asUint8List();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel['PASS_TOOLS'];

      if (sheet == null) {
        print("No se encontró la hoja PASS_TOOLS");
        return;
      }

      Map<String, List<Map<String, dynamic>>> tempData = {};

      for (var row in sheet.rows.skip(1)) {
        final category = row[0]?.value?.toString().trim() ?? '';
        final equipo = row[1]?.value?.toString().trim() ?? '';
        final user = row[2]?.value?.toString().trim() ?? '';
        final password1 = row[3]?.value?.toString().trim() ?? '';
        final url = row[4]?.value?.toString().trim() ?? '';

        if (category.isEmpty || equipo.isEmpty) continue;

        tempData.putIfAbsent(category, () => []).add({
          'equipo': equipo,
          'user': user,
          'passwords': password1.split(',').map((e) => e.trim()).toList(),
          'url': url,
        });
      }

      setState(() {
        passwordsData = tempData;
      });
    } catch (e) {
      print('Error al cargar Excel desde assets: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copiado: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = <String, List<Map<String, dynamic>>>{};

    passwordsData.forEach((category, items) {
      final filteredItems = items.where((item) {
        final equipo = item['equipo']?.toString().toLowerCase() ?? '';
        final user = item['user']?.toString().toLowerCase() ?? '';
        return equipo.contains(searchQuery.toLowerCase()) ||
            user.contains(searchQuery.toLowerCase());
      }).toList();

      if (filteredItems.isNotEmpty) {
        filteredData[category] = filteredItems;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar equipo o usuario',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filteredData.entries.map((entry) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: entry.value.map((item) {
                      final List passwords = item['passwords'] ?? [];
                      return SizedBox(
                        width: 300,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Equipo: ${item['equipo']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('Usuario: ${item['user']}'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () =>
                                          _copyToClipboard(item['user']),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...passwords.map((pw) => Row(
                                      children: [
                                        const Expanded(
                                          child: Text('Contraseña: ********'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.copy),
                                          onPressed: () => _copyToClipboard(pw),
                                        ),
                                      ],
                                    )),
                                if ((item['url'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text('URL: ${item['url']}')),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () =>
                                            _copyToClipboard(item['url']),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
