Pod::Spec.new do |s|
  s.name         = "CTFluentLogger"
  s.version      = "0.0.1"
  s.summary      = "Logging to Fluentd library."
  s.homepage     = "https://github.com/rizumita/CTFluentLogger"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Ryoichi Izumita" => "r.izumita@caph.jp" }
  s.social_media_url   = "http://twitter.com/rizumita"
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/rizumita/CTFluentLogger.git", :tag => "0.0.1" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "CocoaAsyncSocket"
  s.dependency "MessagePack"
end
