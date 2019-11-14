//
//  CameraAuthorizationController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

struct CameraAuthorizationController {
    /// Type alias for camera permission completion
    public typealias CameraPermissionReceived = (_ granted: Bool) -> Void
    
    /// Function that you can call to see if the User has provided camera authorization
    /// - Parameter authorization: A Type that can determine the Camera Authorization status
    public func isCameraAuthorized(authorization: AVCaptureDevice.Type = AVCaptureDevice.self) -> Bool {
        guard authorization.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized else {
            return false
        }
        return true
    }
    
    /// Function to check the Authorization status for the presence of the `.denied` flag in the Authorization Status. If this returns true then the user denied Authorization and the user has to go to settings to fix this.
    public func didUserDenyAuthorization() -> Bool {
        let authorizationStatus = self.authorizationStatus()
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
    public func requestCameraPermission(authorization: AVCaptureDevice.Type = AVCaptureDevice.self, completionHandle: @escaping CameraPermissionReceived) {
        authorization.requestAccess(for: AVMediaType.video) { (didComplete) in
            DispatchQueue.main.async {
                completionHandle(didComplete)
                NotificationCenter.default.post(name: CameraAuthorizationStateChangedNotification, object: self.authorizationStatus())
            }
        }
    }
    
    
    public func authorizationStatus(authorization: AVCaptureDevice.Type = AVCaptureDevice.self, type: AVMediaType = AVMediaType.video) -> AVAuthorizationStatus {
        return authorization.authorizationStatus(for: type)
    }
}
