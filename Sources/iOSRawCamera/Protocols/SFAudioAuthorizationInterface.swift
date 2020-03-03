//
//  SFAudioAuthorizationInterface.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 2/15/20.
//  Copyright © 2020 Nomad Company. All rights reserved.
//
/**
 We need an interface declaration so that we could write test eventually.
 
 The `SFSpeechRecognizer`contains these properties and functions that the `SFAudioAuthorizationController` needs to manage authorization in the way that I want.
 
 */
public protocol SFAudioAuthorizationInterface {
    
    var isAvailable: Bool { get }
    
    // True if this recognition can handle requests with requiresOnDeviceRecognition set to true
    @available(iOS 13, *)
    var supportsOnDeviceRecognition: Bool { get }
    
    static func authorizationStatus() -> SFSpeechRecognizerAuthorizationStatus

    static func requestAuthorization(_ handler: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void)
}



