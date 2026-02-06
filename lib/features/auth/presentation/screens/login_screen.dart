import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card con el contenido
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          // Logo/Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_sync,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          Text(
                            'Conectar con Microsoft',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sincroniza tus recetas y comisiones\ncon Excel en OneDrive',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Beneficios
                          _buildBenefit(Icons.cloud_upload, 'Respaldo automático en la nube'),
                          const SizedBox(height: 12),
                          _buildBenefit(Icons.table_chart, 'Exportación directa a Excel'),
                          const SizedBox(height: 12),
                          _buildBenefit(Icons.sync, 'Sincronización en tiempo real'),
                          
                          const SizedBox(height: 32),
                          
                          // Consumer para acceder al AuthProvider
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.isLoading) {
                                return const Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Conectando...'),
                                  ],
                                );
                              }
                              
                              return Column(
                                children: [
                                  // Botón de Microsoft Login
                                  ElevatedButton(
                                    onPressed: () async {
                                      final success = await authProvider.loginWithMicrosoft();
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Conectado exitosamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        context.go('/home');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 56),
                                      backgroundColor: const Color(0xFF0078D4), // Microsoft blue
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.cloud,
                                            color: Color(0xFF0078D4),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Conectar con Microsoft',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (authProvider.errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              authProvider.errorMessage!,
                                              style: const TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Botón para continuar sin login
                                  TextButton(
                                    onPressed: () => context.go('/home'),
                                    child: const Text('Continuar sin conectar (datos solo locales)'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Información de privacidad
                  Text(
                    'Tus datos están seguros y protegidos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
