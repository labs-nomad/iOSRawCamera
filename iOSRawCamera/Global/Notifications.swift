//
//  Notifications.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

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
