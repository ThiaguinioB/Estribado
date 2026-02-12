import 'package:flutter/material.dart';
import '../../domain/entities/honorario.dart';
import '../../data/repositories/honorario_repository.dart';

class HonorarioFormProvider extends ChangeNotifier {
  final HonorarioRepository repository;
  
  // Estado actual del formulario
  Honorario _state;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Lista de honorarios
  List<Honorario> _honorarios = [];
  
  // Getters para que la UI consuma datos ya calculados
  Honorario get state => _state;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalCalculado => _state.totalHonorario;
  List<Honorario> get honorarios => _honorarios;

  HonorarioFormProvider({required this.repository}) 
      : _state = Honorario(
          fecha: DateTime.now(),
          clienteNombre: '',
        );

  // Validación del formulario
  bool get isValid {
    return _state.clienteNombre.isNotEmpty &&
           _state.descripcionTarea.isNotEmpty;
  }

  // --- EVENTOS DE LA UI ---

  void updateClienteNombre(String value) {
    _state = _state.copyWith(clienteNombre: value);
    notifyListeners();
  }

  void updateFecha(DateTime value) {
    _state = _state.copyWith(fecha: value);
    notifyListeners();
  }

  // Nro de Receta con +/- como en recetario
  void updateNumeroReceta(String value) {
    int? val = int.tryParse(value);
    _state = _state.copyWith(numeroReceta: val);
    notifyListeners();
  }

  /// Carga el número de receta inicial basado en los honorarios existentes.
  /// Si no hay honorarios previos, empieza en 1.
  Future<void> cargarNumeroRecetaInicial() async {
    try {
      final honorarios = await repository.getAllHonorarios();
      if (honorarios.isEmpty) {
        _state = _state.copyWith(numeroReceta: 1);
      } else {
        final maxReceta = honorarios
            .where((h) => h.numeroReceta != null)
            .map((h) => h.numeroReceta!)
            .fold<int>(0, (prev, el) => el > prev ? el : prev);
        _state = _state.copyWith(numeroReceta: maxReceta + 1);
      }
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(numeroReceta: 1);
      notifyListeners();
    }
  }

  void incrementarNumeroReceta() {
    final current = _state.numeroReceta ?? 0;
    _state = _state.copyWith(numeroReceta: current + 1);
    notifyListeners();
  }

  void decrementarNumeroReceta() {
    final current = _state.numeroReceta ?? 0;
    if (current > 1) {
      _state = _state.copyWith(numeroReceta: current - 1);
    }
    notifyListeners();
  }

  // --- Km Recorridos ---
  void updateKmRecorridos(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(kmRecorridos: val);
    notifyListeners();
  }

  void updateCostoKm(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(costoKm: val);
    notifyListeners();
  }

  void updateMonedaKm(String value) {
    _state = _state.copyWith(monedaKm: value);
    notifyListeners();
  }

  // --- Hora Técnica ---
  void updateHoraTecnica(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(horaTecnica: val);
    notifyListeners();
  }

  void updateCostoHora(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(costoHora: val);
    notifyListeners();
  }

  void updateMonedaHora(String value) {
    _state = _state.copyWith(monedaHora: value);
    notifyListeners();
  }

  // --- Plus Técnico ---
  void updatePlusTecnico(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(plusTecnico: val);
    notifyListeners();
  }

  void updateDescripcionPlus(String value) {
    _state = _state.copyWith(descripcionPlus: value);
    notifyListeners();
  }

  void updateMonedaPlus(String value) {
    _state = _state.copyWith(monedaPlus: value);
    notifyListeners();
  }

  // --- Descripción tarea ---
  void updateDescripcionTarea(String value) {
    _state = _state.copyWith(descripcionTarea: value);
    notifyListeners();
  }
  
  // Guardar honorario localmente
  Future<bool> guardarHonorario() async {
    if (!isValid) {
      _errorMessage = 'Por favor complete todos los campos requeridos';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Asignar número de operación automático
      final honorarios = await repository.getAllHonorarios();
      final nuevoNumero = honorarios.isEmpty 
          ? 1 
          : (honorarios.map((h) => h.numeroOperacion ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      
      _state = _state.copyWith(numeroOperacion: nuevoNumero);
      await repository.saveHonorario(_state);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al guardar: $e';
      notifyListeners();
      return false;
    }
  }

  // Exportar a Excel (Microsoft OneDrive)
  Future<bool> exportarAExcel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.exportToExcel([_state]);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al exportar a Excel: $e';
      notifyListeners();
      return false;
    }
  }

  // Generar PDF
  Future<bool> generarPdf() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.exportToPdf(_state);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al generar PDF: $e';
      notifyListeners();
      return false;
    }
  }

  // Compartir PDF
  Future<bool> compartirPdf([Honorario? honorario]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.compartirPdf(honorario ?? _state);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al compartir PDF: $e';
      notifyListeners();
      return false;
    }
  }

  // Limpiar formulario
  void resetForm() {
    _state = Honorario(
      fecha: DateTime.now(),
      clienteNombre: '',
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Cargar lista de honorarios
  Future<void> loadHonorarios() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _honorarios = await repository.getAllHonorarios();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar honorarios: $e';
      notifyListeners();
    }
  }

  // Cargar un honorario para editar
  void loadHonorarioForEdit(Honorario honorario) {
    _state = honorario;
    notifyListeners();
  }

  // Actualizar honorario existente
  Future<bool> actualizarHonorario() async {
    if (!isValid) {
      _errorMessage = 'Por favor complete todos los campos requeridos';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateHonorario(_state);
      await loadHonorarios(); // Recargar la lista
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar: $e';
      notifyListeners();
      return false;
    }
  }

  // Eliminar honorario
  Future<bool> eliminarHonorario(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteHonorario(id);
      await loadHonorarios(); // Recargar la lista
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar: $e';
      notifyListeners();
      return false;
    }
  }

  // Exportar múltiples honorarios a Excel
  Future<bool> exportarVariosHonorariosAExcel(List<Honorario> honorarios) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.exportToExcel(honorarios);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al exportar a Excel: $e';
      notifyListeners();
      return false;
    }
  }
}
