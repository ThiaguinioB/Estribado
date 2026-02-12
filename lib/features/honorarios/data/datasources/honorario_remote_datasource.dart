import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../domain/entities/honorario.dart';

/// DataSource para operaciones remotas (Excel y PDF)
class HonorarioRemoteDataSource {
  final ExcelGraphService excelService;
  final PdfGeneratorService pdfService;

  HonorarioRemoteDataSource({
    required this.excelService,
    required this.pdfService,
  });

  Future<void> uploadToExcel(List<Honorario> honorarios) async {
    await excelService.uploadHonorariosToExcel(honorarios);
  }

  Future<void> generatePdf(Honorario honorario) async {
    await pdfService.generateHonorarioPdf(honorario);
  }

  Future<void> sharePdf(Honorario honorario) async {
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
                'HONORARIOS PROFESIONALES',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('DATOS GENERALES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Cliente:', honorario.clienteNombre),
            _row('Fecha:', dateFormat.format(honorario.fecha)),
            if (honorario.numeroReceta != null)
              _row('Nro. de Receta:', honorario.numeroReceta.toString().padLeft(5, '0')),
            pw.SizedBox(height: 20),
            pw.Text('DETALLE DE COSTOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Km. Recorridos:', '${honorario.kmRecorridos.toStringAsFixed(1)} km'),
            if (honorario.costoKm > 0) ...[              _row('Costo por Km (${honorario.monedaKm}):', '${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.costoKm.toStringAsFixed(2)}'),
              _row('Subtotal Km:', '${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.subtotalKm.toStringAsFixed(2)}', isBold: true),
            ],
            _row('Hora Técnica:', '${honorario.horaTecnica.toStringAsFixed(1)} hs'),
            if (honorario.costoHora > 0) ...[              _row('Costo por Hora (${honorario.monedaHora}):', '${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.costoHora.toStringAsFixed(2)}'),
              _row('Subtotal Horas:', '${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.subtotalHora.toStringAsFixed(2)}', isBold: true),
            ],
            if (honorario.plusTecnico > 0) ...[              _row('Plus Técnico (${honorario.monedaPlus}):', '${Honorario.simboloMoneda(honorario.monedaPlus)} ${honorario.plusTecnico.toStringAsFixed(2)}'),
              if (honorario.descripcionPlus.isNotEmpty)
                _row('Descripción Plus:', honorario.descripcionPlus),
            ],
            pw.SizedBox(height: 10),
            _row('TOTAL HONORARIO:', honorario.totalFormateado, isBold: true, color: PdfColors.green),
            pw.SizedBox(height: 20),
            pw.Text('DESCRIPCIÓN DE LA TAREA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey), borderRadius: pw.BorderRadius.circular(5)),
              child: pw.Text(honorario.descripcionTarea.isNotEmpty ? honorario.descripcionTarea : 'Sin descripción'),
            ),
            pw.Spacer(),
            pw.Divider(),
            pw.Text('Documento generado por Estribado - Software Agropecuario', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    String nombreArchivo = 'Honorario-${honorario.clienteNombre}-${honorario.numeroReceta ?? 0}.pdf';
    nombreArchivo = nombreArchivo.replaceAll(RegExp(r'[^\w\s\-\.]'), '');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Te envío el honorario: $nombreArchivo',
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
