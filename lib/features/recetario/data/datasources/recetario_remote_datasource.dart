import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../domain/entities/receta.dart';
import '../../../../core/services/excel_graph_service.dart';

/// DataSource para operaciones remotas (PDF y Excel)
class RecetarioRemoteDataSource {
  final ExcelGraphService? excelService;

  RecetarioRemoteDataSource({this.excelService});
  Future<pw.Document> _crearDocumentoPdf(Receta receta) async {
    String numeroFormateado = (receta.numeroReceta ?? 1).toString().padLeft(5, '0');

    // Crear título dinámico
    String titulo = "${receta.cliente}-${receta.establecimiento}-Nro$numeroFormateado";
    titulo = titulo.replaceAll(RegExp(r'[^\w\s\-\.]'), '');

    final doc = pw.Document(title: titulo);

    // Cargar Logo
    pw.MemoryImage? logoImage;
    try {
      final imageBytes = await rootBundle.load('assets/logo.jpg');
      logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (e) {
      print("No se encontró el logo: $e");
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER CON LOGO Y NÚMERO
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  logoImage != null
                      ? pw.Image(logoImage, width: 60, height: 60)
                      : pw.Text(
                          "RECETA AGRONÓMICA",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "ORDEN DE TRABAJO",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      pw.Text(
                        "N° $numeroFormateado",
                        style: pw.TextStyle(
                          color: PdfColors.red,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              _buildPdfRow(
                "Fecha:",
                DateFormat('dd/MM/yyyy').format(receta.fecha),
                "Cliente:",
                receta.cliente,
              ),
              _buildPdfRow(
                "Cantidad Has:",
                receta.cantidadHas.toString(),
                "Ident. Lote:",
                receta.lote,
              ),
              _buildPdfRow(
                "Cultivo:",
                receta.cultivo,
                "Establecimiento:",
                receta.establecimiento,
              ),
              _buildPdfRow("Contratista:", receta.contratista, "", ""),
              pw.SizedBox(height: 20),

              // TABLA
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: const [
                  'Dosis por Ha',
                  'Unidad',
                  'Producto',
                  'Total a Utilizar',
                ],
                data: receta.productos
                    .map(
                      (p) => [
                        p.dosisPorHa.toString(),
                        p.unidad,
                        p.nombre,
                        "${p.total} ${p.unidadTotal}",
                      ],
                    )
                    .toList(),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(4),
                  3: pw.FlexColumnWidth(3),
                },
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                "OBSERVACIONES:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Container(
                width: double.infinity,
                height: 100,
                padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Text(receta.observaciones),
              ),
            ],
          );
        },
      ),
    );
    return doc;
  }

  pw.Widget _buildPdfRow(
    String label1,
    String val1,
    String label2,
    String val2,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "$label1 ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: val1),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "$label2 ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: val2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generatePdf(Receta receta) async {
    final doc = await _crearDocumentoPdf(receta);
    
    String numeroFormateado = (receta.numeroReceta ?? 1).toString().padLeft(5, '0');
    String nombreArchivo = "${receta.cliente}-${receta.establecimiento}-${receta.contratista}-Nro$numeroFormateado.pdf";
    nombreArchivo = nombreArchivo.replaceAll(RegExp(r'[^\w\s\-\.]'), '');

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: nombreArchivo,
    );
  }

  Future<void> sharePdf(Receta receta) async {
    final doc = await _crearDocumentoPdf(receta);
    final bytes = await doc.save();

    String numeroFormateado = (receta.numeroReceta ?? 1).toString().padLeft(5, '0');
    String nombreArchivo = "${receta.cliente}-${receta.establecimiento}-${receta.contratista}-Nro$numeroFormateado.pdf";
    nombreArchivo = nombreArchivo.replaceAll(RegExp(r'[^\w\s\-\.]'), '');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Te envío la receta: $nombreArchivo',
    );
  }

  Future<void> exportToExcel(List<Receta> recetas) async {
    if (excelService == null) {
      throw Exception('ExcelService no está configurado');
    }
    await excelService!.uploadRecetasToExcel(recetas);
  }
}
