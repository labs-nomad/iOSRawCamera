//
//  AVCaptureDevice_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import AVFoundation
/**
 This extension forces conformance of the `AVCaptureDevice` to the `AVCaptureDeviceCameraAuthorizationInterface` so that we can provide objects with testable implementations
 
 */
extension AVCaptureDevice: AVCaptureDeviceCameraAuthorizationInterface {
    func automaticConfiguration() {
        if self.isExposureModeSupported(.continuousAutoExposure) {
            self.exposureMode = .continuousAutoExposure
        }
        if self.isFocusModeSupported(.continuousAutoFocus) {
            self.focusMode = .continuousAutoFocus
        }
        if self.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
            self.whiteBalanceMode = .continuousAutoWhiteBalance
        }
    }
}

extension AVCaptureDevice: FrameRateManagable {
    public func setFrameRate(rate: Int32) throws {
        let newTime = CMTimeMake(value: 1, timescale: rate)
        let asFloat = CMTimeGetSeconds(newTime)
        try self.validate(desiredFrameRate: asFloat)
        try self.lockForConfiguration()
        self.activeVideoMaxFrameDuration = newTime
        self.activeVideoMinFrameDuration = newTime
        self.unlockForConfiguration()
    }
    
    public func currentFrameRate() -> FrameRateRange {
        let min = self.activeVideoMinFrameDuration
        let max = self.activeVideoMaxFrameDuration
        return (CMTimeGetSeconds(min), CMTimeGetSeconds(max))
    }
    
    public func availableFrameRateRange() throws -> FrameRateRange {
        guard let frameRateRange = self.activeFormat.videoSupportedFrameRateRanges.first else {
            throw SetFrameRateError.noFrameRateRangeAvailable
        }
        let availableRange = (frameRateRange.minFrameRate, frameRateRange.maxFrameRate)
        return availableRange
    }
    
    public func validate(desiredFrameRate rate: Float64) throws {
        let availableFrameRateRanges = try self.availableFrameRateRange()
        let min = availableFrameRateRanges.min
        let max = availableFrameRateRanges.max
        if rate < min {
            throw SetFrameRateError.invalidFrameRateRange
        }
        
        if rate > max {
            throw SetFrameRateError.invalidFrameRateRange
        }
    }
    
    public func startObserving() -> [NSKeyValueObservation] {
        let factorObservation = self.observe(\.self.systemPressureState.factors, options: .new) { [weak self] (_, change) in
            guard let systemPressureFactors = change.newValue else {
                return
            }
            guard let strongSelf = self else {
                return
            }
            let reading: SystemPressureReading = (systemPressureFactors, strongSelf.systemPressureState.level)
            let object: DevicePressureReading = (strongSelf, reading)
            NotificationCenter.default.post(name: DeviceInputPressureChangeNotification, object: object)
        }
        let levelObservation = self.observe(\.self.systemPressureState.level, options: .new) { [weak self] (_, change) in
            guard let systemPressureLevel = change.newValue else {
                return
            }
            guard let strongSelf = self else {
                return
            }
            let reading: SystemPressureReading = (strongSelf.systemPressureState.factors, systemPressureLevel)
            let object: DevicePressureReading = (strongSelf, reading)
            NotificationCenter.default.post(name: DeviceInputPressureChangeNotification, object: object)
        }
        let minFrameRateObservation = self.observe(\.self.activeVideoMinFrameDuration, options: .new) { [weak self] (_, change) in
            guard let strongSelf = self else {
                return
            }
            let rate: FrameRateRange = strongSelf.currentFrameRate()
            let object: DeviceFrameRateChange = (strongSelf, rate)
            NotificationCenter.default.post(name: DeviceFrameRateChangedNotification, object: object)
        }
        let maxFrameRateObservation = self.observe(\.self.activeVideoMaxFrameDuration, options: .new) { [weak self] (_, chnage) in
            guard let strongSelf = self else {
                return
            }
            let rate: FrameRateRange = strongSelf.currentFrameRate()
            let object: DeviceFrameRateChange = (strongSelf, rate)
            NotificationCenter.default.post(name: DeviceFrameRateChangedNotification, object: object)
        }
        return [factorObservation, levelObservation, minFrameRateObservation, maxFrameRateObservation]
    }
}
