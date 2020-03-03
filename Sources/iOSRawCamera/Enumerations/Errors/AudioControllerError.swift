//
//  AudioControllerError.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 2/16/20.
//  Copyright © 2020 Nomad Company. All rights reserved.
//

import Foundation


public enum AudioControllerError: Error, Equatable {
    case permissionDenied
    case permissionNotDetermined
    case badPermissions
    case becameUnavailable
    case onDeviceRecognitionNotSupported
}
