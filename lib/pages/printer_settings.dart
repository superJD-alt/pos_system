import 'package:flutter/material.dart';
import 'package:pos_system/models/welirkca_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({Key? key}) : super(key: key);

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final WelirkcaPrinterService _printer = WelirkcaPrinterService();

  List<Map<String, String>> _printers = [];
  bool _isScanning = false;
  bool _isConnected = false;
  String? _connectedPrinterId;
  String? _connectedPrinterName;

  // Para WiFi
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedPrinter();
    _setupCallbacks();
  }

  void _setupCallbacks() {
    WelirkcaPrinterService.onPrinterConnected = () {
      setState(() => _isConnected = true);
      _savePrinterConnection();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Impresora conectada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    };

    WelirkcaPrinterService.onPrinterDisconnected = () {
      setState(() {
        _isConnected = false;
        _connectedPrinterId = null;
        _connectedPrinterName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Impresora desconectada'),
          backgroundColor: Colors.orange,
        ),
      );
    };
  }

  Future<void> _loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _connectedPrinterId = prefs.getString('printer_id');
      _connectedPrinterName = prefs.getString('printer_name');
      _ipController.text = prefs.getString('printer_ip') ?? '192.168.1.100';
      _isConnected = _connectedPrinterId != null;
    });
  }

  Future<void> _savePrinterConnection() async {
    if (_connectedPrinterId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('printer_id', _connectedPrinterId!);
      if (_connectedPrinterName != null) {
        await prefs.setString('printer_name', _connectedPrinterName!);
      }
    }
  }

  Future<void> _clearSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('printer_id');
    await prefs.remove('printer_name');
  }

  Future<void> _scanForPrinters() async {
    setState(() {
      _isScanning = true;
      _printers.clear();
    });

    try {
      final printers = await _printer.scanPrinters();
      setState(() {
        _printers = printers;
        _isScanning = false;
      });

      if (_printers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ No se encontraron impresoras. Verifica que el Bluetooth esté encendido.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al buscar impresoras: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _connectToPrinter(String deviceId, String deviceName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _printer.connectBluetooth(deviceId);
      Navigator.pop(context); // Cerrar loading

      if (success) {
        setState(() {
          _connectedPrinterId = deviceId;
          _connectedPrinterName = deviceName;
          _isConnected = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo conectar a la impresora'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al conectar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _connectWifi() async {
    final ip = _ipController.text.trim();

    if (ip.isEmpty) {
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
      final success = await _printer.connectWifi(ip);
      Navigator.pop(context);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('printer_ip', ip);

        setState(() {
          _connectedPrinterId = 'wifi_$ip';
          _connectedPrinterName = 'WiFi - $ip';
          _isConnected = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo conectar por WiFi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al conectar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    await _printer.disconnect();
    await _clearSavedPrinter();
    setState(() {
      _isConnected = false;
      _connectedPrinterId = null;
      _connectedPrinterName = null;
    });
  }

  Future<void> _printTest() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Conecta una impresora primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _printer.setPrintWidth(384); // 58mm

      final testTicket =
          '''
================================
    PRUEBA DE IMPRESORA
================================

Esta es una impresión de prueba
para verificar que la impresora
está funcionando correctamente.

--------------------------------
Fecha: ${DateTime.now().toString().substring(0, 19)}
--------------------------------

✅ Si puedes leer esto, 
   la impresora funciona bien!

================================
''';

      await _printer.printText(testTicket);
      await _printer.cutPaper();
      await _printer.beep();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Impresión de prueba enviada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al imprimir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Impresora'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado actual
            _buildStatusCard(),

            const SizedBox(height: 24),

            // Tabs para Bluetooth y WiFi
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.blue.shade700,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue.shade700,
                    tabs: const [
                      Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
                      Tab(icon: Icon(Icons.wifi), text: 'WiFi'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [_buildBluetoothTab(), _buildWiFiTab()],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            if (_isConnected) ...[
              ElevatedButton.icon(
                onPressed: _printTest,
                icon: const Icon(Icons.print),
                label: const Text('IMPRIMIR PRUEBA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.close),
                label: const Text('DESCONECTAR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _isConnected ? Icons.print : Icons.print_disabled,
              size: 64,
              color: _isConnected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isConnected ? '🟢 CONECTADO' : '🔴 DESCONECTADO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isConnected ? Colors.green : Colors.grey,
              ),
            ),
            if (_connectedPrinterName != null) ...[
              const SizedBox(height: 8),
              Text(
                _connectedPrinterName!,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothTab() {
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
            label: Text(_isScanning ? 'Buscando...' : 'BUSCAR IMPRESORAS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 16),

          if (_printers.isEmpty && !_isScanning)
            Center(
              child: Column(
                children: const [
                  Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No se han encontrado impresoras',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona "Buscar" para escanear',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _printers.length,
              itemBuilder: (context, index) {
                final printer = _printers[index];
                final isSelected = printer['id'] == _connectedPrinterId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected ? Colors.green.shade50 : null,
                  child: ListTile(
                    leading: Icon(
                      isSelected ? Icons.print : Icons.bluetooth,
                      color: isSelected ? Colors.green : Colors.blue,
                    ),
                    title: Text(
                      printer['name'] ?? 'Sin nombre',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(printer['id'] ?? ''),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () =>
                        _connectToPrinter(printer['id']!, printer['name']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWiFiTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Conectar por dirección IP',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _ipController,
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
            onPressed: _connectWifi,
            icon: const Icon(Icons.wifi),
            label: const Text('CONECTAR POR WiFi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Instrucciones:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '1. Asegúrate de que la impresora esté en la misma red WiFi',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '2. Encuentra la IP en la configuración de red de la impresora',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '3. Ingresa la dirección IP completa',
                  style: TextStyle(fontSize: 12),
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
    _ipController.dispose();
    super.dispose();
  }
}
