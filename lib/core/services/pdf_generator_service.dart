import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/comisiones/domain/entities/comision.dart';

/// Servicio para generar archivos PDF de comisiones
class PdfGeneratorService {
  
  Future<void> generateComisionPdf(Comision comision) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'COMPROBANTE DE COMISIÓN',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Información del cliente
            pw.Text('DATOS DEL CLIENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Cliente:', comision.clienteNombre),
            _buildInfoRow('CUIT:', comision.clienteCuit),
            _buildInfoRow('Fecha:', dateFormat.format(comision.fecha)),
            if (comision.numeroOperacion != null)
              _buildInfoRow('N° Operación:', comision.numeroOperacion.toString()),
            pw.SizedBox(height: 20),

            // Información del producto
            pw.Text('DETALLE DEL PRODUCTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Producto:', comision.productoNombre),
            _buildInfoRow('Tipo:', comision.tipoProducto),
            _buildInfoRow('Cantidad:', comision.cantidad.toStringAsFixed(2)),
            _buildInfoRow('Precio Unitario:', '\$ ${comision.precioUnitario.toStringAsFixed(2)}'),
            pw.SizedBox(height: 20),

            // Cálculos
            pw.Text('CÁLCULOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Subtotal Neto:', '\$ ${comision.subtotalNeto.toStringAsFixed(2)}'),
            _buildInfoRow('IVA (${comision.porcentajeIva}%):', '\$ ${comision.montoIva.toStringAsFixed(2)}'),
            _buildInfoRow(
              'TOTAL CON IMPUESTOS:',
              '\$ ${comision.totalConImpuestos.toStringAsFixed(2)}',
              isBold: true,
            ),
            pw.SizedBox(height: 10),
            _buildInfoRow(
              'Comisión (${comision.porcentajeComision}%):',
              '\$ ${comision.valorComision.toStringAsFixed(2)}',
              isBold: true,
              color: PdfColors.green,
            ),
            pw.SizedBox(height: 20),

            // Estado
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text('Estado: ${comision.estado}'),
            ),

            pw.Spacer(),

            // Footer
            pw.Divider(),
            pw.Text(
              'Documento generado por Estribado - Software Agropecuario',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );

    // Mostrar preview y permitir compartir/imprimir
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget _buildInfoRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
