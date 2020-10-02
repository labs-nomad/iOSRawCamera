//
//  MockAuthorizer.swift
//  iOSRawCameraTests
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import iOSRawCamera
import AVFoundation

class StaticMockAuthorizer: AVCaptureDeviceCameraAuthorizationInterface {
    //MARK: Properties
    static var state: AVAuthorizationStatus = .notDetermined
    
    static var requestOutcome: AVAuthorizationStatus = .authorized
    
    static var hasAccess: Bool = false
    
    //MARK: Functions
    static func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        return StaticMockAuthorizer.state
    }
    
    static func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void) {
        StaticMockAuthorizer.state = StaticMockAuthorizer.requestOutcome
        let authorized = (StaticMockAuthorizer.state == AVAuthorizationStatus.authorized)
        StaticMockAuthorizer.hasAccess = authorized
        handler(StaticMockAuthorizer.hasAccess)
    }
    
}
