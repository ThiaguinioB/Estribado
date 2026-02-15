import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/comision.dart';

/// DataSource para persistencia local de comisiones
class ComisionLocalDataSource {
  static const String _key = 'comisiones_list';

  Future<List<Comision>> getAllComisiones() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => _comisionFromJson(json)).toList();
  }

  Future<Comision> getComisionById(int id) async {
    final comisiones = await getAllComisiones();
    return comisiones.firstWhere(
      (c) => c.numeroOperacion == id,
      orElse: () => throw Exception('Comisión no encontrada'),
    );
  }

  Future<void> saveComision(Comision comision) async {
    final comisiones = await getAllComisiones();
    comisiones.add(comision);
    await _saveAll(comisiones);
  }

  Future<void> updateComision(Comision comision) async {
    final comisiones = await getAllComisiones();
    final index = comisiones.indexWhere((c) => c.numeroOperacion == comision.numeroOperacion);
    
    if (index != -1) {
      comisiones[index] = comision;
      await _saveAll(comisiones);
    }
  }

  Future<void> deleteComision(int id) async {
    final comisiones = await getAllComisiones();
    comisiones.removeWhere((c) => c.numeroOperacion == id);
    await _saveAll(comisiones);
  }

  Future<void> _saveAll(List<Comision> comisiones) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = comisiones.map((c) => _comisionToJson(c)).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  // Helper para serialización
  Map<String, dynamic> _comisionToJson(Comision c) {
    return {
      'numeroOperacion': c.numeroOperacion,
      'fecha': c.fecha.toIso8601String(),
      'clienteNombre': c.clienteNombre,
      'clienteCuit': c.clienteCuit,
      'proveedor': c.proveedor,
      'proveedorCuit': c.proveedorCuit,
      'productoNombre': c.productoNombre,
      'tipoProducto': c.tipoProducto,
      'cantidad': c.cantidad,
      'unidad': c.unidad,
      'precioUnitario': c.precioUnitario,
      'porcentajeIva': c.porcentajeIva,
      'porcentajeComision': c.porcentajeComision,
      'estado': c.estado,
    };
  }

  Comision _comisionFromJson(Map<String, dynamic> json) {
    return Comision(
      numeroOperacion: json['numeroOperacion'],
      fecha: DateTime.parse(json['fecha']),
      clienteNombre: json['clienteNombre'],
      clienteCuit: json['clienteCuit'],
      proveedor: json['proveedor'] ?? '',
      proveedorCuit: json['proveedorCuit'] ?? '',
      productoNombre: json['productoNombre'],
      tipoProducto: json['tipoProducto'],
      cantidad: json['cantidad'],
      unidad: json['unidad'] ?? 'ton',
      precioUnitario: json['precioUnitario'],
      porcentajeIva: json['porcentajeIva'],
      porcentajeComision: json['porcentajeComision'],
      estado: json['estado'],
    );
  }
}
