//
//  AudioState.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 2/16/20.
//  Copyright © 2020 Nomad Company. All rights reserved.
//


/// The states that the audio controller can be in
///
/// - notPrepared: The `AudioController` has not been prepared or an attempt was made to prepare but there was an error
/// - prepared: The audio controller is set up and ready to start doing inference
/// - preparing: The audio controller was requested to prepare but has nto been fully prepared
/// - running: The audio controller is using the `Speech` API to gather text snippets
public enum AudioState {
    case notPrepared(Error?)
    case prepared
    case preparing
    case running
}

extension AudioState: Equatable {
    public static func == (lhs: AudioState, rhs: AudioState) -> Bool {
        switch (lhs, rhs) {
        case (AudioState.notPrepared(nil), AudioState.notPrepared(nil)):
            return true
        case (AudioState.prepared, AudioState.prepared):
            return true
        case (AudioState.preparing, AudioState.preparing):
            return true
        case (AudioState.running, AudioState.running):
            return true
        case (AudioState.notPrepared(let errorRHS), AudioState.notPrepared(let errorLHS)):
            return(errorLHS?.localizedDescription == errorRHS?.localizedDescription) ? true : false
            default:
                return false
        }
    }
}
