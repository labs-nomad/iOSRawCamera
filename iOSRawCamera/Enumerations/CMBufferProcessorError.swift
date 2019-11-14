//
//  CMBufferProcessorError.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

/// Enumeation that represents and error when the CMSampleBuffer is beign converted into a CVPixelBuffer
///
/// - invalidBuffer: The `CMSampleBufferIsValid` function returned false
/// - dataIsNotReady: The `CMSampleBufferDataIsReady` function returned false
/// - cvPixelBufferConversionFailed: The `CMSampleBufferGetImageBuffer` failed to convert the `CMSampleBuffer` to `CVPixelBuffer`
enum CMBufferProcessorError: Error, Equatable {
    case invalidBuffer
    case dataIsNotReady
    case cvPixelBufferConversionFailed
    
    public static func == (lhs: CMBufferProcessorError, rhs: CMBufferProcessorError) -> Bool {
        switch (lhs, rhs) {
        case (CMBufferProcessorError.invalidBuffer, CMBufferProcessorError.invalidBuffer):
            return true
        case (CMBufferProcessorError.dataIsNotReady, CMBufferProcessorError.dataIsNotReady):
            return true
        case (CMBufferProcessorError.cvPixelBufferConversionFailed, CMBufferProcessorError.cvPixelBufferConversionFailed):
            return true
        default:
            return false
        }
    }
}
