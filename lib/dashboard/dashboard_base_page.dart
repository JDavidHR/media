import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mc_dashboard/pages.dart/device_page.dart';
import 'package:mc_dashboard/pages.dart/home_page.dart';
import 'package:mc_dashboard/pages.dart/odc_personal_page.dart';
import 'package:mc_dashboard/pages.dart/pass_tools_page.dart';
import 'package:mc_dashboard/pages.dart/pass_rg_page.dart';

class DashboardBasePage extends StatefulWidget {
  const DashboardBasePage({super.key});

  @override
  State<DashboardBasePage> createState() => _DashboardBasePageState();
}

class _DashboardBasePageState extends State<DashboardBasePage> {
  Widget _selectedPage = const EquiposPage();

  void _onMenuItemSelected(String page) {
    setState(() {
      switch (page) {
        case 'Equipos':
          _selectedPage = const EquiposPage();
          break;
        case 'Pass - RG':
          _selectedPage = const PassRGPage();
          break;
        case 'Pass-Herramientas':
          _selectedPage = const PassHerramientasPage();
          break;
        case 'ODC':
          _selectedPage = const OdcPage();
          break;
        default:
          _selectedPage = const Center(
            child: Text(
              '¡Proximamente!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 38,
              ),
            ),
          );
      }
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
      body: Row(
        children: [
          BarLeft(
            onItemSelected: _onMenuItemSelected,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _selectedPage,
            ),
          ),
        ],
      ),
    );
  }
}

class BarLeft extends StatefulWidget {
  final ValueChanged<String> onItemSelected;

  const BarLeft({
    super.key,
    required this.onItemSelected,
  });

  @override
  State<BarLeft> createState() => _BarLeftState();
}

class _BarLeftState extends State<BarLeft> {
  String _selectedItem = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200,
      child: Column(
        children: [
          // Imagen fija
          Container(
            color: const Color(0xFFF9F3FA),
            height: 100,
            child: Center(
              child: Image.asset(
                'assets/logos/MC_logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Lista desplazable
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem('Equipos', LucideIcons.monitor),
                _buildMenuItem('Pass - RG', LucideIcons.badgeCheck),
                _buildMenuItem('Pass-Herramientas', LucideIcons.box),
                _buildMenuItem('INA', LucideIcons.users),
                _buildMenuItem('ODC', LucideIcons.users),
                _buildMenuItem('SR', LucideIcons.users),
                _buildMenuItem('Permisos de ingreso', LucideIcons.key),
                _buildMenuItem('Fibras oscuras', LucideIcons.waves),
                _buildMenuItem('Special', LucideIcons.star),
                _buildMenuItem('Terceros', LucideIcons.users),
                _buildMenuItem(
                    'Escalamiento Jerarquico', LucideIcons.trendingUp),
                _buildMenuItem('Proyecto RUAV', LucideIcons.network),
                _buildMenuItem('ITX', LucideIcons.cpu),
                _buildMenuItem(
                    'CONT-N2-Residentes-Special-ISP', LucideIcons.server),
                _buildMenuItem('Clientes arquetipos', LucideIcons.briefcase),
                _buildMenuItem('Directorio', LucideIcons.book),
                _buildMenuItem('Perú', LucideIcons.flag),
                _buildMenuItem('RB Meganet', LucideIcons.globe),
                _buildMenuItem(
                    'Descuento-Indisponibilidad', LucideIcons.percent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    final isSelected = _selectedItem == title;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
      ),
      tileColor: isSelected ? Colors.blue : null,
      onTap: () {
        setState(() {
          _selectedItem = title;
        });
        widget.onItemSelected(title);
      },
    );
  }
}
