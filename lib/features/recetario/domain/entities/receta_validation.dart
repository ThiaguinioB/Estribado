/// Validaciones para la entidad Receta
class RecetaValidation {
  static String? validateCliente(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del cliente es requerido';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateCantidadHas(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad de hectáreas es requerida';
    }
    
    final cantidad = double.tryParse(value.replaceAll(',', '.'));
    if (cantidad == null) {
      return 'Ingrese un número válido';
    }
    
    if (cantidad <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    
    return null;
  }

  static String? validateLote(String? value) {
    if (value == null || value.isEmpty) {
      return 'La identificación del lote es requerida';
    }
    return null;
  }

  static String? validateCultivo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El cultivo es requerido';
    }
    return null;
  }

  static String? validateEstablecimiento(String? value) {
    if (value == null || value.isEmpty) {
      return 'El establecimiento es requerido';
    }
    return null;
  }

  static String? validateContratista(String? value) {
    if (value == null || value.isEmpty) {
      return 'El contratista es requerido';
    }
    return null;
  }

  static String? validateProductoNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del producto es requerido';
    }
    return null;
  }

  static String? validateDosis(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dosis es requerida';
    }
    
    final dosis = double.tryParse(value.replaceAll(',', '.'));
    if (dosis == null) {
      return 'Ingrese un número válido';
    }
    
    if (dosis <= 0) {
      return 'La dosis debe ser mayor a 0';
    }
    
    return null;
  }

  static double parsearNumero(String texto) {
    String normalizado = texto.replaceAll(',', '.');
    return double.tryParse(normalizado) ?? 0.0;
  }

  /// Calcular total desde dosis
  static double calcularTotalDesdeDosis(
    double dosis,
    double hectareas,
    String unidad,
  ) {
    double total = dosis * hectareas;
    
    // Conversión automática
    if (unidad == 'cc' && total >= 1000) {
      total = total / 1000;
    } else if (unidad == 'g' && total >= 1000) {
      total = total / 1000;
    }
    
    // Redondear a 4 decimales
    return double.parse(total.toStringAsFixed(4));
  }

  /// Calcular dosis desde total
  static double calcularDosisDesdeTot(double total, double hectareas) {
    if (hectareas <= 0) return 0.0;
    double dosis = total / hectareas;
    // Redondear a 4 decimales
    return double.parse(dosis.toStringAsFixed(4));
  }

  /// Obtener unidad después de conversión
  static String obtenerUnidadConvertida(String unidadOriginal, double total) {
    if (unidadOriginal == 'cc' && total >= 1000) {
      return 'L';
    } else if (unidadOriginal == 'g' && total >= 1000) {
      return 'Kg';
    }
    return unidadOriginal;
  }
}
