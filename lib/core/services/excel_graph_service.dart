import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../features/comisiones/domain/entities/comision.dart';
import '../../features/recetario/domain/entities/receta.dart';
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
        throw Exception('No se pudo obtener el token de autenticación. Por favor, inicie sesión en Microsoft.');
      }

      // Nombre del archivo
      final fileName = 'Comisiones_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      // Subir a OneDrive en la carpeta "Estribado/Comisiones"
      final url = Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:/Estribado/Comisiones/$fileName:/content');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        body: await file.readAsBytes(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Excel subido exitosamente a OneDrive: Estribado/Comisiones/$fileName');
        // Eliminar archivo local después de subir
        await file.delete();
      } else {
        print('❌ Error al subir a OneDrive: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        throw Exception('Error al subir Excel a OneDrive: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error al generar/subir Excel: $e');
      throw Exception('Error al generar/subir Excel: $e');
    }
  }

  /// Genera un archivo Excel con las recetas
  Future<File> generateRecetasExcelFile(List<Receta> recetas) async {
    final excel = Excel.createExcel();
    final sheet = excel['Recetas'];

    // Headers
    sheet.appendRow([
      TextCellValue('N° Receta'),
      TextCellValue('Fecha'),
      TextCellValue('Cliente'),
      TextCellValue('Establecimiento'),
      TextCellValue('Contratista'),
      TextCellValue('Hectáreas'),
      TextCellValue('Lote'),
      TextCellValue('Cultivo'),
      TextCellValue('Productos'),
      TextCellValue('Observaciones'),
    ]);

    // Data rows
    for (var receta in recetas) {
      // Concatenar productos
      final productosStr = receta.productos
          .map((p) => '${p.nombre} (${p.dosisPorHa} ${p.unidad}/Ha → ${p.total} ${p.unidadTotal})')
          .join('; ');

      sheet.appendRow([
        IntCellValue(receta.numeroReceta ?? 0),
        TextCellValue(receta.fecha.toString().split(' ')[0]),
        TextCellValue(receta.cliente),
        TextCellValue(receta.establecimiento),
        TextCellValue(receta.contratista),
        DoubleCellValue(receta.cantidadHas),
        TextCellValue(receta.lote),
        TextCellValue(receta.cultivo),
        TextCellValue(productosStr),
        TextCellValue(receta.observaciones),
      ]);
    }

    // Guardar archivo localmente
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recetas_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.encode()!;
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    return file;
  }

  /// Sube recetas a Excel
  Future<void> uploadRecetasToExcel(List<Receta> recetas) async {
    try {
      // Generar archivo Excel
      final file = await generateRecetasExcelFile(recetas);

      // Obtener token de autenticación
      final token = await authService.getAccessToken();
      
      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación. Por favor, inicie sesión en Microsoft.');
      }

      // Nombre del archivo
      final fileName = 'Recetas_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      // Subir a OneDrive en la carpeta "Estribado/Recetario"
      final url = Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:/Estribado/Recetario/$fileName:/content');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        body: await file.readAsBytes(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Excel de recetas subido exitosamente a OneDrive: Estribado/Recetario/$fileName');
        // Eliminar archivo local después de subir
        await file.delete();
      } else {
        print('❌ Error al subir recetas a OneDrive: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        throw Exception('Error al subir Excel de recetas a OneDrive: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error al generar/subir Excel de recetas: $e');
      throw Exception('Error al generar/subir Excel de recetas: $e');
    }
  }
}
