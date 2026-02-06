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

  /// Descarga el archivo Excel existente desde OneDrive
  Future<Excel?> _downloadExistingExcel(String token, String fileName) async {
    try {
      final url = Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:/Estribado/$fileName:/content');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Archivo Excel descargado desde OneDrive');
        return Excel.decodeBytes(response.bodyBytes);
      } else if (response.statusCode == 404) {
        print('ℹ️ Archivo no existe, se creará uno nuevo');
        return null;
      } else {
        print('⚠️ Error al descargar Excel: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error al descargar Excel: $e');
      return null;
    }
  }

  /// Actualiza el archivo Excel con las comisiones en OneDrive
  Future<void> uploadComisionesToExcel(List<Comision> comisiones) async {
    try {
      // Obtener token de autenticación
      final token = await authService.getAccessToken();
      
      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación. Por favor, inicie sesión en Microsoft.');
      }

      // Nombre fijo del archivo
      const fileName = 'Comisiones.xlsx';
      
      // Intentar descargar el archivo existente
      Excel excel = await _downloadExistingExcel(token, fileName) ?? Excel.createExcel();
      
      // Eliminar la hoja si existe y crear una nueva
      if (excel.tables.containsKey('Comisiones')) {
        excel.delete('Comisiones');
      }
      
      // Crear la hoja
      Sheet sheet = excel['Comisiones'];

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

      // Data rows - agregar todas las comisiones
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

      // Codificar el archivo
      final fileBytes = excel.encode()!;
      
      // Subir a OneDrive (sobreescribe el archivo existente)
      final url = Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:/Estribado/$fileName:/content');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        body: fileBytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Excel actualizado exitosamente en OneDrive: Estribado/$fileName');
        print('📊 Total de comisiones: ${comisiones.length}');
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

  /// Genera un archivo Excel con las recetas (deprecado - solo para compatibilidad)
  Future<File> generateRecetasExcelFile(List<Receta> recetas) async {
    final excel = Excel.createExcel();
    final sheet = excel['Recetas'];

    // Headers - con columnas separadas para productos
    sheet.appendRow([
      TextCellValue('N° Receta'),
      TextCellValue('Fecha'),
      TextCellValue('Cliente'),
      TextCellValue('Establecimiento'),
      TextCellValue('Contratista'),
      TextCellValue('Hectáreas'),
      TextCellValue('Lote'),
      TextCellValue('Cultivo'),
      TextCellValue('Nombre comercial o principio activo'),
      TextCellValue('Dosis/Ha'),
      TextCellValue('Unidad'),
      TextCellValue('Total'),
      TextCellValue('Unidad Total'),
      TextCellValue('Observaciones'),
    ]);

    // Data rows - una fila por cada producto
    for (var receta in recetas) {
      if (receta.productos.isEmpty) {
        // Si no hay productos, crear una fila con los datos de la receta
        sheet.appendRow([
          IntCellValue(receta.numeroReceta ?? 0),
          TextCellValue(receta.fecha.toString().split(' ')[0]),
          TextCellValue(receta.cliente),
          TextCellValue(receta.establecimiento),
          TextCellValue(receta.contratista),
          DoubleCellValue(receta.cantidadHas),
          TextCellValue(receta.lote),
          TextCellValue(receta.cultivo),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(receta.observaciones),
        ]);
      } else {
        // Una fila por cada producto, repitiendo los datos de la receta
        for (var producto in receta.productos) {
          sheet.appendRow([
            IntCellValue(receta.numeroReceta ?? 0),
            TextCellValue(receta.fecha.toString().split(' ')[0]),
            TextCellValue(receta.cliente),
            TextCellValue(receta.establecimiento),
            TextCellValue(receta.contratista),
            DoubleCellValue(receta.cantidadHas),
            TextCellValue(receta.lote),
            TextCellValue(receta.cultivo),
            TextCellValue(producto.nombre),
            DoubleCellValue(producto.dosisPorHa),
            TextCellValue(producto.unidad),
            DoubleCellValue(producto.total),
            TextCellValue(producto.unidadTotal),
            TextCellValue(receta.observaciones),
          ]);
        }
      }
    }

    // Guardar archivo localmente
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/recetas_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.encode()!;
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    return file;
  }

  /// Actualiza el archivo Excel con las recetas en OneDrive
  Future<void> uploadRecetasToExcel(List<Receta> recetas) async {
    try {
      // Obtener token de autenticación
      final token = await authService.getAccessToken();
      
      if (token == null) {
        throw Exception('No se pudo obtener el token de autenticación. Por favor, inicie sesión en Microsoft.');
      }

      // Nombre fijo del archivo
      const fileName = 'Recetas.xlsx';
      
      // Intentar descargar el archivo existente
      Excel excel = await _downloadExistingExcel(token, fileName) ?? Excel.createExcel();
      
      // Eliminar la hoja si existe y crear una nueva
      if (excel.tables.containsKey('Recetas')) {
        excel.delete('Recetas');
      }
      
      // Crear la hoja
      Sheet sheet = excel['Recetas'];

      // Headers - con columnas separadas para productos
      sheet.appendRow([
        TextCellValue('N° Receta'),
        TextCellValue('Fecha'),
        TextCellValue('Cliente'),
        TextCellValue('Establecimiento'),
        TextCellValue('Contratista'),
        TextCellValue('Hectáreas'),
        TextCellValue('Lote'),
        TextCellValue('Cultivo'),
        TextCellValue('Nombre comercial o principio activo'),
        TextCellValue('Dosis/Ha'),
        TextCellValue('Unidad'),
        TextCellValue('Total'),
        TextCellValue('Unidad Total'),
        TextCellValue('Observaciones'),
      ]);

      // Data rows - una fila por cada producto
      for (var receta in recetas) {
        if (receta.productos.isEmpty) {
          // Si no hay productos, crear una fila con los datos de la receta
          sheet.appendRow([
            IntCellValue(receta.numeroReceta ?? 0),
            TextCellValue(receta.fecha.toString().split(' ')[0]),
            TextCellValue(receta.cliente),
            TextCellValue(receta.establecimiento),
            TextCellValue(receta.contratista),
            DoubleCellValue(receta.cantidadHas),
            TextCellValue(receta.lote),
            TextCellValue(receta.cultivo),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(receta.observaciones),
          ]);
        } else {
          // Una fila por cada producto, repitiendo los datos de la receta
          for (var producto in receta.productos) {
            sheet.appendRow([
              IntCellValue(receta.numeroReceta ?? 0),
              TextCellValue(receta.fecha.toString().split(' ')[0]),
              TextCellValue(receta.cliente),
              TextCellValue(receta.establecimiento),
              TextCellValue(receta.contratista),
              DoubleCellValue(receta.cantidadHas),
              TextCellValue(receta.lote),
              TextCellValue(receta.cultivo),
              TextCellValue(producto.nombre),
              DoubleCellValue(producto.dosisPorHa),
              TextCellValue(producto.unidad),
              DoubleCellValue(producto.total),
              TextCellValue(producto.unidadTotal),
              TextCellValue(receta.observaciones),
            ]);
          }
        }
      }

      // Codificar el archivo
      final fileBytes = excel.encode()!;
      
      // Subir a OneDrive (sobreescribe el archivo existente)
      final url = Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root:/Estribado/$fileName:/content');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        body: fileBytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Excel de recetas actualizado exitosamente en OneDrive: Estribado/$fileName');
        print('📊 Total de recetas: ${recetas.length}');
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
