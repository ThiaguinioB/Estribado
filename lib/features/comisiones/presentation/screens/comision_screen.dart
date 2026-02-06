import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comision_form_provider.dart';
import '../../domain/entities/comision_validation.dart';
import '../../data/repositories/comision_repository_impl.dart';
import '../../data/datasources/comision_local_datasource.dart';
import '../../data/datasources/comision_remote_datasource.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class ComisionScreen extends StatelessWidget {
  const ComisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar dependencias (en producción usar DI como get_it)
    final authService = MicrosoftAuthService();
    final excelService = ExcelGraphService(authService: authService);
    final pdfService = PdfGeneratorService();
    final localDataSource = ComisionLocalDataSource();
    final remoteDataSource = ComisionRemoteDataSource(
      excelService: excelService,
      pdfService: pdfService,
    );
    final repository = ComisionRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    return ChangeNotifierProvider(
      create: (_) => ComisionFormProvider(repository: repository),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nueva Comisión"),
        ),
        body: const _ComisionFormBody(),
      ),
    );
  }
}

class _ComisionFormBody extends StatefulWidget {
  const _ComisionFormBody();

  @override
  State<_ComisionFormBody> createState() => _ComisionFormBodyState();
}

class _ComisionFormBodyState extends State<_ComisionFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _cuitController = TextEditingController();
  final _productoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();
  final _comisionController = TextEditingController();
  final _ivaOtroController = TextEditingController();
  
  String _ivaSeleccionado = '21.0'; // Por defecto 21%

  @override
  void dispose() {
    _clienteController.dispose();
    _cuitController.dispose();
    _productoController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _comisionController.dispose();
    _ivaOtroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComisionFormProvider>();
    final comision = provider.state;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cliente
          TextFormField(
            controller: _clienteController,
            decoration: const InputDecoration(
              labelText: "Nombre del Cliente *",
              prefixIcon: Icon(Icons.person),
            ),
            validator: ComisionValidation.validateClienteNombre,
            onChanged: provider.updateClienteNombre,
          ),
          const SizedBox(height: 16),

          // CUIT
          TextFormField(
            controller: _cuitController,
            decoration: const InputDecoration(
              labelText: "CUIT *",
              prefixIcon: Icon(Icons.badge),
              hintText: "20-12345678-9",
            ),
            keyboardType: TextInputType.number,
            validator: ComisionValidation.validateClienteCuit,
            onChanged: provider.updateClienteCuit,
          ),
          const SizedBox(height: 16),

          // Producto
          TextFormField(
            controller: _productoController,
            decoration: const InputDecoration(
              labelText: "Nombre del Producto *",
              prefixIcon: Icon(Icons.inventory),
            ),
            validator: ComisionValidation.validateProductoNombre,
            onChanged: provider.updateProductoNombre,
          ),
          const SizedBox(height: 16),

          // Cantidad
          TextFormField(
            controller: _cantidadController,
            decoration: const InputDecoration(
              labelText: "Cantidad *",
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
            validator: ComisionValidation.validateCantidad,
            onChanged: provider.updateCantidad,
          ),
          const SizedBox(height: 16),

          // Precio Unitario
          TextFormField(
            controller: _precioController,
            decoration: const InputDecoration(
              labelText: "Precio Unitario *",
              prefixIcon: Icon(Icons.attach_money),
              prefixText: "\$ ",
            ),
            keyboardType: TextInputType.number,
            validator: ComisionValidation.validatePrecio,
            onChanged: provider.updatePrecio,
          ),
          const SizedBox(height: 16),

          // Porcentaje de IVA
          DropdownButtonFormField<String>(
            value: _ivaSeleccionado,
            decoration: const InputDecoration(
              labelText: "IVA % *",
              prefixIcon: Icon(Icons.percent),
            ),
            items: const [
              DropdownMenuItem(value: '0.0', child: Text('0%')),
              DropdownMenuItem(value: '10.5', child: Text('10.5%')),
              DropdownMenuItem(value: '21.0', child: Text('21%')),
              DropdownMenuItem(value: 'otro', child: Text('Otros')),
            ],
            onChanged: (value) {
              setState(() {
                _ivaSeleccionado = value!;
                if (value != 'otro') {
                  provider.updateIva(double.parse(value));
                  _ivaOtroController.clear();
                }
              });
            },
          ),
          
          // Campo para IVA personalizado
          if (_ivaSeleccionado == 'otro') ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _ivaOtroController,
              decoration: const InputDecoration(
                labelText: "IVA Personalizado %",
                prefixIcon: Icon(Icons.edit),
                hintText: "Ej: 15",
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el porcentaje de IVA';
                }
                final num = double.tryParse(value);
                if (num == null || num < 0) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
              onChanged: (value) {
                final num = double.tryParse(value);
                if (num != null) {
                  provider.updateIva(num);
                }
              },
            ),
          ],
          const SizedBox(height: 16),

          // Porcentaje de Comisión (campo libre)
          TextFormField(
            controller: _comisionController,
            decoration: const InputDecoration(
              labelText: "Comisión % *",
              prefixIcon: Icon(Icons.monetization_on),
              hintText: "Ej: 10",
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el porcentaje de comisión';
              }
              final num = double.tryParse(value);
              if (num == null || num < 0) {
                return 'Ingrese un número válido';
              }
              return null;
            },
            onChanged: (value) {
              final num = double.tryParse(value);
              if (num != null) {
                provider.updateComision(num);
              }
            },
          ),
          const SizedBox(height: 24),

          const Divider(thickness: 2),
          const SizedBox(height: 16),

          // RESULTADOS EN TIEMPO REAL
          _ResultRow("Subtotal:", comision.subtotalNeto),
          _ResultRow("IVA (${comision.porcentajeIva}%):", comision.montoIva),
          _ResultRow("TOTAL:", comision.totalConImpuestos, isBold: true),
          const SizedBox(height: 8),
          _ResultRow(
            "Comisión (${comision.porcentajeComision}%):",
            comision.valorComision,
            isBold: true,
            color: Colors.green,
          ),

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

          // Botones de acción
          ElevatedButton.icon(
            icon: provider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text("Guardar Localmente"),
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await provider.guardarComision();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comisión guardada exitosamente')),
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
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;

  const _ResultRow(
    this.label,
    this.value, {
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            "\$ ${value.toStringAsFixed(2)}",
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
