import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/honorario.dart';

/// DataSource para persistencia local de honorarios
class HonorarioLocalDataSource {
  static const String _key = 'honorarios_list';

  Future<List<Honorario>> getAllHonorarios() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => _honorarioFromJson(json)).toList();
  }

  Future<Honorario> getHonorarioById(int id) async {
    final honorarios = await getAllHonorarios();
    return honorarios.firstWhere(
      (h) => h.numeroOperacion == id,
      orElse: () => throw Exception('Honorario no encontrado'),
    );
  }

  Future<void> saveHonorario(Honorario honorario) async {
    final honorarios = await getAllHonorarios();
    honorarios.add(honorario);
    await _saveAll(honorarios);
  }

  Future<void> updateHonorario(Honorario honorario) async {
    final honorarios = await getAllHonorarios();
    final index = honorarios.indexWhere((h) => h.numeroOperacion == honorario.numeroOperacion);
    
    if (index != -1) {
      honorarios[index] = honorario;
      await _saveAll(honorarios);
    }
  }

  Future<void> deleteHonorario(int id) async {
    final honorarios = await getAllHonorarios();
    honorarios.removeWhere((h) => h.numeroOperacion == id);
    await _saveAll(honorarios);
  }

  Future<void> _saveAll(List<Honorario> honorarios) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = honorarios.map((h) => _honorarioToJson(h)).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  // Helper para serialización
  Map<String, dynamic> _honorarioToJson(Honorario h) {
    return {
      'numeroOperacion': h.numeroOperacion,
      'fecha': h.fecha.toIso8601String(),
      'clienteNombre': h.clienteNombre,
      'numeroReceta': h.numeroReceta,
      'kmRecorridos': h.kmRecorridos,
      'costoKm': h.costoKm,
      'monedaKm': h.monedaKm,
      'horaTecnica': h.horaTecnica,
      'costoHora': h.costoHora,
      'monedaHora': h.monedaHora,
      'plusTecnico': h.plusTecnico,
      'descripcionPlus': h.descripcionPlus,
      'monedaPlus': h.monedaPlus,
      'descripcionTarea': h.descripcionTarea,
      'estado': h.estado,
    };
  }

  Honorario _honorarioFromJson(Map<String, dynamic> json) {
    return Honorario(
      numeroOperacion: json['numeroOperacion'],
      fecha: DateTime.parse(json['fecha']),
      clienteNombre: json['clienteNombre'] ?? '',
      numeroReceta: json['numeroReceta'],
      kmRecorridos: (json['kmRecorridos'] ?? 0.0).toDouble(),
      costoKm: (json['costoKm'] ?? 0.0).toDouble(),
      monedaKm: json['monedaKm'] ?? 'ARS',
      horaTecnica: (json['horaTecnica'] ?? 0.0).toDouble(),
      costoHora: (json['costoHora'] ?? 0.0).toDouble(),
      monedaHora: json['monedaHora'] ?? 'ARS',
      plusTecnico: (json['plusTecnico'] ?? 0.0).toDouble(),
      descripcionPlus: json['descripcionPlus'] ?? '',
      monedaPlus: json['monedaPlus'] ?? 'ARS',
      descripcionTarea: json['descripcionTarea'] ?? '',
      estado: json['estado'] ?? 'Pendiente',
    );
  }
}
