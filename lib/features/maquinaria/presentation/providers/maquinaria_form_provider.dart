import 'package:flutter/material.dart';
import '../../domain/entities/maquinaria.dart';
import '../../data/repositories/maquinaria_repository.dart';

class MaquinariaFormProvider extends ChangeNotifier {
  final MaquinariaRepository repository;
  
  // Estado actual del formulario
  Maquinaria _state;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Lista de maquinarias
  List<Maquinaria> _maquinarias = [];
  
  // Getters para que la UI consuma datos ya calculados
  Maquinaria get state => _state;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalCalculado => _state.totalCosto;
  List<Maquinaria> get maquinarias => _maquinarias;

  MaquinariaFormProvider({required this.repository}) 
      : _state = Maquinaria(
          fecha: DateTime.now(),
          clienteNombre: '',
        );

  // Validación del formulario
  bool get isValid {
    return _state.clienteNombre.isNotEmpty &&
           _state.tipoServicio.isNotEmpty;
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

  void updateTipoServicio(String value) {
    _state = _state.copyWith(tipoServicio: value);
    notifyListeners();
  }

  // --- Superficie ---
  void updateSuperficie(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(superficie: val);
    notifyListeners();
  }

  void updateUnidadSuperficie(String value) {
    _state = _state.copyWith(unidadSuperficie: value);
    notifyListeners();
  }

  // --- Costo por unidad ---
  void updateCostoPorUnidad(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(costoPorUnidad: val);
    notifyListeners();
  }

  void updateUnidadCosto(String value) {
    _state = _state.copyWith(unidadCosto: value);
    notifyListeners();
  }

  // --- Descripción ---
  void updateDescripcion(String value) {
    _state = _state.copyWith(descripcion: value);
    notifyListeners();
  }
  
  // Guardar maquinaria localmente
  Future<bool> guardarMaquinaria() async {
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
      final maquinarias = await repository.getAllMaquinarias();
      final nuevoNumero = maquinarias.isEmpty 
          ? 1 
          : (maquinarias.map((m) => m.numeroOperacion ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      
      _state = _state.copyWith(numeroOperacion: nuevoNumero);
      await repository.saveMaquinaria(_state);
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
  Future<bool> compartirPdf([Maquinaria? maquinaria]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.compartirPdf(maquinaria ?? _state);
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
    _state = Maquinaria(
      fecha: DateTime.now(),
      clienteNombre: '',
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Cargar lista de maquinarias
  Future<void> loadMaquinarias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _maquinarias = await repository.getAllMaquinarias();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar maquinarias: $e';
      notifyListeners();
    }
  }

  // Cargar una maquinaria para editar
  void loadMaquinariaForEdit(Maquinaria maquinaria) {
    _state = maquinaria;
    notifyListeners();
  }

  // Actualizar maquinaria existente
  Future<bool> actualizarMaquinaria() async {
    if (!isValid) {
      _errorMessage = 'Por favor complete todos los campos requeridos';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateMaquinaria(_state);
      await loadMaquinarias(); // Recargar la lista
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

  // Eliminar maquinaria
  Future<bool> eliminarMaquinaria(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteMaquinaria(id);
      await loadMaquinarias(); // Recargar la lista
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

  // Exportar múltiples maquinarias a Excel
  Future<bool> exportarVariasMaquinariasAExcel(List<Maquinaria> maquinarias) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.exportToExcel(maquinarias);
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
