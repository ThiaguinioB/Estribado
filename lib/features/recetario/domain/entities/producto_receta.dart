import 'package:equatable/equatable.dart';

class ProductoReceta extends Equatable {
  final String nombre;
  final double dosisPorHa;
  final String unidad;
  final double total;
  final String unidadTotal;

  const ProductoReceta({
    required this.nombre,
    required this.dosisPorHa,
    required this.unidad,
    required this.total,
    required this.unidadTotal,
  });

  // Método copyWith para inmutabilidad
  ProductoReceta copyWith({
    String? nombre,
    double? dosisPorHa,
    String? unidad,
    double? total,
    String? unidadTotal,
  }) {
    return ProductoReceta(
      nombre: nombre ?? this.nombre,
      dosisPorHa: dosisPorHa ?? this.dosisPorHa,
      unidad: unidad ?? this.unidad,
      total: total ?? this.total,
      unidadTotal: unidadTotal ?? this.unidadTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dosisPorHa': dosisPorHa,
      'unidad': unidad,
      'total': total,
      'unidadTotal': unidadTotal,
    };
  }

  factory ProductoReceta.fromJson(Map<String, dynamic> json) {
    return ProductoReceta(
      nombre: json['nombre'] as String,
      dosisPorHa: (json['dosisPorHa'] as num).toDouble(),
      unidad: json['unidad'] as String,
      total: (json['total'] as num).toDouble(),
      unidadTotal: json['unidadTotal'] as String,
    );
  }

  @override
  List<Object?> get props => [nombre, dosisPorHa, unidad, total, unidadTotal];
}
