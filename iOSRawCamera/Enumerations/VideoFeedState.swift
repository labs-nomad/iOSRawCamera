//
//  VideoFeedState.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

/// The three states of a CameraController.
///
/// - notPrepared: The CameraController has been initalized but not prepared
/// - preparing: The Prepare function has been called but has not completed
/// - prepared: The CameraController is prepared.
public enum VideoFeedState {
    case notPrepared(Error?)
    case preparing
    case prepared
    case running
}

public extension VideoFeedState: Equatable {
    public static func == (lhs: VideoFeedState, rhs: VideoFeedState) -> Bool {
        switch (lhs, rhs) {
        case (VideoFeedState.notPrepared(nil), VideoFeedState.notPrepared(nil)):
            return true
        case (VideoFeedState.prepared, VideoFeedState.prepared):
            return true
        case (VideoFeedState.preparing, VideoFeedState.preparing):
            return true
        case (VideoFeedState.running, VideoFeedState.running):
            return true
        case (VideoFeedState.notPrepared(let errorLHS), VideoFeedState.notPrepared(let errorRHS)):
            return (errorLHS?.localizedDescription == errorRHS?.localizedDescription) ? true : false
        default:
            return false
        }
    }
}
