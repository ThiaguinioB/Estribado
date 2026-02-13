import '../../domain/entities/maquinaria.dart';

/// Repository para gestionar servicios de maquinaria
/// Abstracción entre datos locales y remotos (Microsoft Excel)
abstract class MaquinariaRepository {
  Future<List<Maquinaria>> getAllMaquinarias();
  Future<Maquinaria> getMaquinariaById(int id);
  Future<void> saveMaquinaria(Maquinaria maquinaria);
  Future<void> updateMaquinaria(Maquinaria maquinaria);
  Future<void> deleteMaquinaria(int id);
  Future<void> exportToExcel(List<Maquinaria> maquinarias);
  Future<void> exportToPdf(Maquinaria maquinaria);
  Future<void> compartirPdf(Maquinaria maquinaria);
}
