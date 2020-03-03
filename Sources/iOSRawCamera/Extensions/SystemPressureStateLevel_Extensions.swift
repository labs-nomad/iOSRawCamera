//
//  SystemPressureStateLevel_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/27/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import AVFoundation

public extension AVCaptureDevice.SystemPressureState.Level {
    /// Returns the human readabel string for the level of system pressure.
    func toString() -> String {
        switch self {
        case .critical:
            return "System pressure is critically elevated. Capture quality and performance are significantly impacted. Frame rate throttling is highly advised."
        case .fair:
            return "System pressure is slightly elevated."
        case .nominal:
            return "System pressure level is normal (not pressured)."
        case .serious:
            return "System pressure is highly elevated. Capture performance may be impacted. Frame rate throttling is advised."
        case .shutdown:
            return "System pressure is beyond critical, so the capture system has shut down."
        default:
            return "System pressure state level is unknown."
        }
    }
}
