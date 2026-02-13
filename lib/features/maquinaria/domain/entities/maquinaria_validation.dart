/// Validaciones para la entidad Maquinaria
class MaquinariaValidation {
  static String? validateClienteNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del cliente es requerido';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateTipoServicio(String? value) {
    if (value == null || value.isEmpty) {
      return 'El tipo de servicio es requerido';
    }
    if (value.length < 3) {
      return 'El tipo de servicio debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateSuperficie(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio
    }
    final superficie = double.tryParse(value);
    if (superficie == null) {
      return 'Ingrese un número válido';
    }
    if (superficie < 0) {
      return 'La superficie no puede ser negativa';
    }
    return null;
  }

  static String? validateCostoPorUnidad(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio
    }
    final costo = double.tryParse(value);
    if (costo == null) {
      return 'Ingrese un número válido';
    }
    if (costo < 0) {
      return 'El costo no puede ser negativo';
    }
    return null;
  }

  static String? validateDescripcion(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio para maquinaria
    }
    return null;
  }
}
