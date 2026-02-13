import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/maquinaria.dart';

/// DataSource para persistencia local de maquinarias
class MaquinariaLocalDataSource {
  static const String _key = 'maquinarias_list';

  Future<List<Maquinaria>> getAllMaquinarias() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => _maquinariaFromJson(json)).toList();
  }

  Future<Maquinaria> getMaquinariaById(int id) async {
    final maquinarias = await getAllMaquinarias();
    return maquinarias.firstWhere(
      (m) => m.numeroOperacion == id,
      orElse: () => throw Exception('Maquinaria no encontrada'),
    );
  }

  Future<void> saveMaquinaria(Maquinaria maquinaria) async {
    final maquinarias = await getAllMaquinarias();
    maquinarias.add(maquinaria);
    await _saveAll(maquinarias);
  }

  Future<void> updateMaquinaria(Maquinaria maquinaria) async {
    final maquinarias = await getAllMaquinarias();
    final index = maquinarias.indexWhere((m) => m.numeroOperacion == maquinaria.numeroOperacion);
    
    if (index != -1) {
      maquinarias[index] = maquinaria;
      await _saveAll(maquinarias);
    }
  }

  Future<void> deleteMaquinaria(int id) async {
    final maquinarias = await getAllMaquinarias();
    maquinarias.removeWhere((m) => m.numeroOperacion == id);
    await _saveAll(maquinarias);
  }

  Future<void> _saveAll(List<Maquinaria> maquinarias) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = maquinarias.map((m) => _maquinariaToJson(m)).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  // Helper para serialización
  Map<String, dynamic> _maquinariaToJson(Maquinaria m) {
    return {
      'numeroOperacion': m.numeroOperacion,
      'fecha': m.fecha.toIso8601String(),
      'clienteNombre': m.clienteNombre,
      'tipoServicio': m.tipoServicio,
      'superficie': m.superficie,
      'unidadSuperficie': m.unidadSuperficie,
      'costoPorUnidad': m.costoPorUnidad,
      'unidadCosto': m.unidadCosto,
      'descripcion': m.descripcion,
    };
  }

  Maquinaria _maquinariaFromJson(Map<String, dynamic> json) {
    return Maquinaria(
      numeroOperacion: json['numeroOperacion'],
      fecha: DateTime.parse(json['fecha']),
      clienteNombre: json['clienteNombre'] ?? '',
      tipoServicio: json['tipoServicio'] ?? '',
      superficie: (json['superficie'] ?? 0.0).toDouble(),
      unidadSuperficie: json['unidadSuperficie'] ?? 'ha',
      costoPorUnidad: (json['costoPorUnidad'] ?? 0.0).toDouble(),
      unidadCosto: json['unidadCosto'] ?? 'ARS',
      descripcion: json['descripcion'] ?? '',
    );
  }
}
