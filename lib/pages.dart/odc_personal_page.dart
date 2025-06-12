import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';

class OdcPage extends StatefulWidget {
  const OdcPage({super.key});

  @override
  State<OdcPage> createState() => _OdcPageState();
}

class _OdcPageState extends State<OdcPage> {
  List<Map<String, dynamic>> personalList = [];
  List<Map<String, dynamic>> filteredList = [];
  bool _isLoading = true;
  String? _loadError;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPersonalOdc();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalOdc() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final cursor = MongoDatabase.db.collection('personal_odc').find();
      final List<Map<String, dynamic>> data = await cursor.toList();

      setState(() {
        personalList = data;
        filteredList = List.from(data);
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
        filteredList = List.from(personalList);
      });
      return;
    }

    final filtered = personalList.where((item) {
      final zona = item['zona']?.toString().toLowerCase() ?? '';
      final nameJr = item['name_jr']?.toString().toLowerCase() ?? '';
      return zona.contains(query) || nameJr.contains(query);
    }).toList();

    setState(() {
      filteredList = filtered;
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
              Text("Error al cargar datos:\n$_loadError",
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPersonalOdc,
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
        onRefresh: _loadPersonalOdc,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔍 Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por Zona o Nombre del JR',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📋 Tabla
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Zona')),
                  DataColumn(label: Text('Nombre JR')),
                  DataColumn(label: Text('Tel. Personal')),
                  DataColumn(label: Text('Tel. Coop')),
                  DataColumn(label: Text('Observación')),
                  DataColumn(label: Text('Primer Escalamiento')),
                  DataColumn(label: Text('Tel. O&M')),
                  DataColumn(label: Text('Email O&M')),
                  DataColumn(label: Text('Segundo Escalamiento')),
                  DataColumn(label: Text('Tel. Red FO')),
                  DataColumn(label: Text('Email Red FO')),
                ],
                rows: filteredList.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['zona'] ?? 'N/A')),
                      DataCell(Container(
                          color: Colors.green.withOpacity(0.6),
                          child: Text(item['name_jr'] ?? 'N/A'))),

                      // Teléfono Personal con botón copiar
                      DataCell(Row(
                        children: [
                          Expanded(
                              child: Text(item['phone_personal'] ?? 'N/A')),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar teléfono personal',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: item['phone_personal'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Teléfono personal copiado")),
                              );
                            },
                          ),
                        ],
                      )),

                      // Teléfono Coop
                      DataCell(Row(
                        children: [
                          Expanded(child: Text(item['phone_coop'] ?? 'N/A')),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar teléfono coop',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: item['phone_coop'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Teléfono coop copiado")),
                              );
                            },
                          ),
                        ],
                      )),

                      DataCell(Text(item['observation'] ?? 'N/A')),
                      DataCell(Container(
                          color: Colors.blue.withOpacity(0.6),
                          child: Text(item['o&m_regional_name'] ?? 'N/A'))),

                      // Teléfono O&M
                      DataCell(Row(
                        children: [
                          Expanded(
                              child: Text(item['o&m_regional_phone'] ?? 'N/A')),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar teléfono O&M',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: item['o&m_regional_phone'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Teléfono O&M copiado")),
                              );
                            },
                          ),
                        ],
                      )),

                      // Email O&M
                      DataCell(Row(
                        children: [
                          Expanded(
                              child: Text(item['o&m_regional_email'] ?? 'N/A')),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar email O&M',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: item['o&m_regional_email'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Email O&M copiado")),
                              );
                            },
                          ),
                        ],
                      )),

                      DataCell(Container(
                        color: Colors.red.withOpacity(0.6),
                        child: Text(item['network_director_fo_name'] ?? 'N/A'),
                      )),

                      // Teléfono Dir FO
                      DataCell(Row(
                        children: [
                          Expanded(
                              child: Text(
                                  item['network_director_fo_phone'] ?? 'N/A')),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar teléfono Dir FO',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      item['network_director_fo_phone'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Teléfono Dir FO copiado")),
                              );
                            },
                          ),
                        ],
                      )),

                      // Email Dir FO
                      DataCell(Row(
                        children: [
                          Expanded(
                              child: Text(
                                  item['network_director_fo_email'] ?? 'N/A')),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copiar email Dir FO',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      item['network_director_fo_email'] ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Email Dir FO copiado")),
                              );
                            },
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
