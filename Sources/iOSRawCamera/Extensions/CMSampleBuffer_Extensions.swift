//
//  CMSampleBuffer_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//
import AVFoundation

public extension CMSampleBuffer {
    
    /// Returns the camera intrtinsics to pass to core vision as options.
    var cameraIntrinsics: CFTypeRef? {
        return CMGetAttachment(self, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
    }
    
    
    /// Converts the `CMSampleBuffer` into a `CVPixelBuffer`.
    ///
    /// - Returns: A `CVPixelBuffer` that uses the `CMSampleBufferGetImageBuffer` constructor.
    /// - Throws: Will throw a `CMBufferProcessorError` if the data is not ready, not valid, or failed to convert to a `CVPixelBuffer`
    func cvPixelBuffer() throws -> CVPixelBuffer {
        guard CMSampleBufferDataIsReady(self) == true else {
            throw CMBufferProcessorError.dataIsNotReady
        }
        
        guard CMSampleBufferIsValid(self) else {
            throw CMBufferProcessorError.invalidBuffer
        }
        
        guard let cvBuffer = CMSampleBufferGetImageBuffer(self) else {
            throw CMBufferProcessorError.cvPixelBufferConversionFailed
        }
        
        return cvBuffer
    }
}
