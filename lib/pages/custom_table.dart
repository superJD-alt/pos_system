import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/order.dart';

class CustomTable extends StatelessWidget {
  const CustomTable({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Custom Tables")),
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          //mesa 1 (2 personas)
          Positioned(
            left: screenWidth * 0.05,
            top: screenHeight * 0.08,
            child: const MesaBase(
              cantidadPersonas: 2,
              ancho: 80,
              alto: 80,
              numeroMesa: 1,
            ),
          ),
          //mesa 2 (2 personas)
          Positioned(
            left: screenWidth * 0.20,
            top: screenHeight * 0.08,
            child: const MesaBase(
              cantidadPersonas: 2,
              ancho: 80,
              alto: 80,
              numeroMesa: 2,
            ),
          ),

          // mesa 3 (4 personas)
          Positioned(
            left: screenWidth * 0.05,
            top: screenHeight * 0.33,
            child: const MesaBase(
              cantidadPersonas: 4,
              ancho: 100,
              alto: 100,
              numeroMesa: 3,
            ),
          ),
          //mesa 4 (4 personas)
          Positioned(
            left: screenWidth * 0.28,
            top: screenHeight * 0.33,
            child: const MesaBase(
              cantidadPersonas: 4,
              ancho: 100,
              alto: 100,
              numeroMesa: 4,
            ),
          ),

          //mesa 5 (6 personas)
          Positioned(
            left: screenWidth * 0.40,
            top: screenHeight * 0.08,
            child: const MesaBase(
              cantidadPersonas: 6,
              ancho: 160,
              alto: 80,
              numeroMesa: 5,
            ),
          ),
          //mesa 6 (6 personas)
          Positioned(
            left: screenWidth * 0.69,
            top: screenHeight * 0.08,
            child: const MesaBase(
              cantidadPersonas: 6,
              ancho: 160,
              alto: 80,
              numeroMesa: 6,
            ),
          ),

          //mesa 7 (8 personas)
          Positioned(
            left: screenWidth * 0.55,
            top: screenHeight * 0.30,
            child: const MesaBase(
              cantidadPersonas: 8,
              ancho: 200,
              alto: 80,
              numeroMesa: 7,
            ),
          ),
          //mesa 8 (8 personas)
          Positioned(
            left: screenWidth * 0.38,
            top: screenHeight * 0.58,
            child: const MesaBase(
              cantidadPersonas: 8,
              ancho: 200,
              alto: 80,
              numeroMesa: 8,
            ),
          ),
          //mesa 9 (8 personas)
          Positioned(
            left: screenWidth * 0.71,
            top: screenHeight * 0.58,
            child: const MesaBase(
              cantidadPersonas: 8,
              ancho: 200,
              alto: 80,
              numeroMesa: 9,
            ),
          ),

          //mesa 10 (10 personas)
          Positioned(
            left: screenWidth * 0.05,
            top: screenHeight * 0.58,
            child: const MesaBase(
              cantidadPersonas: 10,
              ancho: 260,
              alto: 90,
              numeroMesa: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 🟦 WIDGET BASE (mesa + distribución de comensales)
// ----------------------------------------------------
class MesaBase extends StatefulWidget {
  final int cantidadPersonas;
  final double ancho;
  final double alto;
  final int numeroMesa;

  const MesaBase({
    super.key,
    required this.cantidadPersonas,
    required this.ancho,
    required this.alto,
    required this.numeroMesa,
  });

  @override
  State<MesaBase> createState() => _MesaBaseState();
}

class _MesaBaseState extends State<MesaBase> {
  int? comensalesActuales;
  String numeroSeleccionado = '';

  void _mostrarTecladoComensales() {
    setState(() {
      numeroSeleccionado = '';
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Mesa ${widget.numeroMesa}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Cuántos comensales?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                // Display del número seleccionado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Text(
                    numeroSeleccionado.isNotEmpty ? numeroSeleccionado : '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: numeroSeleccionado.isNotEmpty
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTecladoNumerico(setDialogState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTecladoNumerico(StateSetter setDialogState) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeclaNumero('1', setDialogState),
            _buildTeclaNumero('2', setDialogState),
            _buildTeclaNumero('3', setDialogState),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeclaNumero('4', setDialogState),
            _buildTeclaNumero('5', setDialogState),
            _buildTeclaNumero('6', setDialogState),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeclaNumero('7', setDialogState),
            _buildTeclaNumero('8', setDialogState),
            _buildTeclaNumero('9', setDialogState),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeclaNumero('0', setDialogState),
            _buildTeclaConfirmar(),
            _buildTeclaLimpiar(),
          ],
        ),
      ],
    );
  }

  Widget _buildTeclaNumero(String numero, StateSetter setDialogState) {
    return ElevatedButton(
      onPressed: () {
        setDialogState(() {
          // Limitar a 2 dígitos máximo
          if (numeroSeleccionado.length < 2) {
            numeroSeleccionado += numero;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(60, 60),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        numero,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTeclaConfirmar() {
    return ElevatedButton(
      onPressed: () {
        if (numeroSeleccionado.isNotEmpty) {
          int comensales = int.parse(numeroSeleccionado);
          if (comensales > 0) {
            setState(() {
              comensalesActuales = comensales;
            });
            Navigator.pop(context);

            // Navegar a OrderPage con los parámetros
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderPage(
                  numeroMesa: widget.numeroMesa,
                  comensales: comensales,
                ),
              ),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(60, 60),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Icon(Icons.check, size: 28),
    );
  }

  Widget _buildTeclaLimpiar() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          comensalesActuales = null;
        });
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(60, 60),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Icon(Icons.clear, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esCircular = widget.cantidadPersonas <= 4;
    return GestureDetector(
      onTap: _mostrarTecladoComensales,
      child: esCircular ? _mesaCircular() : _mesaRectangular(),
    );
  }

  // 🔹 Diseño circular (2 o 4 personas)
  Widget _mesaCircular() {
    double radio = (max(widget.ancho, widget.alto) / 2) + 30;
    double diametroTotal = (radio + 20) * 2;

    return SizedBox(
      width: diametroTotal,
      height: diametroTotal,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.ancho,
            height: widget.alto,
            decoration: BoxDecoration(
              color: comensalesActuales != null ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.numeroMesa}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (comensalesActuales != null)
                    Text(
                      '$comensalesActuales',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ...List.generate(widget.cantidadPersonas, (i) {
            final angle = (2 * pi / widget.cantidadPersonas) * i - pi / 2;
            final dx = radio * cos(angle);
            final dy = radio * sin(angle);

            return Positioned(
              left: diametroTotal / 2 + dx - 15,
              top: diametroTotal / 2 + dy - 15,
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.orange,
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🔸 Diseño rectangular (más de 4 personas)
  Widget _mesaRectangular() {
    const double separacion = 20;

    List<Widget> comensales = [];

    // Calcular distribución según cantidad de personas
    int personasPorLadoLargo = 0;

    if (widget.cantidadPersonas == 6) {
      personasPorLadoLargo = 2;
    } else if (widget.cantidadPersonas == 8) {
      personasPorLadoLargo = 3;
    } else if (widget.cantidadPersonas == 10) {
      personasPorLadoLargo = 4;
    }

    // 🔹 Cabecera izquierda
    comensales.add(_buildComensal(-widget.ancho / 2 - separacion, 0));

    // 🔹 Lado superior
    for (int i = 0; i < personasPorLadoLargo; i++) {
      double x =
          (widget.ancho / (personasPorLadoLargo + 1)) * (i + 1) -
          widget.ancho / 2;
      comensales.add(_buildComensal(x, -widget.alto / 2 - separacion));
    }

    // 🔹 Cabecera derecha
    comensales.add(_buildComensal(widget.ancho / 2 + separacion, 0));

    // 🔹 Lado inferior
    for (int i = 0; i < personasPorLadoLargo; i++) {
      double x =
          (widget.ancho / (personasPorLadoLargo + 1)) * (i + 1) -
          widget.ancho / 2;
      comensales.add(_buildComensal(x, widget.alto / 2 + separacion));
    }

    return SizedBox(
      width: widget.ancho + 120,
      height: widget.alto + 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.ancho,
            height: widget.alto,
            decoration: BoxDecoration(
              color: comensalesActuales != null ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.numeroMesa}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (comensalesActuales != null)
                    Text(
                      '$comensalesActuales',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ...comensales,
        ],
      ),
    );
  }

  Widget _buildComensal(double dx, double dy) {
    return Positioned(
      left: (widget.ancho + 120) / 2 + dx - 15,
      top: (widget.alto + 120) / 2 + dy - 15,
      child: const CircleAvatar(radius: 15, backgroundColor: Colors.orange),
    );
  }
}
