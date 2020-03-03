//
//  SystemPressureStateFactors_Extension.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/27/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

public extension AVCaptureDevice.SystemPressureState.Factors {
    /// Returns the human readable string that describes the system pressure factors.
    func toString() -> String {
        switch self {
        case .depthModuleTemperature:
            return "The module capturing depth information is operating at an elevated temperature."
        case .peakPower:
            return "The system's peak power requirements exceed the battery's current capacity."
        case .systemTemperature:
            return "The entire system is under elevated thermal load."
        default:
            return "System pressure factors are unknown."
        }
    }
}
