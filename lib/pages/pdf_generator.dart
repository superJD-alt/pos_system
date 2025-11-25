// Puedes colocar esto en un archivo separado como /utils/pdf_generator.dart
import 'package:flutter/services.dart'; // Necesario para Uint8List
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/cuenta_cerrada.dart'; // Ajusta la ruta a tu modelo

Future<Uint8List> generateTicketPdf(CuentaCerrada cuenta) async {
  final pdf = pw.Document();
  // Formateador de moneda para pesos mexicanos
  final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(
        80 * PdfPageFormat.mm, // Ancho estándar de ticket de 80mm
        double.infinity, // Altura infinita para autoajustar
        marginAll: 4 * PdfPageFormat.mm, // Márgenes reducidos
      ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- Encabezado ---
            pw.Center(
              child: pw.Text(
                'NOMBRE DE TU RESTAURANTE',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'DIRECCIÓN O ESLOGAN',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.SizedBox(height: 5),

            // --- Detalles de la Venta ---
            pw.Text(
              'FOLIO: ${cuenta.id.substring(0, 8)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              'MESA: ${cuenta.numeroMesa}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              'MESERO: ${cuenta.mesero}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              'COMENSALES: ${cuenta.comensales}',
              style: const pw.TextStyle(fontSize: 8),
            ),
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
                        width: 70, // Ajusta el ancho para el nombre
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
                  // Nota del producto (si existe)
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
                  // No tienes subtotal e IVA explícitos, usamos el total directamente
                  // Si tu totalCuenta ya incluye el IVA:
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
            pw.Center(
              child: pw.Text(
                'El ticket promedio fue de ${formatCurrency.format(cuenta.ticketPromedio)} por comensal.',
                style: const pw.TextStyle(fontSize: 7),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
