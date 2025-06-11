import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';

class EquiposPage extends StatefulWidget {
  const EquiposPage({super.key});

  @override
  State<EquiposPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<EquiposPage> {
  Map<String, List<Map<String, dynamic>>> equiposPorCategoria = {};
  Map<String, List<Map<String, dynamic>>> equiposFiltrados = {};
  bool _isLoading = true;
  String? _loadError;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDevices();

    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final cursor = MongoDatabase.db.collection('devices').find();
      final List<Map<String, dynamic>> all = await cursor.toList();

      final Map<String, List<Map<String, dynamic>>> data = {};
      for (var doc in all) {
        final category = (doc['category'] as String? ?? 'N/A').toUpperCase();

        final equipo = {
          'vendor': doc['vendor'] ?? 'N/A',
          'reference': doc['reference']?.toString() ?? 'N/A',
          'capacity': doc['capacity']?.toString() ?? 'N/A',
          'type': doc['type'] ?? 'N/A',
          'status': doc['status'] ?? 'N/A',
          'conversor': doc['conversor'] ?? 'N/A',
          'ref_transceiver': doc['ref_transceiver'] ?? 'N/A',
        };

        data.putIfAbsent(category, () => []).add(equipo);
      }

      setState(() {
        equiposPorCategoria = data;
        equiposFiltrados = Map.from(data); // Inicialmente igual
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        equiposFiltrados = Map.from(equiposPorCategoria);
      });
      return;
    }

    final Map<String, List<Map<String, dynamic>>> filtered = {};

    equiposPorCategoria.forEach((categoria, lista) {
      final matches = lista.where((equipo) {
        final vendor = equipo['vendor'].toString().toLowerCase();
        final reference = equipo['reference'].toString().toLowerCase();
        return vendor.contains(query) || reference.contains(query);
      }).toList();

      if (matches.isNotEmpty) {
        filtered[categoria] = matches;
      }
    });

    setState(() {
      equiposFiltrados = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text("Error al cargar dispositivos:\n$_loadError",
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadDevices,
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FA),
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔍 Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por Vendor o Referencia',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🧾 Tablas filtradas
            ...equiposFiltrados.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipos ${entry.key}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Vendor')),
                        DataColumn(label: Text('Referencia')),
                        DataColumn(label: Text('Capacidad')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Conversor')),
                        DataColumn(label: Text('Ref. Transceiver')),
                      ],
                      rows: entry.value.map((equipo) {
                        return DataRow(cells: [
                          DataCell(Text(equipo['vendor'])),
                          DataCell(Text(equipo['reference'])),
                          DataCell(Text(equipo['capacity'])),
                          DataCell(Text(equipo['type'])),
                          DataCell(Text(equipo['status'])),
                          DataCell(Text(equipo['conversor'])),
                          DataCell(Text(equipo['ref_transceiver'])),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
