import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';
import 'package:mc_dashboard/pages.dart/home.dart';
import 'package:mongo_dart/mongo_dart.dart' as mdb;

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

  void showAddClientDialog() {
    final nameController = TextEditingController();
    final workloadController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: workloadController,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final workload = workloadController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();

                if (name.isEmpty ||
                    workload.isEmpty ||
                    phone.isEmpty ||
                    email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Todos los campos son obligatorios')),
                  );
                  return;
                }

                try {
                  final coll =
                      MongoDatabase.db.collection('client_information');
                  await coll.insertOne({
                    '_id': mdb.ObjectId(), // genera un ObjectId válido
                    'name': name,
                    'workload': workload,
                    'phone': phone,
                    'email': email,
                  });

                  Navigator.pop(context); // Cierra el diálogo
                  _loadClients(); // Recarga la tabla
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Cliente agregado exitosamente')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al agregar cliente: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          SizedBox(
            width: 100,
            height: 40,
            child: FloatingActionButton.extended(
              heroTag: 'addClientButton',
              onPressed: showAddClientDialog,
              // icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            height: 40,
            child: FloatingActionButton.extended(
              heroTag: 'backButton',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MinimalMenuPage(),
                  ),
                );
              },
              //icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
        ],
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
