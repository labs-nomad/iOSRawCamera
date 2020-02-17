//
//  CameraControllerError.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

/// Enumeration that encompases errors that can be thrown from the `CameraController`
public enum CameraControllerError: Error, Equatable {
    case inputsAreInvalid
    case noCamerasAvailable
    case permissionDenied
    case permissionNotDetermined
    case badPermissions
    case videoOrientationChangesNotSupported
    case couldNotMakeNewVideoOrientation
    case noConnections
    
    public static func ==(lhs: CameraControllerError, rhs: CameraControllerError) -> Bool {
        switch (lhs, rhs) {
        case (CameraControllerError.inputsAreInvalid, CameraControllerError.inputsAreInvalid):
            return true
        case (CameraControllerError.noCamerasAvailable, CameraControllerError.noCamerasAvailable):
            return true
        case (CameraControllerError.permissionDenied, CameraControllerError.permissionDenied):
            return true
        case (CameraControllerError.permissionNotDetermined, CameraControllerError.permissionNotDetermined):
            return true
        case (CameraControllerError.badPermissions, CameraControllerError.badPermissions):
            return true
        default:
            return false
        }
    }
}
