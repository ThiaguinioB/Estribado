import '../../domain/entities/maquinaria.dart';
import '../datasources/maquinaria_local_datasource.dart';
import '../datasources/maquinaria_remote_datasource.dart';
import 'maquinaria_repository.dart';

class MaquinariaRepositoryImpl implements MaquinariaRepository {
  final MaquinariaLocalDataSource localDataSource;
  final MaquinariaRemoteDataSource remoteDataSource;

  MaquinariaRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Maquinaria>> getAllMaquinarias() async {
    try {
      return await localDataSource.getAllMaquinarias();
    } catch (e) {
      throw Exception('Error al obtener maquinarias: $e');
    }
  }

  @override
  Future<Maquinaria> getMaquinariaById(int id) async {
    try {
      return await localDataSource.getMaquinariaById(id);
    } catch (e) {
      throw Exception('Error al obtener maquinaria: $e');
    }
  }

  @override
  Future<void> saveMaquinaria(Maquinaria maquinaria) async {
    try {
      await localDataSource.saveMaquinaria(maquinaria);
    } catch (e) {
      throw Exception('Error al guardar maquinaria: $e');
    }
  }

  @override
  Future<void> updateMaquinaria(Maquinaria maquinaria) async {
    try {
      await localDataSource.updateMaquinaria(maquinaria);
    } catch (e) {
      throw Exception('Error al actualizar maquinaria: $e');
    }
  }

  @override
  Future<void> deleteMaquinaria(int id) async {
    try {
      await localDataSource.deleteMaquinaria(id);
    } catch (e) {
      throw Exception('Error al eliminar maquinaria: $e');
    }
  }

  @override
  Future<void> exportToExcel(List<Maquinaria> maquinarias) async {
    try {
      await remoteDataSource.uploadToExcel(maquinarias);
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  @override
  Future<void> exportToPdf(Maquinaria maquinaria) async {
    try {
      await remoteDataSource.generatePdf(maquinaria);
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  @override
  Future<void> compartirPdf(Maquinaria maquinaria) async {
    try {
      await remoteDataSource.sharePdf(maquinaria);
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }
}
