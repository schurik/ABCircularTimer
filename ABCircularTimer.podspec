Pod::Spec.new do |s|
  s.platform     = :ios, '8.0'
  s.name         = "ABCircularTimer"
  s.version      = "v1.0"
  s.summary      = "simple circle timer view."
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "schurik" => "buss.alexander@gmail.com" }
  s.homepage     = 'https://github.com/schurik/ABCircularTimer'
  s.source       = { :git => "https://github.com/schurik/ABCircularTimer.git", :tag => "v1.0" }
  s.source_files = 'ABCircularTimer/*.{swift}'
  s.requires_arc = true
end
