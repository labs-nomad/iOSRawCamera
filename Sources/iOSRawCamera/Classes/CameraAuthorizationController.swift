//
//  CameraAuthorizationController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//
import Combine
import AVFoundation

/// This is a struct that you can use to determine the authorization status of the camera.
public struct CameraAuthorizationController {
    //MARK: Public properties
    
    //MARK: Embedded Objects
    /// An error that can happen during a camera authorization request.
    public enum CameraAuthorizationError: Error {
        case accessRequestFailed
    }
    
    //MARK Init
    /// Designated initalizer for this struct.
    public init() {
        
    }
    
    /// Function that you can call to see if the User has provided camera authorization
    /// - Parameter authorization: A Type that can determine the Camera Authorization status
    public func isCameraAuthorized(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self) -> Bool {
        guard authorization.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized else {
            return false
        }
        return true
    }
    
    
    /// Function to check the Authorization status for the presence of the `.denied` flag in the Authorization Status. If this returns true then the user denied Authorization and the user has to go to settings to fix this.
    public func didUserDenyAuthorization(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self) -> Bool {
        let authorizationStatus = self.authorizationStatus(authorization: authorization, type: AVMediaType.video)
        switch authorizationStatus {
        case .denied:
            return true
        default:
            return false
        }
    }
    

    /// Kicks off the request camera permission flow.
    /// - Parameter authorization: An object capable of granting authorization
    /// - Returns: A Combine future to tell you when the request finishes.
    public func requestCameraPermission(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self) -> Future<AVAuthorizationAction, CameraAuthorizationError> {
        let future: Future<AVAuthorizationAction, CameraAuthorizationError> = Future<AVAuthorizationAction, CameraAuthorizationError> { promise in
            authorization.requestAccess(for: AVMediaType.video) { (didComplete) in
                switch didComplete {
                case false:
                    promise(.failure(CameraAuthorizationError.accessRequestFailed))
                case true:
                    promise(.success(AVAuthorizationAction.requestAuthorization))
                }
            }
        }
        return future
    }
    
    
    /// Convenience function that will return to you the `AVAuthorizationStatus` of the input `AVMediaType`
    /// - Parameters:
    ///   - authorization: The type that can determine authorization. Defaults to `AVCaptureDevice.self`
    ///   - type: The type that you want to determine authorization for. Defaults to `AVMediaType.video`
    public func authorizationStatus(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, type: AVMediaType = AVMediaType.video) -> AVAuthorizationStatus {
        return authorization.authorizationStatus(for: type)
    }
}
