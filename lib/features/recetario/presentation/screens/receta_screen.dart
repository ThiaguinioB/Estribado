import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/producto_receta.dart';
import '../../domain/entities/receta_validation.dart';
import '../providers/recetario_form_provider.dart';

class RecetaScreen extends StatefulWidget {
  final int? numeroRecetaEditar;

  const RecetaScreen({super.key, this.numeroRecetaEditar});

  @override
  State<RecetaScreen> createState() => _RecetaScreenState();
}

class _RecetaScreenState extends State<RecetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _cantidadHasController = TextEditingController();
  final _loteController = TextEditingController();
  final _cultivoController = TextEditingController();
  final _establecimientoController = TextEditingController();
  final _contratistaController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecetarioFormProvider>();
      
      if (widget.numeroRecetaEditar != null) {
        provider.cargarRecetaParaEditar(widget.numeroRecetaEditar!).then((_) {
          _actualizarControladores(provider);
        });
      } else {
        provider.cargarNumeroReceta();
        provider.limpiarFormulario();
      }
    });
  }

  void _actualizarControladores(RecetarioFormProvider provider) {
    _clienteController.text = provider.cliente;
    _cantidadHasController.text = provider.cantidadHas.toString();
    _loteController.text = provider.lote;
    _cultivoController.text = provider.cultivo;
    _establecimientoController.text = provider.establecimiento;
    _contratistaController.text = provider.contratista;
    _observacionesController.text = provider.observaciones;
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _cantidadHasController.dispose();
    _loteController.dispose();
    _cultivoController.dispose();
    _establecimientoController.dispose();
    _contratistaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.numeroRecetaEditar == null ? 'Nueva Receta' : 'Editar Receta'),
      ),
      body: Consumer<RecetarioFormProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Número de receta
                _buildNumeroRecetaCard(provider),
                const SizedBox(height: 16),

                // Fecha
                _buildFechaCard(provider),
                const SizedBox(height: 16),

                // Cliente
                _buildTextField(
                  controller: _clienteController,
                  label: 'Cliente *',
                  icon: Icons.person,
                  onChanged: provider.setCliente,
                  validator: RecetaValidation.validateCliente,
                ),
                const SizedBox(height: 12),

                // Establecimiento
                _buildTextField(
                  controller: _establecimientoController,
                  label: 'Establecimiento *',
                  icon: Icons.home_work,
                  onChanged: provider.setEstablecimiento,
                  validator: RecetaValidation.validateEstablecimiento,
                ),
                const SizedBox(height: 12),

                // Contratista
                _buildTextField(
                  controller: _contratistaController,
                  label: 'Contratista *',
                  icon: Icons.engineering,
                  onChanged: provider.setContratista,
                  validator: RecetaValidation.validateContratista,
                ),
                const SizedBox(height: 12),

                // Cantidad Has
                _buildTextField(
                  controller: _cantidadHasController,
                  label: 'Cantidad Hectáreas *',
                  icon: Icons.landscape,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => provider.setCantidadHas(double.tryParse(v) ?? 0),
                  validator: RecetaValidation.validateCantidadHas,
                ),
                const SizedBox(height: 12),

                // Lote
                _buildTextField(
                  controller: _loteController,
                  label: 'Identificación del Lote *',
                  icon: Icons.grid_on,
                  onChanged: provider.setLote,
                  validator: RecetaValidation.validateLote,
                ),
                const SizedBox(height: 12),

                // Cultivo
                _buildTextField(
                  controller: _cultivoController,
                  label: 'Cultivo *',
                  icon: Icons.grass,
                  onChanged: provider.setCultivo,
                  validator: RecetaValidation.validateCultivo,
                ),
                const SizedBox(height: 16),

                // PRODUCTOS
                _buildProductosCard(provider),
                const SizedBox(height: 16),

                // Observaciones
                _buildTextField(
                  controller: _observacionesController,
                  label: 'Observaciones',
                  icon: Icons.notes,
                  maxLines: 4,
                  onChanged: provider.setObservaciones,
                ),
                const SizedBox(height: 32),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ElevatedButton.icon(
                        onPressed: _guardarReceta,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton(
                        onPressed: _guardarYCompartir,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Guardar y Compartir',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumeroRecetaCard(RecetarioFormProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Número de Receta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: provider.decrementarNumero,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    provider.numeroReceta?.toString().padLeft(5, '0') ?? '00001',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: provider.incrementarNumero,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaCard(RecetarioFormProvider provider) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Fecha'),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(provider.fecha)),
        onTap: () async {
          final fecha = await showDatePicker(
            context: context,
            initialDate: provider.fecha,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (fecha != null) {
            provider.setFecha(fecha);
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: keyboardType == TextInputType.number 
          ? TextCapitalization.none 
          : TextCapitalization.sentences,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildProductosCard(RecetarioFormProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Productos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  onPressed: () => _mostrarDialogoProducto(context, provider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.productos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay productos agregados'),
                ),
              )
            else
              ...provider.productos.asMap().entries.map((entry) {
                final index = entry.key;
                final producto = entry.value;
                final totalConvertido = RecetaValidation.obtenerValorConvertido(producto.unidad, producto.total);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text(
                      'Dosis: ${producto.dosisPorHa} ${producto.unidad}/Ha\n'
                      'Total: ${totalConvertido.toStringAsFixed(2)} ${producto.unidadTotal}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _mostrarDialogoProducto(
                            context,
                            provider,
                            index: index,
                            producto: producto,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.eliminarProducto(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoProducto(
    BuildContext context,
    RecetarioFormProvider provider, {
    int? index,
    ProductoReceta? producto,
  }) {
    final nombreController = TextEditingController(text: producto?.nombre ?? '');
    final dosisController = TextEditingController(
      text: producto?.dosisPorHa.toString() ?? '',
    );
    String unidadSeleccionada = producto?.unidad ?? 'lts';
    bool editandoDosis = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final calcularTotal = () {
            final dosis = double.tryParse(dosisController.text) ?? 0;
            return RecetaValidation.calcularTotalDesdeDosis(
              dosis,
              provider.cantidadHas,
              unidadSeleccionada,
            );
          };

          final calcularDosis = (double total) {
            return RecetaValidation.calcularDosisDesdeTot(
              total,
              provider.cantidadHas,
            );
          };

          return AlertDialog(
            title: Text(index == null ? 'Agregar Producto' : 'Editar Producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: unidadSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'lts', child: Text('lts (litros)')),
                      DropdownMenuItem(value: 'kg', child: Text('kg (kilogramos)')),
                      DropdownMenuItem(value: 'cc', child: Text('cc (centímetros cúbicos)')),
                      DropdownMenuItem(value: 'g', child: Text('g (gramos)')),
                      DropdownMenuItem(value: 'unidades', child: Text('unidades')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        unidadSeleccionada = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dosisController,
                    decoration: InputDecoration(
                      labelText: editandoDosis 
                          ? 'Dosis por Ha ($unidadSeleccionada)'
                          : 'Total (${RecetaValidation.obtenerUnidadConvertida(unidadSeleccionada, calcularTotal())})',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(editandoDosis ? Icons.swap_horiz : Icons.swap_horiz),
                        onPressed: () {
                          setState(() {
                            if (editandoDosis) {
                              // Cambiar a editar total
                              final total = calcularTotal();
                              if (total > 0) {
                                dosisController.text = total.toStringAsFixed(2);
                              } else {
                                dosisController.clear();
                              }
                            } else {
                              // Cambiar a editar dosis
                              final total = double.tryParse(dosisController.text) ?? 0;
                              final dosis = calcularDosis(total);
                              if (dosis > 0) {
                                dosisController.text = dosis.toStringAsFixed(2);
                              } else {
                                dosisController.clear();
                              }
                            }
                            editandoDosis = !editandoDosis;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    editandoDosis
                        ? 'Total: ${calcularTotal().toStringAsFixed(2)} ${RecetaValidation.obtenerUnidadConvertida(unidadSeleccionada, calcularTotal())}'
                        : 'Dosis: ${calcularDosis(double.tryParse(dosisController.text) ?? 0).toStringAsFixed(2)} $unidadSeleccionada/Ha',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final nombre = nombreController.text;
                  if (nombre.isEmpty) return;

                  double dosis;
                  double total;
                  if (editandoDosis) {
                    dosis = double.tryParse(dosisController.text) ?? 0;
                    total = RecetaValidation.calcularTotalDesdeDosis(
                      dosis,
                      provider.cantidadHas,
                      unidadSeleccionada,
                    );
                  } else {
                    total = double.tryParse(dosisController.text) ?? 0;
                    dosis = calcularDosis(total);
                  }

                  final unidadTotal = RecetaValidation.obtenerUnidadConvertida(
                    unidadSeleccionada,
                    total,
                  );

                  final nuevoProducto = ProductoReceta(
                    nombre: nombre,
                    dosisPorHa: dosis,
                    unidad: unidadSeleccionada,
                    total: total,
                    unidadTotal: unidadTotal,
                  );

                  if (index == null) {
                    provider.agregarProducto(nuevoProducto);
                  } else {
                    provider.actualizarProducto(index, nuevoProducto);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _guardarReceta() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<RecetarioFormProvider>();
      final error = provider.validarFormulario();

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        return;
      }

      bool exito;
      if (widget.numeroRecetaEditar == null) {
        exito = await provider.guardarReceta();
      } else {
        exito = await provider.actualizarReceta(widget.numeroRecetaEditar!);
      }

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta guardada exitosamente')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _guardarYCompartir() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<RecetarioFormProvider>();
      final error = provider.validarFormulario();

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Guardando y generando PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Guardar receta
        bool exito;
        if (widget.numeroRecetaEditar == null) {
          exito = await provider.guardarReceta();
        } else {
          exito = await provider.actualizarReceta(widget.numeroRecetaEditar!);
        }

        if (!exito) {
          if (mounted) {
            Navigator.pop(context); // Cerrar loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al guardar la receta'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Obtener la receta guardada para compartir
        final recetas = provider.recetas;
        if (recetas.isEmpty) {
          if (mounted) {
            Navigator.pop(context); // Cerrar loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al obtener la receta guardada'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final recetaGuardada = recetas.first; // La más reciente

        // Compartir PDF
        await provider.compartirPdf(recetaGuardada);

        if (mounted) {
          Navigator.pop(context); // Cerrar loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receta guardada y compartida exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Volver a la lista
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Cerrar loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
