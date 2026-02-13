import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/maquinaria_form_provider.dart';
import '../../domain/entities/maquinaria.dart';
import '../../data/repositories/maquinaria_repository_impl.dart';
import '../../data/datasources/maquinaria_local_datasource.dart';
import '../../data/datasources/maquinaria_remote_datasource.dart';
import '../../../../core/services/excel_graph_service.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../core/services/microsoft_auth_service.dart';

class MaquinariaListScreen extends StatelessWidget {
  const MaquinariaListScreen({super.key});

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
      create: (_) => MaquinariaFormProvider(repository: repository)..loadMaquinarias(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maquinaria Agrícola'),
          actions: [
            Consumer<MaquinariaFormProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Exportar a Excel',
                  onPressed: provider.maquinarias.isEmpty
                      ? null
                      : () => _exportarTodosAExcel(context, provider),
                );
              },
            ),
          ],
        ),
        body: const _MaquinariaListBody(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/maquinaria/nueva'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Servicio'),
        ),
      ),
    );
  }

  Future<void> _exportarTodosAExcel(BuildContext context, MaquinariaFormProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar a Excel'),
        content: Text('¿Desea exportar ${provider.maquinarias.length} registros de maquinaria a Excel?'),
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
      final success = await provider.exportarVariasMaquinariasAExcel(provider.maquinarias);
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

class _MaquinariaListBody extends StatelessWidget {
  const _MaquinariaListBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<MaquinariaFormProvider>(
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
                  onPressed: provider.loadMaquinarias,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (provider.maquinarias.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay servicios de maquinaria registrados',
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
          onRefresh: provider.loadMaquinarias,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.maquinarias.length,
            itemBuilder: (context, index) {
              final maquinaria = provider.maquinarias[index];
              return _MaquinariaCard(maquinaria: maquinaria);
            },
          ),
        );
      },
    );
  }
}

class _MaquinariaCard extends StatelessWidget {
  final Maquinaria maquinaria;

  const _MaquinariaCard({required this.maquinaria});

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
                          maquinaria.clienteNombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (maquinaria.tipoServicio.isNotEmpty)
                          Text(
                            maquinaria.tipoServicio,
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
                      value: dateFormat.format(maquinaria.fecha),
                      icon: Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Superficie',
                      value: '${maquinaria.superficie.toStringAsFixed(2)} ${maquinaria.unidadSuperficie}',
                      icon: Icons.square_foot,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Costo/${maquinaria.unidadSuperficie}',
                      value: maquinaria.costoPorUnidad > 0
                          ? '${Maquinaria.simboloUnidadCosto(maquinaria.unidadCosto)} ${maquinaria.costoPorUnidad.toStringAsFixed(2)}'
                          : '-',
                      icon: Icons.attach_money,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Total',
                      value: maquinaria.totalFormateado,
                      icon: Icons.attach_money,
                      valueColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
              if (maquinaria.descripcion.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  maquinaria.descripcion,
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
                    onPressed: () => _editarMaquinaria(context),
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
                    onPressed: () => _eliminarMaquinaria(context),
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
      builder: (context) => _MaquinariaDetalleDialog(maquinaria: maquinaria),
    );
  }

  void _editarMaquinaria(BuildContext context) {
    context.push('/maquinaria/editar/${maquinaria.numeroOperacion}');
  }

  Future<void> _compartirPdf(BuildContext context) async {
    final provider = context.read<MaquinariaFormProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparando PDF para compartir...')),
    );

    final success = await provider.compartirPdf(maquinaria);

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
    final provider = context.read<MaquinariaFormProvider>();
    provider.loadMaquinariaForEdit(maquinaria);
    
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

  Future<void> _eliminarMaquinaria(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Maquinaria'),
        content: const Text('¿Está seguro que desea eliminar este registro de maquinaria?'),
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
      final provider = context.read<MaquinariaFormProvider>();
      final success = await provider.eliminarMaquinaria(maquinaria.numeroOperacion!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Maquinaria eliminada' : 'Error al eliminar'),
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

class _MaquinariaDetalleDialog extends StatelessWidget {
  final Maquinaria maquinaria;

  const _MaquinariaDetalleDialog({required this.maquinaria});

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
                  const Icon(Icons.agriculture, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Detalle de Maquinaria',
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
                    _DetalleRow(label: 'Cliente', value: maquinaria.clienteNombre),
                    _DetalleRow(label: 'Fecha', value: dateFormat.format(maquinaria.fecha)),
                    _DetalleRow(label: 'Tipo de Servicio', value: maquinaria.tipoServicio),
                    const Divider(height: 24),
                    _DetalleRow(
                      label: 'Superficie',
                      value: '${maquinaria.superficie.toStringAsFixed(2)} ${maquinaria.unidadSuperficie}',
                    ),
                    if (maquinaria.costoPorUnidad > 0)
                      _DetalleRow(
                        label: 'Costo/${maquinaria.unidadSuperficie}',
                        value: '${Maquinaria.simboloUnidadCosto(maquinaria.unidadCosto)} ${maquinaria.costoPorUnidad.toStringAsFixed(2)}',
                      ),
                    const Divider(height: 24),
                    _DetalleRow(
                      label: 'Total',
                      value: maquinaria.totalFormateado,
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    if (maquinaria.descripcion.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text(
                        'Observaciones:',
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
                          maquinaria.descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
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
