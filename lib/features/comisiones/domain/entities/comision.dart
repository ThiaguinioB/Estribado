import 'package:equatable/equatable.dart'; // Ayuda a comparar objetos

class Comision extends Equatable {
  final int? numeroOperacion;
  final DateTime fecha;
  final String clienteNombre;
  final String clienteCuit;
  final String productoNombre;
  final String tipoProducto; // Semilla, Herbicida, etc.
  final double cantidad;
  final double precioUnitario;
  final double porcentajeIva;
  final double porcentajeComision;
  final String estado; // Pendiente, Pagado, etc.

  const Comision({
    this.numeroOperacion,
    required this.fecha,
    required this.clienteNombre,
    required this.clienteCuit,
    required this.productoNombre,
    required this.tipoProducto,
    this.cantidad = 0.0,
    this.precioUnitario = 0.0,
    this.porcentajeIva = 21.0,
    this.porcentajeComision = 0.0,
    this.estado = 'Pendiente',
  });

  // --- LÓGICA DE NEGOCIO PURA (Business Logic) ---
  // Las fórmulas matemáticas pertenecen a la entidad, no a la UI.
  
  double get subtotalNeto => cantidad * precioUnitario;
  
  double get montoIva => subtotalNeto * (porcentajeIva / 100);
  
  double get totalConImpuestos => subtotalNeto + montoIva;
  
  double get valorComision => totalConImpuestos * (porcentajeComision / 100);

  // Método copyWith para inmutabilidad (Vital para gestión de estado segura)
  Comision copyWith({
    String? clienteNombre,
    double? cantidad,
    double? precioUnitario,
    double? porcentajeIva,
    double? porcentajeComision,
    // ... agregar el resto de campos si es necesario
  }) {
    return Comision(
      fecha: this.fecha,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteCuit: this.clienteCuit,
      productoNombre: this.productoNombre,
      tipoProducto: this.tipoProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      porcentajeIva: porcentajeIva ?? this.porcentajeIva,
      porcentajeComision: porcentajeComision ?? this.porcentajeComision,
    );
  }

  @override
  List<Object?> get props => [numeroOperacion, clienteCuit, totalConImpuestos];
}