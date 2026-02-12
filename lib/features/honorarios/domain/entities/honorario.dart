import 'package:equatable/equatable.dart';

class Honorario extends Equatable {
  final int? numeroOperacion;
  final DateTime fecha;
  final String clienteNombre;
  final int? numeroReceta;

  // Km recorridos
  final double kmRecorridos;       // Cantidad en Km
  final double costoKm;            // Costo unitario por Km (opcional)
  final String monedaKm;           // USD, ARS, Otras

  // Hora técnica
  final double horaTecnica;        // Cantidad de horas
  final double costoHora;          // Costo por hora (opcional)
  final String monedaHora;         // USD, ARS, Otras

  // Plus técnico
  final double plusTecnico;        // Monto del plus
  final String descripcionPlus;    // Descripción corta del plus
  final String monedaPlus;         // USD, ARS, Otras

  final String descripcionTarea;
  final String estado; // Pendiente, Pagado, etc.

  const Honorario({
    this.numeroOperacion,
    required this.fecha,
    required this.clienteNombre,
    this.numeroReceta,
    this.kmRecorridos = 0.0,
    this.costoKm = 0.0,
    this.monedaKm = 'ARS',
    this.horaTecnica = 0.0,
    this.costoHora = 0.0,
    this.monedaHora = 'ARS',
    this.plusTecnico = 0.0,
    this.descripcionPlus = '',
    this.monedaPlus = 'ARS',
    this.descripcionTarea = '',
    this.estado = 'Pendiente',
  });

  // --- LÓGICA DE NEGOCIO PURA (Business Logic) ---

  /// Subtotal Km = kmRecorridos * costoKm
  double get subtotalKm => kmRecorridos * costoKm;

  /// Subtotal Hora = horaTecnica * costoHora
  double get subtotalHora => horaTecnica * costoHora;

  /// Total numérico bruto (suma sin distinguir monedas)
  double get totalHonorario => subtotalKm + subtotalHora + plusTecnico;

  /// Totales agrupados por moneda
  Map<String, double> get totalesPorMoneda {
    final map = <String, double>{};
    if (subtotalKm > 0) {
      map[monedaKm] = (map[monedaKm] ?? 0) + subtotalKm;
    }
    if (subtotalHora > 0) {
      map[monedaHora] = (map[monedaHora] ?? 0) + subtotalHora;
    }
    if (plusTecnico > 0) {
      map[monedaPlus] = (map[monedaPlus] ?? 0) + plusTecnico;
    }
    return map;
  }

  /// Total formateado con moneda: "ARS 5000.00" o "USD 100.00 + ARS 3000.00"
  String get totalFormateado {
    final totales = totalesPorMoneda;
    if (totales.isEmpty) return '\$ 0.00';
    // Orden fijo: USD, ARS, Otras
    final orden = ['USD', 'ARS', 'Otras'];
    final sorted = totales.entries.toList()
      ..sort((a, b) {
        final ia = orden.indexOf(a.key);
        final ib = orden.indexOf(b.key);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });
    return sorted
        .map((e) => '${simboloMoneda(e.key)} ${e.value.toStringAsFixed(2)}')
        .join(' + ');
  }

  // Método copyWith para inmutabilidad
  Honorario copyWith({
    int? numeroOperacion,
    DateTime? fecha,
    String? clienteNombre,
    int? numeroReceta,
    double? kmRecorridos,
    double? costoKm,
    String? monedaKm,
    double? horaTecnica,
    double? costoHora,
    String? monedaHora,
    double? plusTecnico,
    String? descripcionPlus,
    String? monedaPlus,
    String? descripcionTarea,
    String? estado,
  }) {
    return Honorario(
      numeroOperacion: numeroOperacion ?? this.numeroOperacion,
      fecha: fecha ?? this.fecha,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      numeroReceta: numeroReceta ?? this.numeroReceta,
      kmRecorridos: kmRecorridos ?? this.kmRecorridos,
      costoKm: costoKm ?? this.costoKm,
      monedaKm: monedaKm ?? this.monedaKm,
      horaTecnica: horaTecnica ?? this.horaTecnica,
      costoHora: costoHora ?? this.costoHora,
      monedaHora: monedaHora ?? this.monedaHora,
      plusTecnico: plusTecnico ?? this.plusTecnico,
      descripcionPlus: descripcionPlus ?? this.descripcionPlus,
      monedaPlus: monedaPlus ?? this.monedaPlus,
      descripcionTarea: descripcionTarea ?? this.descripcionTarea,
      estado: estado ?? this.estado,
    );
  }

  /// Helper para mostrar el símbolo de moneda
  static String simboloMoneda(String moneda) {
    switch (moneda) {
      case 'USD':
        return 'US\$';
      case 'ARS':
        return '\$';
      default:
        return moneda;
    }
  }

  @override
  List<Object?> get props => [numeroOperacion, clienteNombre, totalHonorario];
}
