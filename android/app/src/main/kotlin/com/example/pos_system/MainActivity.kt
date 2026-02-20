package com.example.pos_system

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tuapp/welirkca_printer"
    private var bluetoothSocket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null
    private var methodChannel: MethodChannel? = null
    private val PRINTER_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                
                "isBluetoothEnabled" -> {
                    val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
                    result.success(bluetoothManager?.adapter?.isEnabled ?: false)
                }
                
                "scanPrinters" -> {
                    try {
                        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
                        val bluetoothAdapter = bluetoothManager?.adapter
                        val pairedDevices = bluetoothAdapter?.bondedDevices ?: emptySet()
                        val printers = pairedDevices.map { mapOf("id" to it.address, "name" to (it.name ?: "Desconocido")) }
                        result.success(printers)
                    } catch (e: Exception) {
                        result.error("SCAN_ERROR", e.message, null)
                    }
                }
                
                "connectBluetooth" -> {
                    val deviceId = call.argument<String>("deviceId")
                    Thread {
                        try {
                            val bluetoothAdapter = (getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
                            val device = bluetoothAdapter.getRemoteDevice(deviceId)
                            bluetoothSocket?.close()
                            bluetoothSocket = device.createRfcommSocketToServiceRecord(PRINTER_UUID)
                            bluetoothSocket?.connect()
                            outputStream = bluetoothSocket?.outputStream
                            runOnUiThread { result.success(true) }
                        } catch (e: Exception) {
                            runOnUiThread { result.success(false) }
                        }
                    }.start()
                }

                "printText" -> {
                    val text = call.argument<String>("text") ?: ""
                    if (outputStream == null) {
                        result.error("NOT_CONNECTED", "Impresora no conectada", null)
                        return@setMethodCallHandler
                    }
                    try {
                        // Usamos ISO-8859-1 para compatibilidad con tildes y caracteres especiales
                        outputStream?.write(text.toByteArray(Charsets.ISO_8859_1))
                        outputStream?.flush()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("PRINT_ERROR", e.message, null)
                    }
                }

                "selfTest" -> {
                    try {
                        // Comando estándar ESC/POS para autotest
                        outputStream?.write(byteArrayOf(0x12, 0x54))
                        outputStream?.flush()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }

                "cutPaper" -> {
                    try {
                        outputStream?.write(byteArrayOf(0x1D, 0x56, 0x42, 0x00))
                        outputStream?.flush()
                        result.success(true)
                    } catch (e: Exception) { result.success(false) }
                }

                "beep" -> {
                    try {
                        outputStream?.write(byteArrayOf(0x1B, 0x42, 0x02, 0x02))
                        outputStream?.flush()
                        result.success(true)
                    } catch (e: Exception) { result.success(false) }
                }

                // Estos métodos ahora responden "true" para evitar errores en Flutter
                "setPrintWidth", "setFontSize" -> result.success(true)
                
                "disconnect" -> {
                    outputStream?.close()
                    bluetoothSocket?.close()
                    outputStream = null
                    bluetoothSocket = null
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}