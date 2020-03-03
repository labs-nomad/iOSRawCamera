//
//  InterruptionReason_Extension.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/27/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

public extension AVCaptureSession.InterruptionReason {
    /// Returns the Apple documentation string for the reason.
    func toString() -> String {
        switch self {
        case .audioDeviceInUseByAnotherClient:
            return "An interruption caused by the audio hardware temporarily being made unavailable (for example, for a phone call or alarm)."
        case .videoDeviceInUseByAnotherClient:
            return "An interruption caused by the video device temporarily being made unavailable (for example, when used by another capture session)."
        case .videoDeviceNotAvailableDueToSystemPressure:
            return "An interruption due to system pressure, such as thermal duress."
        case .videoDeviceNotAvailableInBackground:
            return "An interruption caused by the app being sent to the background while using a camera."
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            return "An interruption caused when your app is running in Slide Over, Split View, or Picture in Picture mode on iPad."
        @unknown default:
            return "Unknown"
        }
    }
}
