//
//  Notifications.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

//MARK: Camera Controller notifications

/// Notification that gets fired from the VideoFeedAndInferenceController when the state of the video feed changes. The `VideoFeedState` gets passed through on the `.object` property of this notification.
public let VideoFeedStateChangedNotification = Notification.Name.init("VideoFeedStateChangedNotification")
/// Notification that gets fired when the Video output has a new froma
public let NewCameraBufferNotification = Notification.Name.init("NewCameraBufferNotification")
/// Notification that gets fired if an error occures from the `CameraController`
public let CameraControllerErrorNotification = Notification.Name.init("CameraControllerErrorNotification")
/// Notification that gets fired when the `AVCaptureDeviceInput` changes. Either during setup or when the inputs changes
public let DeviceInputChangedNotification = Notification.Name.init("DeviceInputChangedNotification")


//MARK: Camera Authorization Controller Notifications

/// Notification that gets fired is the camera needs Authorization from the user
public let CameraNeedsAuthorizationNotification = Notification.Name.init("CameraNeedsAuthorizationNotification")
/// Notification that gets fired when the Camera Authorization state changes
public let CameraAuthorizationStateChangedNotification = Notification.Name.init("CameraAuthorizationStateChangedNotification")

//MARK: CameraInput Notifications
/// Notification that gets fired when either the system pressure level or state changes on an input device. Posts a `DevicePressureReading` tuple object
public let DeviceInputPressureChangeNotification = Notification.Name.init("DeviceInputPressureChangeNotification")
/// Notification that gets fired when the frame rate for an `AVCaptureDevice` you are observing changes. `DeviceFrameRateChange`
public let DeviceFrameRateChangedNotification = Notification.Name.init("DeviceFrameRateChangedNotification")

//MARK: Audio Controller Notifications
/// The state of the audio controller changed
public let AudioStateChangedNotification = Notification.Name.init("AudioStateChangedNotification")
/// The on device speech recognition service detected a new set of text that it considers "final"
public let NewAudioInferenceNotification = Notification.Name.init("NewAudioInference")
/// The AudioController experienced soem sort of error
public let AudioControllerErrorNotification = Notification.Name.init("AudioControllerError")

//MARK: Audio Authorization Controller Notifications
/// Notification that gets fired if audio needs authorization from the user
public let AudioNeedsAuthorizationNotification = Notification.Name.init("AudioNeedsAuthorizationNotification")
/// Notification that gets fired when the Audio Authorization state changed
public let AudioAuthorizationStateChangedNotification = Notification.Name.init("AudioAuthorizationStateChangedNotification")
