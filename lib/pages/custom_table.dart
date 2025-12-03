import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/order.dart'; // Asegúrate de que OrderPage esté definido
import 'mesa_state.dart'; // Asegúrate de que MesaState esté definida e implementada
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
    // Es buena práctica restablecer las orientaciones si la aplicación
    // no espera una orientación fija en otros lugares
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    // Usamos MediaQuery.of(context).size fuera de LayoutBuilder solo para
    // el posicionamiento rígido en el modo Landscape.
    final screenSize = MediaQuery.of(context).size;

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
          final isLandscape = width > height;

          // Definición de tamaños responsivos para Portrait
          final baseSize = min(width, height) * 0.12;
          final smallTable = baseSize * 1.2;
          final mediumTable = baseSize * 1.5;
          final mediumSmallTable = baseSize * 1.35;

          final horizontalMargin = width * 0.03;
          final verticalMargin = height * 0.04;

          if (isLandscape) {
            // 🌐 DISTRIBUCIÓN HORIZONTAL (Landscape) - Usando screenSize
            return Stack(
              children: [
                //mesa 1 (2 personas)
                Positioned(
                  left: screenSize.width * 0.59,
                  top: screenSize.height * 0.38,
                  child: const MesaBase(
                    cantidadPersonas: 2,
                    ancho: 80,
                    alto: 80,
                    numeroMesa: 4,
                  ),
                ),
                //mesa 2 (2 personas)
                Positioned(
                  left: screenSize.width * 0.59,
                  top: screenSize.height * 0.08,
                  child: const MesaBase(
                    cantidadPersonas: 2,
                    ancho: 80,
                    alto: 80,
                    numeroMesa: 3,
                  ),
                ),
                // mesa 3 (4 personas)
                Positioned(
                  left: screenSize.width * 0.70,
                  top: screenSize.height * 0.59,
                  child: const MesaBase(
                    cantidadPersonas: 4,
                    ancho: 200,
                    alto: 80,
                    numeroMesa: 2,
                  ),
                ),
                //mesa 4 (4 personas)
                Positioned(
                  left: screenSize.width * 0.35,
                  top: screenSize.height * 0.33,
                  child: const MesaBase(
                    cantidadPersonas: 4,
                    ancho: 150,
                    alto: 80,
                    numeroMesa: 6,
                  ),
                ),
                //mesa 5 (6 personas)
                Positioned(
                  left: screenSize.width * 0.35,
                  top: screenSize.height * 0.08,
                  child: const MesaBase(
                    cantidadPersonas: 6,
                    ancho: 160,
                    alto: 80,
                    numeroMesa: 5,
                  ),
                ),
                //mesa 6 (6 personas)
                Positioned(
                  left: screenSize.width * 0.72,
                  top: screenSize.height * 0.18,
                  child: const MesaBase(
                    cantidadPersonas: 6,
                    ancho: 160,
                    alto: 80,
                    numeroMesa: 1,
                  ),
                ),
                //mesa 7 (8 personas)
                Positioned(
                  left: screenSize.width * 0.06,
                  top: screenSize.height * 0.33,
                  child: const MesaBase(
                    cantidadPersonas: 8,
                    ancho: 200,
                    alto: 80,
                    numeroMesa: 9,
                  ),
                ),
                //mesa 8 (8 personas)
                Positioned(
                  left: screenSize.width * 0.06,
                  top: screenSize.height * 0.58,
                  child: const MesaBase(
                    cantidadPersonas: 8,
                    ancho: 200,
                    alto: 80,
                    numeroMesa: 10,
                  ),
                ),
                //mesa 9 (8 personas)
                Positioned(
                  left: screenSize.width * 0.06,
                  top: screenSize.height * 0.08,
                  child: const MesaBase(
                    cantidadPersonas: 8,
                    ancho: 200,
                    alto: 80,
                    numeroMesa: 8,
                  ),
                ),
                //mesa 10 (10 personas)
                Positioned(
                  left: screenSize.width * 0.35,
                  top: screenSize.height * 0.58,
                  child: const MesaBase(
                    cantidadPersonas: 10,
                    ancho: 260,
                    alto: 90,
                    numeroMesa: 7,
                  ),
                ),
              ],
            );
          } else {
            // 📱 DISTRIBUCIÓN VERTICAL (Portrait) - Usando LayoutBuilder
            return SingleChildScrollView(
              child: Container(
                // Esto asegura que el SingleChildScrollView sea suficientemente largo
                height: height * 1.5,
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
        },
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

  // Agregamos un método estático para poder notificar a esta mesa
  static void actualizarMesa(BuildContext context) {
    context.findAncestorStateOfType<_MesaBaseState>()?.setState(() {});
  }

  @override
  State<MesaBase> createState() => _MesaBaseState();
}

class _MesaBaseState extends State<MesaBase> {
  // ATENCIÓN: En un sistema real, MesaState debería ser un ChangeNotifier
  // o utilizar un StreamBuilder para la reactividad.
  // Por ahora, lo mantenemos como instancia única de utilidad.
  final MesaState mesaState = MesaState();
  String numeroSeleccionado = '';

  void _mostrarTecladoComensales() {
    final bool mesaOcupada = mesaState.estaMesaOcupada(widget.numeroMesa);

    if (mesaOcupada) {
      // Caso 1: Mesa ya ocupada -> Navegar a la página de pedidos
      final int comensalesActuales = mesaState.obtenerComensales(
        widget.numeroMesa,
      )!;
      _irAOrderPage(comensalesActuales);
      return;
    }

    // Caso 2: Mesa disponible -> Mostrar teclado para abrir la mesa
    numeroSeleccionado = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenSize = MediaQuery.of(context).size;
          final screenWidth = screenSize.width;
          final screenHeight = screenSize.height;

          final isLandscape = screenWidth > screenHeight;
          final dialogWidth = isLandscape
              ? min(screenWidth * 0.5, 450.0)
              : min(screenWidth * 0.85, 400.0);

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
              padding: EdgeInsets.all(isLandscape ? 16 : 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mesa ${widget.numeroMesa}',
                      style: TextStyle(
                        fontSize: isLandscape ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: isLandscape ? 10 : 15),
                    Text(
                      'Ingresa el número de comensales',
                      style: TextStyle(
                        fontSize: isLandscape ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: isLandscape ? 10 : 15),
                    // Display del número seleccionado
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isLandscape ? 12 : 18,
                        horizontal: isLandscape ? 15 : 20,
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
                          fontSize: isLandscape ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 12 : 20),
                    // Teclado
                    _buildTecladoNumerico(
                      setDialogState,
                      dialogWidth,
                      isLandscape,
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
    bool isLandscape,
  ) {
    final buttonSize = isLandscape
        ? min((dialogWidth - 80) / 3.5, 70.0)
        : min((dialogWidth - 100) / 3.5, 90.0);

    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: isLandscape ? 3 : 4),
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
        SizedBox(height: isLandscape ? 3 : 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTeclaBorrar(buttonSize, setDialogState), // ✅ Borrar
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
            // Máximo de 2 dígitos, y no puede empezar con 0 a menos que sea 0
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

  // ✅ Tecla de borrado
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
            // Validamos que haya al menos 1 comensal
            if (comensales > 0) {
              mesaState.ocuparMesa(widget.numeroMesa, comensales);
              Navigator.pop(context); // Cierra el diálogo
              _irAOrderPage(comensales); // Navega a la página de pedidos
            } else {
              // Muestra un mensaje si los comensales son 0
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
            // Muestra un mensaje si no se ha ingresado nada
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
      // ⚠️ CRÍTICO: Usamos .then((_) => setState(() {})) para asegurar
      // que la MesaBase se reconstruya y actualice su color (rojo)
      // al volver de la página de pedidos.
    ).then((_) {
      // Forzar la reconstrucción de esta mesa específica
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool esCircular = widget.cantidadPersonas == 2;
    // La reactividad está garantizada por el setState() en _irAOrderPage
    final int? comensales = mesaState.obtenerComensales(widget.numeroMesa);
    final bool estaOcupada = mesaState.estaMesaOcupada(widget.numeroMesa);

    return GestureDetector(
      onTap: _mostrarTecladoComensales,
      child: esCircular
          ? _mesaCircular(comensales, estaOcupada)
          : _mesaRectangular(comensales, estaOcupada),
    );
  }

  // 🔹 Diseño circular (con sillas funcionales)
  Widget _mesaCircular(int? comensales, bool estaOcupada) {
    final minDimension = widget.ancho < widget.alto
        ? widget.ancho
        : widget.alto;
    final fontSize = minDimension * 0.28;
    final comensalesFontSize = fontSize * 0.70;

    // ✅ AJUSTE CLAVE: Distancia del centro de la mesa al centro de la silla
    // (Radio de la mesa + Radio de la silla (15) + GAP (5 unidades)) = radio + 20
    final double radio = minDimension / 2;
    final double chairCenterDistance = radio + 20;

    final double sillaSize = 30; // Diámetro de la silla

    // El diámetro total debe ajustarse a la nueva distancia
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
            // Usamos la nueva distancia ajustada
            final dx = chairCenterDistance * cos(angle);
            final dy = chairCenterDistance * sin(angle);

            // Determina si esta silla teórica está ocupada
            final bool isComensalPresent = comensales != null && i < comensales;

            return Positioned(
              // El centro de la silla se calcula desde el centro del Stack
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

  // 🔸 Diseño rectangular (con sillas funcionales)
  Widget _mesaRectangular(int? comensales, bool estaOcupada) {
    final List<Widget> comensalesWidgets = [];

    // ✅ AJUSTE CLAVE: Distancia de la silla a la mesa
    // (Radio de la silla (15) + GAP (5 unidades)) = 20
    final double separacion = 20;
    final double sillaSize = 30; // Diámetro de la silla

    // Calcula la cantidad de sillas que irán en los lados largos (horizontalmente)
    int personasPorLadoLargo = 0;
    if (widget.cantidadPersonas == 4 || widget.cantidadPersonas == 6) {
      personasPorLadoLargo = 2; // Dos en cada lado largo
    } else if (widget.cantidadPersonas == 8) {
      personasPorLadoLargo = 3;
    } else if (widget.cantidadPersonas == 10) {
      personasPorLadoLargo = 4;
    }

    // Lógica para distribuir las sillas
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

    // Lados Cortos (Izquierda y Derecha) - (Depende de la capacidad total)
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

    // Ajustamos el tamaño del contenedor Stack para incluir el espacio de las sillas
    // Ancho total = ancho de la mesa + 2 * (separacion + radio de la silla)
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

  // ✅ Método de construcción de silla con estado de ocupación
  Widget _buildComensal(
    double dx,
    double dy,
    int index,
    int comensalesCount,
    double size,
  ) {
    // La silla está ocupada si su índice es menor que el número de comensales.
    final bool isComensalPresent = index < comensalesCount;

    // Recalcular el tamaño del contenedor para posicionar correctamente.
    // Esto se usa para centrar el stack, no para calcular el tamaño.
    final double containerWidth = widget.ancho + 2 * (20 + 30 / 2);
    final double containerHeight = widget.alto + 2 * (20 + 30 / 2);

    return Positioned(
      // Centramos la posición, luego aplicamos el desplazamiento (dx, dy)
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
