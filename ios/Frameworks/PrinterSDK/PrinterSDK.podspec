Pod::Spec.new do |s|
  s.name             = 'PrinterSDK'
  s.version          = '1.0.0'
  s.summary          = 'Welirkca Printer SDK'
  s.homepage         = 'https://welirkca.com'
  s.license          = { :type => 'Commercial' }
  s.author           = { 'Welirkca' => 'support@welirkca.com' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '12.0'
  
  s.vendored_libraries = '*.a'
  s.source_files = '*.h'
  s.public_header_files = '*.h'
  
  s.frameworks = 'CoreBluetooth', 'SystemConfiguration'
  s.libraries = 'c++'
end
