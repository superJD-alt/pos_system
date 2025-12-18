import 'package:flutter/services.dart';

class PrinterService {
  // El nombre del canal debe coincidir exactamente con el de AppDelegate.swift
  static const MethodChannel _channel = MethodChannel(
    'com.tuapp/welirkca_printer',
  );

  // Escanear impresoras cercanas (Bluetooth)
  Future<List<Map<String, String>>> scanPrinters() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('scanPrinters');
      if (result == null) return [];
      return result.map((e) => Map<String, String>.from(e)).toList();
    } on PlatformException catch (e) {
      print("Error al escanear: ${e.message}");
      return [];
    }
  }

  // Conectar a una impresora por su UUID (Bluetooth)
  Future<bool> connectBluetooth(String deviceId) async {
    try {
      final bool success = await _channel.invokeMethod('connectBluetooth', {
        'deviceId': deviceId,
      });
      return success;
    } catch (e) {
      print("Error de conexión BT: $e");
      return false;
    }
  }

  // Conectar por IP (WiFi)
  Future<bool> connectWifi(String ipAddress) async {
    try {
      final bool success = await _channel.invokeMethod('connectWifi', {
        'ipAddress': ipAddress,
      });
      return success;
    } catch (e) {
      print("Error de conexión WiFi: $e");
      return false;
    }
  }

  // Enviar bytes de una imagen (Lo que usaremos para el ticket del PDF)
  Future<void> printImage(Uint8List imageBytes) async {
    try {
      await _channel.invokeMethod('printImage', {'imageBytes': imageBytes});
    } on PlatformException catch (e) {
      print("Error al imprimir imagen: ${e.message}");
    }
  }

  // Comandos de control físico
  Future<void> cutPaper() async => await _channel.invokeMethod('cutPaper');
  Future<void> beep() async => await _channel.invokeMethod('beep');
  Future<void> openCashDrawer() async =>
      await _channel.invokeMethod('openCashDrawer');

  // Desconectar la impresora actual
  Future<void> disconnect() async => await _channel.invokeMethod('disconnect');
}
