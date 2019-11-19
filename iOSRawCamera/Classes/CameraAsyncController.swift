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
    ///Callback definition for the `setUp` function
    public typealias ErrorCallback = ((_ error: Error?) -> Void)
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
    public func setUpAsync(cameraController controller: CameraController, sessionPreset: AVCaptureSession.Preset = .vga640x480, desiredCameraPosition: CameraRoute = .front, authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, authorizationController: CameraAuthorizationController = CameraAuthorizationController(), finished: ErrorCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
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
    
    
    public func startAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.startRunning()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    
    public func stopAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.stopRunning()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    public func resetAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.resetCaptureSession()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    public func toggleAsync(cameraController controller: CameraController, callback: EmptyCallback? = nil, returnQueue: DispatchQueue = DispatchQueue.main) {
        self.serialDispatchQueue.async {
            controller.toggleRunning()
            returnQueue.async {
                callback?()
            }
        }
    }
    
    
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
