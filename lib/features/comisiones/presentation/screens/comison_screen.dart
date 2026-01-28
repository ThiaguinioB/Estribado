import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/comision_form_provider.dart';

class ComisionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usamos ChangeNotifierProvider para instanciar la lógica
    return ChangeNotifierProvider(
      create: (_) => ComisionFormProvider(),
      child: Scaffold(
        appBar: AppBar(title: Text("Nueva Comisión")),
        body: _ComisionFormBody(),
      ),
    );
  }
}

class _ComisionFormBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accedemos al estado
    final provider = context.watch<ComisionFormProvider>();
    final comision = provider.state;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Ejemplo de Input limpio
        TextField(
          decoration: InputDecoration(labelText: "Cantidad"),
          keyboardType: TextInputType.number,
          // La UI solo avisa "cambió el texto", no calcula
          onChanged: (value) => provider.updateCantidad(value),
        ),
        TextField(
          decoration: InputDecoration(labelText: "Precio Unitario"),
          keyboardType: TextInputType.number,
          onChanged: (value) => provider.updatePrecio(value),
        ),
        
        Divider(),
        
        // RESULTADOS EN TIEMPO REAL
        // Observa cómo ya no hay variables sueltas, todo viene de la Entidad
        _ResultRow("Subtotal:", comision.subtotalNeto),
        _ResultRow("IVA:", comision.montoIva),
        _ResultRow("TOTAL:", comision.totalConImpuestos, isBold: true),
        
        SizedBox(height: 20),
        
        ElevatedButton.icon(
          icon: Icon(Icons.cloud_upload),
          label: Text("Guardar en Microsoft Excel"),
          onPressed: () {
            // Aquí se detonará la lógica de conexión futura
            provider.guardarYExportar();
          },
        )
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _ResultRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text("\$ ${value.toStringAsFixed(2)}", style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}