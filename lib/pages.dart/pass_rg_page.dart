import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';

class PassRGPage extends StatefulWidget {
  const PassRGPage({super.key});

  @override
  State<PassRGPage> createState() => _PassRGPageState();
}

class _PassRGPageState extends State<PassRGPage> {
  List<Map<String, dynamic>> rgDevices = [];
  List<Map<String, dynamic>> filteredDevices = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPassRG();
    searchController.addListener(_filterDevices);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterDevices);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPassRG() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final collection = MongoDatabase.db.collection('rg_devices');
      final data = await collection.find().toList();

      setState(() {
        rgDevices = data;
        filteredDevices = List.from(rgDevices);
      });
    } catch (e) {
      print('❌ Error al cargar datos: $e');
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error al cargar la colección RG Devices")),
        );
      });
    }
  }

  void _filterDevices() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredDevices = rgDevices
          .where((item) =>
              item['city']?.toString().toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  void _copyToClipboard(BuildContext context, String pass) {
    FlutterClipboard.copy(pass).then((_) {
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
          child: filteredDevices.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final city =
                        filteredDevices[index]['city'] ?? 'Desconocido';
                    final pass = filteredDevices[index]['password'] ?? '';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          city,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Contraseña: $pass'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(context, pass),
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
