import '../../domain/entities/honorario.dart';

/// Repository para gestionar honorarios profesionales
/// Abstracción entre datos locales y remotos (Microsoft Excel)
abstract class HonorarioRepository {
  Future<List<Honorario>> getAllHonorarios();
  Future<Honorario> getHonorarioById(int id);
  Future<void> saveHonorario(Honorario honorario);
  Future<void> updateHonorario(Honorario honorario);
  Future<void> deleteHonorario(int id);
  Future<void> exportToExcel(List<Honorario> honorarios);
  Future<void> exportToPdf(Honorario honorario);
  Future<void> compartirPdf(Honorario honorario);
}
