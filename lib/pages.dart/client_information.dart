import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';
import 'package:mc_dashboard/pages.dart/home.dart';

class ClientInfoPage extends StatefulWidget {
  const ClientInfoPage({super.key});

  @override
  State<ClientInfoPage> createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<ClientInfoPage> {
  List<Map<String, dynamic>> clients = [];
  List<Map<String, dynamic>> filteredClients = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadClients();
    searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterClients);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final coll = MongoDatabase.db.collection('client_information');
      final data = await coll.find().toList();

      setState(() {
        clients = data;
        filteredClients = List.from(clients);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = "Error al cargar información de clientes";
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No se pudieron cargar los datos de clientes.")),
      );
    }
  }

  void _filterClients() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredClients = clients.where((c) {
        final name = (c['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  void _copyText(String field, String text) {
    FlutterClipboard.copy(text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field copiado')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MinimalMenuPage(),
            ),
          );
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Clientes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_loadError != null)
              Center(child: Text(_loadError!))
            else if (filteredClients.isEmpty)
              const Center(child: Text('No se encontraron clientes'))
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Cargo')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: filteredClients.map((client) {
                      final name = client['name'] ?? '';
                      final workload = client['workload'] ?? '';
                      final phone = client['phone'] ?? '';
                      final email = client['email'] ?? '';
                      return DataRow(cells: [
                        DataCell(Text(name)),
                        DataCell(Text(workload)),
                        DataCell(Text(phone)),
                        DataCell(Text(email)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.phone_outlined, size: 20),
                              tooltip: 'Copiar teléfono',
                              onPressed: () => _copyText('Teléfono', phone),
                            ),
                            IconButton(
                              icon: const Icon(Icons.email_outlined, size: 20),
                              tooltip: 'Copiar email',
                              onPressed: () => _copyText('Email', email),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
