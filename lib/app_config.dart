/// Configuración global de la aplicación
class AppConfig {
  // Microsoft Azure AD Config
  // Tu Client ID actual de Azure
  static const String microsoftClientId = '9457a928-d8ae-4f0f-a1cb-80a96ca5e1fc';
  
  // IMPORTANTE: Usa 'common' para permitir:
  // - Cuentas personales de Microsoft (@outlook.com, @hotmail.com, @live.com)
  // - Cuentas organizacionales de Azure AD
  static const String microsoftTenantId = 'common';
  
  // URI de redirección - debe coincidir con lo configurado en Azure Portal
  static const String microsoftRedirectUri = 'msauth://com.estribado.app/callback';
  
  // Microsoft Graph API Endpoints
  static const String graphApiUrl = 'https://graph.microsoft.com/v1.0';
  
  // Scopes necesarios para Microsoft Graph
  // IMPORTANTE: NO uses .default, usa los scopes específicos
  static const String graphApiScopes = 'https://graph.microsoft.com/Files.ReadWrite https://graph.microsoft.com/User.Read offline_access';
  
  // App Settings
  static const String appName = 'Estribado';
  static const String appVersion = '0.1.0';
  
  // Default Values
  static const double defaultIva = 21.0;
  static const double defaultComision = 10.0;
  
  // Database
  static const String databaseName = 'estribado.db';
  static const int databaseVersion = 1;
}
