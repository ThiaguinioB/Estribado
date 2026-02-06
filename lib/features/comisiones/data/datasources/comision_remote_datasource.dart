import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../domain/entities/comision.dart';

/// DataSource para operaciones remotas (Excel y PDF)
class ComisionRemoteDataSource {
  final ExcelGraphService excelService;
  final PdfGeneratorService pdfService;

  ComisionRemoteDataSource({
    required this.excelService,
    required this.pdfService,
  });

  Future<void> uploadToExcel(List<Comision> comisiones) async {
    await excelService.uploadComisionesToExcel(comisiones);
  }

  Future<void> generatePdf(Comision comision) async {
    await pdfService.generateComisionPdf(comision);
  }
}
