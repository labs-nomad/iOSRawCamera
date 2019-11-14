//
//  Notifications.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

//MARK: Camera Controller notifications

/// Notification that gets fired from the VideoFeedAndInferenceController when the state of the video feed changes. The `VideoFeedState` gets passed through on the `.object` property of this notification.
let VideoFeedStateChangedNotification = Notification.Name.init("VideoFeedStateChangedNotification")
/// Notification that gets fired when the Video output has a new froma
let NewCameraBufferNotification = Notification.Name.init("NewCameraBufferNotification")
/// Notification that gets fired if an error occures from the `CameraController`
let CameraControllerErrorNotification = Notification.Name.init("CameraControllerErrorNotification")


//MARK: Camera Authorization Controller Notifications
/// Notification that gets fired is the camera needs Authorization from the user
let CameraNeedsAuthorizationNotification = Notification.Name.init("CameraNeedsAuthorizationNotification")
/// Notification that gets fired when the Camera Authorization state changes
let CameraAuthorizationStateChangedNotification = Notification.Name.init("CameraAuthorizationStateChangedNotification")
