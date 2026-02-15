import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> sharePdf(Comision comision) async {
    final bytes = await pdfService.generateComisionPdfBytes(comision);

    String nombreArchivo = "Comision-${comision.clienteNombre}-${comision.productoNombre}.pdf";
    nombreArchivo = nombreArchivo.replaceAll(RegExp(r'[^\w\s\-\.]'), '');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Te envío la comisión: $nombreArchivo',
    );
  }
}
