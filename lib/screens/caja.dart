import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pos_system/widgets/content_card.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({Key? key}) : super(key: key);

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _cajaActualId;
  Map<String, dynamic>? _cajaActual;
  bool _cargando = true;

  // Control de usuarios autorizados
  List<Map<String, dynamic>> _usuariosAutorizados = [];
  String? _usuarioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarUsuariosAutorizados();
    _verificarCajaAbierta();
  }

  // Cargar usuarios con rol "cajero" o "administrador"
  Future<void> _cargarUsuariosAutorizados() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('rol', whereIn: ['cajero', 'administrador'])
          .get();

      setState(() {
        _usuariosAutorizados = snapshot.docs
            .map(
              (doc) => {
                'id': doc.id,
                'nombre': doc.data()['nombre'] ?? 'Sin nombre',
                'rol': doc.data()['rol'] ?? '',
              },
            )
            .toList();
      });
    } catch (e) {
      print('Error al cargar usuarios: $e');
    }
  }

  Future<void> _verificarCajaAbierta() async {
    setState(() => _cargando = true);

    try {
      // Consulta simplificada - NO requiere índice
      final snapshot = await _firestore
          .collection('cajas')
          .where('estado', isEqualTo: 'abierta')
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Si hay múltiples cajas abiertas (no debería pasar), tomar la primera
        setState(() {
          _cajaActualId = snapshot.docs.first.id;
          _cajaActual = snapshot.docs.first.data();
        });
      }
    } catch (e) {
      print('Error al verificar caja: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _mostrarDialogoAperturaCaja() async {
    // Verificar que haya usuarios autorizados
    if (_usuariosAutorizados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ No hay usuarios autorizados. Registra cajeros o administradores primero.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final fondoController = TextEditingController(text: '1000');
    String? cajeroSeleccionado = _usuariosAutorizados.first['id'];
    String turnoSeleccionado = 'mañana';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.lock_open, color: Colors.green),
              SizedBox(width: 8),
              Text('Apertura de Caja'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de usuario autorizado
                  DropdownButtonFormField<String>(
                    value: cajeroSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Cajero / Administrador',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: _usuariosAutorizados.map((usuario) {
                      return DropdownMenuItem<String>(
                        value: usuario['id'],
                        child: Row(
                          children: [
                            Text(usuario['nombre']),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: usuario['rol'] == 'administrador'
                                    ? Colors.purple.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                usuario['rol'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: usuario['rol'] == 'administrador'
                                      ? Colors.purple.shade900
                                      : Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    validator: (v) => v == null ? 'Selecciona un cajero' : null,
                    onChanged: (v) =>
                        setDialogState(() => cajeroSeleccionado = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: turnoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Turno',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'mañana', child: Text('Mañana')),
                      DropdownMenuItem(value: 'tarde', child: Text('Tarde')),
                      DropdownMenuItem(value: 'noche', child: Text('Noche')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => turnoSeleccionado = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: fondoController,
                    decoration: const InputDecoration(
                      labelText: 'Fondo Inicial',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v!) == null ? 'Monto inválido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Abrir Caja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Obtener nombre del cajero seleccionado
                  final cajero = _usuariosAutorizados.firstWhere(
                    (u) => u['id'] == cajeroSeleccionado,
                    orElse: () => {'nombre': 'Desconocido'},
                  );

                  Navigator.pop(context);
                  await _abrirCaja(
                    double.parse(fondoController.text),
                    cajero['nombre'],
                    cajeroSeleccionado!,
                    turnoSeleccionado,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirCaja(
    double fondo,
    String cajeroNombre,
    String cajeroId,
    String turno,
  ) async {
    try {
      final docRef = await _firestore.collection('cajas').add({
        'fecha_apertura': FieldValue.serverTimestamp(),
        'fondo_inicial': fondo,
        'cajero': cajeroNombre,
        'cajeroId': cajeroId, // Guardar ID del usuario
        'turno': turno,
        'estado': 'abierta',
        'total_efectivo': 0.0,
        'total_tarjeta': 0.0,
        'total_transferencia': 0.0,
        'total_propinas': 0.0,
        'total_egresos': 0.0,
        'efectivo_esperado': fondo,
        'notas': '',
      });

      await _verificarCajaAbierta();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Caja abierta por $cajeroNombre'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _mostrarDialogoMovimiento(String tipo) async {
    final formKey = GlobalKey<FormState>();
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();
    String categoriaSeleccionada = tipo == 'ingreso'
        ? 'venta_efectivo'
        : 'compra_ingredientes';

    final categoriasIngreso = {
      'venta_efectivo': 'Venta en Efectivo',
      'venta_tarjeta': 'Venta con Tarjeta',
      'venta_transferencia': 'Venta por Transferencia',
      'propinas': 'Propinas',
      'otros_ingresos': 'Otros Ingresos',
    };

    final categoriasEgreso = {
      'compra_ingredientes': 'Compra de Ingredientes',
      'pago_proveedor': 'Pago a Proveedor',
      'servicios': 'Servicios (luz, agua, gas)',
      'retiro_autorizado': 'Retiro Autorizado',
      'devolucion': 'Devolución a Cliente',
      'otros_egresos': 'Otros Egresos',
    };

    final categorias = tipo == 'ingreso' ? categoriasIngreso : categoriasEgreso;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            tipo == 'ingreso' ? 'Registrar Ingreso' : 'Registrar Egreso',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: categorias.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => categoriaSeleccionada = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: montoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v!) == null ? 'Monto inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await _registrarMovimiento(
                    tipo,
                    categoriaSeleccionada,
                    double.parse(montoController.text),
                    descripcionController.text,
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registrarMovimiento(
    String tipo,
    String categoria,
    double monto,
    String descripcion,
  ) async {
    if (_cajaActualId == null) return;

    try {
      // Registrar movimiento
      await _firestore.collection('movimientos_caja').add({
        'cajaId': _cajaActualId,
        'fecha': FieldValue.serverTimestamp(),
        'tipo': tipo,
        'categoria': categoria,
        'monto': monto,
        'descripcion': descripcion,
        'cajero': _cajaActual!['cajero'],
      });

      // Actualizar totales de la caja
      final cajaRef = _firestore.collection('cajas').doc(_cajaActualId);

      if (tipo == 'ingreso') {
        if (categoria == 'venta_efectivo') {
          await cajaRef.update({
            'total_efectivo': FieldValue.increment(monto),
            'efectivo_esperado': FieldValue.increment(monto),
          });
        } else if (categoria == 'venta_tarjeta') {
          await cajaRef.update({'total_tarjeta': FieldValue.increment(monto)});
        } else if (categoria == 'venta_transferencia') {
          await cajaRef.update({
            'total_transferencia': FieldValue.increment(monto),
          });
        } else if (categoria == 'propinas') {
          await cajaRef.update({'total_propinas': FieldValue.increment(monto)});
        }
      } else {
        await cajaRef.update({
          'total_egresos': FieldValue.increment(monto),
          'efectivo_esperado': FieldValue.increment(-monto),
        });
      }

      await _verificarCajaAbierta();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ ${tipo == 'ingreso' ? 'Ingreso' : 'Egreso'} registrado',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _mostrarDialogoCierreCaja() async {
    // Verificar autorización
    if (_cajaActual == null) return;

    final cajeroId = _cajaActual!['cajeroId'] as String?;

    // Verificar que el usuario que cierra sea cajero o administrador
    if (_usuariosAutorizados.isEmpty) {
      await _cargarUsuariosAutorizados();
    }

    final formKey = GlobalKey<FormState>();
    final efectivoContadoController = TextEditingController();
    final notasController = TextEditingController();
    String? usuarioCierreId = cajeroId; // Por defecto, el mismo que abrió

    final efectivo_esperado = _cajaActual!['efectivo_esperado'] ?? 0.0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.lock, color: Colors.red),
              SizedBox(width: 8),
              Text('Cierre de Caja'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de usuario que cierra
                  DropdownButtonFormField<String>(
                    value: usuarioCierreId,
                    decoration: const InputDecoration(
                      labelText: 'Usuario que cierra',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: _usuariosAutorizados.map((usuario) {
                      return DropdownMenuItem<String>(
                        value: usuario['id'],
                        child: Row(
                          children: [
                            Text(usuario['nombre']),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: usuario['rol'] == 'administrador'
                                    ? Colors.purple.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                usuario['rol'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: usuario['rol'] == 'administrador'
                                      ? Colors.purple.shade900
                                      : Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    validator: (v) =>
                        v == null ? 'Selecciona un usuario' : null,
                    onChanged: (v) => setDialogState(() => usuarioCierreId = v),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Efectivo Esperado: ${efectivo_esperado.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: efectivoContadoController,
                    decoration: const InputDecoration(
                      labelText: 'Efectivo Contado',
                      prefixIcon: Icon(Icons.calculate),
                      helperText: 'Contar todo el efectivo físico en caja',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        double.tryParse(v!) == null ? 'Monto inválido' : null,
                    onChanged: (v) {
                      // Mostrar diferencia en tiempo real
                      setDialogState(() {});
                    },
                  ),
                  if (efectivoContadoController.text.isNotEmpty &&
                      double.tryParse(efectivoContadoController.text) !=
                          null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (double.parse(efectivoContadoController.text) -
                                    efectivo_esperado) ==
                                0
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Diferencia:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${(double.parse(efectivoContadoController.text) - efectivo_esperado).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  (double.parse(
                                            efectivoContadoController.text,
                                          ) -
                                          efectivo_esperado) ==
                                      0
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notasController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Observaciones',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Cerrar Caja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Obtener nombre del usuario que cierra
                  final usuarioCierre = _usuariosAutorizados.firstWhere(
                    (u) => u['id'] == usuarioCierreId,
                    orElse: () => {'nombre': 'Desconocido'},
                  );

                  Navigator.pop(context);
                  await _cerrarCaja(
                    double.parse(efectivoContadoController.text),
                    notasController.text,
                    usuarioCierre['nombre'],
                    usuarioCierreId!,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cerrarCaja(
    double efectivoContado,
    String notas,
    String usuarioCierreNombre,
    String usuarioCierreId,
  ) async {
    if (_cajaActualId == null) return;

    try {
      final efectivo_esperado = _cajaActual!['efectivo_esperado'] ?? 0.0;
      final diferencia = efectivoContado - efectivo_esperado;

      await _firestore.collection('cajas').doc(_cajaActualId).update({
        'fechaCierre': FieldValue.serverTimestamp(),
        'estado': 'cerrada',
        'efectivoContado': efectivoContado,
        'diferencia': diferencia,
        'notas': notas,
        'cerradoPor': usuarioCierreNombre,
        'cerradoPorId': usuarioCierreId,
      });

      setState(() {
        _cajaActualId = null;
        _cajaActual = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              diferencia == 0
                  ? "✓ Caja cerrada por $usuarioCierreNombre - Sin diferencias"
                  : "✓ Caja cerrada por $usuarioCierreNombre - Diferencia: ${diferencia.toStringAsFixed(2)}",
            ),
            backgroundColor: diferencia == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool cajaAbierta = _cajaActualId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Gestión de Caja',
        child: Column(
          children: [
            // Estado de la caja
            _buildEstadoCaja(cajaAbierta),
            const SizedBox(height: 24),

            // Botones principales
            if (!cajaAbierta) ...[
              ElevatedButton.icon(
                onPressed: _mostrarDialogoAperturaCaja,
                icon: const Icon(Icons.lock_open),
                label: const Text('Abrir Caja'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],

            if (cajaAbierta) ...[
              // Tarjetas de información
              _buildInfoCards(),
              const SizedBox(height: 24),

              // Botones de acciones
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoMovimiento('ingreso'),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Registrar Ingreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoMovimiento('egreso'),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Registrar Egreso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarMovimientos(),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Ver Movimientos'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoCierreCaja,
                    icon: const Icon(Icons.lock),
                    label: const Text('Cerrar Caja'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lista de movimientos del día
              _buildMovimientosDelDia(),
            ],

            const SizedBox(height: 24),
            // Historial de cierres
            _buildHistorialCierres(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCaja(bool abierta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: abierta ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: abierta ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            abierta ? Icons.check_circle : Icons.cancel,
            color: abierta ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  abierta ? 'Caja Abierta' : 'Caja Cerrada',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: abierta
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                ),
                if (abierta && _cajaActual != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Cajero: ${_cajaActual!['cajero']} - Turno: ${_cajaActual!['turno']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    if (_cajaActual == null) return const SizedBox();

    final fondo_inicial = _cajaActual!['fondo_inicial'] ?? 0.0;
    final total_efectivo = _cajaActual!['total_efectivo'] ?? 0.0;
    final total_tarjeta = _cajaActual!['total_tarjeta'] ?? 0.0;
    final total_transferencia = _cajaActual!['total_transferencia'] ?? 0.0;
    final total_propinas = _cajaActual!['total_propinas'] ?? 0.0;
    final total_egresos = _cajaActual!['total_egresos'] ?? 0.0;
    final efectivo_esperado = _cajaActual!['efectivo_esperado'] ?? 0.0;

    final total_ingresos =
        total_efectivo + total_tarjeta + total_transferencia + total_propinas;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Fondo Inicial',
                '${fondo_inicial.toStringAsFixed(2)}',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Efectivo Esperado',
                '${efectivo_esperado.toStringAsFixed(2)}',
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Ventas Efectivo',
                '${total_efectivo.toStringAsFixed(2)}',
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Ventas Tarjeta',
                '${total_tarjeta.toStringAsFixed(2)}',
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Transferencias',
                '${total_transferencia.toStringAsFixed(2)}',
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Propinas',
                '${total_propinas.toStringAsFixed(2)}',
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Total Ingresos',
                '${total_ingresos.toStringAsFixed(2)}',
                Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Total Egresos',
                '${total_egresos.toStringAsFixed(2)}',
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosDelDia() {
    if (_cajaActualId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('movimientos_caja')
          .where('cajaId', isEqualTo: _cajaActualId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay movimientos registrados'),
            ),
          );
        }

        // Ordenar manualmente y limitar a 5 más recientes
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final fechaA =
              (a.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
          final fechaB =
              (b.data() as Map<String, dynamic>)['fecha'] as Timestamp?;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA);
        });

        final limitedDocs = docs.take(5).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Últimos Movimientos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ...limitedDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final tipo = data['tipo'] ?? '';
                  final monto = data['monto'] ?? 0.0;
                  final categoria = data['categoria'] ?? '';
                  final descripcion = data['descripcion'] ?? '';

                  return ListTile(
                    leading: Icon(
                      tipo == 'ingreso'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: tipo == 'ingreso' ? Colors.green : Colors.red,
                    ),
                    title: Text(categoria.replaceAll('_', ' ').toUpperCase()),
                    subtitle: Text(descripcion.isEmpty ? '-' : descripcion),
                    trailing: Text(
                      "${monto.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tipo == 'ingreso' ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarMovimientos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovimientosScreen(cajaId: _cajaActualId!),
      ),
    );
  }

  Widget _buildHistorialCierres() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('cajas')
          .where('estado', isEqualTo: 'cerrada')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay historial de cierres'),
            ),
          );
        }

        // Ordenar manualmente en memoria
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final fechaA =
              (a.data() as Map<String, dynamic>)['fechaCierre'] as Timestamp?;
          final fechaB =
              (b.data() as Map<String, dynamic>)['fechaCierre'] as Timestamp?;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA); // Descendente (más reciente primero)
        });

        // Limitar a 10 más recientes
        final limitedDocs = docs.take(10).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial de Cierres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Fecha')),
                      DataColumn(label: Text('Cajero')),
                      DataColumn(label: Text('Turno')),
                      DataColumn(label: Text('Fondo Inicial')),
                      DataColumn(label: Text('Ingresos')),
                      DataColumn(label: Text('Egresos')),
                      DataColumn(label: Text('Diferencia')),
                    ],
                    rows: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final fechaCierre = data['fechaCierre'] as Timestamp?;
                      final total_ingresos =
                          (data['total_efectivo'] ?? 0.0) +
                          (data['total_tarjeta'] ?? 0.0) +
                          (data['total_transferencia'] ?? 0.0) +
                          (data['total_propinas'] ?? 0.0);

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              fechaCierre != null
                                  ? DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(fechaCierre.toDate())
                                  : '-',
                            ),
                          ),
                          DataCell(Text(data['cajero'] ?? '-')),
                          DataCell(Text(data['turno'] ?? '-')),
                          DataCell(
                            Text(
                              "${(data['fondo_inicial'] ?? 0.0).toStringAsFixed(2)}",
                            ),
                          ),
                          DataCell(
                            Text("${total_ingresos.toStringAsFixed(2)}"),
                          ),
                          DataCell(
                            Text(
                              "${(data['total_egresos'] ?? 0.0).toStringAsFixed(2)}",
                            ),
                          ),
                          DataCell(
                            Text(
                              "${(data['diferencia'] ?? 0.0).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: (data['diferencia'] ?? 0.0) == 0
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Pantalla de movimientos detallados
class MovimientosScreen extends StatelessWidget {
  final String cajaId;

  const MovimientosScreen({Key? key, required this.cajaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos de Caja')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('movimientos_caja')
            .where('cajaId', isEqualTo: cajaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay movimientos registrados'));
          }

          // Ordenar manualmente por fecha (más reciente primero)
          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final fechaA =
                (a.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
            final fechaB =
                (b.data() as Map<String, dynamic>)['fecha'] as Timestamp?;

            if (fechaA == null && fechaB == null) return 0;
            if (fechaA == null) return 1;
            if (fechaB == null) return -1;

            return fechaB.compareTo(fechaA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final tipo = data['tipo'] ?? '';
              final categoria = data['categoria'] ?? '';
              final monto = data['monto'] ?? 0.0;
              final descripcion = data['descripcion'] ?? '';
              final fecha = data['fecha'] as Timestamp?;
              final cajero = data['cajero'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tipo == 'ingreso'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      tipo == 'ingreso' ? Icons.add : Icons.remove,
                      color: tipo == 'ingreso' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    categoria.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (descripcion.isNotEmpty) Text(descripcion),
                      const SizedBox(height: 4),
                      Text(
                        'Cajero: $cajero',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (fecha != null)
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm:ss',
                          ).format(fecha.toDate()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    "${tipo == 'ingreso' ? '+' : '-'}${monto.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tipo == 'ingreso' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
