import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Estado para el usuario logueado
  User? _currentUser;
  String? _currentUserName;
  String? _currentUserRole; // Almacenará el rol en minúsculas

  // Control de usuarios autorizados (solo para el Dropdown en el cierre)
  List<Map<String, dynamic>> _usuariosAutorizados = [];

  // Formateador de moneda
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'es_CL',
    symbol: '\$',
  );

  // Formateador de fecha
  final DateFormat dateTimeFormat = DateFormat('dd/MM/yy HH:mm');

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _cargarUsuariosAutorizados();
    _verificarCajaAbierta();
  }

  // MODIFICACIÓN CLAVE 1: Normaliza el rol del usuario actual
  Future<void> _loadCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      setState(() => _cargando = false);
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _currentUserName =
              userDoc.get('nombre') ?? 'Cajero ID: ${_currentUser!.uid}';
          // Convertir el rol a minúsculas aquí
          _currentUserRole = (userDoc.data()?['rol'] as String?)?.toLowerCase();
        });
      } else {
        setState(() {
          _currentUserName = 'Cajero ID: ${_currentUser!.uid}';
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario actual: $e');
      setState(() {
        _currentUserName = 'Error Cargando Nombre';
      });
    }
  }

  // MODIFICACIÓN CLAVE 2: Normaliza los roles de los usuarios autorizados
  Future<void> _cargarUsuariosAutorizados() async {
    try {
      // Usamos whereIn para capturar todos los usuarios con roles relevantes,
      // la normalización a minúsculas se hace al guardar en la lista.
      final snapshot = await _firestore
          .collection('usuarios')
          .where(
            'rol',
            whereIn: [
              'cajero',
              'administrador',
              'Cajero',
              'Administrador',
              'CAJERO',
              'ADMINISTRADOR',
            ],
          )
          .get();

      setState(() {
        _usuariosAutorizados = snapshot.docs
            .map(
              (doc) => {
                'id': doc.id,
                'nombre': doc.data()['nombre'] ?? 'Sin nombre',
                // Convertir el rol a minúsculas aquí para usarlo en el Dropdown
                'rol': (doc.data()['rol'] as String?)?.toLowerCase() ?? '',
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
      final snapshot = await _firestore
          .collection('cajas')
          .where('estado', isEqualTo: 'abierta')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _cajaActualId = snapshot.docs.first.id;
          _cajaActual = snapshot.docs.first.data();
        });
      } else {
        setState(() {
          _cajaActualId = null;
          _cajaActual = null;
        });
      }
    } catch (e) {
      print('Error al verificar caja: $e');
    } finally {
      if (_currentUserName != null || _currentUser == null) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _mostrarDialogoAperturaCaja() async {
    if (_currentUser == null || _currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Error: No se pudo cargar la información del usuario logueado.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // El rol ya está en minúsculas gracias a _loadCurrentUser
    if (_currentUserRole != 'administrador' && _currentUserRole != 'cajero') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🚫 Solo administradores y cajeros pueden abrir la caja.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final fondoController = TextEditingController(text: '1000');
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Cajero de Apertura: $_currentUserName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
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
                  final cajeroNombre = _currentUserName!;
                  final cajeroId = _currentUser!.uid;

                  Navigator.pop(context);
                  await _abrirCaja(
                    double.parse(fondoController.text),
                    cajeroNombre,
                    cajeroId,
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
      await _firestore.collection('cajas').add({
        'fecha_apertura': FieldValue.serverTimestamp(),
        'fondo_inicial': fondo,
        'cajero': cajeroNombre,
        'cajeroId': cajeroId,
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

      // Los movimientos que afectan el efectivo esperado son:
      // Ingreso efectivo (aumenta efectivo esperado) y Egreso (disminuye efectivo esperado).
      // Tarjeta y Transferencia aumentan los totales, pero no el efectivo físico esperado.

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
          // Si las propinas son en efectivo, deberían incrementar el efectivo esperado.
          // Por simplicidad, asumiremos que las propinas en efectivo se registran como 'venta_efectivo'
          // si son parte de una venta, y solo se registra el total_propinas aquí si son de otra fuente.
          await cajaRef.update({'total_propinas': FieldValue.increment(monto)});
        }
      } else {
        // Todo egreso implica una salida de efectivo (disminuye efectivo esperado)
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
    if (_cajaActual == null) return;

    if (_currentUser == null || _currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Error: No se pudo cargar la información del usuario logueado para el cierre.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final efectivoContadoController = TextEditingController();
    final notasController = TextEditingController();

    // Por defecto, el usuario que cierra es el que está logueado
    String? usuarioCierreId = _currentUser!.uid;

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
                                // El rol ya está en minúsculas para la comparación
                                color: usuario['rol'] == 'administrador'
                                    ? Colors.purple.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                // Mostramos el rol en mayúsculas para mejor visualización
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
                            "Efectivo Esperado: ${currencyFormat.format(efectivo_esperado)}",
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
                            currencyFormat.format(
                              double.parse(efectivoContadoController.text) -
                                  efectivo_esperado,
                            ),
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
                  : "✓ Caja cerrada por $usuarioCierreNombre - Diferencia: ${currencyFormat.format(diferencia)}",
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
    if (_cargando || _currentUserName == null) {
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
                  // El botón de movimientos ahora solo dirige la vista al widget de abajo
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Consulta la sección "Movimientos del Día" abajo.',
                          ),
                        ),
                      );
                    },
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

              // Lista de movimientos del día (Implementación regresada)
              _buildMovimientosDelDia(),
            ],

            const SizedBox(height: 24),
            // Historial de cierres (Implementación regresada)
            _buildHistorialCierres(),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las tarjetas de información
  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
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
                currencyFormat.format(fondo_inicial),
                Colors.blue.shade600,
              ),
            ),
            Expanded(
              child: _buildInfoCard(
                'Ingresos Totales',
                currencyFormat.format(total_ingresos),
                Colors.green.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Efectivo Esperado',
                currencyFormat.format(efectivo_esperado),
                Colors.red.shade600,
              ),
            ),
            Expanded(
              child: _buildInfoCard(
                'Egresos Totales',
                currencyFormat.format(total_egresos),
                Colors.orange.shade600,
              ),
            ),
          ],
        ),
      ],
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

  // REIMPLEMENTADO: Muestra los movimientos en tiempo real de la caja actual
  Widget _buildMovimientosDelDia() {
    if (_cajaActualId == null) {
      return const ContentCard(
        title: 'Movimientos del Día',
        child: Center(
          child: Text(
            'No hay caja abierta para registrar movimientos.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Mapeo para nombres de categorías más amigables
    const categoryNames = {
      'venta_efectivo': 'Venta Efectivo',
      'venta_tarjeta': 'Venta Tarjeta',
      'venta_transferencia': 'Venta Transferencia',
      'propinas': 'Propinas',
      'otros_ingresos': 'Otros Ingresos',
      'compra_ingredientes': 'Compra Ingredientes',
      'pago_proveedor': 'Pago Proveedor',
      'servicios': 'Servicios',
      'retiro_autorizado': 'Retiro',
      'devolucion': 'Devolución',
      'otros_egresos': 'Otros Egresos',
    };

    return ContentCard(
      title: 'Movimientos del Día',
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('movimientos_caja')
            .where('cajaId', isEqualTo: _cajaActualId)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay movimientos registrados.'));
          }

          final movimientos = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = movimientos[index];
              final data = movimiento.data() as Map<String, dynamic>;
              final tipo = data['tipo'] as String;
              final monto = data['monto'] ?? 0.0;
              final categoria = data['categoria'] as String;
              final descripcion = data['descripcion'] ?? 'Sin descripción';
              final fecha = (data['fecha'] as Timestamp?)?.toDate();

              final isIngreso = tipo == 'ingreso';
              final color = isIngreso
                  ? Colors.green.shade700
                  : Colors.red.shade700;
              final icon = isIngreso
                  ? Icons.arrow_upward
                  : Icons.arrow_downward;
              final sign = isIngreso ? '+' : '-';
              final categoryText = categoryNames[categoria] ?? categoria;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                title: Text(
                  '$sign ${currencyFormat.format(monto)} (${categoryText})',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                subtitle: Text('$descripcion\nCajero: ${data['cajero']}'),
                trailing: Text(
                  fecha != null ? dateTimeFormat.format(fecha) : '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // REIMPLEMENTADO: Muestra el historial de cierres
  Widget _buildHistorialCierres() {
    return ContentCard(
      title: 'Historial de Cierres de Caja (Cortes Anteriores)',
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cajas')
            .where('estado', isEqualTo: 'cerrada')
            .orderBy('fechaCierre', descending: true)
            .limit(10) // Mostrar solo los últimos 10 cierres
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay cierres de caja registrados.'),
            );
          }

          final cierres = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cierres.length,
            itemBuilder: (context, index) {
              final cierre = cierres[index];
              final data = cierre.data() as Map<String, dynamic>;
              final fechaCierre = (data['fechaCierre'] as Timestamp?)?.toDate();
              final diferencia = data['diferencia'] ?? 0.0;
              final fondo = data['fondo_inicial'] ?? 0.0;
              final contado = data['efectivoContado'] ?? 0.0;

              final color = diferencia == 0
                  ? Colors.green
                  : diferencia > 0
                  ? Colors.orange.shade800
                  : Colors.red.shade800;
              final diffText = diferencia == 0
                  ? 'Sin diferencia'
                  : 'Diferencia: ${currencyFormat.format(diferencia)}';

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.archive, color: color),
                  title: Text(
                    'Corte del ${fechaCierre != null ? dateTimeFormat.format(fechaCierre) : 'Fecha Desconocida'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cajero de Apertura: ${data['cajero']}\nCerrado por: ${data['cerradoPor']}\nFondo Inicial: ${currencyFormat.format(fondo)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(contado),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        diffText,
                        style: TextStyle(color: color, fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Acción para ver detalles completos del cierre (opcional)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Corte seleccionado: ${cierre.id}'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
