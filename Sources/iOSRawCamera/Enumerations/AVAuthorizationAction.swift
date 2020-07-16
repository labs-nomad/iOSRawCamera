//
//  AVAuthorizationAction.swift
//  
//
//  Created by Nomad Company on 7/15/20.
//

import Foundation

/// Enumeration that represents the actions the user can take to request Authorization. These requests can be passed into the `iOSRawCameraAuthorizationPublishers.requestCameraAuthorization` publisher
public enum AVAuthorizationAction {
    //The app is requesting access to the camera.
    case requestAuthorization
}
