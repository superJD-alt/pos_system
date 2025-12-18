import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private var printerChannel: FlutterMethodChannel?
    private var printerSDK: PrinterSDK?
    private var discoveredPrinters: [Printer] = []

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        
        // Configurar Method Channel
        printerChannel = FlutterMethodChannel(
            name: "com.tuapp/welirkca_printer",
            binaryMessenger: controller.binaryMessenger
        )
        
        // Inicializar SDK - CORREGIDO: defaultPrinterSDK()
        printerSDK = PrinterSDK.defaultPrinterSDK()
        
        // Escuchar notificaciones del SDK
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(printerConnected),
            name: NSNotification.Name(rawValue: PrinterConnectedNotification),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(printerDisconnected),
            name: NSNotification.Name(rawValue: PrinterDisconnectedNotification),
            object: nil
        )
        
        // Manejar llamadas desde Flutter
        printerChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "scanPrinters":
                self.scanPrinters(result: result)
                
            case "stopScan":
                self.stopScan(result: result)
                
            case "connectBluetooth":
                if let args = call.arguments as? [String: Any],
                   let deviceId = args["deviceId"] as? String {
                    self.connectBluetooth(deviceId: deviceId, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Device ID requerido", details: nil))
                }
                
            case "connectWifi":
                if let args = call.arguments as? [String: Any],
                   let ipAddress = args["ipAddress"] as? String {
                    self.connectWifi(ipAddress: ipAddress, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "IP requerida", details: nil))
                }
                
            case "disconnect":
                self.disconnect(result: result)
                
            case "setPrintWidth":
                if let args = call.arguments as? [String: Any],
                   let width = args["width"] as? Int {
                    self.setPrintWidth(width: width, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Width requerido", details: nil))
                }
                
            case "printText":
                if let args = call.arguments as? [String: Any],
                   let text = args["text"] as? String {
                    self.printText(text: text, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Text requerido", details: nil))
                }
                
            case "printTextImage":
                if let args = call.arguments as? [String: Any],
                   let text = args["text"] as? String {
                    self.printTextImage(text: text, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Text requerido", details: nil))
                }
                
            case "printBarcode":
                if let args = call.arguments as? [String: Any],
                   let code = args["code"] as? String,
                   let typeValue = args["type"] as? Int {
                    self.printBarcode(code: code, type: typeValue, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Code y type requeridos", details: nil))
                }
                
            case "printQRCode":
                if let args = call.arguments as? [String: Any],
                   let data = args["data"] as? String {
                    self.printQRCode(data: data, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Data requerido", details: nil))
                }
                
            case "printImage":
                if let args = call.arguments as? [String: Any],
                   let imageBytes = args["imageBytes"] as? FlutterStandardTypedData {
                    self.printImage(imageBytes: imageBytes, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "ImageBytes requerido", details: nil))
                }
                
            case "cutPaper":
                self.cutPaper(result: result)
                
            case "beep":
                self.beep(result: result)
                
            case "openCashDrawer":
                self.openCashDrawer(result: result)
                
            case "setFontSize":
                if let args = call.arguments as? [String: Any],
                   let multiple = args["multiple"] as? Int {
                    self.setFontSize(multiple: multiple, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Multiple requerido", details: nil))
                }
                
            case "printTestPaper":
                self.printTestPaper(result: result)
                
            case "selfTest":
                self.selfTest(result: result)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Métodos de impresora
    
    private func scanPrinters(result: @escaping FlutterResult) {
        discoveredPrinters.removeAll()
        
        // CORREGIDO: scanPrintersWithCompletion
        printerSDK?.scanPrinters(completion: { [weak self] printer in
            guard let self = self, let printer = printer else { return }
            self.discoveredPrinters.append(printer)
        })
        
        // Esperar 3 segundos para recolectar resultados
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            
            let devices = self.discoveredPrinters.map { printer -> [String: String] in
                return [
                    "id": printer.uuidString,      // Propiedad del SDK
                    "name": printer.name           // Propiedad del SDK
                ]
            }
            result(devices)
        }
    }
    
    private func stopScan(result: @escaping FlutterResult) {
        printerSDK?.stopScanPrinters()
        result(nil)
    }
    
    private func connectBluetooth(deviceId: String, result: @escaping FlutterResult) {
        // CORREGIDO: UUIDString (mayúscula según el header)
        if let printer = discoveredPrinters.first(where: { $0.uuidString == deviceId }) {
            printerSDK?.connectBT(printer)
            result(true)
        } else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Impresora no encontrada", details: nil))
        }
    }
    
    private func connectWifi(ipAddress: String, result: @escaping FlutterResult) {
        let success = printerSDK?.connectIP(ipAddress) ?? false
        result(success)
    }
    
    private func disconnect(result: @escaping FlutterResult) {
        printerSDK?.disconnect()
        result(nil)
    }
    
    private func setPrintWidth(width: Int, result: @escaping FlutterResult) {
        printerSDK?.setPrintWidth(width)
        result(nil)
    }
    
    private func printText(text: String, result: @escaping FlutterResult) {
        printerSDK?.printText(text)
        result(nil)
    }
    
    private func printTextImage(text: String, result: @escaping FlutterResult) {
        printerSDK?.printTextImage(text)
        result(nil)
    }
    
    private func printBarcode(code: String, type: Int, result: @escaping FlutterResult) {
        // Convertir el Int a CodeBarType del SDK
        let barcodeType = CodeBarType(rawValue: UInt32(type)) ?? CodeBarType_CODE128
        printerSDK?.printCodeBar(code, type: barcodeType)
        result(nil)
    }
    
    private func printQRCode(data: String, result: @escaping FlutterResult) {
        printerSDK?.printQrCode(data)
        result(nil)
    }
    
    private func printImage(imageBytes: FlutterStandardTypedData, result: @escaping FlutterResult) {
        if let image = UIImage(data: imageBytes.data) {
            printerSDK?.printImage(image)
            result(nil)
        } else {
            result(FlutterError(code: "INVALID_IMAGE", message: "No se pudo crear imagen", details: nil))
        }
    }
    
    private func cutPaper(result: @escaping FlutterResult) {
        printerSDK?.cutPaper()
        result(nil)
    }
    
    private func beep(result: @escaping FlutterResult) {
        printerSDK?.beep()
        result(nil)
    }
    
    private func openCashDrawer(result: @escaping FlutterResult) {
        printerSDK?.openCasher()
        result(nil)
    }
    
    private func setFontSize(multiple: Int, result: @escaping FlutterResult) {
        printerSDK?.setFontSizeMultiple(multiple)
        result(nil)
    }
    
    private func printTestPaper(result: @escaping FlutterResult) {
        printerSDK?.printTestPaper()
        result(nil)
    }
    
    private func selfTest(result: @escaping FlutterResult) {
        printerSDK?.selfTest()
        result(nil)
    }
    
    // MARK: - Notificaciones
    
    @objc private func printerConnected() {
        printerChannel?.invokeMethod("onPrinterConnected", arguments: nil)
    }
    
    @objc private func printerDisconnected() {
        printerChannel?.invokeMethod("onPrinterDisconnected", arguments: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}