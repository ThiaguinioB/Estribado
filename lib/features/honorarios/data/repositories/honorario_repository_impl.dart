import '../../domain/entities/honorario.dart';
import '../datasources/honorario_local_datasource.dart';
import '../datasources/honorario_remote_datasource.dart';
import 'honorario_repository.dart';

class HonorarioRepositoryImpl implements HonorarioRepository {
  final HonorarioLocalDataSource localDataSource;
  final HonorarioRemoteDataSource remoteDataSource;

  HonorarioRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Honorario>> getAllHonorarios() async {
    try {
      return await localDataSource.getAllHonorarios();
    } catch (e) {
      throw Exception('Error al obtener honorarios: $e');
    }
  }

  @override
  Future<Honorario> getHonorarioById(int id) async {
    try {
      return await localDataSource.getHonorarioById(id);
    } catch (e) {
      throw Exception('Error al obtener honorario: $e');
    }
  }

  @override
  Future<void> saveHonorario(Honorario honorario) async {
    try {
      await localDataSource.saveHonorario(honorario);
    } catch (e) {
      throw Exception('Error al guardar honorario: $e');
    }
  }

  @override
  Future<void> updateHonorario(Honorario honorario) async {
    try {
      await localDataSource.updateHonorario(honorario);
    } catch (e) {
      throw Exception('Error al actualizar honorario: $e');
    }
  }

  @override
  Future<void> deleteHonorario(int id) async {
    try {
      await localDataSource.deleteHonorario(id);
    } catch (e) {
      throw Exception('Error al eliminar honorario: $e');
    }
  }

  @override
  Future<void> exportToExcel(List<Honorario> honorarios) async {
    try {
      await remoteDataSource.uploadToExcel(honorarios);
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  @override
  Future<void> exportToPdf(Honorario honorario) async {
    try {
      await remoteDataSource.generatePdf(honorario);
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  @override
  Future<void> compartirPdf(Honorario honorario) async {
    try {
      await remoteDataSource.sharePdf(honorario);
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }
}
