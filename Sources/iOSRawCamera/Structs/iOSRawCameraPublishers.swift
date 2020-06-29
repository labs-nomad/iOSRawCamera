//
//  iOSRawCameraPublishers.swift
//  
//
//  Created by Nomad Company on 6/5/20.
//

import Combine
import AVFoundation

/// Struct that houses the definitions for publishers exposed from this library.
public struct iOSRawCameraPublishers {
    /// The definition of the Combine publishers that will start the pipeline for camera authorization.
    public static let cameraAuthorization: CurrentValueSubject<AVAuthorizationStatus, Never> = CurrentValueSubject<AVAuthorizationStatus, Never>(CameraAuthorizationController().authorizationStatus())
    /// The definition of the Combine publisher that lets a user trigger the camera authentication workflow
    public static let requestCameraAuthorization: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
    /// If there was an error in the Authorization process then that error will be published through here.
    public static let cameraAuthorizationError: PassthroughSubject<CameraAuthorizationController.CameraAuthorizationError, Never> = PassthroughSubject<CameraAuthorizationController.CameraAuthorizationError, Never>()
    /// The definition of the Combine publisher that will provide CVPixelBuffers
    public static let newPixelBuffer: PassthroughSubject<CVPixelBuffer, Never> = PassthroughSubject<CVPixelBuffer, Never>()
}
