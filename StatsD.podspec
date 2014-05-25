Pod::Spec.new do |s|
  s.name     = 'StatsD'
  s.version  = '0.0.1'
  s.homepage = 'https://github.com/newspaperclub/statsd-cocoa'
  s.summary  = 'StatsD client for Objective-C/Cocoa'
  s.license  = 'MIT'
  s.author   = { 'Tom Taylor' => 'tom@newspaperclub.com' }
  s.source   = { :git => 'https://github.com/newspaperclub/statsd-cocoa.git', :tag => s.version.to_s }

  s.platform            = :osx, "10.7"
  s.requires_arc        = true
  s.source_files        = 'StatsD/StatsD.{h,m}'
  s.public_header_files = 'StatsD/StatsD.h'

  s.dependency 'CocoaAsyncSocket', '~> 7.3'
end
