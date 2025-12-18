import 'package:flutter/services.dart';

class WelirkcaPrinterService {
  static const MethodChannel _channel = MethodChannel(
    'com.tuapp/welirkca_printer',
  );

  // Callback para eventos de conexión
  static Function? onPrinterConnected;
  static Function? onPrinterDisconnected;

  WelirkcaPrinterService() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  // Manejar callbacks desde iOS
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onPrinterConnected':
        onPrinterConnected?.call();
        break;
      case 'onPrinterDisconnected':
        onPrinterDisconnected?.call();
        break;
    }
  }

  // ==================== CONEXIÓN ====================

  /// Buscar impresoras Bluetooth cercanas
  /// Retorna lista de impresoras: [{"id": "...", "name": "..."}]
  Future<List<Map<String, String>>> scanPrinters() async {
    try {
      final result = await _channel.invokeMethod('scanPrinters');
      return List<Map<String, String>>.from(
        result.map((item) => Map<String, String>.from(item)),
      );
    } catch (e) {
      print('Error escaneando impresoras: $e');
      return [];
    }
  }

  /// Detener búsqueda de impresoras
  Future<void> stopScan() async {
    try {
      await _channel.invokeMethod('stopScan');
    } catch (e) {
      print('Error deteniendo escaneo: $e');
    }
  }

  /// Conectar a impresora por Bluetooth
  Future<bool> connectBluetooth(String deviceId) async {
    try {
      final result = await _channel.invokeMethod('connectBluetooth', {
        'deviceId': deviceId,
      });
      return result ?? false;
    } catch (e) {
      print('Error conectando Bluetooth: $e');
      return false;
    }
  }

  /// Conectar a impresora por WiFi
  Future<bool> connectWifi(String ipAddress) async {
    try {
      final result = await _channel.invokeMethod('connectWifi', {
        'ipAddress': ipAddress,
      });
      return result ?? false;
    } catch (e) {
      print('Error conectando WiFi: $e');
      return false;
    }
  }

  /// Desconectar impresora
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
    } catch (e) {
      print('Error desconectando: $e');
    }
  }

  // ==================== CONFIGURACIÓN ====================

  /// Establecer ancho de impresión
  /// 384 para 58mm, 576 para 80mm
  Future<void> setPrintWidth(int width) async {
    try {
      await _channel.invokeMethod('setPrintWidth', {'width': width});
    } catch (e) {
      print('Error estableciendo ancho: $e');
    }
  }

  /// Establecer tamaño de fuente
  /// 0 = 1x, 1 = 2x, 2 = 3x, 3 = 4x
  Future<void> setFontSize(int multiple) async {
    try {
      await _channel.invokeMethod('setFontSize', {'multiple': multiple});
    } catch (e) {
      print('Error estableciendo fuente: $e');
    }
  }

  // ==================== IMPRESIÓN ====================

  /// Imprimir texto simple
  Future<void> printText(String text) async {
    try {
      await _channel.invokeMethod('printText', {'text': text});
    } catch (e) {
      print('Error imprimiendo texto: $e');
    }
  }

  /// Imprimir texto como imagen (mejor calidad)
  Future<void> printTextImage(String text) async {
    try {
      await _channel.invokeMethod('printTextImage', {'text': text});
    } catch (e) {
      print('Error imprimiendo texto imagen: $e');
    }
  }

  /// Imprimir código de barras
  /// types: 0=UPC-A, 1=UPC-E, 2=JAN13, 3=JAN8, 4=CODE39, 5=ITF, 6=CODABAR, 7=CODE93, 8=CODE128
  Future<void> printBarcode(String code, int type) async {
    try {
      await _channel.invokeMethod('printBarcode', {'code': code, 'type': type});
    } catch (e) {
      print('Error imprimiendo código de barras: $e');
    }
  }

  /// Imprimir código QR
  Future<void> printQRCode(String data) async {
    try {
      await _channel.invokeMethod('printQRCode', {'data': data});
    } catch (e) {
      print('Error imprimiendo QR: $e');
    }
  }

  /// Imprimir imagen desde bytes
  Future<void> printImage(Uint8List imageBytes) async {
    try {
      await _channel.invokeMethod('printImage', {'imageBytes': imageBytes});
    } catch (e) {
      print('Error imprimiendo imagen: $e');
    }
  }

  /// Imprimir ticket de prueba
  Future<void> printTestPaper() async {
    try {
      await _channel.invokeMethod('printTestPaper');
    } catch (e) {
      print('Error imprimiendo prueba: $e');
    }
  }

  // ==================== OTROS ====================

  /// Cortar papel
  Future<void> cutPaper() async {
    try {
      await _channel.invokeMethod('cutPaper');
    } catch (e) {
      print('Error cortando papel: $e');
    }
  }

  /// Hacer sonar beep
  Future<void> beep() async {
    try {
      await _channel.invokeMethod('beep');
    } catch (e) {
      print('Error con beep: $e');
    }
  }

  /// Abrir caja registradora
  Future<void> openCashDrawer() async {
    try {
      await _channel.invokeMethod('openCashDrawer');
    } catch (e) {
      print('Error abriendo caja: $e');
    }
  }

  /// Auto-test de impresora
  Future<void> selfTest() async {
    try {
      await _channel.invokeMethod('selfTest');
    } catch (e) {
      print('Error en self test: $e');
    }
  }
}
