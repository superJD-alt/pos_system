// Puedes colocar esto en un archivo separado como /utils/pdf_generator.dart
import 'package:flutter/services.dart'; // Necesario para Uint8List
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/cuenta_cerrada.dart'; // Ajusta la ruta a tu modelo

Future<Uint8List> generateTicketPdf(CuentaCerrada cuenta) async {
  final pdf = pw.Document();
  final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  // 🎯 CARGAR EL SELLO/LOGO DE LA EMPRESA DESDE ASSETS
  final logoImage = await rootBundle.load('assets/images/icon_pos2.png');
  final logoBytes = logoImage.buffer.asUint8List();

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(
        80 * PdfPageFormat.mm,
        double.infinity,
        marginAll: 4 * PdfPageFormat.mm,
      ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 🎯 SELLO/LOGO DE LA EMPRESA EN LA PARTE SUPERIOR
            pw.Center(
              child: pw.Image(pw.MemoryImage(logoBytes), width: 90, height: 90),
            ),
            pw.SizedBox(height: 5),

            // --- Encabezado ---
            pw.Center(
              child: pw.Text(
                'PARRILLA VILLA',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Emiliano Zapata 57, Centro, 40000',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Iguala de la Independencia, Gro.',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.Center(
              child: pw.Text('México', style: const pw.TextStyle(fontSize: 8)),
            ),
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                'RFC: FOME940127132',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),

            pw.Divider(thickness: 0.5),

            // --- Detalles de la Venta ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'FOLIO: ${cuenta.id.substring(0, 8)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'MESA: ${cuenta.numeroMesa}',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'MESERO: ${cuenta.mesero}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'COMENSALES: ${cuenta.comensales}',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2),

            pw.Text(
              'FECHA: ${DateFormat('dd/MM/yyyy HH:mm').format(cuenta.fechaCierre)}',
              style: const pw.TextStyle(fontSize: 8),
            ),

            pw.Divider(thickness: 0.5),

            // --- Títulos de la tabla de items ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Cant.',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Producto',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Precio',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Total',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 0.5),

            // --- Items de la cuenta ---
            ...cuenta.productos.map((item) {
              final cantidad = item['cantidad'] as int;
              final nombre = item['nombre'] as String;
              final precioUnitario = item['precio'] as double;
              final totalItem = (precioUnitario * cantidad);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        width: 25,
                        child: pw.Text(
                          '$cantidad',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        width: 70,
                        child: pw.Text(
                          nombre,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        width: 40,
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            formatCurrency.format(precioUnitario),
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 40,
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            formatCurrency.format(totalItem),
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.containsKey('nota') &&
                      (item['nota'] as String).isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                      child: pw.Text(
                        'Nota: ${item['nota']}',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
            pw.Divider(thickness: 0.5),

            // --- Totales ---
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL: ${formatCurrency.format(cuenta.totalCuenta)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // --- Pie de página ---
            pw.Center(
              child: pw.Text(
                '¡GRACIAS POR SU VISITA!',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
