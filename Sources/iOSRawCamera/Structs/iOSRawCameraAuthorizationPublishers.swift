//
//  iOSRawCameraAuthorizationPublishers.swift
//  
//
//  Created by Nomad Company on 6/5/20.
//

import Combine
import AVFoundation

/// Struct that houses the definitions for publishers exposed from this library.
public struct iOSRawCameraAuthorizationPublishers {
    /// The definition of the Combine publishers that will start the pipeline for camera authorization. If a piece of your app is interested in the `AVAuthorizationStatus` for the app you can obtain the status here as well and listen for changes.
    public static let cameraAuthorization: CurrentValueSubject<AVAuthorizationStatus, Never> = CurrentValueSubject<AVAuthorizationStatus, Never>(CameraAuthorizationController().authorizationStatus())
    /// The definition of the Combine publisher that lets a user trigger the camera authentication workflow
    public static let requestCameraAuthorization: PassthroughSubject<AVAuthorizationAction, Never> = PassthroughSubject<AVAuthorizationAction, Never>()
    /// If there was an error in the Authorization process then that error will be published through here.
    public static let cameraAuthorizationError: PassthroughSubject<CameraAuthorizationController.CameraAuthorizationError, Never> = PassthroughSubject<CameraAuthorizationController.CameraAuthorizationError, Never>()
}
