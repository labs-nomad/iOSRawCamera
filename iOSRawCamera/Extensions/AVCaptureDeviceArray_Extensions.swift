//
//  AVCaptureDeviceArray_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

/*
 According to the Apple documentation around the discovery session the order of the array is preserved according to the requested device types. This means that you can ask for the best / latest camera first and expect that to be listed before the least performing camera.
 https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/choosing_a_capture_device
 We also need to configure the devices properties
 https://developer.apple.com/documentation/avfoundation/avcapturedevice
 */
extension Array where Element: AVCaptureDevice {
    /// The best front camera
    var front: AVCaptureDevice? {
        return self.first { (device) -> Bool in
            return device.position == AVCaptureDevice.Position.front
        }
    }
    
    //The best back camera
    var back: AVCaptureDevice? {
        return self.first { (device) -> Bool in
            return device.position == AVCaptureDevice.Position.back
        }
    }
}
