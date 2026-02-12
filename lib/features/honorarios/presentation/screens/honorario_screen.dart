import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/honorario_form_provider.dart';
import '../../domain/entities/honorario.dart';
import '../../domain/entities/honorario_validation.dart';
import '../../data/repositories/honorario_repository_impl.dart';
import '../../data/datasources/honorario_local_datasource.dart';
import '../../data/datasources/honorario_remote_datasource.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class HonorarioScreen extends StatelessWidget {
  final int? numeroOperacionEditar;

  const HonorarioScreen({super.key, this.numeroOperacionEditar});

  @override
  Widget build(BuildContext context) {
    // Inicializar dependencias
    final authService = MicrosoftAuthService();
    final excelService = ExcelGraphService(authService: authService);
    final pdfService = PdfGeneratorService();
    final localDataSource = HonorarioLocalDataSource();
    final remoteDataSource = HonorarioRemoteDataSource(
      excelService: excelService,
      pdfService: pdfService,
    );
    final repository = HonorarioRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    return ChangeNotifierProvider(
      create: (_) {
        final provider = HonorarioFormProvider(repository: repository);
        if (numeroOperacionEditar != null) {
          repository.getHonorarioById(numeroOperacionEditar!).then((honorario) {
            provider.loadHonorarioForEdit(honorario);
          });
        } else {
          // Nuevo honorario: auto-cargar el siguiente número de receta
          provider.cargarNumeroRecetaInicial();
        }
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(numeroOperacionEditar != null
              ? "Editar Honorario"
              : "Nuevo Honorario"),
        ),
        body: _HonorarioFormBody(isEditing: numeroOperacionEditar != null),
      ),
    );
  }
}

class _HonorarioFormBody extends StatefulWidget {
  final bool isEditing;

  const _HonorarioFormBody({required this.isEditing});

  @override
  State<_HonorarioFormBody> createState() => _HonorarioFormBodyState();
}

class _HonorarioFormBodyState extends State<_HonorarioFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _kmController = TextEditingController();
  final _costoKmController = TextEditingController();
  final _horasController = TextEditingController();
  final _costoHoraController = TextEditingController();
  final _plusTecnicoController = TextEditingController();
  final _descripcionPlusController = TextEditingController();
  final _descripcionController = TextEditingController();

  DateTime _fechaSeleccionada = DateTime.now();
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _clienteController.dispose();
    _kmController.dispose();
    _costoKmController.dispose();
    _horasController.dispose();
    _costoHoraController.dispose();
    _plusTecnicoController.dispose();
    _descripcionPlusController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _initControllersFromState(HonorarioFormProvider provider) {
    if (!_controllersInitialized && widget.isEditing) {
      final h = provider.state;
      _clienteController.text = h.clienteNombre;
      _kmController.text = h.kmRecorridos > 0 ? h.kmRecorridos.toString() : '';
      _costoKmController.text = h.costoKm > 0 ? h.costoKm.toString() : '';
      _horasController.text = h.horaTecnica > 0 ? h.horaTecnica.toString() : '';
      _costoHoraController.text = h.costoHora > 0 ? h.costoHora.toString() : '';
      _plusTecnicoController.text = h.plusTecnico > 0 ? h.plusTecnico.toString() : '';
      _descripcionPlusController.text = h.descripcionPlus;
      _descripcionController.text = h.descripcionTarea;
      _fechaSeleccionada = h.fecha;
      _controllersInitialized = true;
    }
  }

  Future<void> _selectDate(BuildContext context, HonorarioFormProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
      provider.updateFecha(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HonorarioFormProvider>();
    final honorario = provider.state;
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Inicializar controllers si estamos editando
    if (widget.isEditing && honorario.clienteNombre.isNotEmpty) {
      _initControllersFromState(provider);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Cliente ──
          TextFormField(
            controller: _clienteController,
            decoration: const InputDecoration(
              labelText: "Cliente *",
              prefixIcon: Icon(Icons.person),
            ),
            validator: HonorarioValidation.validateClienteNombre,
            onChanged: provider.updateClienteNombre,
          ),
          const SizedBox(height: 16),

          // ── Fecha ──
          InkWell(
            onTap: () => _selectDate(context, provider),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Fecha *",
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                dateFormat.format(_fechaSeleccionada),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Nro. de Receta (con +/- como recetario) ──
          _buildNumeroRecetaCard(provider),
          const SizedBox(height: 20),

          // ══════════════ SECCIÓN KM RECORRIDOS ══════════════
          _buildCostSectionCard(
            title: 'Km. Recorridos',
            icon: Icons.directions_car,
            color: Colors.blue,
            qtyLabel: 'Cantidad de Km',
            qtyController: _kmController,
            qtyValidator: HonorarioValidation.validateKmRecorridos,
            onQtyChanged: provider.updateKmRecorridos,
            costLabel: 'Costo por Km',
            costController: _costoKmController,
            costValidator: HonorarioValidation.validateCostoUnitario,
            onCostChanged: provider.updateCostoKm,
            moneda: honorario.monedaKm,
            onMonedaChanged: provider.updateMonedaKm,
            subtotal: honorario.subtotalKm,
          ),
          const SizedBox(height: 16),

          // ══════════════ SECCIÓN HORA TÉCNICA ══════════════
          _buildCostSectionCard(
            title: 'Hora Técnica',
            icon: Icons.access_time,
            color: Colors.purple,
            qtyLabel: 'Cantidad de Horas',
            qtyController: _horasController,
            qtyValidator: HonorarioValidation.validateHoraTecnica,
            onQtyChanged: provider.updateHoraTecnica,
            costLabel: 'Costo por Hora',
            costController: _costoHoraController,
            costValidator: HonorarioValidation.validateCostoUnitario,
            onCostChanged: provider.updateCostoHora,
            moneda: honorario.monedaHora,
            onMonedaChanged: provider.updateMonedaHora,
            subtotal: honorario.subtotalHora,
          ),
          const SizedBox(height: 16),

          // ══════════════ SECCIÓN PLUS TÉCNICO ══════════════
          _buildPlusTecnicoCard(provider, honorario),
          const SizedBox(height: 16),

          // ── Descripción de la tarea/trabajo ──
          TextFormField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              labelText: "Descripción de la tarea/trabajo *",
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: HonorarioValidation.validateDescripcion,
            onChanged: provider.updateDescripcionTarea,
          ),
          const SizedBox(height: 24),

          const Divider(thickness: 2),
          const SizedBox(height: 16),

          // ═══════ RESULTADOS EN TIEMPO REAL ═══════
          _buildResultadosCard(honorario),

          const SizedBox(height: 24),

          // Mensaje de error
          if (provider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ═══════ BOTONES DE ACCIÓN ═══════
          ElevatedButton.icon(
            icon: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(widget.isEditing ? "Actualizar" : "Guardar Localmente"),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = widget.isEditing
                          ? await provider.actualizarHonorario()
                          : await provider.guardarHonorario();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.isEditing
                                ? 'Honorario actualizado exitosamente'
                                : 'Honorario guardado exitosamente'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  },
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Exportar a Microsoft Excel"),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await provider.exportarAExcel();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exportado a Excel exitosamente')),
                        );
                      }
                    }
                  },
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Generar PDF"),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      await provider.generarPdf();
                    }
                  },
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text("Compartir PDF"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      await provider.compartirPdf();
                    }
                  },
          ),
        ],
      ),
    );
  }

  // ── Nro de Receta con botones +/- al estilo recetario ──
  Widget _buildNumeroRecetaCard(HonorarioFormProvider provider) {
    final numero = provider.state.numeroReceta;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Nro. de Receta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: numero != null && numero > 1
                      ? provider.decrementarNumeroReceta
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: numero != null
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    numero?.toString().padLeft(5, '0') ?? '-----',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: provider.incrementarNumeroReceta,
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

  // ── Dropdown de moneda reutilizable ──
  Widget _buildMonedaDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isDense: true,
      decoration: const InputDecoration(
        labelText: "Moneda",
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: 'ARS', child: Text('AR\$')),
        DropdownMenuItem(value: 'USD', child: Text('U\$D')),
        DropdownMenuItem(value: 'Otras', child: Text('Otras')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  // ── Card de sección de costo (Km / Hora) ──
  Widget _buildCostSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required String qtyLabel,
    required TextEditingController qtyController,
    required String? Function(String?) qtyValidator,
    required ValueChanged<String> onQtyChanged,
    required String costLabel,
    required TextEditingController costController,
    required String? Function(String?) costValidator,
    required ValueChanged<String> onCostChanged,
    required String moneda,
    required ValueChanged<String> onMonedaChanged,
    required double subtotal,
  }) {
    final simbolo = Honorario.simboloMoneda(moneda);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Cantidad
            TextFormField(
              controller: qtyController,
              decoration: InputDecoration(
                labelText: qtyLabel,
                prefixIcon: Icon(icon, size: 20),
              ),
              keyboardType: TextInputType.number,
              validator: qtyValidator,
              onChanged: onQtyChanged,
            ),
            const SizedBox(height: 12),
            // Costo unitario + moneda
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: costController,
                    decoration: InputDecoration(
                      labelText: '$costLabel (opcional)',
                      prefixText: '$simbolo ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: costValidator,
                    onChanged: onCostChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildMonedaDropdown(
                    value: moneda,
                    onChanged: onMonedaChanged,
                  ),
                ),
              ],
            ),
            if (subtotal > 0) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Subtotal: $simbolo ${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Card de Plus Técnico con campo descripción condicional ──
  Widget _buildPlusTecnicoCard(HonorarioFormProvider provider, Honorario honorario) {
    final simbolo = Honorario.simboloMoneda(honorario.monedaPlus);
    final tieneValor = honorario.plusTecnico > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.teal, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Plus Técnico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Spacer(),
                Text(
                  'Opcional',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Monto + moneda
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _plusTecnicoController,
                    decoration: InputDecoration(
                      labelText: 'Monto del Plus',
                      prefixText: '$simbolo ',
                      hintText: 'Coste extra eventual',
                    ),
                    keyboardType: TextInputType.number,
                    validator: HonorarioValidation.validatePlusTecnico,
                    onChanged: provider.updatePlusTecnico,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildMonedaDropdown(
                    value: honorario.monedaPlus,
                    onChanged: provider.updateMonedaPlus,
                  ),
                ),
              ],
            ),
            // Descripción condicional: se muestra cuando hay valor cargado
            if (tieneValor) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionPlusController,
                decoration: InputDecoration(
                  labelText: 'Descripción del plus',
                  hintText: 'Ej: Recetado de productos lote 5',
                  prefixIcon: const Icon(Icons.short_text),
                  filled: true,
                  fillColor: Colors.teal.withValues(alpha: 0.05),
                ),
                onChanged: provider.updateDescripcionPlus,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Filas de total agrupadas por moneda ──
  List<Widget> _buildTotalRows(Honorario h) {
    final totales = h.totalesPorMoneda;
    if (totales.isEmpty) {
      return [
        const _ResultRow(
          'TOTAL HONORARIO:',
          0,
          isBold: true,
          color: Colors.green,
        ),
      ];
    }
    if (totales.length == 1) {
      final entry = totales.entries.first;
      return [
        _ResultRow(
          'TOTAL HONORARIO:',
          entry.value,
          isBold: true,
          color: Colors.green,
          moneda: entry.key,
        ),
      ];
    }
    // Múltiples monedas: mostrar cada una
    final orden = ['USD', 'ARS', 'Otras'];
    final sorted = totales.entries.toList()
      ..sort((a, b) {
        final ia = orden.indexOf(a.key);
        final ib = orden.indexOf(b.key);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });
    return [
      const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Text(
          'TOTAL HONORARIO:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      ...sorted.map((e) => _ResultRow(
            '  ${e.key}:',
            e.value,
            isBold: true,
            color: Colors.green,
            moneda: e.key,
          )),
    ];
  }

  // ── Card de resultados en tiempo real ──
  Widget _buildResultadosCard(Honorario h) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Costos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (h.subtotalKm > 0)
              _ResultRow(
                'Km (${h.kmRecorridos.toStringAsFixed(1)} × ${Honorario.simboloMoneda(h.monedaKm)} ${h.costoKm.toStringAsFixed(2)}):',
                h.subtotalKm,
                moneda: h.monedaKm,
              ),
            if (h.kmRecorridos > 0 && h.costoKm == 0)
              _ResultRow(
                'Km Recorridos: ${h.kmRecorridos.toStringAsFixed(1)} km',
                0,
                showValue: false,
              ),
            if (h.subtotalHora > 0)
              _ResultRow(
                'Horas (${h.horaTecnica.toStringAsFixed(1)} × ${Honorario.simboloMoneda(h.monedaHora)} ${h.costoHora.toStringAsFixed(2)}):',
                h.subtotalHora,
                moneda: h.monedaHora,
              ),
            if (h.horaTecnica > 0 && h.costoHora == 0)
              _ResultRow(
                'Horas Técnicas: ${h.horaTecnica.toStringAsFixed(1)} hs',
                0,
                showValue: false,
              ),
            if (h.plusTecnico > 0)
              _ResultRow(
                'Plus Técnico${h.descripcionPlus.isNotEmpty ? " (${h.descripcionPlus})" : ""}:',
                h.plusTecnico,
                moneda: h.monedaPlus,
              ),
            const SizedBox(height: 8),
            // Total por moneda
            ..._buildTotalRows(h),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;
  final String? moneda;
  final bool showValue;

  const _ResultRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.color,
    this.moneda,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final simbolo = moneda != null ? Honorario.simboloMoneda(moneda!) : '\$';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ),
          if (showValue)
            Text(
              "$simbolo ${value.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
