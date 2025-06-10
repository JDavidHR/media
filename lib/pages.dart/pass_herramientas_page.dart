import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:mc_dashboard/core/models/db_helper/mongodb_connection.dart';

class PassHerramientasPage extends StatefulWidget {
  const PassHerramientasPage({super.key});

  @override
  State<PassHerramientasPage> createState() => _PassHerramientasPageState();
}

class _PassHerramientasPageState extends State<PassHerramientasPage> {
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  String searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPassTools();
  }

  Future<void> _loadPassTools() async {
    try {
      final collection = MongoDatabase.db.collection('pass_tools');
      final data = await collection.find().toList();

      final Map<String, List<Map<String, dynamic>>> tempGrouped = {};

      for (var item in data) {
        final category =
            (item['category'] ?? 'Sin categoría').toString().toUpperCase();
        final device = item['device'] ?? 'Dispositivo';
        final user = item['user'] ?? 'Usuario';
        final passList = (item['pass_list'] ?? '')
            .toString()
            .split(',')
            .map((e) => e.trim())
            .toList();
        final url = item['url'] ?? '';

        final entry = {
          'device': device,
          'user': user,
          'passwords': passList,
          'url': url,
        };

        tempGrouped.putIfAbsent(category, () => []).add(entry);
      }

      setState(() {
        groupedData = tempGrouped;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error al cargar datos de MongoDB: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error al cargar la colección pass_tools")),
      );
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text) {
    FlutterClipboard.copy(text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copiado: $text')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = <String, List<Map<String, dynamic>>>{};

    groupedData.forEach((category, items) {
      final filteredItems = items.where((item) {
        final device = item['device']?.toString().toLowerCase() ?? '';
        final user = item['user']?.toString().toLowerCase() ?? '';
        return device.contains(searchQuery.toLowerCase()) ||
            user.contains(searchQuery.toLowerCase());
      }).toList();

      if (filteredItems.isNotEmpty) {
        filteredData[category] = filteredItems;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Equipo: ${item['device']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      'Usuario: ${item['user']}')),
                                              IconButton(
                                                icon: const Icon(Icons.copy),
                                                onPressed: () =>
                                                    _copyToClipboard(
                                                        item['user']),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ...passwords.map((pw) => Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                          'Contraseña: $pw')),
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.copy),
                                                    onPressed: () =>
                                                        _copyToClipboard(pw),
                                                  ),
                                                ],
                                              )),
                                          if ((item['url'] ?? '')
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        'URL: ${item['url']}')),
                                                IconButton(
                                                  icon: const Icon(Icons.copy),
                                                  onPressed: () =>
                                                      _copyToClipboard(
                                                          item['url']),
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
