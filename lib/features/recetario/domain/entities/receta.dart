import 'package:equatable/equatable.dart';
import 'producto_receta.dart';

class Receta extends Equatable {
  final int? numeroReceta;
  final DateTime fecha;
  final String cliente;
  final double cantidadHas;
  final String lote;
  final String cultivo;
  final String establecimiento;
  final String contratista;
  final String observaciones;
  final List<ProductoReceta> productos;

  const Receta({
    this.numeroReceta,
    required this.fecha,
    required this.cliente,
    this.cantidadHas = 0.0,
    required this.lote,
    required this.cultivo,
    required this.establecimiento,
    required this.contratista,
    this.observaciones = '',
    this.productos = const [],
  });

  // Método copyWith para inmutabilidad
  Receta copyWith({
    int? numeroReceta,
    DateTime? fecha,
    String? cliente,
    double? cantidadHas,
    String? lote,
    String? cultivo,
    String? establecimiento,
    String? contratista,
    String? observaciones,
    List<ProductoReceta>? productos,
  }) {
    return Receta(
      numeroReceta: numeroReceta ?? this.numeroReceta,
      fecha: fecha ?? this.fecha,
      cliente: cliente ?? this.cliente,
      cantidadHas: cantidadHas ?? this.cantidadHas,
      lote: lote ?? this.lote,
      cultivo: cultivo ?? this.cultivo,
      establecimiento: establecimiento ?? this.establecimiento,
      contratista: contratista ?? this.contratista,
      observaciones: observaciones ?? this.observaciones,
      productos: productos ?? this.productos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroReceta': numeroReceta,
      'fecha': fecha.toIso8601String(),
      'cliente': cliente,
      'cantidadHas': cantidadHas,
      'lote': lote,
      'cultivo': cultivo,
      'establecimiento': establecimiento,
      'contratista': contratista,
      'observaciones': observaciones,
      'productos': productos.map((p) => p.toJson()).toList(),
    };
  }

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      numeroReceta: json['numeroReceta'] as int?,
      fecha: DateTime.parse(json['fecha'] as String),
      cliente: json['cliente'] as String,
      cantidadHas: (json['cantidadHas'] as num).toDouble(),
      lote: json['lote'] as String,
      cultivo: json['cultivo'] as String,
      establecimiento: json['establecimiento'] as String,
      contratista: json['contratista'] as String,
      observaciones: json['observaciones'] as String? ?? '',
      productos: (json['productos'] as List<dynamic>?)
              ?.map((p) => ProductoReceta.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        numeroReceta,
        fecha,
        cliente,
        cantidadHas,
        lote,
        cultivo,
        establecimiento,
        contratista,
        observaciones,
        productos,
      ];
}
