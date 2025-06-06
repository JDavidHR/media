import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class EquiposPage extends StatefulWidget {
  const EquiposPage({super.key});

  @override
  State<EquiposPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<EquiposPage> {
  Map<String, List<Map<String, dynamic>>> equiposPorCategoria = {};

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  Future<void> _loadExcelData() async {
    final ByteData data = await rootBundle.load('assets/bd_local/BD_TEST.xlsx');
    final List<int> bytes = data.buffer.asUint8List();
    final Excel excel = Excel.decodeBytes(bytes);

    final Sheet sheet = excel.tables[excel.tables.keys.first]!;
    final List<String> headers =
        sheet.rows.first.map((e) => e?.value.toString() ?? '').toList();

    final requiredColumns = [
      'VENDOR',
      'REFERENCIA',
      'CAPACIDAD',
      'ESTADO',
      'CATEGORIA',
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

      final vendor = parseValue(row[headerIndex['VENDOR']!]);
      final referencia = parseValue(row[headerIndex['REFERENCIA']!]);
      final capacidad = parseValue(row[headerIndex['CAPACIDAD']!]);
      final estado = parseValue(row[headerIndex['ESTADO']!]);
      final categoria =
          parseValue(row[headerIndex['CATEGORIA']!]).toUpperCase();
      final tipo = parseValue(row[headerIndex['TIPO']!]);

      final equipo = {
        'vendor': vendor,
        'referencia': referencia,
        'capacidad': capacidad,
        'estado': estado,
        'tipo': tipo,
      };

      if (!equiposPorCategoria.containsKey(categoria)) {
        equiposPorCategoria[categoria] = [];
      }
      equiposPorCategoria[categoria]!.add(equipo);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: equiposPorCategoria.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Equipos ${entry.key}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: entry.value.map((equipo) {
                  return SizedBox(
                    width: 300,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipo['vendor'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Referencia: ${equipo['referencia']}'),
                            Text(
                                'Capacidad: ${equipo['capacidad']} ${equipo['tipo']}'),
                            Text('Estado: ${equipo['estado']}'),
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
    );
  }
}
