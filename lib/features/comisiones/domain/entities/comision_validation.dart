/// Validaciones para la entidad Comision
class ComisionValidation {
  static String? validateClienteNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del cliente es requerido';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateClienteCuit(String? value) {
    // CUIT es opcional
    if (value == null || value.isEmpty) {
      return null;
    }
    
    // Remover guiones para validación
    final cuitClean = value.replaceAll('-', '');
    
    if (cuitClean.length != 11) {
      return 'El CUIT/CUIL debe tener 11 dígitos';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cuitClean)) {
      return 'El CUIT/CUIL solo debe contener números';
    }
    
    return null;
  }

  static String? validateProductoNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del producto es requerido';
    }
    return null;
  }

  static String? validateCantidad(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }
    
    final cantidad = double.tryParse(value);
    if (cantidad == null) {
      return 'Ingrese un número válido';
    }
    
    if (cantidad <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    
    return null;
  }

  static String? validatePrecio(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    
    final precio = double.tryParse(value);
    if (precio == null) {
      return 'Ingrese un precio válido';
    }
    
    if (precio <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    
    return null;
  }

  static String? validatePorcentaje(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    
    final porcentaje = double.tryParse(value);
    if (porcentaje == null) {
      return 'Ingrese un porcentaje válido';
    }
    
    if (porcentaje < 0 || porcentaje > 100) {
      return 'El porcentaje debe estar entre 0 y 100';
    }
    
    return null;
  }

  /// Formatea un CUIT con guiones: 20-12345678-9
  static String formatCuit(String cuit) {
    final clean = cuit.replaceAll('-', '');
    if (clean.length == 11) {
      return '${clean.substring(0, 2)}-${clean.substring(2, 10)}-${clean.substring(10)}';
    }
    return cuit;
  }
}
