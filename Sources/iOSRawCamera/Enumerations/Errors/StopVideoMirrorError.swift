//
//  StopVideoMirrorError.swift
//  
//
//  Created by Nomad Company on 8/7/20.
//

import Foundation


/// An Error that can be thrown from the `.stopMirroring()` function of an `AVCaptureVideoPreviewLayer`
public enum StopVideoMirrorError: Error {
    case noCaptureSession
    case mirroringNotSupported
}
