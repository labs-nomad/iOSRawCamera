//
//  AudioAuthorizationController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 2/15/20.
//  Copyright © 2020 Nomad Company. All rights reserved.
//
import Speech
import Foundation

/// Struct that facilitates the management and exploration of Text To Speech Authorization status.
public struct AudioAuthorizationController {
    //MARK: Public properties
    
    /// Type alias for camera permission change
    public typealias AudioPermissionReceived = (_ granted: Bool) -> Void
    
    /// Designated initalizer for the struct
    public init() {
        
    }
    
    //MARK: Public functions
    /// Quickly check to see if we are authorized
    /// - Parameter authorization: The authorization interface. Defaults to a static `SFSpeechRecognizer`
    public func isAudioAuthorized(authorization: SFAudioAuthorizationInterface.Type = SFSpeechRecognizer.self) -> Bool {
        let status = authorization.authorizationStatus()
        switch status {
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    /// We might wan't to know if the user denied Authorization. We can check that here
    /// - Parameter authorization: The authorization interface. Defaults to a static `SFSpeechRecognizer`
    public func didUserDenyAuthorization(authorization: SFAudioAuthorizationInterface.Type = SFSpeechRecognizer.self) -> Bool {
        let status = authorization.authorizationStatus()
        switch status {
        case .denied:
            return true
        default:
            return false
        }
    }
    
    /// Some devices might not allow speech recognition. We want to know about that so you can ask here
    /// - Parameter authorization: The authorization interface. Defaults to a `SFSpeechRecognizer()`
    public func speechRecognitionAvailable(authorization: SFAudioAuthorizationInterface? = SFSpeechRecognizer()) -> Bool {
        guard let authorizer = authorization else {
            return false
        }
        guard authorizer.isAvailable == true else {
            return false
        }
        if #available(iOS 13, *) {
            guard authorizer.supportsOnDeviceRecognition == true else {
                return false
            }
        } else {
            // Fallback on earlier versions
        }
        return true
    }
    
    /// Quickly retreive the authorization status
    /// - Parameter authorization: The authorization interface. Defaults to a static `SFSpeechRecognizer`
    public func authorizationStatus(authorization: SFAudioAuthorizationInterface.Type = SFSpeechRecognizer.self) -> SFSpeechRecognizerAuthorizationStatus {
        let status = authorization.authorizationStatus()
        return status
    }
    
    
    /// Requesting Authorization is a async operation. You start the process here and on completion a `AudioAuthorizationStateChangedNotification` will be fired.
    /// - Parameters:
    ///   - authorization: The authorization interface. Defaults to a static `SFSpeechRecognizer`
    ///   - completionHandle: The completion of the request with a boolean to indicate if we were authorized or not. If you want more details the call the sync authorization status. This callback gets returned on the main thread.
    public func requestSpeechPermission(authorization: SFAudioAuthorizationInterface.Type = SFSpeechRecognizer.self, completionHandle: @escaping(AudioPermissionReceived)) {
        authorization.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    completionHandle(true)
                default:
                    completionHandle(false)
                }
                NotificationCenter.default.post(name: AudioAuthorizationStateChangedNotification, object: status)
            }
        }
    }
    
    
}
