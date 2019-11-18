//
//  CameraAuthorizationController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

/// This is a struct that you can use to determine the authorization status of the camera.
public struct CameraAuthorizationController {
    //MARK: Public properties
    
    /// Type alias for camera permission completion
    public typealias CameraPermissionReceived = (_ granted: Bool) -> Void
    
    
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
    ///
    /// - Parameters:
    ///   - authorization: An object that has the appropriate methods to request access.
    ///   - completionHandle: The completion that tells you if the app has access or not.
    public func requestCameraPermission(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, completionHandle: @escaping CameraPermissionReceived) {
        authorization.requestAccess(for: AVMediaType.video) { (didComplete) in
            DispatchQueue.main.async {
                completionHandle(didComplete)
                NotificationCenter.default.post(name: CameraAuthorizationStateChangedNotification, object: self.authorizationStatus(authorization: authorization))
            }
        }
    }
    
    
    /// Convenience function that will return to you the `AVAuthorizationStatus` of the input `AVMediaType`
    /// - Parameters:
    ///   - authorization: The type that can determine authorization. Defaults to `AVCaptureDevice.self`
    ///   - type: The type that you want to determine authorization for. Defaults to `AVMediaType.video`
    public func authorizationStatus(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, type: AVMediaType = AVMediaType.video) -> AVAuthorizationStatus {
        return authorization.authorizationStatus(for: type)
    }
}
