import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/order.dart';
import 'mesa_state.dart';
import 'package:flutter/services.dart';

class CustomTable extends StatefulWidget {
  const CustomTable({super.key});

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  @override
  void initState() {
    super.initState();
    print('🔓 Permitiendo todas las orientaciones');
    _setOrientation([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    print('🔓 Manteniendo todas las orientaciones');
    super.dispose();
  }

  Future<void> _setOrientation(List<DeviceOrientation> orientations) async {
    try {
      await SystemChrome.setPreferredOrientations(orientations);
      print('✅ Orientación cambiada exitosamente');
    } catch (e) {
      print('❌ Error al cambiar orientación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selección de mesas"),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // ✅ Determinar tipo de pantalla
          bool isSmallScreen = width < 600;
          bool isMediumScreen = width >= 600 && width < 1200;
          bool isLargeScreen = width >= 1200;
          bool isLandscape = width > height;

          // ✅ Tamaños base responsivos
          final baseSize =
              min(width, height) *
              (isSmallScreen
                  ? 0.12
                  : isMediumScreen
                  ? 0.10
                  : 0.08);
          final smallTable = baseSize * 1.2;
          final mediumTable = baseSize * 1.5;
          final mediumSmallTable = baseSize * 1.35;

          final horizontalMargin = width * (isSmallScreen ? 0.03 : 0.04);
          final verticalMargin = height * (isSmallScreen ? 0.04 : 0.05);

          if (isLargeScreen && isLandscape) {
            // 🖥️ PANTALLAS GRANDES EN LANDSCAPE
            return _buildLargeLandscapeLayout(width, height);
          } else if (isMediumScreen && isLandscape) {
            // 💻 PANTALLAS MEDIANAS EN LANDSCAPE
            return _buildMediumLandscapeLayout(width, height);
          } else if (isSmallScreen && isLandscape) {
            // 📱 PANTALLAS PEQUEÑAS EN LANDSCAPE
            return _buildSmallLandscapeLayout(width, height);
          } else {
            // 📱 MODO PORTRAIT (Todas las pantallas)
            return _buildPortraitLayout(
              width,
              height,
              baseSize,
              smallTable,
              mediumTable,
              mediumSmallTable,
              horizontalMargin,
              verticalMargin,
              isSmallScreen,
            );
          }
        },
      ),
    );
  }

  // 🖥️ Layout para pantallas grandes en landscape
  Widget _buildLargeLandscapeLayout(double width, double height) {
    return Stack(
      children: [
        // Mesas de 2 personas
        Positioned(
          left: width * 0.59,
          top: height * 0.38,
          child: const MesaBase(
            cantidadPersonas: 2,
            ancho: 90,
            alto: 90,
            numeroMesa: 4,
          ),
        ),
        Positioned(
          left: width * 0.59,
          top: height * 0.08,
          child: const MesaBase(
            cantidadPersonas: 2,
            ancho: 90,
            alto: 90,
            numeroMesa: 3,
          ),
        ),
        // Mesas de 4 personas
        Positioned(
          left: width * 0.70,
          top: height * 0.59,
          child: const MesaBase(
            cantidadPersonas: 4,
            ancho: 220,
            alto: 90,
            numeroMesa: 2,
          ),
        ),
        Positioned(
          left: width * 0.35,
          top: height * 0.33,
          child: const MesaBase(
            cantidadPersonas: 4,
            ancho: 170,
            alto: 90,
            numeroMesa: 6,
          ),
        ),
        // Mesas de 6 personas
        Positioned(
          left: width * 0.35,
          top: height * 0.08,
          child: const MesaBase(
            cantidadPersonas: 6,
            ancho: 180,
            alto: 90,
            numeroMesa: 5,
          ),
        ),
        Positioned(
          left: width * 0.72,
          top: height * 0.18,
          child: const MesaBase(
            cantidadPersonas: 6,
            ancho: 180,
            alto: 90,
            numeroMesa: 1,
          ),
        ),
        // Mesas de 8 personas
        Positioned(
          left: width * 0.06,
          top: height * 0.33,
          child: const MesaBase(
            cantidadPersonas: 8,
            ancho: 220,
            alto: 90,
            numeroMesa: 9,
          ),
        ),
        Positioned(
          left: width * 0.06,
          top: height * 0.58,
          child: const MesaBase(
            cantidadPersonas: 8,
            ancho: 220,
            alto: 90,
            numeroMesa: 10,
          ),
        ),
        Positioned(
          left: width * 0.06,
          top: height * 0.08,
          child: const MesaBase(
            cantidadPersonas: 8,
            ancho: 220,
            alto: 90,
            numeroMesa: 8,
          ),
        ),
        // Mesa de 10 personas
        Positioned(
          left: width * 0.35,
          top: height * 0.58,
          child: const MesaBase(
            cantidadPersonas: 10,
            ancho: 280,
            alto: 100,
            numeroMesa: 7,
          ),
        ),
      ],
    );
  }

  // 💻 Layout para pantallas medianas en landscape
  Widget _buildMediumLandscapeLayout(double width, double height) {
    return Stack(
      children: [
        Positioned(
          left: width * 0.59,
          top: height * 0.38,
          child: const MesaBase(
            cantidadPersonas: 2,
            ancho: 75,
            alto: 75,
            numeroMesa: 4,
          ),
        ),
        Positioned(
          left: width * 0.59,
          top: height * 0.08,
          child: const MesaBase(
            cantidadPersonas: 2,
            ancho: 75,
            alto: 75,
            numeroMesa: 3,
          ),
        ),
        Positioned(
          left: width * 0.70,
          top: height * 0.59,
          child: const MesaBase(
            cantidadPersonas: 4,
            ancho: 180,
            alto: 75,
            numeroMesa: 2,
          ),
        ),
        Positioned(
          left: width * 0.35,
          top: height * 0.33,
          child: const MesaBase(
            cantidadPersonas: 4,
            ancho: 140,
            alto: 75,
            numeroMesa: 6,
          ),
        ),
        Positioned(
          left: width * 0.35,
          top: height * 0.08,
          child: const MesaBase(
            cantidadPersonas: 6,
            ancho: 150,
            alto: 75,
            numeroMesa: 5,
          ),
        ),
        Positioned(
          left: width * 0.72,
          top: height * 0.18,
          child: const MesaBase(
            cantidadPersonas: 6,
            ancho: 150,
            alto: 75,
            numeroMesa: 1,
          ),
        ),
        Positioned(
          left: width * 0.06,
          top: height * 0.33,
          child: const MesaBase(
            cantidadPersonas: 8,
            ancho: 180,
            alto: 75,
            numeroMesa: 9,
          ),
        ),
        Positioned(
          left: width * 0.06,
          top: height * 0.58,
          child: const MesaBase(
            cantidadPersonas: 8,
            ancho: 180,
            alto: 75,
            numeroMesa: 10,
          ),
        ),
        Positioned(
          left: width * 0.06,
          top: height * 0.08,
          child: const MesaBase(
            cantidadPersonas: 8,
            ancho: 180,
            alto: 75,
            numeroMesa: 8,
          ),
        ),
        Positioned(
          left: width * 0.35,
          top: height * 0.58,
          child: const MesaBase(
            cantidadPersonas: 10,
            ancho: 240,
            alto: 85,
            numeroMesa: 7,
          ),
        ),
      ],
    );
  }

  // 📱 Layout para pantallas pequeñas en landscape
  Widget _buildSmallLandscapeLayout(double width, double height) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width * 1.5,
        height: height,
        child: Stack(
          children: [
            Positioned(
              left: width * 0.65,
              top: height * 0.38,
              child: const MesaBase(
                cantidadPersonas: 2,
                ancho: 60,
                alto: 60,
                numeroMesa: 4,
              ),
            ),
            Positioned(
              left: width * 0.65,
              top: height * 0.08,
              child: const MesaBase(
                cantidadPersonas: 2,
                ancho: 60,
                alto: 60,
                numeroMesa: 3,
              ),
            ),
            Positioned(
              left: width * 0.85,
              top: height * 0.59,
              child: const MesaBase(
                cantidadPersonas: 4,
                ancho: 140,
                alto: 60,
                numeroMesa: 2,
              ),
            ),
            Positioned(
              left: width * 0.40,
              top: height * 0.33,
              child: const MesaBase(
                cantidadPersonas: 4,
                ancho: 120,
                alto: 60,
                numeroMesa: 6,
              ),
            ),
            Positioned(
              left: width * 0.40,
              top: height * 0.08,
              child: const MesaBase(
                cantidadPersonas: 6,
                ancho: 130,
                alto: 60,
                numeroMesa: 5,
              ),
            ),
            Positioned(
              left: width * 0.85,
              top: height * 0.18,
              child: const MesaBase(
                cantidadPersonas: 6,
                ancho: 130,
                alto: 60,
                numeroMesa: 1,
              ),
            ),
            Positioned(
              left: width * 0.05,
              top: height * 0.33,
              child: const MesaBase(
                cantidadPersonas: 8,
                ancho: 150,
                alto: 60,
                numeroMesa: 9,
              ),
            ),
            Positioned(
              left: width * 0.05,
              top: height * 0.58,
              child: const MesaBase(
                cantidadPersonas: 8,
                ancho: 150,
                alto: 60,
                numeroMesa: 10,
              ),
            ),
            Positioned(
              left: width * 0.05,
              top: height * 0.08,
              child: const MesaBase(
                cantidadPersonas: 8,
                ancho: 150,
                alto: 60,
                numeroMesa: 8,
              ),
            ),
            Positioned(
              left: width * 0.40,
              top: height * 0.58,
              child: const MesaBase(
                cantidadPersonas: 10,
                ancho: 200,
                alto: 70,
                numeroMesa: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📱 Layout para modo portrait (todas las pantallas)
  Widget _buildPortraitLayout(
    double width,
    double height,
    double baseSize,
    double smallTable,
    double mediumTable,
    double mediumSmallTable,
    double horizontalMargin,
    double verticalMargin,
    bool isSmallScreen,
  ) {
    return SingleChildScrollView(
      child: Container(
        height: height * (isSmallScreen ? 1.5 : 1.3),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalMargin * 2,
          vertical: verticalMargin,
        ),
        child: Stack(
          children: [
            // ========== SECCIÓN SUPERIOR ==========
            Positioned(
              left: width * 0.05,
              top: 0,
              child: MesaBase(
                cantidadPersonas: 6,
                ancho: width * 0.55,
                alto: baseSize * 0.9,
                numeroMesa: 8,
              ),
            ),
            Positioned(
              right: width * 0.05,
              top: baseSize * 0.1,
              child: MesaBase(
                cantidadPersonas: 2,
                ancho: smallTable,
                alto: smallTable,
                numeroMesa: 3,
              ),
            ),
            // ========== SECCIÓN ALTA ==========
            Positioned(
              left: width * 0.08,
              top: height * 0.12,
              child: MesaBase(
                cantidadPersonas: 2,
                ancho: smallTable,
                alto: smallTable,
                numeroMesa: 11,
              ),
            ),
            Positioned(
              right: width * 0.08,
              top: height * 0.14,
              child: MesaBase(
                cantidadPersonas: 4,
                ancho: mediumTable,
                alto: mediumTable,
                numeroMesa: 5,
              ),
            ),
            // ========== SECCIÓN MEDIA-ALTA ==========
            Positioned(
              left: width * 0.05,
              top: height * 0.24,
              child: MesaBase(
                cantidadPersonas: 6,
                ancho: width * 0.55,
                alto: baseSize * 0.9,
                numeroMesa: 1,
              ),
            ),
            Positioned(
              right: width * 0.08,
              top: height * 0.26,
              child: MesaBase(
                cantidadPersonas: 3,
                ancho: mediumSmallTable,
                alto: mediumSmallTable,
                numeroMesa: 13,
              ),
            ),
            // ========== SECCIÓN CENTRO ==========
            Positioned(
              left: width * 0.05,
              top: height * 0.38,
              child: MesaBase(
                cantidadPersonas: 6,
                ancho: width * 0.55,
                alto: baseSize * 0.9,
                numeroMesa: 9,
              ),
            ),
            Positioned(
              right: width * 0.05,
              top: height * 0.39,
              child: MesaBase(
                cantidadPersonas: 2,
                ancho: smallTable,
                alto: smallTable,
                numeroMesa: 12,
              ),
            ),
            // ========== SECCIÓN MEDIA ==========
            Positioned(
              left: width * 0.08,
              top: height * 0.50,
              child: MesaBase(
                cantidadPersonas: 2,
                ancho: smallTable,
                alto: smallTable,
                numeroMesa: 4,
              ),
            ),
            Positioned(
              right: width * 0.08,
              top: height * 0.52,
              child: MesaBase(
                cantidadPersonas: 4,
                ancho: mediumTable,
                alto: mediumTable,
                numeroMesa: 6,
              ),
            ),
            // ========== SECCIÓN MEDIA-BAJA ==========
            Positioned(
              left: width * 0.05,
              top: height * 0.64,
              child: MesaBase(
                cantidadPersonas: 6,
                ancho: width * 0.55,
                alto: baseSize * 0.9,
                numeroMesa: 10,
              ),
            ),
            Positioned(
              right: width * 0.08,
              top: height * 0.66,
              child: MesaBase(
                cantidadPersonas: 4,
                ancho: mediumTable,
                alto: mediumTable,
                numeroMesa: 2,
              ),
            ),
            // ========== SECCIÓN INFERIOR ==========
            Positioned(
              left: width * 0.1,
              top: height * 0.82,
              child: MesaBase(
                cantidadPersonas: 10,
                ancho: width * 0.75,
                alto: baseSize * 1.0,
                numeroMesa: 7,
              ),
            ),
          ],
        ),
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

  static void actualizarMesa(BuildContext context) {
    context.findAncestorStateOfType<_MesaBaseState>()?.setState(() {});
  }

  @override
  State<MesaBase> createState() => _MesaBaseState();
}

class _MesaBaseState extends State<MesaBase> {
  final MesaState mesaState = MesaState();
  String numeroSeleccionado = '';

  void _mostrarTecladoComensales() {
    final bool mesaOcupada = mesaState.estaMesaOcupada(widget.numeroMesa);

    if (mesaOcupada) {
      final int comensalesActuales = mesaState.obtenerComensales(
        widget.numeroMesa,
      )!;
      _irAOrderPage(comensalesActuales);
      return;
    }

    numeroSeleccionado = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenSize = MediaQuery.of(context).size;
          final screenWidth = screenSize.width;
          final screenHeight = screenSize.height;

          // ✅ Responsividad mejorada para el diálogo
          final isSmallScreen = screenWidth < 600;
          final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
          final isLargeScreen = screenWidth >= 900;
          final isLandscape = screenWidth > screenHeight;

          final dialogWidth = isSmallScreen
              ? min(screenWidth * 0.90, 380.0)
              : isMediumScreen
              ? min(screenWidth * 0.70, 450.0)
              : min(screenWidth * 0.50, 500.0);

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(
                maxHeight: screenHeight * (isSmallScreen ? 0.85 : 0.75),
              ),
              padding: EdgeInsets.all(
                isSmallScreen
                    ? 16
                    : isMediumScreen
                    ? 20
                    : 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mesa ${widget.numeroMesa}',
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? 22
                            : isMediumScreen
                            ? 26
                            : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Ingresa el número de comensales',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    // Display del número seleccionado
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 18,
                        horizontal: isSmallScreen ? 16 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Text(
                        numeroSeleccionado.isNotEmpty
                            ? numeroSeleccionado
                            : '0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 32
                              : isMediumScreen
                              ? 38
                              : 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 14 : 20),
                    // Teclado
                    _buildTecladoNumerico(
                      setDialogState,
                      dialogWidth,
                      isSmallScreen,
                      isMediumScreen,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTecladoNumerico(
    StateSetter setDialogState,
    double dialogWidth,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    final buttonSize = isSmallScreen
        ? min((dialogWidth - 80) / 3.5, 85.0)
        : isMediumScreen
        ? min((dialogWidth - 100) / 3.5, 95.0)
        : min((dialogWidth - 120) / 3.5, 105.0);

    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 1; col <= 3; col++)
                  _buildTeclaNumero(
                    '${row * 3 + col}',
                    setDialogState,
                    buttonSize,
                  ),
              ],
            ),
          ),
        SizedBox(height: isSmallScreen ? 4 : 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeclaBorrar(buttonSize, setDialogState),
            _buildTeclaNumero('0', setDialogState, buttonSize),
            _buildTeclaConfirmar(buttonSize),
          ],
        ),
      ],
    );
  }

  Widget _buildTeclaNumero(
    String numero,
    StateSetter setDialogState,
    double size,
  ) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: ElevatedButton(
        onPressed: () {
          setDialogState(() {
            if (numeroSeleccionado.length < 2 &&
                !(numeroSeleccionado.isEmpty && numero == '0')) {
              numeroSeleccionado += numero;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            numero,
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeclaBorrar(double size, StateSetter setDialogState) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: ElevatedButton(
        onPressed: () {
          setDialogState(() {
            if (numeroSeleccionado.isNotEmpty) {
              numeroSeleccionado = numeroSeleccionado.substring(
                0,
                numeroSeleccionado.length - 1,
              );
            }
          });
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(Icons.backspace_outlined, size: size * 0.45),
        ),
      ),
    );
  }

  Widget _buildTeclaConfirmar(double size) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: ElevatedButton(
        onPressed: () {
          if (numeroSeleccionado.isNotEmpty) {
            int comensales = int.tryParse(numeroSeleccionado) ?? 0;
            if (comensales > 0) {
              mesaState.ocuparMesa(widget.numeroMesa, comensales);
              Navigator.pop(context);
              _irAOrderPage(comensales);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Debe haber al menos 1 comensal para abrir la mesa.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, ingresa el número de comensales.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(Icons.check, size: size * 0.5),
        ),
      ),
    );
  }

  void _irAOrderPage(int comensales) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OrderPage(numeroMesa: widget.numeroMesa, comensales: comensales),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool esCircular = widget.cantidadPersonas == 2;
    final int? comensales = mesaState.obtenerComensales(widget.numeroMesa);
    final bool estaOcupada = mesaState.estaMesaOcupada(widget.numeroMesa);

    return GestureDetector(
      onTap: _mostrarTecladoComensales,
      child: esCircular
          ? _mesaCircular(comensales, estaOcupada)
          : _mesaRectangular(comensales, estaOcupada),
    );
  }

  Widget _mesaCircular(int? comensales, bool estaOcupada) {
    final minDimension = widget.ancho < widget.alto
        ? widget.ancho
        : widget.alto;
    final fontSize = minDimension * 0.28;
    final comensalesFontSize = fontSize * 0.70;

    final double radio = minDimension / 2;
    final double chairCenterDistance = radio + 20;
    final double sillaSize = 30;
    final double diametroTotal = 2 * (chairCenterDistance + sillaSize / 2);

    return SizedBox(
      width: diametroTotal,
      height: diametroTotal,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. La Mesa
          Container(
            width: widget.ancho,
            height: widget.alto,
            decoration: BoxDecoration(
              color: estaOcupada ? Colors.red[700] : Colors.green[600],
              borderRadius: BorderRadius.circular(widget.ancho * 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.numeroMesa}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (comensales != null)
                    Text(
                      '$comensales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: comensalesFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 2. Las Sillas
          ...List.generate(widget.cantidadPersonas, (i) {
            final angle = (2 * pi / widget.cantidadPersonas) * i - pi / 2;
            final dx = chairCenterDistance * cos(angle);
            final dy = chairCenterDistance * sin(angle);

            final bool isComensalPresent = comensales != null && i < comensales;

            return Positioned(
              left: diametroTotal / 2 + dx - sillaSize / 2,
              top: diametroTotal / 2 + dy - sillaSize / 2,
              child: CircleAvatar(
                radius: sillaSize / 2,
                backgroundColor: isComensalPresent
                    ? Colors.orange
                    : Colors.grey[400],
                child: isComensalPresent
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _mesaRectangular(int? comensales, bool estaOcupada) {
    final List<Widget> comensalesWidgets = [];

    final double separacion = 20;
    final double sillaSize = 30;

    int personasPorLadoLargo = 0;
    if (widget.cantidadPersonas == 4 || widget.cantidadPersonas == 6) {
      personasPorLadoLargo = 2;
    } else if (widget.cantidadPersonas == 8) {
      personasPorLadoLargo = 3;
    } else if (widget.cantidadPersonas == 10) {
      personasPorLadoLargo = 4;
    }

    int comensalesCount = comensales ?? 0;
    int sillaIndex = 0;

    // Lados Largos (Arriba y Abajo)
    for (int i = 0; i < personasPorLadoLargo; i++) {
      // Arriba
      double x_top =
          (widget.ancho / (personasPorLadoLargo + 1)) * (i + 1) -
          widget.ancho / 2;
      comensalesWidgets.add(
        _buildComensal(
          x_top,
          -widget.alto / 2 - separacion,
          sillaIndex++,
          comensalesCount,
          sillaSize,
        ),
      );
      // Abajo
      double x_bottom =
          (widget.ancho / (personasPorLadoLargo + 1)) * (i + 1) -
          widget.ancho / 2;
      comensalesWidgets.add(
        _buildComensal(
          x_bottom,
          widget.alto / 2 + separacion,
          sillaIndex++,
          comensalesCount,
          sillaSize,
        ),
      );
    }

    // Lados Cortos (Izquierda y Derecha)
    int sillasRestantes = widget.cantidadPersonas - (personasPorLadoLargo * 2);
    if (sillasRestantes > 0) {
      // Izquierda
      comensalesWidgets.add(
        _buildComensal(
          -widget.ancho / 2 - separacion,
          0,
          sillaIndex++,
          comensalesCount,
          sillaSize,
        ),
      );
      if (sillasRestantes > 1) {
        // Derecha
        comensalesWidgets.add(
          _buildComensal(
            widget.ancho / 2 + separacion,
            0,
            sillaIndex++,
            comensalesCount,
            sillaSize,
          ),
        );
      }
    }

    final double containerWidth =
        widget.ancho + 2 * (separacion + sillaSize / 2);
    final double containerHeight =
        widget.alto + 2 * (separacion + sillaSize / 2);

    final minDimension = widget.ancho < widget.alto
        ? widget.ancho
        : widget.alto;
    final fontSize = minDimension * 0.22;
    final comensalesFontSize = fontSize * 0.70;

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. La Mesa
          Container(
            width: widget.ancho,
            height: widget.alto,
            decoration: BoxDecoration(
              color: estaOcupada ? Colors.red[700] : Colors.green[600],
              borderRadius: BorderRadius.circular(minDimension * 0.075),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.numeroMesa}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (comensales != null)
                    Text(
                      '$comensales',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: comensalesFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 2. Las Sillas
          ...comensalesWidgets,
        ],
      ),
    );
  }

  Widget _buildComensal(
    double dx,
    double dy,
    int index,
    int comensalesCount,
    double size,
  ) {
    final bool isComensalPresent = index < comensalesCount;

    final double containerWidth = widget.ancho + 2 * (20 + 30 / 2);
    final double containerHeight = widget.alto + 2 * (20 + 30 / 2);

    return Positioned(
      left: containerWidth / 2 + dx - (size / 2),
      top: containerHeight / 2 + dy - (size / 2),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: isComensalPresent ? Colors.orange : Colors.grey[400],
        child: isComensalPresent
            ? const Icon(Icons.person, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
