import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/comision_form_provider.dart';
import '../../domain/entities/comision.dart';
import '../../data/repositories/comision_repository_impl.dart';
import '../../data/datasources/comision_local_datasource.dart';
import '../../data/datasources/comision_remote_datasource.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class ComisionListScreen extends StatelessWidget {
  const ComisionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar dependencias
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
      create: (_) => ComisionFormProvider(repository: repository)..loadComisiones(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comisiones'),
          actions: [
            Consumer<ComisionFormProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Exportar a Excel',
                  onPressed: provider.comisiones.isEmpty
                      ? null
                      : () => _exportarTodasAExcel(context, provider),
                );
              },
            ),
          ],
        ),
        body: const _ComisionListBody(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/comisiones/nueva'),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Comisión'),
        ),
      ),
    );
  }

  Future<void> _exportarTodasAExcel(BuildContext context, ComisionFormProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar a Excel'),
        content: Text('¿Desea exportar ${provider.comisiones.length} comisiones a Excel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exportar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.exportarVariasComisionesAExcel(provider.comisiones);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Excel generado exitosamente' : 'Error al exportar'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _ComisionListBody extends StatelessWidget {
  const _ComisionListBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<ComisionFormProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: provider.loadComisiones,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (provider.comisiones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay comisiones registradas',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona el botón + para agregar una',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadComisiones,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.comisiones.length,
            itemBuilder: (context, index) {
              final comision = provider.comisiones[index];
              return _ComisionCard(comision: comision);
            },
          ),
        );
      },
    );
  }
}

class _ComisionCard extends StatelessWidget {
  final Comision comision;

  const _ComisionCard({required this.comision});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_AR', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _verDetalle(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comision.clienteNombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CUIT: ${comision.clienteCuit}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _EstadoChip(estado: comision.estado),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Producto',
                      value: comision.productoNombre,
                      icon: Icons.shopping_bag,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Fecha',
                      value: dateFormat.format(comision.fecha),
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Total',
                      value: currencyFormat.format(comision.totalConImpuestos),
                      icon: Icons.attach_money,
                      valueColor: Colors.green[700],
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Comisión',
                      value: currencyFormat.format(comision.valorComision),
                      icon: Icons.monetization_on,
                      valueColor: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editarComision(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _generarPdf(context),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _eliminarComision(context),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verDetalle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ComisionDetalleDialog(comision: comision),
    );
  }

  void _editarComision(BuildContext context) {
    final provider = context.read<ComisionFormProvider>();
    provider.loadComisionForEdit(comision);
    context.push('/comisiones/editar/${comision.numeroOperacion}');
  }

  Future<void> _generarPdf(BuildContext context) async {
    final provider = context.read<ComisionFormProvider>();
    provider.loadComisionForEdit(comision);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando PDF...')),
    );

    final success = await provider.generarPdf();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'PDF generado exitosamente' : 'Error al generar PDF'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarComision(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Comisión'),
        content: const Text('¿Está seguro que desea eliminar esta comisión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<ComisionFormProvider>();
      final success = await provider.eliminarComision(comision.numeroOperacion!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Comisión eliminada' : 'Error al eliminar'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'pagado':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pendiente':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'cancelado':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        estado,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _ComisionDetalleDialog extends StatelessWidget {
  final Comision comision;

  const _ComisionDetalleDialog({required this.comision});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_AR', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Detalle de Comisión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetalleRow(label: 'Cliente', value: comision.clienteNombre),
                  _DetalleRow(label: 'CUIT', value: comision.clienteCuit),
                  _DetalleRow(label: 'Fecha', value: dateFormat.format(comision.fecha)),
                  const Divider(height: 24),
                  _DetalleRow(label: 'Producto', value: comision.productoNombre),
                  _DetalleRow(label: 'Tipo', value: comision.tipoProducto),
                  _DetalleRow(label: 'Cantidad', value: comision.cantidad.toString()),
                  _DetalleRow(
                    label: 'Precio Unitario',
                    value: currencyFormat.format(comision.precioUnitario),
                  ),
                  const Divider(height: 24),
                  _DetalleRow(
                    label: 'Subtotal',
                    value: currencyFormat.format(comision.subtotalNeto),
                  ),
                  _DetalleRow(
                    label: 'IVA (${comision.porcentajeIva}%)',
                    value: currencyFormat.format(comision.montoIva),
                  ),
                  _DetalleRow(
                    label: 'Total',
                    value: currencyFormat.format(comision.totalConImpuestos),
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const Divider(height: 24),
                  _DetalleRow(
                    label: 'Comisión (${comision.porcentajeComision}%)',
                    value: currencyFormat.format(comision.valorComision),
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DetalleRow(label: 'Estado', value: comision.estado),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetalleRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: valueStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
