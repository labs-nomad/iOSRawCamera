//
//  InputManager.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

/// Class that will let
public class InputManager: NSObject {
    //MARK: Public Properties
    public typealias FrameRateRange = (min: Float64, max: Float64)
    public typealias FactorAndLevel = (factor: AVCaptureDevice.SystemPressureState.Factors, level: AVCaptureDevice.SystemPressureState.Level)
    
    //MARK: Private Properties
    var keyValueObservations: [NSKeyValueObservation] = []
    

    //MARK: Init
    
    
    //MARK: Public Functions
    public func setFrameRate(forInput input: AVCaptureDeviceInput, rate: Int32) throws {
        let newTime = CMTimeMake(value: 1, timescale: rate)
        try input.device.lockForConfiguration()
        input.device.activeVideoMaxFrameDuration = newTime
        input.device.activeVideoMinFrameDuration = newTime
        input.device.unlockForConfiguration()
    }
    
    //https://warrenmoore.net/understanding-cmtime
    public func currentFrameRate(forInput input: AVCaptureDeviceInput) -> FrameRateRange {
        let min = input.device.activeVideoMinFrameDuration
        let max = input.device.activeVideoMaxFrameDuration
        return (CMTimeGetSeconds(min), CMTimeGetSeconds(max))
    }
    
    public func availableFrameRateRange(forInput input: AVCaptureDeviceInput) -> FrameRateRange {
        let frameRateRanges = input.device.activeFormat.videoSupportedFrameRateRanges
        var min: Float64?
        var max: Float64?
        for range in frameRateRanges {
            if min == nil {
                min = range.minFrameRate
            }else if min! < range.minFrameRate {
                min = range.minFrameRate
            }
            if max == nil {
                max = range.maxFrameRate
            }else if max! > range.maxFrameRate {
                max = range.maxFrameRate
            }
        }
        guard let finalMin = min, let finalMax = max else {
            return (0, 0)
        }
        return (finalMin, finalMax)
    }
    
    
    
    public func getSystemPressureReading(forInput input: AVCaptureDeviceInput) -> FactorAndLevel {
        let factor = input.device.systemPressureState.factors
        let level = input.device.systemPressureState.level
        return (factor, level)
    }
    
    
//    public func startObserving(input: AVCaptureDeviceInput) {
//        let observable: AVCaptureDeviceInput = input
//        let observations = self.observe(\.observable.device.systemPressureState, options: .new) { _, change in
//            guard let systemPressureState = change.newValue else { return }
//        }
//    }
    
}
