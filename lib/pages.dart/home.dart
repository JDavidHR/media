import 'package:flutter/material.dart';
import 'package:mc_dashboard/dashboard/dashboard_base_page.dart';

class MinimalMenuPage extends StatelessWidget {
  const MinimalMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen superior sin recorte
              SizedBox(
                width: 200,
                height: 120,
                child: Image.asset(
                  'assets/logos/MC_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Botón: Escalamientos terceros
              _buildMenuButton(
                context,
                label: 'Escalamientos terceros',
                icon: Icons.groups_2,
                onPressed: () {},
              ),
              const SizedBox(height: 20),

              // Botón: Archivos descargables
              _buildMenuButton(
                context,
                label: 'Archivos descargables',
                icon: Icons.download,
                onPressed: () {},
              ),
              const SizedBox(height: 20),

              // Botón: Soporte
              _buildMenuButton(
                context,
                label: 'Soporte',
                icon: Icons.support_agent,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardBasePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Informacion clientes
              _buildMenuButton(
                context,
                label: 'Informacion clientes',
                icon: Icons.folder,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 280, // Tamaño fijo del botón
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black87,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
