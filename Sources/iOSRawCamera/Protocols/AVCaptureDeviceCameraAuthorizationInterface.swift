//
//  AVCaptureDeviceCameraAuthorizationInterface.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import AVFoundation


public protocol AVCaptureDeviceCameraAuthorizationInterface {
    //MARK: Properties
    
    
    //MARK: Functions
    static func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
    static func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void)
}
