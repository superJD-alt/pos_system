import 'package:flutter/material.dart';

class PedidosActivos extends StatelessWidget {
  const PedidosActivos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Actvios'),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(),
    );
  }
}
