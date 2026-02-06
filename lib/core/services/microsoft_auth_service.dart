import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import '../../app_config.dart';

/// Servicio de autenticación con Microsoft Azure AD
class MicrosoftAuthService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static final Config _config = Config(
    tenant: AppConfig.microsoftTenantId,
    clientId: AppConfig.microsoftClientId,
    scope: AppConfig.graphApiScopes,
    redirectUri: AppConfig.microsoftRedirectUri,
    navigatorKey: navigatorKey,
  );

  final AadOAuth _oauth = AadOAuth(_config);

  /// Inicia sesión con Microsoft
  Future<bool> login() async {
    try {
      await _oauth.login();
      return await isLoggedIn();
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      await _oauth.logout();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isLoggedIn() async {
    try {
      final token = await _oauth.getAccessToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el token de acceso actual
  Future<String?> getAccessToken() async {
    try {
      return await _oauth.getAccessToken();
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  /// Refresca el token de acceso
  Future<String?> refreshToken() async {
    try {
      return await _oauth.getAccessToken();
    } catch (e) {
      print('Error al refrescar token: $e');
      return null;
    }
  }
}
