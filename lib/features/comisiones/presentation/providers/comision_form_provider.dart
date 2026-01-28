import 'package:flutter/material.dart';
import '../../domain/entities/comision.dart';

class ComisionFormProvider extends ChangeNotifier {
  // Estado actual del formulario
  Comision _state;
  
  // Getters para que la UI consuma datos ya calculados
  Comision get state => _state;
  double get totalCalculado => _state.totalConImpuestos;
  double get comisionCalculada => _state.valorComision;

  ComisionFormProvider() : _state = Comision(
    fecha: DateTime.now(),
    clienteNombre: '',
    clienteCuit: '',
    productoNombre: '',
    tipoProducto: 'Semilla',
  );

  // Eventos: La UI llama a esto, no hace cálculos
  void updateCantidad(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(cantidad: val);
    notifyListeners(); // Avisa a la vista que se redibuje
  }

  void updatePrecio(String value) {
    double val = double.tryParse(value) ?? 0.0;
    _state = _state.copyWith(precioUnitario: val);
    notifyListeners();
  }

  void updateIva(double nuevoIva) {
    _state = _state.copyWith(porcentajeIva: nuevoIva);
    notifyListeners();
  }
  
  // Aquí inyectaremos luego los servicios de Excel y PDF
  Future<void> guardarYExportar() async {
    // 1. Validar datos
    // 2. Llamar al servicio de Microsoft Graph API (Repository)
    // 3. Generar PDF
  }
}