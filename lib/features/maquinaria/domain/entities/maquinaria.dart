import 'package:equatable/equatable.dart';

class Maquinaria extends Equatable {
  final int? numeroOperacion;
  final DateTime fecha;
  final String clienteNombre;
  final String tipoServicio;

  // Superficie
  final double superficie;          // Cantidad
  final String unidadSuperficie;    // 'm²' o 'ha'

  // Costo por unidad de superficie
  final double costoPorUnidad;      // Costo por ha o m²
  final String unidadCosto;         // 'Lts. combustible', 'USD', 'ARS'

  final String descripcion;

  const Maquinaria({
    this.numeroOperacion,
    required this.fecha,
    required this.clienteNombre,
    this.tipoServicio = '',
    this.superficie = 0.0,
    this.unidadSuperficie = 'ha',
    this.costoPorUnidad = 0.0,
    this.unidadCosto = 'ARS',
    this.descripcion = '',
  });

  // --- LÓGICA DE NEGOCIO PURA ---

  /// Total = superficie × costoPorUnidad
  double get totalCosto => superficie * costoPorUnidad;

  /// Etiqueta de la unidad de superficie
  String get etiquetaUnidadSuperficie =>
      unidadSuperficie == 'ha' ? 'hectáreas' : 'm²';

  /// Etiqueta del costo por unidad
  String get etiquetaCostoPorUnidad =>
      'Costo por ${unidadSuperficie == "ha" ? "ha" : "m²"}';

  /// Total formateado con unidad de costo
  String get totalFormateado {
    if (totalCosto == 0) return '\$ 0.00';
    return '${simboloUnidadCosto(unidadCosto)} ${totalCosto.toStringAsFixed(2)}';
  }

  /// Helper para mostrar el símbolo/unidad de costo
  static String simboloUnidadCosto(String unidad) {
    switch (unidad) {
      case 'USD':
        return 'US\$';
      case 'ARS':
        return '\$';
      case 'Lts. combustible':
        return 'Lts.';
      default:
        return unidad;
    }
  }

  // Método copyWith para inmutabilidad
  Maquinaria copyWith({
    int? numeroOperacion,
    DateTime? fecha,
    String? clienteNombre,
    String? tipoServicio,
    double? superficie,
    String? unidadSuperficie,
    double? costoPorUnidad,
    String? unidadCosto,
    String? descripcion,
  }) {
    return Maquinaria(
      numeroOperacion: numeroOperacion ?? this.numeroOperacion,
      fecha: fecha ?? this.fecha,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      superficie: superficie ?? this.superficie,
      unidadSuperficie: unidadSuperficie ?? this.unidadSuperficie,
      costoPorUnidad: costoPorUnidad ?? this.costoPorUnidad,
      unidadCosto: unidadCosto ?? this.unidadCosto,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  @override
  List<Object?> get props => [numeroOperacion, clienteNombre, totalCosto];
}
