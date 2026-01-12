// ═══════════════════════════════════════════════════════════════
// ARCHIVO: lib/pages/dual_printer_settings.dart
// Pantalla para configurar ambas impresoras (Cocina y Barra)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:pos_system/models/printer_manager.dart';

class DualPrinterSettingsPage extends StatefulWidget {
  const DualPrinterSettingsPage({Key? key}) : super(key: key);

  @override
  State<DualPrinterSettingsPage> createState() =>
      _DualPrinterSettingsPageState();
}

class _DualPrinterSettingsPageState extends State<DualPrinterSettingsPage> {
  final PrinterManager _printerManager = PrinterManager();

  List<Map<String, String>> _printers = [];
  bool _isScanning = false;

  // Estados de conexión
  bool _cocinaConectada = false;
  bool _barraConectada = false;

  // Info de impresoras
  String? _cocinaName;
  String? _barraName;

  // Controladores WiFi
  final TextEditingController _ipCocinaController = TextEditingController();
  final TextEditingController _ipBarraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    await _printerManager.cargarConfiguracion();
    setState(() {
      final infoCocina = _printerManager.getInfo(TipoImpresora.cocina);
      final infoBarra = _printerManager.getInfo(TipoImpresora.barra);

      _cocinaConectada = infoCocina['conectada'] ?? false;
      _cocinaName = infoCocina['name'];

      _barraConectada = infoBarra['conectada'] ?? false;
      _barraName = infoBarra['name'];
    });
  }

  Future<void> _scanForPrinters() async {
    setState(() {
      _isScanning = true;
      _printers.clear();
    });

    try {
      final printers = await _printerManager.buscarImpresoras();
      setState(() {
        _printers = printers;
        _isScanning = false;
      });

      if (_printers.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ No se encontraron impresoras. Verifica el Bluetooth.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al buscar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectBluetooth(
    TipoImpresora tipo,
    String deviceId,
    String deviceName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _printerManager.conectarBluetooth(
        tipo: tipo,
        deviceId: deviceId,
        deviceName: deviceName,
      );

      Navigator.pop(context);

      if (success) {
        await _cargarConfiguracion();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${tipo.name.toUpperCase()} conectada: $deviceName',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo conectar'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _connectWifi(TipoImpresora tipo, String ip) async {
    if (ip.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Ingresa una dirección IP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _printerManager.conectarWifi(
        tipo: tipo,
        ipAddress: ip.trim(),
      );

      Navigator.pop(context);

      if (success) {
        await _cargarConfiguracion();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${tipo.name.toUpperCase()} conectada por WiFi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se pudo conectar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _disconnect(TipoImpresora tipo) async {
    await _printerManager.desconectar(tipo);
    await _cargarConfiguracion();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔌 ${tipo.name.toUpperCase()} desconectada'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _printTest(TipoImpresora tipo) async {
    if (!_printerManager.estaConectada(tipo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Conecta la impresora de ${tipo.name.toUpperCase()} primero',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _printerManager.imprimirPrueba(tipo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Prueba enviada a ${tipo.name.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error en prueba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Impresoras'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header informativo
            _buildInfoHeader(),

            const SizedBox(height: 24),

            // IMPRESORA A - COCINA
            _buildPrinterSection(
              tipo: TipoImpresora.cocina,
              titulo: 'IMPRESORA A - COCINA',
              subtitulo: 'Comandas de platillos',
              icono: Icons.restaurant,
              color: Colors.orange,
              conectada: _cocinaConectada,
              nombreConectado: _cocinaName,
              ipController: _ipCocinaController,
            ),

            const SizedBox(height: 24),

            // IMPRESORA B - BARRA
            _buildPrinterSection(
              tipo: TipoImpresora.barra,
              titulo: 'IMPRESORA B - BARRA',
              subtitulo: 'Comandas de bebidas + Tickets de cuenta',
              icono: Icons.local_bar,
              color: Colors.purple,
              conectada: _barraConectada,
              nombreConectado: _barraName,
              ipController: _ipBarraController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Configura 2 impresoras térmicas para clasificar las impresiones automáticamente',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterSection({
    required TipoImpresora tipo,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
    required bool conectada,
    required String? nombreConectado,
    required TextEditingController ipController,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (nombreConectado != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        nombreConectado,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: conectada ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: conectada ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      conectada ? Icons.check_circle : Icons.error,
                      color: conectada ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      conectada ? 'OK' : 'OFF',
                      style: TextStyle(
                        color: conectada ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Tabs Bluetooth y WiFi
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: color,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: color,
                  tabs: const [
                    Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
                    Tab(icon: Icon(Icons.wifi), text: 'WiFi'),
                  ],
                ),
                SizedBox(
                  height: 280,
                  child: TabBarView(
                    children: [
                      _buildBluetoothTab(tipo, color),
                      _buildWiFiTab(tipo, color, ipController),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botones de acción
          if (conectada) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _printTest(tipo),
                    icon: const Icon(Icons.print),
                    label: const Text('PRUEBA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _disconnect(tipo),
                    icon: const Icon(Icons.close),
                    label: const Text('DESCONECTAR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBluetoothTab(TipoImpresora tipo, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _scanForPrinters,
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isScanning ? 'Buscando...' : 'BUSCAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _printers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.bluetooth_searching,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No hay impresoras',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _printers.length,
                    itemBuilder: (context, index) {
                      final printer = _printers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.bluetooth, color: color),
                          title: Text(
                            printer['name'] ?? 'Sin nombre',
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            printer['id'] ?? '',
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () => _connectBluetooth(
                            tipo,
                            printer['id']!,
                            printer['name']!,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWiFiTab(
    TipoImpresora tipo,
    Color color,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Dirección IP',
              hintText: '192.168.1.100',
              prefixIcon: const Icon(Icons.computer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => _connectWifi(tipo, controller.text),
            icon: const Icon(Icons.wifi),
            label: const Text('CONECTAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '💡 Consejos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  '• Misma red WiFi que la tablet',
                  style: TextStyle(fontSize: 11),
                ),
                SizedBox(height: 4),
                Text(
                  '• Usa IP fija (configurada en router)',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipCocinaController.dispose();
    _ipBarraController.dispose();
    super.dispose();
  }
}
