import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../domain/entities/maquinaria.dart';

/// DataSource para operaciones remotas (Excel y PDF)
class MaquinariaRemoteDataSource {
  final ExcelGraphService excelService;
  final PdfGeneratorService pdfService;

  MaquinariaRemoteDataSource({
    required this.excelService,
    required this.pdfService,
  });

  Future<void> uploadToExcel(List<Maquinaria> maquinarias) async {
    await excelService.uploadMaquinariasToExcel(maquinarias);
  }

  Future<void> generatePdf(Maquinaria maquinaria) async {
    await pdfService.generateMaquinariaPdf(maquinaria);
  }

  Future<void> sharePdf(Maquinaria maquinaria) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'SERVICIO DE MAQUINARIA',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('DATOS GENERALES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Cliente:', maquinaria.clienteNombre),
            _row('Fecha:', dateFormat.format(maquinaria.fecha)),
            if (maquinaria.numeroOperacion != null)
              _row('N° Operación:', maquinaria.numeroOperacion.toString()),
            _row('Tipo de Servicio:', maquinaria.tipoServicio),
            pw.SizedBox(height: 20),
            pw.Text('DETALLE DEL SERVICIO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Superficie:', '${maquinaria.superficie.toStringAsFixed(2)} ${maquinaria.unidadSuperficie}'),
            if (maquinaria.costoPorUnidad > 0) ...[
              _row(
                'Costo por ${maquinaria.unidadSuperficie}:',
                '${Maquinaria.simboloUnidadCosto(maquinaria.unidadCosto)} ${maquinaria.costoPorUnidad.toStringAsFixed(2)}',
              ),
              _row(
                'TOTAL:',
                maquinaria.totalFormateado,
                isBold: true,
                color: PdfColors.green,
              ),
            ],
            pw.SizedBox(height: 20),
            if (maquinaria.descripcion.isNotEmpty) ...[
              pw.Text('OBSERVACIONES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(maquinaria.descripcion),
              ),
            ],
            pw.Spacer(),
            pw.Divider(),
            pw.Text(
              'Documento generado por Estribado - Software Agropecuario',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    String nombreArchivo = 'Maquinaria-${maquinaria.clienteNombre}-${maquinaria.numeroOperacion ?? 0}.pdf';
    nombreArchivo = nombreArchivo.replaceAll(RegExp(r'[^\w\s\-\.]'), '');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Te envío el servicio de maquinaria: $nombreArchivo',
    );
  }

  static pw.Widget _row(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, color: color)),
        ],
      ),
    );
  }
}
