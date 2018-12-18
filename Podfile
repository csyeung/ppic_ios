# Podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'ppic_ios' do
  pod 'Mapbox-iOS-SDK'
  pod 'ClusterKit/Mapbox'
  pod 'Firebase'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Auth'
  pod 'Firebase/Performance'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'
  pod 'JSQMessagesViewController', :git => 'https://github.com/Ariandr/JSQMessagesViewController.git', :branch => 'master', :inhibit_warnings => true
  pod 'CropViewController'
  pod 'SwiftDate'
  pod 'Fabric'
  pod 'Crashlytics'

  # Tests
  target 'ppic_iosTests' do
    inherit! :search_paths
  end
end
