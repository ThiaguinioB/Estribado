/// Validaciones para la entidad Honorario
class HonorarioValidation {
  static String? validateClienteNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre del cliente es requerido';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateNumeroReceta(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio
    }
    final numero = int.tryParse(value);
    if (numero == null) {
      return 'Ingrese un número válido';
    }
    if (numero <= 0) {
      return 'El número de receta debe ser mayor a 0';
    }
    return null;
  }

  static String? validateKmRecorridos(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio
    }
    final km = double.tryParse(value);
    if (km == null) {
      return 'Ingrese un número válido';
    }
    if (km < 0) {
      return 'Los kilómetros no pueden ser negativos';
    }
    return null;
  }

  static String? validateCostoUnitario(String? value) {
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

  static String? validateHoraTecnica(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio
    }
    final hora = double.tryParse(value);
    if (hora == null) {
      return 'Ingrese un número válido';
    }
    if (hora < 0) {
      return 'El valor no puede ser negativo';
    }
    return null;
  }

  static String? validatePlusTecnico(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No es obligatorio
    }
    final plus = double.tryParse(value);
    if (plus == null) {
      return 'Ingrese un número válido';
    }
    if (plus < 0) {
      return 'El valor no puede ser negativo';
    }
    return null;
  }

  static String? validateDescripcion(String? value) {
    if (value == null || value.isEmpty) {
      return 'La descripción de la tarea es requerida';
    }
    if (value.length < 5) {
      return 'La descripción debe tener al menos 5 caracteres';
    }
    return null;
  }
}
