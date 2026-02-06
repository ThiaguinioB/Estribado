import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar personalizado
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Estribado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decoración con iconos de estribos
                    Positioned(
                      right: -30,
                      top: 20,
                      child: Transform.rotate(
                        angle: 0.3,
                        child: Icon(
                          Icons.panorama_fish_eye_outlined,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 60,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          Icons.panorama_fish_eye_outlined,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Icon(
                          Icons.panorama_fish_eye_outlined,
                          size: 90,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 50,
                      bottom: -10,
                      child: Icon(
                        Icons.agriculture,
                        size: 120,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => context.push('/login'),
                tooltip: 'Cuenta',
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de bienvenida
                  const _WelcomeCard(),
                  const SizedBox(height: 24),

                  // Título de sección
                  const Text(
                    'Gestión Agropecuaria',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona una herramienta para comenzar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid de features
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      FeatureCard(
                        title: 'Comisiones',
                        subtitle: 'Gestión de comisiones',
                        icon: Icons.attach_money,
                        color: Colors.green,
                        onTap: () => context.push('/comisiones'),
                      ),
                      FeatureCard(
                        title: 'Recetario',
                        subtitle: 'Recetas agronómicas',
                        icon: Icons.spa,
                        color: Colors.purple,
                        onTap: () => context.push('/recetario'),
                      ),
                      FeatureCard(
                        title: 'Honorarios',
                        subtitle: 'Honorarios profesionales',
                        icon: Icons.business_center,
                        color: Colors.blue,
                        isAvailable: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Módulo en desarrollo'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      FeatureCard(
                        title: 'Maquinaria',
                        subtitle: 'Maquinaria agrícola',
                        icon: Icons.agriculture,
                        color: Colors.orange,
                        isAvailable: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Módulo en desarrollo'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sección de acciones rápidas
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botones de acciones rápidas
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickActionButton(
                        label: 'Nueva Comisión',
                        icon: Icons.add_circle,
                        color: Colors.green,
                        onTap: () => context.push('/comisiones/nueva'),
                      ),
                      _QuickActionButton(
                        label: 'Ver Todas',
                        icon: Icons.list_alt,
                        color: Colors.blue,
                        onTap: () => context.push('/comisiones'),
                      ),
                      _QuickActionButton(
                        label: 'Exportar Excel',
                        icon: Icons.upload_file,
                        color: Colors.teal,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ir a la lista de comisiones para exportar'),
                            ),
                          );
                        },
                      ),
                      _QuickActionButton(
                        label: 'Configuración',
                        icon: Icons.settings,
                        color: Colors.grey,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Configuración próximamente'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Buenos días';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      greetingIcon = Icons.wb_cloudy;
    } else {
      greeting = 'Buenas noches';
      greetingIcon = Icons.nightlight_round;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                greetingIcon,
                size: 32,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bienvenido a tu sistema de gestión',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}
