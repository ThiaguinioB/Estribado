import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/microsoft_auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/comisiones/presentation/providers/comision_form_provider.dart';
import 'features/comisiones/data/repositories/comision_repository_impl.dart';
import 'features/comisiones/data/datasources/comision_local_datasource.dart';
import 'features/comisiones/data/datasources/comision_remote_datasource.dart';
import 'features/recetario/presentation/providers/recetario_form_provider.dart';
import 'features/recetario/data/repositories/recetario_repository_impl.dart';
import 'features/recetario/data/datasources/recetario_local_datasource.dart';
import 'features/recetario/data/datasources/recetario_remote_datasource.dart';
import 'core/services/excel_graph_service.dart';
import 'core/services/pdf_generator_service.dart';

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
        // Comisiones Provider
        ChangeNotifierProvider(
          create: (_) => ComisionFormProvider(
            repository: ComisionRepositoryImpl(
              localDataSource: ComisionLocalDataSource(),
              remoteDataSource: ComisionRemoteDataSource(
                excelService: ExcelGraphService(
                  authService: MicrosoftAuthService(),
                ),
                pdfService: PdfGeneratorService(),
              ),
            ),
          ),
        ),
        // Recetario Provider
        ChangeNotifierProvider(
          create: (_) => RecetarioFormProvider(
            repository: RecetarioRepositoryImpl(
              localDataSource: RecetarioLocalDataSource(),
              remoteDataSource: RecetarioRemoteDataSource(
                excelService: ExcelGraphService(
                  authService: MicrosoftAuthService(),
                ),
              ),
            ),
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
