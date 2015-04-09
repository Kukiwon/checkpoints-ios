#
# Be sure to run `pod lib lint Checkpoints.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Checkpoints"
  s.version          = "0.1.6"
  s.summary          = "This is the iOS SDK for Checkpoints, a simple but powerful debugging and testing tool."
  s.description      = <<-DESC
            Checkpoints allows you to place 'checkpoints' within your app. Doing so, you can track your application flow on user-level. Once you set up the SDK, you can access session- and checkpoint data and insights inside the Checkpoint control panel.
			For more info, check: https://github.com/Kukiwon/checkpoints
			DESC
  s.homepage         = "https://github.com/kukiwon/checkpoints-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jordy van Kuijk" => "jvankuijk@me.com" }
  s.source           = { :git => "https://github.com/Kukiwon/checkpoints-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jvankuijk'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.ios.vendored_frameworks = 'LoopBack.framework'

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Checkpoints' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
