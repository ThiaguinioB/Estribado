import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../features/comisiones/domain/entities/comision.dart';
import 'microsoft_auth_service.dart';

/// Servicio para generar archivos Excel y subirlos a Microsoft OneDrive
class ExcelGraphService {
  final MicrosoftAuthService authService;

  ExcelGraphService({required this.authService});

  /// Genera un archivo Excel con las comisiones
  Future<File> generateExcelFile(List<Comision> comisiones) async {
    final excel = Excel.createExcel();
    final sheet = excel['Comisiones'];

    // Headers
    sheet.appendRow([
      TextCellValue('N° Operación'),
      TextCellValue('Fecha'),
      TextCellValue('Cliente'),
      TextCellValue('CUIT'),
      TextCellValue('Producto'),
      TextCellValue('Tipo'),
      TextCellValue('Cantidad'),
      TextCellValue('Precio Unit.'),
      TextCellValue('Subtotal'),
      TextCellValue('IVA %'),
      TextCellValue('Monto IVA'),
      TextCellValue('Total'),
      TextCellValue('Comisión %'),
      TextCellValue('Valor Comisión'),
      TextCellValue('Estado'),
    ]);

    // Data rows
    for (var comision in comisiones) {
      sheet.appendRow([
        IntCellValue(comision.numeroOperacion ?? 0),
        TextCellValue(comision.fecha.toString().split(' ')[0]),
        TextCellValue(comision.clienteNombre),
        TextCellValue(comision.clienteCuit),
        TextCellValue(comision.productoNombre),
        TextCellValue(comision.tipoProducto),
        DoubleCellValue(comision.cantidad),
        DoubleCellValue(comision.precioUnitario),
        DoubleCellValue(comision.subtotalNeto),
        DoubleCellValue(comision.porcentajeIva),
        DoubleCellValue(comision.montoIva),
        DoubleCellValue(comision.totalConImpuestos),
        DoubleCellValue(comision.porcentajeComision),
        DoubleCellValue(comision.valorComision),
        TextCellValue(comision.estado),
      ]);
    }

    // Guardar archivo localmente
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/comisiones_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.encode()!;
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    return file;
  }

  /// Sube el archivo Excel a Microsoft OneDrive
  Future<void> uploadComisionesToExcel(List<Comision> comisiones) async {
    try {
      // Generar archivo Excel
      final file = await generateExcelFile(comisiones);

      // Obtener token de autenticación
      final token = await authService.getAccessToken();
      
      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      // TODO: Implementar subida a OneDrive usando Microsoft Graph API
      // final response = await http.put(
      //   Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:/Estribado/${file.path}:/content'),
      //   headers: {'Authorization': 'Bearer $token'},
      //   body: await file.readAsBytes(),
      // );

      print('Excel generado localmente: ${file.path}');
      // await file.delete(); // Descomentar después de subir
    } catch (e) {
      throw Exception('Error al generar/subir Excel: $e');
    }
  }
}
