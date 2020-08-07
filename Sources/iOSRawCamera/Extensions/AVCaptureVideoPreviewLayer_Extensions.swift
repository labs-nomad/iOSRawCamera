//
//  AVCaptureVideoPreviewLayer_Extensions.swift
//  
//
//  Created by Nomad Company on 8/7/20.
//

import AVFoundation


public extension AVCaptureVideoPreviewLayer {
    /// A function that encapsulates the logic and checks to stop the` AVCaptureVideoPreviewLayer` from dispalying as a mirror. Will throw a `StopVideoMirrorError` if there is a problem
    func stopMirroring() throws {
        guard let connection = self.connection else {
            throw StopVideoMirrorError.noCaptureSession
        }
        
        guard connection.isVideoMirroringSupported == true else {
            throw StopVideoMirrorError.mirroringNotSupported
        }
        
        connection.automaticallyAdjustsVideoMirroring = false
        
        connection.isVideoMirrored = false
        
    }
}
