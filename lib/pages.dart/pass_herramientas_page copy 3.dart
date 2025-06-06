import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import 'package:excel/excel.dart';

class PassHerramientasPage extends StatefulWidget {
  const PassHerramientasPage({super.key});

  @override
  State<PassHerramientasPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<PassHerramientasPage> {
  Map<String, List<Map<String, dynamic>>> equiposPorCategoria = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  Future<void> _loadExcelData() async {
    try {
      final ByteData data =
          await rootBundle.load('assets/bd_local/BD_TEST.xlsx');
      final List<int> bytes = data.buffer.asUint8List();
      final Excel excel = Excel.decodeBytes(bytes);

      //final Sheet? sheet = excel.tables[excel.tables.keys.first];
      final sheet = excel['PASS_TOOLS'];
      if (sheet == null) {
        print('No se encontró la hoja');
        return;
      }

      final List<String> headers = sheet.rows.first
          .map((e) => e?.value.toString().trim() ?? '')
          .toList();

      final requiredColumns = [
        'EQUIPO',
        'USER',
        'PASS_LIST',
        'URL',
        'CATEGORIA'
      ];

      if (!requiredColumns.every((c) => headers.contains(c))) {
        print("Error: faltan columnas requeridas");
        return;
      }

      final Map<String, int> headerIndex = {
        for (int i = 0; i < headers.length; i++) headers[i]: i
      };

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        String parseValue(Data? cell) {
          final value = cell?.value?.toString().trim();
          return (value == null || value.isEmpty) ? 'N/A' : value;
        }

        final equipo = parseValue(row[headerIndex['EQUIPO']!]);
        final user = parseValue(row[headerIndex['USER']!]);
        final passListRaw = parseValue(row[headerIndex['PASS_LIST']!]);
        final url = parseValue(row[headerIndex['URL']!]);
        final categoria =
            parseValue(row[headerIndex['CATEGORIA']!]).toUpperCase();

        final equipoData = {
          'equipo': equipo,
          'user': user,
          'passwords': passListRaw.split(',').map((e) => e.trim()).toList(),
          'url': url,
        };

        equiposPorCategoria.putIfAbsent(categoria, () => []).add(equipoData);
      }

      setState(() {});
    } catch (e) {
      print('Error al cargar el archivo Excel: $e');
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

    equiposPorCategoria.forEach((category, items) {
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categoría: ${entry.key}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
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
                                          child:
                                              Text('Usuario: ${item['user']}'),
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
                                              child:
                                                  Text('Contraseña: ********'),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () =>
                                                  _copyToClipboard(pw),
                                            ),
                                          ],
                                        )),
                                    if ((item['url'] ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                              child:
                                                  Text('URL: ${item['url']}')),
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
                      ),
                      const SizedBox(height: 32),
                    ],
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
