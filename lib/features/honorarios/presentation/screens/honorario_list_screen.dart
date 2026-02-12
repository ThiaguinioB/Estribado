import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/honorario_form_provider.dart';
import '../../domain/entities/honorario.dart';
import '../../data/repositories/honorario_repository_impl.dart';
import '../../data/datasources/honorario_local_datasource.dart';
import '../../data/datasources/honorario_remote_datasource.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class HonorarioListScreen extends StatelessWidget {
  const HonorarioListScreen({super.key});

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
      create: (_) => HonorarioFormProvider(repository: repository)..loadHonorarios(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Honorarios Profesionales'),
          actions: [
            Consumer<HonorarioFormProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Exportar a Excel',
                  onPressed: provider.honorarios.isEmpty
                      ? null
                      : () => _exportarTodosAExcel(context, provider),
                );
              },
            ),
          ],
        ),
        body: const _HonorarioListBody(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/honorarios/nuevo'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Honorario'),
        ),
      ),
    );
  }

  Future<void> _exportarTodosAExcel(BuildContext context, HonorarioFormProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar a Excel'),
        content: Text('¿Desea exportar ${provider.honorarios.length} honorarios a Excel?'),
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
      final success = await provider.exportarVariosHonorariosAExcel(provider.honorarios);
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

class _HonorarioListBody extends StatelessWidget {
  const _HonorarioListBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<HonorarioFormProvider>(
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
                  onPressed: provider.loadHonorarios,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (provider.honorarios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay honorarios registrados',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona el botón + para agregar uno',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadHonorarios,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.honorarios.length,
            itemBuilder: (context, index) {
              final honorario = provider.honorarios[index];
              return _HonorarioCard(honorario: honorario);
            },
          ),
        );
      },
    );
  }
}

class _HonorarioCard extends StatelessWidget {
  final Honorario honorario;

  const _HonorarioCard({required this.honorario});

  @override
  Widget build(BuildContext context) {
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
                          honorario.clienteNombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (honorario.numeroReceta != null)
                          Text(
                            'Receta N°: ${honorario.numeroReceta.toString().padLeft(5, '0')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Fecha',
                      value: dateFormat.format(honorario.fecha),
                      icon: Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Km. Recorridos',
                      value: honorario.costoKm > 0
                          ? '${honorario.kmRecorridos.toStringAsFixed(1)} km × ${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.costoKm.toStringAsFixed(2)}'
                          : '${honorario.kmRecorridos.toStringAsFixed(1)} km',
                      icon: Icons.directions_car,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Hora Técnica',
                      value: honorario.costoHora > 0
                          ? '${honorario.horaTecnica.toStringAsFixed(1)} hs × ${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.costoHora.toStringAsFixed(2)}'
                          : '${honorario.horaTecnica.toStringAsFixed(1)} hs',
                      icon: Icons.access_time,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Total Honorario',
                      value: honorario.totalFormateado,
                      icon: Icons.attach_money,
                      valueColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
              if (honorario.descripcionTarea.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  honorario.descripcionTarea,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _editarHonorario(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                  TextButton.icon(
                    onPressed: () => _generarPdf(context),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF'),
                  ),
                  TextButton.icon(
                    onPressed: () => _compartirPdf(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Compartir'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _eliminarHonorario(context),
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
      builder: (context) => _HonorarioDetalleDialog(honorario: honorario),
    );
  }

  void _editarHonorario(BuildContext context) {
    context.push('/honorarios/editar/${honorario.numeroOperacion}');
  }

  Future<void> _compartirPdf(BuildContext context) async {
    final provider = context.read<HonorarioFormProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparando PDF para compartir...')),
    );

    final success = await provider.compartirPdf(honorario);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al compartir PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generarPdf(BuildContext context) async {
    final provider = context.read<HonorarioFormProvider>();
    provider.loadHonorarioForEdit(honorario);
    
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

  Future<void> _eliminarHonorario(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Honorario'),
        content: const Text('¿Está seguro que desea eliminar este honorario?'),
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
      final provider = context.read<HonorarioFormProvider>();
      final success = await provider.eliminarHonorario(honorario.numeroOperacion!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Honorario eliminado' : 'Error al eliminar'),
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

class _HonorarioDetalleDialog extends StatelessWidget {
  final Honorario honorario;

  const _HonorarioDetalleDialog({required this.honorario});

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.business_center, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Detalle de Honorario',
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetalleRow(label: 'Cliente', value: honorario.clienteNombre),
                    _DetalleRow(label: 'Fecha', value: dateFormat.format(honorario.fecha)),
                    if (honorario.numeroReceta != null)
                      _DetalleRow(label: 'Nro. Receta', value: honorario.numeroReceta.toString().padLeft(5, '0')),
                    const Divider(height: 24),
                    // Km Recorridos
                    _DetalleRow(
                      label: 'Km. Recorridos',
                      value: '${honorario.kmRecorridos.toStringAsFixed(1)} km',
                    ),
                    if (honorario.costoKm > 0)
                      _DetalleRow(
                        label: 'Costo/Km (${honorario.monedaKm})',
                        value: '${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.costoKm.toStringAsFixed(2)}',
                      ),
                    if (honorario.subtotalKm > 0)
                      _DetalleRow(
                        label: 'Subtotal Km',
                        value: '${Honorario.simboloMoneda(honorario.monedaKm)} ${honorario.subtotalKm.toStringAsFixed(2)}',
                        valueStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blue),
                      ),
                    const SizedBox(height: 4),
                    // Hora Técnica
                    _DetalleRow(
                      label: 'Hora Técnica',
                      value: '${honorario.horaTecnica.toStringAsFixed(1)} hs',
                    ),
                    if (honorario.costoHora > 0)
                      _DetalleRow(
                        label: 'Costo/Hora (${honorario.monedaHora})',
                        value: '${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.costoHora.toStringAsFixed(2)}',
                      ),
                    if (honorario.subtotalHora > 0)
                      _DetalleRow(
                        label: 'Subtotal Horas',
                        value: '${Honorario.simboloMoneda(honorario.monedaHora)} ${honorario.subtotalHora.toStringAsFixed(2)}',
                        valueStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.purple),
                      ),
                    const SizedBox(height: 4),
                    // Plus Técnico
                    _DetalleRow(
                      label: 'Plus Técnico',
                      value: honorario.plusTecnico > 0
                          ? '${Honorario.simboloMoneda(honorario.monedaPlus)} ${honorario.plusTecnico.toStringAsFixed(2)}'
                          : '-',
                    ),
                    if (honorario.descripcionPlus.isNotEmpty)
                      _DetalleRow(
                        label: 'Desc. Plus',
                        value: honorario.descripcionPlus,
                      ),
                    const Divider(height: 24),
                    _DetalleRow(
                      label: 'Total',
                      value: honorario.totalFormateado,
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Descripción de la tarea:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        honorario.descripcionTarea.isNotEmpty
                            ? honorario.descripcionTarea
                            : 'Sin descripción',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
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
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
