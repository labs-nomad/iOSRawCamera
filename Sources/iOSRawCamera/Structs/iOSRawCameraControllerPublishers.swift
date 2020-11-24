//
//  iOSRawCameraControllerPublishers.swift
//  
//
//  Created by Nomad Company on 7/15/20.
//

import Combine
import AVFoundation

/// Struct that holds the publishers which
public struct iOSRawCameraControllerPublishers {
    /// The Combine publisher that will send changes to the `VideoFeedState`
    public static let videoFeedState: CurrentValueSubject<VideoFeedState, Never> = CurrentValueSubject<VideoFeedState, Never>(VideoFeedState.notPrepared(nil))
    /// The Combine publisher that will send state changes for the `AVCaptureVideoPreviewLayer`'s state as a `AVCaptureVideoPreviewLayerState` enum
    public static let previewLayerState: CurrentValueSubject<AVCaptureVideoPreviewLayerState, Never> = CurrentValueSubject<AVCaptureVideoPreviewLayerState, Never>(AVCaptureVideoPreviewLayerState.unavailable)
    /// The definition of the Combine publisher that will provide CVPixelBuffers
    public static let newPixelBuffer: PassthroughSubject<CVPixelBuffer, Never> = PassthroughSubject<CVPixelBuffer, Never>()
    /// The Combine publisher that will send updates when the `AVCaptureDeviceInput` changes
    public static let deviceInputChanged: CurrentValueSubject<AVCaptureDeviceInput?, Never> = CurrentValueSubject<AVCaptureDeviceInput?, Never>(nil)
    /// The Combine publisher that will send an update when the `AVCaptureDevice` changes
    public static let captureDeviceChanged: CurrentValueSubject<AVCaptureDevice?, Never> = CurrentValueSubject<AVCaptureDevice?, Never>(nil)
    /// The Combine publisher that gets fired when the `iOSRawCameraRoute` changes.
    public static let cameraRoute: CurrentValueSubject<iOSRawCameraRoute, Never> = CurrentValueSubject<iOSRawCameraRoute, Never>(iOSRawCameraRoute.front)
    /// The publisher that allows the user to change camera routes
    public static let changeCameraRoute: PassthroughSubject<iOSRawCameraRouteAction, Never> = PassthroughSubject<iOSRawCameraRouteAction, Never>()
    /// The Combine publisher that will publish `Error` objects from the `CameraController`
    public static let cameraControllerError: PassthroughSubject<Error, Never> = PassthroughSubject<Error, Never>()
}

