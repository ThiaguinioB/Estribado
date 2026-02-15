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
    
    // NO convertir aquí, solo calcular el total en la unidad original
    // La conversión se mostrará en la unidad de presentación
    
    // Redondear a 0 decimales
    return double.parse(total.toStringAsFixed(0));
  }

  /// Calcular dosis desde total
  static double calcularDosisDesdeTot(double total, double hectareas) {
    if (hectareas <= 0) return 0.0;
    double dosis = total / hectareas;
    // Redondear a 3 decimales
    return double.parse(dosis.toStringAsFixed(3));
  }

  /// Obtener unidad después de conversión para PRESENTACIÓN solamente
  static String obtenerUnidadConvertida(String unidadOriginal, double total) {
    if (unidadOriginal == 'cc' && total >= 1000) {
      return 'L';
    } else if (unidadOriginal == 'g' && total >= 1000) {
      return 'Kg';
    } else if (unidadOriginal == 'lts' && total >= 1000) {
      return 'lts'; // Mantener en litros (o usar 'm³' si prefieres)
    }
    // kg y unidades permanecen sin cambios
    return unidadOriginal;
  }
  
  /// Obtener el valor convertido para PRESENTACIÓN solamente
  static double obtenerValorConvertido(String unidadOriginal, double total) {
    if (unidadOriginal == 'cc' && total >= 1000) {
      return total / 1000; // cc → L
    } else if (unidadOriginal == 'g' && total >= 1000) {
      return total / 1000; // g → Kg
    }
    return total;
  }
}
