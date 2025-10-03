import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  const CustomTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Table")),
      body: Center(
        child: Table(
          border: TableBorder.all(), // Bordes para la tabla
          children: const [
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Fila 1, Columna 1"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Fila 1, Columna 2"),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Fila 2, Columna 1"),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Fila 2, Columna 2"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
