Pod::Spec.new do |s|
  s.name             = 'jyotish'
  s.version          = '2.19.0'
  s.summary          = 'A production-ready Flutter library for Vedic astrology (Jyotish) calculations using Swiss Ephemeris.'
  s.description      = <<-DESC
A production-ready Flutter library for Vedic astrology (Jyotish) calculations using Swiss Ephemeris.
Provides high-precision sidereal planetary positions with Lahiri ayanamsa, nakshatras, and complete birth chart analysis.
                       DESC
  s.homepage         = 'https://github.com/rajsanjib/jyotish-flutter-library'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sanjib Acharya' => 'rajsanjib@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.0'
end
