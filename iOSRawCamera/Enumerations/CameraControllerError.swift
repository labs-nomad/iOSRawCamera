//
//  CameraControllerError.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

enum CameraControllerError: Error, Equatable {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case permissionDenied
    case permissionNotDetermined
    case badPermissions
    case alreadyPrepared
    case videoOrientationChangesNotSupported
    case couldNotMakeNewVideoOrientation
    case noConnections
    case unknown
    
    public static func ==(lhs: CameraControllerError, rhs: CameraControllerError) -> Bool {
        switch (lhs, rhs) {
        case (CameraControllerError.captureSessionAlreadyRunning, CameraControllerError.captureSessionAlreadyRunning):
            return true
        case (CameraControllerError.captureSessionIsMissing, CameraControllerError.captureSessionIsMissing):
            return true
        case (CameraControllerError.inputsAreInvalid, CameraControllerError.inputsAreInvalid):
            return true
        case (CameraControllerError.invalidOperation, CameraControllerError.invalidOperation):
            return true
        case (CameraControllerError.noCamerasAvailable, CameraControllerError.noCamerasAvailable):
            return true
        case (CameraControllerError.permissionDenied, CameraControllerError.permissionDenied):
            return true
        case (CameraControllerError.permissionNotDetermined, CameraControllerError.permissionNotDetermined):
            return true
        case (CameraControllerError.badPermissions, CameraControllerError.badPermissions):
            return true
        case (CameraControllerError.alreadyPrepared, CameraControllerError.alreadyPrepared):
            return true
        case (CameraControllerError.unknown, CameraControllerError.unknown):
            return true
        default:
            return false
        }
    }
}
