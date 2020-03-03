//
//  TypeAliases.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/21/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import AVFoundation


///Represents a range of frame rates
public typealias FrameRateRange = (min: Float64, max: Float64)
///Represents the factor and level of an imput devices `SystemPressureState`
public typealias SystemPressureReading = (factor: AVCaptureDevice.SystemPressureState.Factors, level: AVCaptureDevice.SystemPressureState.Level)
///Object that gets passed through the `DeviceInputPressureChangeNotification`
public typealias DevicePressureReading = (device: AVCaptureDevice, reading: SystemPressureReading)
/// Object that gets passed through the `DeviceFrameRateChangedNotification`
public typealias DeviceFrameRateChange = (device: AVCaptureDevice, frameRate: FrameRateRange)
