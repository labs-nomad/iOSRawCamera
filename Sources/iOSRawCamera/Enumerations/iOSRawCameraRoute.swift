//
//  CameraRoute.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//


/// The simplified route that you want the camera of the iOS Device
public enum iOSRawCameraRoute: Int {
    ///The front facing camera if available
    case front = 0
    ///The back camera if available
    case back = 1
}
