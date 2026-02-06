import '../../domain/entities/receta.dart';

/// Repository para gestionar recetas
abstract class RecetarioRepository {
  Future<List<Receta>> getAllRecetas();
  Future<Receta> getRecetaById(int id);
  Future<void> saveReceta(Receta receta);
  Future<void> updateReceta(Receta receta);
  Future<void> deleteReceta(int id);
  Future<int> getNextNumeroReceta();
  Future<void> setNumeroReceta(int numero);
}
