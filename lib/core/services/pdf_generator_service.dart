import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/comisiones/domain/entities/comision.dart';
import '../../features/honorarios/domain/entities/honorario.dart';
import '../../features/maquinaria/domain/entities/maquinaria.dart';

/// Servicio para generar archivos PDF de comisiones y honorarios
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
            if (comision.proveedor.isNotEmpty)
              _buildInfoRow('Proveedor:', comision.proveedor),
            _buildInfoRow('Fecha:', dateFormat.format(comision.fecha)),
            if (comision.numeroOperacion != null)
              _buildInfoRow('N° Operación:', comision.numeroOperacion.toString()),
            pw.SizedBox(height: 20),

            // Información del producto
            pw.Text('DETALLE DEL PRODUCTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Producto:', comision.productoNombre),
            _buildInfoRow('Tipo:', comision.tipoProducto),
            _buildInfoRow('Cantidad:', '${comision.cantidad.toStringAsFixed(2)} ${comision.unidad}'),
            _buildInfoRow('Precio Unitario:', '\$ ${_formatearMiles(comision.precioUnitario)}'),
            pw.SizedBox(height: 20),

            // Cálculos
            pw.Text('CÁLCULOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Subtotal Neto:', '\$ ${_formatearMiles(comision.subtotalNeto)}'),
            _buildInfoRow('IVA (${comision.porcentajeIva}%):', '\$ ${_formatearMiles(comision.montoIva)}'),
            _buildInfoRow(
              'TOTAL CON IMPUESTOS:',
              '\$ ${_formatearMiles(comision.totalConImpuestos)}',
              isBold: true,
            ),
            pw.SizedBox(height: 10),
            _buildInfoRow(
              'Comisión (${comision.porcentajeComision}%):',
              '\$ ${_formatearMiles(comision.valorComision)}',
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

  /// Genera el PDF de comisión y retorna los bytes para compartir
  Future<List<int>> generateComisionPdfBytes(Comision comision) async {
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
                'COMPROBANTE DE COMISIÓN',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('DATOS DEL CLIENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Cliente:', comision.clienteNombre),
            _buildInfoRow('CUIT:', comision.clienteCuit),
            if (comision.proveedor.isNotEmpty)
              _buildInfoRow('Proveedor:', comision.proveedor),
            _buildInfoRow('Fecha:', dateFormat.format(comision.fecha)),
            if (comision.numeroOperacion != null)
              _buildInfoRow('N° Operación:', comision.numeroOperacion.toString()),
            pw.SizedBox(height: 20),
            pw.Text('DETALLE DEL PRODUCTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Producto:', comision.productoNombre),
            _buildInfoRow('Tipo:', comision.tipoProducto),
            _buildInfoRow('Cantidad:', '${comision.cantidad.toStringAsFixed(2)} ${comision.unidad}'),
            _buildInfoRow('Precio Unitario:', '\$ ${_formatearMiles(comision.precioUnitario)}'),
            pw.SizedBox(height: 20),
            pw.Text('CÁLCULOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Subtotal Neto:', '\$ ${_formatearMiles(comision.subtotalNeto)}'),
            _buildInfoRow('IVA (${comision.porcentajeIva}%):', '\$ ${_formatearMiles(comision.montoIva)}'),
            _buildInfoRow('TOTAL CON IMPUESTOS:', '\$ ${_formatearMiles(comision.totalConImpuestos)}', isBold: true),
            pw.SizedBox(height: 10),
            _buildInfoRow('Comisión (${comision.porcentajeComision}%):', '\$ ${_formatearMiles(comision.valorComision)}', isBold: true, color: PdfColors.green),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text('Estado: ${comision.estado}'),
            ),
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

    return pdf.save();
  }

  /// Formatea un número con separadores de miles (punto) y decimales (coma)
  static String _formatearMiles(double valor) {
    final formatter = NumberFormat('#,##0.00', 'es_AR');
    return formatter.format(valor);
  }

  Future<void> generateHonorarioPdf(Honorario honorario) async {
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
                'HONORARIOS PROFESIONALES',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Información general
            pw.Text('DATOS GENERALES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Cliente:', honorario.clienteNombre),
            _buildInfoRow('Fecha:', dateFormat.format(honorario.fecha)),
            if (honorario.numeroOperacion != null)
              _buildInfoRow('N° Operación:', honorario.numeroOperacion.toString()),
            if (honorario.numeroReceta != null)
              _buildInfoRow('Nro. de Receta:', honorario.numeroReceta.toString()),
            pw.SizedBox(height: 20),

            // Detalle de costos
            pw.Text('DETALLE DE COSTOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            // Km Recorridos
            _buildInfoRow('Km. Recorridos:', '${honorario.kmRecorridos.toStringAsFixed(1)} km'),
            if (honorario.costoKm > 0) ...[
              _buildInfoRow(
                'Costo por Km (${honorario.monedaKm}):',
                '${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.costoKm.toStringAsFixed(2)}',
              ),
              _buildInfoRow(
                'Subtotal Km:',
                '${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.subtotalKm.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
            pw.SizedBox(height: 8),
            // Hora Técnica
            _buildInfoRow('Hora Técnica:', '${honorario.horaTecnica.toStringAsFixed(1)} hs'),
            if (honorario.costoHora > 0) ...[
              _buildInfoRow(
                'Costo por Hora (${honorario.monedaHora}):',
                '${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.costoHora.toStringAsFixed(2)}',
              ),
              _buildInfoRow(
                'Subtotal Horas:',
                '${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.subtotalHora.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
            pw.SizedBox(height: 8),
            // Plus Técnico
            if (honorario.plusTecnico > 0) ...[
              _buildInfoRow(
                'Plus Técnico (${honorario.monedaPlus}):',
                '${Honorario.simboloMoneda(honorario.monedaPlus)} ${honorario.plusTecnico.toStringAsFixed(2)}',
              ),
              if (honorario.descripcionPlus.isNotEmpty)
                _buildInfoRow('Descripción Plus:', honorario.descripcionPlus),
            ],
            pw.SizedBox(height: 10),
            _buildInfoRow(
              'TOTAL HONORARIO:',
              honorario.totalFormateado,
              isBold: true,
              color: PdfColors.green,
            ),
            pw.SizedBox(height: 20),

            // Descripción
            pw.Text('DESCRIPCIÓN DE LA TAREA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text(
                honorario.descripcionTarea.isNotEmpty
                    ? honorario.descripcionTarea
                    : 'Sin descripción',
              ),
            ),
            pw.SizedBox(height: 20),

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

  Future<void> generateMaquinariaPdf(Maquinaria maquinaria) async {
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
                'SERVICIO DE MAQUINARIA',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Información general
            pw.Text('DATOS GENERALES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Cliente:', maquinaria.clienteNombre),
            _buildInfoRow('Fecha:', dateFormat.format(maquinaria.fecha)),
            if (maquinaria.numeroOperacion != null)
              _buildInfoRow('N° Operación:', maquinaria.numeroOperacion.toString()),
            _buildInfoRow('Tipo de Servicio:', maquinaria.tipoServicio),
            pw.SizedBox(height: 20),

            // Detalle del servicio
            pw.Text('DETALLE DEL SERVICIO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInfoRow('Superficie:', '${maquinaria.superficie.toStringAsFixed(2)} ${maquinaria.unidadSuperficie}'),
            if (maquinaria.costoPorUnidad > 0) ...[
              _buildInfoRow(
                'Costo por ${maquinaria.unidadSuperficie}:',
                '${Maquinaria.simboloUnidadCosto(maquinaria.unidadCosto)} ${maquinaria.costoPorUnidad.toStringAsFixed(2)}',
              ),
              _buildInfoRow(
                'TOTAL:',
                maquinaria.totalFormateado,
                isBold: true,
                color: PdfColors.green,
              ),
            ],
            pw.SizedBox(height: 20),

            // Observaciones
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
