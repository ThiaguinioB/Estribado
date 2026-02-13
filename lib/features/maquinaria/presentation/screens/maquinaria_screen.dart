import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/maquinaria_form_provider.dart';
import '../../domain/entities/maquinaria.dart';
import '../../domain/entities/maquinaria_validation.dart';
import '../../data/repositories/maquinaria_repository_impl.dart';
import '../../data/datasources/maquinaria_local_datasource.dart';
import '../../data/datasources/maquinaria_remote_datasource.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class MaquinariaScreen extends StatelessWidget {
  final int? numeroOperacionEditar;

  const MaquinariaScreen({super.key, this.numeroOperacionEditar});

  @override
  Widget build(BuildContext context) {
    // Inicializar dependencias
    final authService = MicrosoftAuthService();
    final excelService = ExcelGraphService(authService: authService);
    final pdfService = PdfGeneratorService();
    final localDataSource = MaquinariaLocalDataSource();
    final remoteDataSource = MaquinariaRemoteDataSource(
      excelService: excelService,
      pdfService: pdfService,
    );
    final repository = MaquinariaRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    return ChangeNotifierProvider(
      create: (_) {
        final provider = MaquinariaFormProvider(repository: repository);
        if (numeroOperacionEditar != null) {
          repository.getMaquinariaById(numeroOperacionEditar!).then((maquinaria) {
            provider.loadMaquinariaForEdit(maquinaria);
          });
        }
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(numeroOperacionEditar != null
              ? "Editar Maquinaria"
              : "Nuevo Servicio de Maquinaria"),
        ),
        body: _MaquinariaFormBody(isEditing: numeroOperacionEditar != null),
      ),
    );
  }
}

class _MaquinariaFormBody extends StatefulWidget {
  final bool isEditing;

  const _MaquinariaFormBody({required this.isEditing});

  @override
  State<_MaquinariaFormBody> createState() => _MaquinariaFormBodyState();
}

class _MaquinariaFormBodyState extends State<_MaquinariaFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _tipoServicioController = TextEditingController();
  final _superficieController = TextEditingController();
  final _costoPorUnidadController = TextEditingController();
  final _descripcionController = TextEditingController();

  DateTime _fechaSeleccionada = DateTime.now();
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _clienteController.dispose();
    _tipoServicioController.dispose();
    _superficieController.dispose();
    _costoPorUnidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _initControllersFromState(MaquinariaFormProvider provider) {
    if (!_controllersInitialized && widget.isEditing) {
      final m = provider.state;
      _clienteController.text = m.clienteNombre;
      _tipoServicioController.text = m.tipoServicio;
      _superficieController.text = m.superficie > 0 ? m.superficie.toString() : '';
      _costoPorUnidadController.text = m.costoPorUnidad > 0 ? m.costoPorUnidad.toString() : '';
      _descripcionController.text = m.descripcion;
      _fechaSeleccionada = m.fecha;
      _controllersInitialized = true;
    }
  }

  Future<void> _selectDate(BuildContext context, MaquinariaFormProvider provider) async {
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
    final provider = context.watch<MaquinariaFormProvider>();
    final maquinaria = provider.state;
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Inicializar controllers si estamos editando
    if (widget.isEditing && maquinaria.clienteNombre.isNotEmpty) {
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
            validator: MaquinariaValidation.validateClienteNombre,
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

          // ── Tipo de servicio ──
          TextFormField(
            controller: _tipoServicioController,
            decoration: const InputDecoration(
              labelText: "Tipo de servicio *",
              prefixIcon: Icon(Icons.agriculture),
              hintText: 'Ej: Siembra, Cosecha, Fumigación...',
            ),
            validator: MaquinariaValidation.validateTipoServicio,
            onChanged: provider.updateTipoServicio,
          ),
          const SizedBox(height: 20),

          // ══════════════ SECCIÓN SUPERFICIE ══════════════
          _buildSuperficieCard(provider, maquinaria),
          const SizedBox(height: 16),

          // ══════════════ SECCIÓN COSTO POR UNIDAD ══════════════
          _buildCostoCard(provider, maquinaria),
          const SizedBox(height: 16),

          // ── Observaciones ──
          TextFormField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              labelText: "Observaciones",
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: MaquinariaValidation.validateDescripcion,
            onChanged: provider.updateDescripcion,
          ),
          const SizedBox(height: 24),

          const Divider(thickness: 2),
          const SizedBox(height: 16),

          // ═══════ RESULTADOS EN TIEMPO REAL ═══════
          _buildResultadosCard(maquinaria),

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
                          ? await provider.actualizarMaquinaria()
                          : await provider.guardarMaquinaria();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.isEditing
                                ? 'Maquinaria actualizada exitosamente'
                                : 'Maquinaria guardada exitosamente'),
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

  // ── Dropdown de unidad de superficie ──
  Widget _buildUnidadSuperficieDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isDense: true,
      decoration: const InputDecoration(
        labelText: "Unidad",
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: 'ha', child: Text('Hectáreas')),
        DropdownMenuItem(value: 'm²', child: Text('m²')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  // ── Dropdown de unidad de costo ──
  Widget _buildUnidadCostoDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isDense: true,
      decoration: const InputDecoration(
        labelText: "Unidad",
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: 'ARS', child: Text('AR\$')),
        DropdownMenuItem(value: 'USD', child: Text('U\$D')),
        DropdownMenuItem(value: 'Lts. combustible', child: Text('Lts. comb.')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  // ── Card de Superficie ──
  Widget _buildSuperficieCard(MaquinariaFormProvider provider, Maquinaria maquinaria) {
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
                const Icon(Icons.square_foot, color: Colors.orange, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Superficie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _superficieController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad (${maquinaria.unidadSuperficie})',
                      prefixIcon: const Icon(Icons.square_foot, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                    validator: MaquinariaValidation.validateSuperficie,
                    onChanged: provider.updateSuperficie,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildUnidadSuperficieDropdown(
                    value: maquinaria.unidadSuperficie,
                    onChanged: provider.updateUnidadSuperficie,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Card de Costo por unidad de superficie ──
  Widget _buildCostoCard(MaquinariaFormProvider provider, Maquinaria maquinaria) {
    final simbolo = Maquinaria.simboloUnidadCosto(maquinaria.unidadCosto);

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
                const Icon(Icons.attach_money, color: Colors.green, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Costo por ${maquinaria.unidadSuperficie}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _costoPorUnidadController,
                    decoration: InputDecoration(
                      labelText: 'Costo por ${maquinaria.unidadSuperficie}',
                      prefixText: '$simbolo ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: MaquinariaValidation.validateCostoPorUnidad,
                    onChanged: provider.updateCostoPorUnidad,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildUnidadCostoDropdown(
                    value: maquinaria.unidadCosto,
                    onChanged: provider.updateUnidadCosto,
                  ),
                ),
              ],
            ),
            if (maquinaria.totalCosto > 0) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: $simbolo ${maquinaria.totalCosto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Card de resultados en tiempo real ──
  Widget _buildResultadosCard(Maquinaria m) {
    final simbolo = Maquinaria.simboloUnidadCosto(m.unidadCosto);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Servicio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (m.tipoServicio.isNotEmpty)
              _ResultRow(
                'Tipo de servicio:',
                m.tipoServicio,
                isText: true,
              ),
            if (m.superficie > 0)
              _ResultRow(
                'Superficie:',
                '${m.superficie.toStringAsFixed(2)} ${m.unidadSuperficie}',
                isText: true,
              ),
            if (m.costoPorUnidad > 0)
              _ResultRow(
                'Costo por ${m.unidadSuperficie}:',
                '$simbolo ${m.costoPorUnidad.toStringAsFixed(2)}',
                isText: true,
              ),
            const SizedBox(height: 8),
            _ResultRow(
              'TOTAL:',
              m.totalCosto > 0 ? '$simbolo ${m.totalCosto.toStringAsFixed(2)}' : '\$ 0.00',
              isBold: true,
              color: Colors.green,
              isText: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  final bool isText;

  const _ResultRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.color,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            value,
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
