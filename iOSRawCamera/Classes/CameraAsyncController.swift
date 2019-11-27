//
//  CameraAsyncController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation


/// This controller helps you do ASYNC processes with the `CameraController` according to Apples best practice documentation. This controller is de-coupled from the `CameraController` because there are no assumptions  made on how you want to manage yoru background threads. This controller is available for convenience.
public struct CameraAsyncController {
    //MARK: Public Properties
    ///Callback definition for an Async call that could contain an error
    public typealias ErrorCallback = ((_ error: Error?) -> Void)
    ///Callback definition for an Async call
    public typealias EmptyCallback = (() -> Void)
    
    //MARK: Private Properties
    let serialDispatchQueue = DispatchQueue(label: QueueNames().cameraConfigurationQueue)
    
    //MARK: Init
    public init() {
        
    }
    
    //MARK: Public Functions
    
    /// Function that uses a serial background queue to prepare the `CameraController` and underlying `AVCaptureSession`
    /// - Parameters:
    ///   - controller: The `CameraController` you want to prepare
    ///   - finished: Once the `CameraController` is prepared then we call this on the return queue
    ///   - returnQueue: The Queue that you want the `SetUpCallback` to be called back on. Defaults to `DispatchQueue.main`
    public func setUpAsync(cameraController controller: CameraController, sessionPreset: AVCaptureSession.Preset = .vga640x480, desiredCameraPosition: iOSRawCameraRoute = .front, authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, authorizationController: CameraAuthorizationController = CameraAuthorizationController(), finished: ErrorCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            do {
                try controller.setUp(sessionPreset: sessionPreset, desiredCameraPosition: desiredCameraPosition, authorization: authorization, authorizationController: authorizationController)
                returnQueue.async {
                    finished?(nil)
                }
            }catch{
                returnQueue.async {
                    finished?(error)
                }
            }
        }
    }
    
    
    /// Starts the Camera Controller on a background Serial Dispatch Queue
    /// - Parameters:
    ///   - controller: The camera controller that you want to start
    ///   - callback: The callback that tells you when the `CameraController` was sucessfully started
    ///   - returnQueue: The `DispatchQueue` that you want the call to return on. Defaults to the man UI Queue
    public func startAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.startRunning()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    
    /// Async stops the camera from running
    /// - Parameters:
    ///   - controller: The camera controller that you want to stop
    ///   - callback: The callback that tells you when the `CameraController` was sucessfully started
    ///   - returnQueue: The `DispatchQueue` that you want the call to return on. Defaults to the man UI Queue
    public func stopAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.stopRunning()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    /// Async resets the camera by callign stop then start on the `AVFoundation` `AVCaptureSession`
    /// - Parameters:
    ///   - controller: The camera controller that you want to restart
    ///   - callback: The callback that tells you when the `CameraController` was sucessfully started
    ///   - returnQueue: The `DispatchQueue` that you want the call to return on. Defaults to the man UI Queue
    public func resetAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.resetCaptureSession()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    /// Async change the running state of the `CameraController`
    /// - Parameters:
    ///   - controller: The camera controller that you want to toggle
    ///   - callback: The callback that tells you when the `CameraController` was sucessfully started
    ///   - returnQueue: The `DispatchQueue` that you want the call to return on. Defaults to the man UI Queue
    public func toggleAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.toggleRunning()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    
    /// Switch the video feed from the front to back or vice versa. Will return an `Error` if something went wrong.
    /// - Parameters:
    ///   - controller: The camera controller that you want to swap cameras
    ///   - callback: The callback that tells you when the `CameraController` was sucessfully started
    ///   - returnQueue: The `DispatchQueue` that you want the call to return on. Defaults to the man UI Queue
    public func swapCamerasAsync(cameraController controller: CameraController, callback: ErrorCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            do {
                try controller.switchCameras()
                returnQueue.async {
                    callback?(nil)
                }
            }catch{
                returnQueue.async {
                    callback?(error)
                }
            }
        }
    }
    
    
}
