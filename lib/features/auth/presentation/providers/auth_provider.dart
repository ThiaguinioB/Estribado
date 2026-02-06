import 'package:flutter/material.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final MicrosoftAuthService _authService;
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _userEmail;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail;

  AuthProvider({required MicrosoftAuthService authService})
      : _authService = authService {
    _checkAuthStatus();
  }

  /// Verifica el estado de autenticación al iniciar
  Future<void> _checkAuthStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  /// Inicia sesión con Microsoft
  Future<bool> loginWithMicrosoft() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login();
      _isLoggedIn = success;
      
      if (!success) {
        _errorMessage = 'No se pudo completar el inicio de sesión';
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isLoggedIn = false;
      _userEmail = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene el token de acceso actual
  Future<String?> getAccessToken() async {
    return await _authService.getAccessToken();
  }
}
