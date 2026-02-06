import '../../domain/entities/comision.dart';

/// Repository para gestionar comisiones
/// Abstracción entre datos locales y remotos (Microsoft Excel)
abstract class ComisionRepository {
  Future<List<Comision>> getAllComisiones();
  Future<Comision> getComisionById(int id);
  Future<void> saveComision(Comision comision);
  Future<void> updateComision(Comision comision);
  Future<void> deleteComision(int id);
  Future<void> exportToExcel(List<Comision> comisiones);
  Future<void> exportToPdf(Comision comision);
}
