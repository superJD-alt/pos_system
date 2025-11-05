import 'dart:math';
import 'package:flutter/material.dart';
import 'mesa_state.dart';

class ViewTable extends StatelessWidget {
  const ViewTable({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de Mesas"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
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
// 🟦 WIDGET BASE (SOLO VISUALIZACIÓN)
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
  final MesaState mesaState = MesaState();

  // ✅ MODIFICADO: Solo mostrar información, sin permitir aperturar
  void _mostrarInformacionMesa() {
    final bool mesaOcupada = mesaState.estaMesaOcupada(widget.numeroMesa);
    final int? comensales = mesaState.obtenerComensales(widget.numeroMesa);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              mesaOcupada ? Icons.info : Icons.check_circle,
              color: mesaOcupada ? Colors.orange : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text('Mesa ${widget.numeroMesa}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de la mesa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mesaOcupada ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mesaOcupada ? Colors.red : Colors.green,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    mesaOcupada ? '🔴 OCUPADA' : '🟢 DISPONIBLE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mesaOcupada ? Colors.red : Colors.green,
                    ),
                  ),
                  if (mesaOcupada && comensales != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '$comensales comensal${comensales != 1 ? 'es' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Información adicional
            Row(
              children: [
                const Icon(Icons.chair, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Capacidad: ${widget.cantidadPersonas} personas',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            if (!mesaOcupada) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta mesa está disponible para nuevos clientes',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esCircular = widget.cantidadPersonas <= 4;
    final int? comensales = mesaState.obtenerComensales(widget.numeroMesa);
    final bool estaOcupada = mesaState.estaMesaOcupada(widget.numeroMesa);

    return GestureDetector(
      onTap: _mostrarInformacionMesa, // ✅ MODIFICADO: Solo mostrar info
      child: esCircular
          ? _mesaCircular(comensales, estaOcupada)
          : _mesaRectangular(comensales, estaOcupada),
    );
  }

  // 🔹 Diseño circular
  Widget _mesaCircular(int? comensales, bool estaOcupada) {
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
              // VERDE = disponible, ROJO = ocupada
              color: estaOcupada ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: estaOcupada
                      ? Colors.red.withOpacity(0.4)
                      : Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
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
                  if (comensales != null)
                    Text(
                      '$comensales',
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

  // 🔸 Diseño rectangular
  Widget _mesaRectangular(int? comensales, bool estaOcupada) {
    const double separacion = 20;
    List<Widget> comensalesWidgets = [];

    int personasPorLadoLargo = 0;
    if (widget.cantidadPersonas == 6)
      personasPorLadoLargo = 2;
    else if (widget.cantidadPersonas == 8)
      personasPorLadoLargo = 3;
    else if (widget.cantidadPersonas == 10)
      personasPorLadoLargo = 4;

    comensalesWidgets.add(_buildComensal(-widget.ancho / 2 - separacion, 0));
    for (int i = 0; i < personasPorLadoLargo; i++) {
      double x =
          (widget.ancho / (personasPorLadoLargo + 1)) * (i + 1) -
          widget.ancho / 2;
      comensalesWidgets.add(_buildComensal(x, -widget.alto / 2 - separacion));
    }
    comensalesWidgets.add(_buildComensal(widget.ancho / 2 + separacion, 0));
    for (int i = 0; i < personasPorLadoLargo; i++) {
      double x =
          (widget.ancho / (personasPorLadoLargo + 1)) * (i + 1) -
          widget.ancho / 2;
      comensalesWidgets.add(_buildComensal(x, widget.alto / 2 + separacion));
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
              // VERDE = disponible, ROJO = ocupada
              color: estaOcupada ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: estaOcupada
                      ? Colors.red.withOpacity(0.4)
                      : Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
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
                  if (comensales != null)
                    Text(
                      '$comensales',
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
          ...comensalesWidgets,
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
