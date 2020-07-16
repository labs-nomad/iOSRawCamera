//
//  Notifications.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

//MARK: CameraInput Notifications
/// Notification that gets fired when either the system pressure level or state changes on an input device. Posts a `DevicePressureReading` tuple object
public let DeviceInputPressureChangeNotification = Notification.Name.init("DeviceInputPressureChangeNotification")
/// Notification that gets fired when the frame rate for an `AVCaptureDevice` you are observing changes. `DeviceFrameRateChange`
public let DeviceFrameRateChangedNotification = Notification.Name.init("DeviceFrameRateChangedNotification")
