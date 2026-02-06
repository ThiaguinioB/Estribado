import '../../domain/entities/receta.dart';
import '../datasources/recetario_local_datasource.dart';
import '../datasources/recetario_remote_datasource.dart';
import 'recetario_repository.dart';

class RecetarioRepositoryImpl implements RecetarioRepository {
  final RecetarioLocalDataSource localDataSource;
  final RecetarioRemoteDataSource remoteDataSource;

  RecetarioRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Receta>> getAllRecetas() async {
    try {
      return await localDataSource.getAllRecetas();
    } catch (e) {
      throw Exception('Error al obtener recetas: $e');
    }
  }

  @override
  Future<Receta> getRecetaById(int id) async {
    try {
      return await localDataSource.getRecetaById(id);
    } catch (e) {
      throw Exception('Error al obtener receta: $e');
    }
  }

  @override
  Future<void> saveReceta(Receta receta) async {
    try {
      await localDataSource.saveReceta(receta);
    } catch (e) {
      throw Exception('Error al guardar receta: $e');
    }
  }

  @override
  Future<void> updateReceta(Receta receta) async {
    try {
      await localDataSource.updateReceta(receta);
    } catch (e) {
      throw Exception('Error al actualizar receta: $e');
    }
  }

  @override
  Future<void> deleteReceta(int id) async {
    try {
      await localDataSource.deleteReceta(id);
    } catch (e) {
      throw Exception('Error al eliminar receta: $e');
    }
  }

  @override
  Future<int> getNextNumeroReceta() async {
    try {
      return await localDataSource.getNextNumeroReceta();
    } catch (e) {
      throw Exception('Error al obtener número de receta: $e');
    }
  }

  @override
  Future<void> setNumeroReceta(int numero) async {
    try {
      await localDataSource.setNumeroReceta(numero);
    } catch (e) {
      throw Exception('Error al establecer número de receta: $e');
    }
  }

  Future<void> generarPdf(Receta receta) async {
    try {
      await remoteDataSource.generatePdf(receta);
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  Future<void> compartirPdf(Receta receta) async {
    try {
      await remoteDataSource.sharePdf(receta);
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }

  Future<void> exportarVariasRecetasAExcel(List<Receta> recetas) async {
    try {
      await remoteDataSource.exportToExcel(recetas);
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }
}
