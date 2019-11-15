#
# Be sure to run `pod lib lint GraphQL-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name = 'iOSRawCamera'
    s.version = '1.0.6'
    s.summary = 'Get the raw camera feed for Computer Vision Tasks'
    s.description = <<-DESC 
    This pod lets you access the CVPixelBuffer object in accordance with Apples Documentation.
     DESC
    
    s.homepage = 'https://github.com/labs-nomad/iOSRawCamera'

    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'shared@nomad-go.com' => 'nomad@shared-go.com' }
    s.source           = { :git => 'https://github.com/labs-nomad/iOSRawCamera.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '11.1'

    s.source_files = 'iOSRawCamera/**/*.{h,m,swift}'
  
    s.swift_version = '5'

    s.frameworks = 'AVFoundation'
end