import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';

class EquiposPage extends StatefulWidget {
  const EquiposPage({super.key});

  @override
  State<EquiposPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<EquiposPage> {
  Map<String, List<Map<String, dynamic>>> equiposPorCategoria = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDevices();
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
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
          children: equiposPorCategoria.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equipos ${entry.key}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                                equipo['vendor'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Referencia: ${equipo['reference']}'),
                              Text(
                                  'Capacidad: ${equipo['capacity']} ${equipo['type']}'),
                              Text('Estado: ${equipo['status']}'),
                              Text('Conversor: ${equipo['conversor']}'),
                              Text(
                                  'Ref. Transceiver: ${equipo['ref_transceiver']}'),
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
    );
  }
}
