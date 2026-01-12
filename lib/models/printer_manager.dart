// ═══════════════════════════════════════════════════════════════
// PROBLEMA IDENTIFICADO:
// El SDK WelirkcaPrinterService usa un MethodChannel global, por lo que
// solo mantiene UNA conexión activa a la vez.
//
// SOLUCIÓN:
// Antes de cada impresión, conectar a la impresora específica.
// ═══════════════════════════════════════════════════════════════

import 'package:pos_system/models/welirkca_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TipoImpresora {
  cocina, // Impresora A - Comandas de cocina
  barra, // Impresora B - Comandas de barra + Cuentas
}

class PrinterManager {
  // ✅ UNA SOLA instancia del SDK (porque usa MethodChannel global)
  final WelirkcaPrinterService _printer = WelirkcaPrinterService();

  // Información de conexión guardada
  String? _cocinaId;
  String? _cocinaName;
  String? _cocinaType; // 'bluetooth' o 'wifi'
  String? _cocinaAddress; // deviceId o IP

  String? _barraId;
  String? _barraName;
  String? _barraType; // 'bluetooth' o 'wifi'
  String? _barraAddress; // deviceId o IP

  // Singleton
  static final PrinterManager _instance = PrinterManager._internal();
  factory PrinterManager() => _instance;
  PrinterManager._internal();

  // ════════════════════════════════════════════════════════
  // GESTIÓN DE CONFIGURACIÓN
  // ════════════════════════════════════════════════════════

  Future<void> cargarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar COCINA
      _cocinaId = prefs.getString('printer_cocina_id');
      _cocinaName = prefs.getString('printer_cocina_name');
      _cocinaType = prefs.getString('printer_cocina_type');
      _cocinaAddress = prefs.getString('printer_cocina_address');

      // Cargar BARRA
      _barraId = prefs.getString('printer_barra_id');
      _barraName = prefs.getString('printer_barra_name');
      _barraType = prefs.getString('printer_barra_type');
      _barraAddress = prefs.getString('printer_barra_address');

      print('📂 Configuración cargada:');
      print('   Cocina: $_cocinaName ($_cocinaType: $_cocinaAddress)');
      print('   Barra: $_barraName ($_barraType: $_barraAddress)');
    } catch (e) {
      print('❌ Error cargando configuración: $e');
    }
  }

  Future<void> guardarConexion({
    required TipoImpresora tipo,
    required String deviceId,
    required String deviceName,
    required String connectionType, // 'bluetooth' o 'wifi'
    required String address, // deviceId o IP
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (tipo == TipoImpresora.cocina) {
        await prefs.setString('printer_cocina_id', deviceId);
        await prefs.setString('printer_cocina_name', deviceName);
        await prefs.setString('printer_cocina_type', connectionType);
        await prefs.setString('printer_cocina_address', address);

        _cocinaId = deviceId;
        _cocinaName = deviceName;
        _cocinaType = connectionType;
        _cocinaAddress = address;
      } else {
        await prefs.setString('printer_barra_id', deviceId);
        await prefs.setString('printer_barra_name', deviceName);
        await prefs.setString('printer_barra_type', connectionType);
        await prefs.setString('printer_barra_address', address);

        _barraId = deviceId;
        _barraName = deviceName;
        _barraType = connectionType;
        _barraAddress = address;
      }

      print(
        '💾 Guardada: ${tipo.name} - $deviceName ($connectionType: $address)',
      );
    } catch (e) {
      print('❌ Error guardando: $e');
    }
  }

  Future<void> limpiarConexion(TipoImpresora tipo) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (tipo == TipoImpresora.cocina) {
        await prefs.remove('printer_cocina_id');
        await prefs.remove('printer_cocina_name');
        await prefs.remove('printer_cocina_type');
        await prefs.remove('printer_cocina_address');

        _cocinaId = null;
        _cocinaName = null;
        _cocinaType = null;
        _cocinaAddress = null;
      } else {
        await prefs.remove('printer_barra_id');
        await prefs.remove('printer_barra_name');
        await prefs.remove('printer_barra_type');
        await prefs.remove('printer_barra_address');

        _barraId = null;
        _barraName = null;
        _barraType = null;
        _barraAddress = null;
      }

      print('🗑️ Limpiada: ${tipo.name}');
    } catch (e) {
      print('❌ Error limpiando: $e');
    }
  }

  // ════════════════════════════════════════════════════════
  // CONEXIÓN (para guardar configuración)
  // ════════════════════════════════════════════════════════

  Future<bool> conectarBluetooth({
    required TipoImpresora tipo,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final success = await _printer.connectBluetooth(deviceId);

      if (success) {
        await guardarConexion(
          tipo: tipo,
          deviceId: deviceId,
          deviceName: deviceName,
          connectionType: 'bluetooth',
          address: deviceId,
        );
        print('✅ ${tipo.name.toUpperCase()} configurada: $deviceName');
      }

      return success;
    } catch (e) {
      print('❌ Error conectando ${tipo.name}: $e');
      return false;
    }
  }

  Future<bool> conectarWifi({
    required TipoImpresora tipo,
    required String ipAddress,
  }) async {
    try {
      final success = await _printer.connectWifi(ipAddress);

      if (success) {
        await guardarConexion(
          tipo: tipo,
          deviceId: 'wifi_$ipAddress',
          deviceName: 'WiFi - $ipAddress',
          connectionType: 'wifi',
          address: ipAddress,
        );
        print('✅ ${tipo.name.toUpperCase()} configurada: $ipAddress');
      }

      return success;
    } catch (e) {
      print('❌ Error conectando ${tipo.name}: $e');
      return false;
    }
  }

  Future<void> desconectar(TipoImpresora tipo) async {
    try {
      await _printer.disconnect();
      await limpiarConexion(tipo);
      print('🔌 ${tipo.name.toUpperCase()} desconectada');
    } catch (e) {
      print('❌ Error desconectando: $e');
    }
  }

  // ════════════════════════════════════════════════════════
  // RECONEXIÓN ANTES DE IMPRIMIR
  // ════════════════════════════════════════════════════════

  /// ✅ Conecta a la impresora específica antes de imprimir
  Future<bool> _conectarAntes(TipoImpresora tipo) async {
    try {
      String? connectionType;
      String? address;

      if (tipo == TipoImpresora.cocina) {
        connectionType = _cocinaType;
        address = _cocinaAddress;
      } else {
        connectionType = _barraType;
        address = _barraAddress;
      }

      if (connectionType == null || address == null) {
        print('❌ ${tipo.name}: No hay configuración guardada');
        return false;
      }

      print(
        '🔄 Conectando a ${tipo.name.toUpperCase()} ($connectionType: $address)...',
      );

      bool success;
      if (connectionType == 'bluetooth') {
        success = await _printer.connectBluetooth(address);
      } else {
        success = await _printer.connectWifi(address);
      }

      if (success) {
        print('✅ Conectado a ${tipo.name.toUpperCase()}');
        // Pequeña pausa para estabilizar la conexión
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        print('❌ No se pudo conectar a ${tipo.name.toUpperCase()}');
      }

      return success;
    } catch (e) {
      print('❌ Error en _conectarAntes(${tipo.name}): $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════
  // MÉTODOS DE IMPRESIÓN
  // ════════════════════════════════════════════════════════

  Future<void> imprimirComanda({
    required String contenido,
    required TipoImpresora tipo,
  }) async {
    try {
      print('\n╔════════════════════════════════════════╗');
      print('║  🖨️  IMPRIMIENDO EN ${tipo.name.toUpperCase().padRight(18)}║');
      print('╚════════════════════════════════════════╝');

      // ✅ PASO 1: Conectar a la impresora específica
      final conectado = await _conectarAntes(tipo);
      if (!conectado) {
        throw Exception('No se pudo conectar a impresora de ${tipo.name}');
      }

      // ✅ PASO 2: Configurar impresora
      await _printer.setPrintWidth(384);
      await _printer.setFontSize(0);

      // ✅ PASO 3: Imprimir contenido
      await _printer.printText(contenido);
      await _printer.printText('\n\n\n');

      // ✅ PASO 4: Cortar papel
      try {
        await _printer.cutPaper();
        print('✅ Papel cortado');
      } catch (e) {
        print('⚠️ No se pudo cortar: $e');
      }

      // ✅ PASO 5: Beep
      try {
        await _printer.beep();
        print('✅ Beep emitido');
      } catch (e) {
        print('⚠️ No se pudo hacer beep: $e');
      }

      print('╔════════════════════════════════════════╗');
      print('║  ✅ COMANDA IMPRESA EN ${tipo.name.toUpperCase().padRight(13)}║');
      print('╚════════════════════════════════════════╝\n');
    } catch (e) {
      print('❌ Error imprimiendo en ${tipo.name}: $e');
      rethrow;
    }
  }

  Future<void> imprimirTicketCuenta({required String contenido}) async {
    try {
      print('\n╔════════════════════════════════════════╗');
      print('║  🧾 IMPRIMIENDO TICKET EN BARRA       ║');
      print('╚════════════════════════════════════════╝');

      // ✅ PASO 1: Conectar a BARRA
      final conectado = await _conectarAntes(TipoImpresora.barra);
      if (!conectado) {
        throw Exception('No se pudo conectar a impresora de BARRA');
      }

      // ✅ PASO 2: Configurar
      await _printer.setPrintWidth(384);
      await _printer.setFontSize(0);

      // ✅ PASO 3: Imprimir
      await _printer.printText(contenido);
      await _printer.printText('\n\n\n');

      // ✅ PASO 4: Cortar
      try {
        await _printer.cutPaper();
        print('✅ Papel cortado');
      } catch (e) {
        print('⚠️ No se pudo cortar: $e');
      }

      // ✅ PASO 5: Beep
      try {
        await _printer.beep();
        print('✅ Beep emitido');
      } catch (e) {
        print('⚠️ No se pudo hacer beep: $e');
      }

      print('╔════════════════════════════════════════╗');
      print('║  ✅ TICKET IMPRESO EN BARRA           ║');
      print('╚════════════════════════════════════════╝\n');
    } catch (e) {
      print('❌ Error imprimiendo ticket: $e');
      rethrow;
    }
  }

  Future<void> imprimirPrueba(TipoImpresora tipo) async {
    try {
      print('🖨️ Prueba de impresión en ${tipo.name.toUpperCase()}...');

      // ✅ Conectar antes de imprimir
      final conectado = await _conectarAntes(tipo);
      if (!conectado) {
        throw Exception('No se pudo conectar a ${tipo.name}');
      }

      await _printer.setPrintWidth(384);
      await _printer.setFontSize(0);

      final mensaje =
          '''
================================
    PRUEBA DE IMPRESIÓN
================================
Impresora: ${tipo == TipoImpresora.cocina ? 'COCINA (A)' : 'BARRA (B)'}
Fecha: ${DateTime.now()}
================================
✅ Si puedes leer esto,
   la impresora funciona
   correctamente.
================================
''';

      await _printer.printText(mensaje);
      await _printer.printText('\n\n\n');

      try {
        await _printer.cutPaper();
      } catch (e) {
        print('⚠️ No se pudo cortar: $e');
      }

      try {
        await _printer.beep();
      } catch (e) {
        print('⚠️ No se pudo hacer beep: $e');
      }

      print('✅ Prueba impresa en ${tipo.name}');
    } catch (e) {
      print('❌ Error en prueba: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES
  // ════════════════════════════════════════════════════════

  bool estaConectada(TipoImpresora tipo) {
    if (tipo == TipoImpresora.cocina) {
      return _cocinaId != null && _cocinaAddress != null;
    } else {
      return _barraId != null && _barraAddress != null;
    }
  }

  Map<String, dynamic> getInfo(TipoImpresora tipo) {
    if (tipo == TipoImpresora.cocina) {
      return {
        'conectada': estaConectada(TipoImpresora.cocina),
        'id': _cocinaId,
        'name': _cocinaName,
        'type': _cocinaType,
        'address': _cocinaAddress,
      };
    } else {
      return {
        'conectada': estaConectada(TipoImpresora.barra),
        'id': _barraId,
        'name': _barraName,
        'type': _barraType,
        'address': _barraAddress,
      };
    }
  }

  Future<List<Map<String, String>>> buscarImpresoras() async {
    try {
      return await _printer.scanPrinters();
    } catch (e) {
      print('❌ Error buscando impresoras: $e');
      return [];
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// EXTENSIÓN PARA PRODUCTOS
// ═══════════════════════════════════════════════════════════════

extension ProductoExtension on Map<String, dynamic> {
  bool get esBarra {
    final categoria = (this['categoria'] as String?)?.toLowerCase() ?? '';
    return categoria.contains('cerveza') ||
        categoria.contains('brandy') ||
        categoria.contains('tequila') ||
        categoria.contains('mezcales') ||
        categoria.contains('sin alcohol') ||
        categoria.contains('cocteleria') ||
        categoria.contains('vinos') ||
        categoria.contains('whisky') ||
        categoria.contains('bebidas');
  }

  bool get esCocina => !esBarra;
}
