/// Configuración global de la aplicación
class AppConfig {
  // Microsoft Azure AD Config
  static const String microsoftClientId = 'YOUR_CLIENT_ID_HERE';
  static const String microsoftTenantId = 'YOUR_TENANT_ID_HERE';
  static const String microsoftRedirectUri = 'msauth://com.estribado.app/callback';
  
  // Microsoft Graph API Endpoints
  static const String graphApiUrl = 'https://graph.microsoft.com/v1.0';
  static const String graphApiScopes = 'Files.ReadWrite offline_access User.Read';
  
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
