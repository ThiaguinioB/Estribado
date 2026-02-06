import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Icon(
                  Icons.agriculture,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                
                // Título
                Text(
                  'Estribado',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Software Agropecuario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),
                
                // Consumer para acceder al AuthProvider
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    
                    return Column(
                      children: [
                        // Botón de Microsoft Login
                        ElevatedButton.icon(
                          onPressed: () async {
                            final success = await authProvider.loginWithMicrosoft();
                            if (success && context.mounted) {
                              context.go('/home');
                            }
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Iniciar sesión con Microsoft'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                        
                        if (authProvider.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            authProvider.errorMessage!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Botón para continuar sin login (temporal)
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Continuar sin iniciar sesión'),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                // Información adicional
                Text(
                  'Sincroniza tus datos con Microsoft Excel\ny genera reportes PDF automáticamente',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
