import 'package:flutter/material.dart';
import '../../domain/entities/comision.dart';
import '../../data/repositories/comision_repository.dart';

class ComisionFormProvider extends ChangeNotifier {
  final ComisionRepository repository;
  
  // Estado actual del formulario
  Comision _state;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Lista de comisiones
  List<Comision> _comisiones = [];
  
  // Getters para que la UI consuma datos ya calculados
  Comision get state => _state;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalCalculado => _state.totalConImpuestos;
  double get comisionCalculada => _state.valorComision;
  List<Comision> get comisiones => _comisiones;

  ComisionFormProvider({required this.repository}) 
      : _state = Comision(
          fecha: DateTime.now(),
          clienteNombre: '',
          clienteCuit: '',
          productoNombre: '',
          tipoProducto: 'Semilla',
        );

  // Validación del formulario
  bool get isValid {
    return _state.proveedor.isNotEmpty &&
           _state.clienteNombre.isNotEmpty &&
           _state.productoNombre.isNotEmpty &&
           _state.cantidad > 0 &&
           _state.precioUnitario > 0;
  }

  // Eventos: La UI llama a esto, no hace cálculos
  void updateClienteNombre(String value) {
    _state = _state.copyWith(clienteNombre: value);
    notifyListeners();
  }

  void updateClienteCuit(String value) {
    _state = _state.copyWith(clienteCuit: value);
    notifyListeners();
  }

  void updateProductoNombre(String value) {
    _state = _state.copyWith(productoNombre: value);
    notifyListeners();
  }

  void updateProveedor(String value) {
    _state = _state.copyWith(proveedor: value);
    notifyListeners();
  }

  void updateProveedorCuit(String value) {
    _state = _state.copyWith(proveedorCuit: value);
    notifyListeners();
  }

  void updateUnidad(String value) {
    _state = _state.copyWith(unidad: value);
    notifyListeners();
  }

  void updateCantidad(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(cantidad: val);
    notifyListeners();
  }

  void updatePrecio(String value) {
    // Remover puntos de separador de miles antes de parsear
    String cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    double val = double.tryParse(cleanValue) ?? 0.0;
    _state = _state.copyWith(precioUnitario: val);
    notifyListeners();
  }

  void updateIva(double nuevoIva) {
    _state = _state.copyWith(porcentajeIva: nuevoIva);
    notifyListeners();
  }

  void updateComision(double nuevaComision) {
    _state = _state.copyWith(porcentajeComision: nuevaComision);
    notifyListeners();
  }
  
  // Guardar comisión localmente
  Future<bool> guardarComision() async {
    if (!isValid) {
      _errorMessage = 'Por favor complete todos los campos requeridos';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.saveComision(_state);
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

  // Exportar a Excel (Microsoft OneDrive) - con autoguardado
  Future<bool> exportarAExcel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Autoguardado antes de exportar
      await repository.saveComision(_state);
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

  // Generar PDF - con autoguardado
  Future<bool> generarPdf() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Autoguardado antes de generar PDF
      await repository.saveComision(_state);
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
  Future<bool> compartirPdf() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Autoguardado antes de compartir
      await repository.saveComision(_state);
      await repository.compartirPdf(_state);
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
    _state = Comision(
      fecha: DateTime.now(),
      clienteNombre: '',
      clienteCuit: '',
      productoNombre: '',
      tipoProducto: 'Semilla',
    );
    _errorMessage = null;
    notifyListeners();
  }

  // Cargar lista de comisiones
  Future<void> loadComisiones() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comisiones = await repository.getAllComisiones();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar comisiones: $e';
      notifyListeners();
    }
  }

  // Cargar una comisión para editar
  void loadComisionForEdit(Comision comision) {
    _state = comision;
    notifyListeners();
  }

  // Actualizar comisión existente
  Future<bool> actualizarComision() async {
    if (!isValid) {
      _errorMessage = 'Por favor complete todos los campos requeridos';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateComision(_state);
      await loadComisiones(); // Recargar la lista
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

  // Eliminar comisión
  Future<bool> eliminarComision(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteComision(id);
      await loadComisiones(); // Recargar la lista
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

  // Exportar múltiples comisiones a Excel
  Future<bool> exportarVariasComisionesAExcel(List<Comision> comisiones) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.exportToExcel(comisiones);
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