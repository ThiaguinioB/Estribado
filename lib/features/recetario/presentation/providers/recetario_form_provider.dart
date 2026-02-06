import 'package:flutter/material.dart';
import '../../domain/entities/receta.dart';
import '../../domain/entities/producto_receta.dart';
import '../../domain/entities/receta_validation.dart';
import '../../data/repositories/recetario_repository_impl.dart';

class RecetarioFormProvider with ChangeNotifier {
  final RecetarioRepositoryImpl repository;

  RecetarioFormProvider({required this.repository});

  // Estado del formulario
  int? _numeroReceta;
  DateTime _fecha = DateTime.now();
  String _cliente = '';
  double _cantidadHas = 0;
  String _lote = '';
  String _cultivo = '';
  String _establecimiento = '';
  String _contratista = '';
  String _observaciones = '';
  List<ProductoReceta> _productos = [];

  // Lista de recetas
  List<Receta> _recetas = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int? get numeroReceta => _numeroReceta;
  DateTime get fecha => _fecha;
  String get cliente => _cliente;
  double get cantidadHas => _cantidadHas;
  String get lote => _lote;
  String get cultivo => _cultivo;
  String get establecimiento => _establecimiento;
  String get contratista => _contratista;
  String get observaciones => _observaciones;
  List<ProductoReceta> get productos => _productos;
  List<Receta> get recetas => _recetas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // NÚMERO DE RECETA
  Future<void> cargarNumeroReceta() async {
    _numeroReceta = await repository.getNextNumeroReceta();
    notifyListeners();
  }

  void incrementarNumero() {
    if (_numeroReceta != null) {
      _numeroReceta = _numeroReceta! + 1;
      notifyListeners();
    }
  }

  void decrementarNumero() {
    if (_numeroReceta != null && _numeroReceta! > 1) {
      _numeroReceta = _numeroReceta! - 1;
      notifyListeners();
    }
  }

  // SETTERS
  void setFecha(DateTime fecha) {
    _fecha = fecha;
    notifyListeners();
  }

  void setCliente(String cliente) {
    _cliente = cliente;
    notifyListeners();
  }

  void setCantidadHas(double cantidad) {
    _cantidadHas = cantidad;
    // Recalcular totales de productos
    _recalcularTotales();
    notifyListeners();
  }

  void setLote(String lote) {
    _lote = lote;
    notifyListeners();
  }

  void setCultivo(String cultivo) {
    _cultivo = cultivo;
    notifyListeners();
  }

  void setEstablecimiento(String establecimiento) {
    _establecimiento = establecimiento;
    notifyListeners();
  }

  void setContratista(String contratista) {
    _contratista = contratista;
    notifyListeners();
  }

  void setObservaciones(String obs) {
    _observaciones = obs;
    notifyListeners();
  }

  // PRODUCTOS
  void agregarProducto(ProductoReceta producto) {
    _productos.add(producto);
    notifyListeners();
  }

  void eliminarProducto(int index) {
    _productos.removeAt(index);
    notifyListeners();
  }

  void actualizarProducto(int index, ProductoReceta producto) {
    _productos[index] = producto;
    notifyListeners();
  }

  void _recalcularTotales() {
    _productos = _productos.map((p) {
      final total = RecetaValidation.calcularTotalDesdeDosis(
        p.dosisPorHa,
        _cantidadHas,
        p.unidad,
      );
      final unidadTotal = RecetaValidation.obtenerUnidadConvertida(p.unidad, total);
      return p.copyWith(total: total, unidadTotal: unidadTotal);
    }).toList();
  }

  // CRUD RECETAS
  Future<void> cargarRecetas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recetas = await repository.getAllRecetas();
      // Ordenar por número descendente
      _recetas.sort((a, b) => (b.numeroReceta ?? 0).compareTo(a.numeroReceta ?? 0));
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> guardarReceta() async {
    try {
      final receta = Receta(
        numeroReceta: _numeroReceta,
        fecha: _fecha,
        cliente: _cliente,
        cantidadHas: _cantidadHas,
        lote: _lote,
        cultivo: _cultivo,
        establecimiento: _establecimiento,
        contratista: _contratista,
        observaciones: _observaciones,
        productos: _productos,
      );

      await repository.saveReceta(receta);
      // Actualizar el número persistido para la próxima receta
      await repository.setNumeroReceta((_numeroReceta ?? 0) + 1);
      await cargarNumeroReceta(); // Cargar siguiente número
      limpiarFormulario();
      await cargarRecetas(); // Refrescar lista
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarReceta(int numeroReceta) async {
    try {
      final receta = Receta(
        numeroReceta: numeroReceta,
        fecha: _fecha,
        cliente: _cliente,
        cantidadHas: _cantidadHas,
        lote: _lote,
        cultivo: _cultivo,
        establecimiento: _establecimiento,
        contratista: _contratista,
        observaciones: _observaciones,
        productos: _productos,
      );

      await repository.updateReceta(receta);
      limpiarFormulario();
      await cargarRecetas();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarReceta(int numeroReceta) async {
    try {
      await repository.deleteReceta(numeroReceta);
      await cargarRecetas();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarRecetaParaEditar(int numeroReceta) async {
    try {
      final receta = await repository.getRecetaById(numeroReceta);
      _numeroReceta = receta.numeroReceta;
      _fecha = receta.fecha;
      _cliente = receta.cliente;
      _cantidadHas = receta.cantidadHas;
      _lote = receta.lote;
      _cultivo = receta.cultivo;
      _establecimiento = receta.establecimiento;
      _contratista = receta.contratista;
      _observaciones = receta.observaciones;
      _productos = List.from(receta.productos);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // PDF
  Future<void> generarPdf(Receta receta) async {
    try {
      await repository.generarPdf(receta);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> compartirPdf(Receta receta) async {
    try {
      await repository.compartirPdf(receta);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> exportarVariasRecetasAExcel() async {
    if (_recetas.isEmpty) {
      _errorMessage = 'No hay recetas para exportar';
      notifyListeners();
      return;
    }

    try {
      await repository.exportarVariasRecetasAExcel(_recetas);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void limpiarFormulario() {
    _numeroReceta = null;
    _fecha = DateTime.now();
    _cliente = '';
    _cantidadHas = 0;
    _lote = '';
    _cultivo = '';
    _establecimiento = '';
    _contratista = '';
    _observaciones = '';
    _productos = [];
    _errorMessage = null;
    notifyListeners();
  }

  String? validarFormulario() {
    if (_cliente.isEmpty) return 'Ingrese el cliente';
    if (_establecimiento.isEmpty) return 'Ingrese el establecimiento';
    if (_contratista.isEmpty) return 'Ingrese el contratista';
    if (_cantidadHas <= 0) return 'Ingrese cantidad de hectáreas válida';
    if (_lote.isEmpty) return 'Ingrese identificación del lote';
    if (_cultivo.isEmpty) return 'Ingrese el cultivo';
    if (_productos.isEmpty) return 'Agregue al menos un producto';
    return null;
  }
}
