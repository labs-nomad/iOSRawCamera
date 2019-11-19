//
//  AVCaptureDevice_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation
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
