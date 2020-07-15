//
//  QueueNames.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

//Simple struct that will hold the names for the two background queues that we use in various parts of the library
internal struct QueueNames {
    //The Queue that all camera configuration can operate on Async
    let cameraConfigurationQueue = "com.iOSRawCamera.cameraConfigurationQueue"
    //The Queue that we ask the video frames to be output on.
    let videoFrameOutputQueue = "com.iOSRawCamera.videoFrameOutputQueue"
}
