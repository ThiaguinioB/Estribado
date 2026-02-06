import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/receta.dart';

/// DataSource para persistencia local de recetas
class RecetarioLocalDataSource {
  static const String _key = 'recetas_list';
  static const String _numeroKey = 'nro_receta';

  Future<List<Receta>> getAllRecetas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Receta.fromJson(json)).toList();
  }

  Future<Receta> getRecetaById(int id) async {
    final recetas = await getAllRecetas();
    return recetas.firstWhere(
      (r) => r.numeroReceta == id,
      orElse: () => throw Exception('Receta no encontrada'),
    );
  }

  Future<void> saveReceta(Receta receta) async {
    final recetas = await getAllRecetas();
    
    // Asignar número si no tiene
    if (receta.numeroReceta == null) {
      final numero = await getNextNumeroReceta();
      receta = receta.copyWith(numeroReceta: numero);
      await incrementarNumeroReceta();
    }
    
    recetas.add(receta);
    await _saveAll(recetas);
  }

  Future<void> updateReceta(Receta receta) async {
    final recetas = await getAllRecetas();
    final index = recetas.indexWhere((r) => r.numeroReceta == receta.numeroReceta);
    
    if (index != -1) {
      recetas[index] = receta;
      await _saveAll(recetas);
    }
  }

  Future<void> deleteReceta(int id) async {
    final recetas = await getAllRecetas();
    recetas.removeWhere((r) => r.numeroReceta == id);
    await _saveAll(recetas);
  }

  Future<void> _saveAll(List<Receta> recetas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = recetas.map((r) => r.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  Future<int> getNextNumeroReceta() async {
    final prefs = await SharedPreferences.getInstance();
    final numeroGuardado = prefs.getInt(_numeroKey);
    
    // Si existe un número guardado, usarlo
    if (numeroGuardado != null) {
      return numeroGuardado;
    }
    
    // Si no hay número guardado, calcular basándose en recetas existentes
    final recetas = await getAllRecetas();
    if (recetas.isEmpty) {
      return 1;
    }
    
    // Encontrar el número más alto y sumar 1
    final maxNumero = recetas
        .map((r) => r.numeroReceta ?? 0)
        .reduce((a, b) => a > b ? a : b);
    
    final siguienteNumero = maxNumero + 1;
    await setNumeroReceta(siguienteNumero);
    return siguienteNumero;
  }

  Future<void> setNumeroReceta(int numero) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_numeroKey, numero);
  }

  Future<void> incrementarNumeroReceta() async {
    final numero = await getNextNumeroReceta();
    await setNumeroReceta(numero + 1);
  }
}
