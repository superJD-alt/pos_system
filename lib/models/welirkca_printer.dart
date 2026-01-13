import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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

  // ==================== PERMISOS ====================

  /// Verificar y solicitar permisos de Bluetooth para Android
  Future<bool> verificarYSolicitarPermisos() async {
    if (!Platform.isAndroid) return true;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    bool todosOtorgados = statuses.values.every((status) => status.isGranted);

    if (!todosOtorgados) {
      bool algunoDenegadoPermanentemente = statuses.values.any(
        (status) => status.isPermanentlyDenied,
      );

      if (algunoDenegadoPermanentemente) {
        await openAppSettings();
      }
    }

    return todosOtorgados;
  }

  // ==================== CONEXIÓN ====================

  /// Buscar impresoras Bluetooth cercanas
  /// Retorna lista de impresoras: [{"id": "...", "name": "..."}]
  Future<List<Map<String, String>>> scanPrinters() async {
    try {
      // ✅ Verificar permisos ANTES de escanear
      bool permisosOk = await verificarYSolicitarPermisos();
      if (!permisosOk) {
        print('❌ Permisos Bluetooth no otorgados');
        return [];
      }

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
      // ✅ Verificar permisos ANTES de conectar
      bool permisosOk = await verificarYSolicitarPermisos();
      if (!permisosOk) {
        print('❌ Permisos Bluetooth no otorgados');
        return false;
      }

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

  // ==================== RESTO DE TUS MÉTODOS (sin cambios) ====================

  Future<void> setPrintWidth(int width) async {
    try {
      await _channel.invokeMethod('setPrintWidth', {'width': width});
    } catch (e) {
      print('Error estableciendo ancho: $e');
    }
  }

  Future<void> setFontSize(int multiple) async {
    try {
      await _channel.invokeMethod('setFontSize', {'multiple': multiple});
    } catch (e) {
      print('Error estableciendo fuente: $e');
    }
  }

  Future<void> printText(String text) async {
    try {
      await _channel.invokeMethod('printText', {'text': text});
    } catch (e) {
      print('Error imprimiendo texto: $e');
    }
  }

  Future<void> printTextImage(String text) async {
    try {
      await _channel.invokeMethod('printTextImage', {'text': text});
    } catch (e) {
      print('Error imprimiendo texto imagen: $e');
    }
  }

  Future<void> printBarcode(String code, int type) async {
    try {
      await _channel.invokeMethod('printBarcode', {'code': code, 'type': type});
    } catch (e) {
      print('Error imprimiendo código de barras: $e');
    }
  }

  Future<void> printQRCode(String data) async {
    try {
      await _channel.invokeMethod('printQRCode', {'data': data});
    } catch (e) {
      print('Error imprimiendo QR: $e');
    }
  }

  Future<void> printImage(Uint8List imageBytes) async {
    try {
      await _channel.invokeMethod('printImage', {'imageBytes': imageBytes});
    } catch (e) {
      print('Error imprimiendo imagen: $e');
    }
  }

  Future<void> printTestPaper() async {
    try {
      await _channel.invokeMethod('printTestPaper');
    } catch (e) {
      print('Error imprimiendo prueba: $e');
    }
  }

  Future<void> cutPaper() async {
    try {
      await _channel.invokeMethod('cutPaper');
    } catch (e) {
      print('Error cortando papel: $e');
    }
  }

  Future<void> beep() async {
    try {
      await _channel.invokeMethod('beep');
    } catch (e) {
      print('Error con beep: $e');
    }
  }

  Future<void> openCashDrawer() async {
    try {
      await _channel.invokeMethod('openCashDrawer');
    } catch (e) {
      print('Error abriendo caja: $e');
    }
  }

  Future<void> selfTest() async {
    try {
      await _channel.invokeMethod('selfTest');
    } catch (e) {
      print('Error en self test: $e');
    }
  }
}
