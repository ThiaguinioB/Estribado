import '../../domain/entities/comision.dart';
import '../datasources/comision_local_datasource.dart';
import '../datasources/comision_remote_datasource.dart';
import 'comision_repository.dart';

class ComisionRepositoryImpl implements ComisionRepository {
  final ComisionLocalDataSource localDataSource;
  final ComisionRemoteDataSource remoteDataSource;

  ComisionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Comision>> getAllComisiones() async {
    try {
      return await localDataSource.getAllComisiones();
    } catch (e) {
      throw Exception('Error al obtener comisiones: $e');
    }
  }

  @override
  Future<Comision> getComisionById(int id) async {
    try {
      return await localDataSource.getComisionById(id);
    } catch (e) {
      throw Exception('Error al obtener comisión: $e');
    }
  }

  @override
  Future<void> saveComision(Comision comision) async {
    try {
      await localDataSource.saveComision(comision);
    } catch (e) {
      throw Exception('Error al guardar comisión: $e');
    }
  }

  @override
  Future<void> updateComision(Comision comision) async {
    try {
      await localDataSource.updateComision(comision);
    } catch (e) {
      throw Exception('Error al actualizar comisión: $e');
    }
  }

  @override
  Future<void> deleteComision(int id) async {
    try {
      await localDataSource.deleteComision(id);
    } catch (e) {
      throw Exception('Error al eliminar comisión: $e');
    }
  }

  @override
  Future<void> exportToExcel(List<Comision> comisiones) async {
    try {
      await remoteDataSource.uploadToExcel(comisiones);
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  @override
  Future<void> exportToPdf(Comision comision) async {
    try {
      await remoteDataSource.generatePdf(comision);
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  @override
  Future<void> compartirPdf(Comision comision) async {
    try {
      await remoteDataSource.sharePdf(comision);
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }
}
