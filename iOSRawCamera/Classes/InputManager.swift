//
//  InputManager.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

class InputManager: NSObject {
    var currentCameraInput: AVCaptureDeviceInput?
    
    
    public func setFrameRate(rate: Int32) throws {
        let newTime = CMTimeMake(value: 1, timescale: rate)
        let seconds = CMTimeGetSeconds(newTime)
        print("New Frame Rate; \(seconds)")
        try self.currentCameraInput?.device.lockForConfiguration()
        self.currentCameraInput?.device.activeVideoMaxFrameDuration = newTime
        self.currentCameraInput?.device.activeVideoMinFrameDuration = newTime
        self.currentCameraInput?.device.unlockForConfiguration()
    }
    
    public typealias FrameRateRange = (min: Float64, max: Float64)
    
    //https://warrenmoore.net/understanding-cmtime
    public func currentFrameRate() -> FrameRateRange? {
        guard let min = self.currentCameraInput?.device.activeVideoMinFrameDuration, let max = self.currentCameraInput?.device.activeVideoMaxFrameDuration else {
            return nil
        }
        return (CMTimeGetSeconds(min), CMTimeGetSeconds(max))
    }
    
    public func availableFrameRateRange() {
        guard let frameRateRanges = self.currentCameraInput?.device.activeFormat.videoSupportedFrameRateRanges else {
            print("No Frame Rate info available")
            return
        }
        
        for range in frameRateRanges {
            print("Max Frame Rate: \(CMTimeGetSeconds(range.maxFrameDuration))")
            print("Min Frame Rate: \(CMTimeGetSeconds(range.minFrameDuration))")
            print("Max Frame Rate: \(range.maxFrameDuration)")
            print("Min Frame Rate: \(range.minFrameDuration)")
        }
    }
    
    public func getSystemPressureReading() -> (AVCaptureDevice.SystemPressureState.Factors, AVCaptureDevice.SystemPressureState.Level)? {
        guard let factor = self.currentCameraInput?.device.systemPressureState.factors, let level = self.currentCameraInput?.device.systemPressureState.level else {
            return nil
        }
        return (factor, level)
    }
}
