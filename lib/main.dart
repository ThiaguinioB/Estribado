import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/microsoft_auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() {
  runApp(const EstribadoApp());
}

class EstribadoApp extends StatelessWidget {
  const EstribadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider global
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: MicrosoftAuthService(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Estribado',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
