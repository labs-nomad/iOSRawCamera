//
//  CVPixelBuffer_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//
import AVFoundation
import UIKit

public extension CVPixelBuffer {
    /// Computed Property to return a `UIImage` from a `CVPixelBuffer`. Makes a `CIImage` from the `CVPixelBuffer` then makes and returns a `UIImage` from a `CIImage`.
    var uiImage: UIImage {
        let ciImage = CIImage(cvImageBuffer: self)
        let uiImage = UIImage(ciImage: ciImage)
        return uiImage
    }
    
    
    /// Computed property that constructs a `CIImage` from the `CVPixelBuffer` using the apple provided constructor.
    var ciImage: CIImage {
        let ciImage = CIImage(cvImageBuffer: self)
        return ciImage
    }
    
    
    /// Loads a UIImage up for display on SwiftUI
    /// - Parameter context: The context to help the loading
    /// - Returns: A UIImage ready for display.
    func load(withContext context: CIContext) -> UIImage? {
        let ciImage = self.ciImage
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage
    }
    
    /**
     The `.isValid` function checks these three things:
     
     1) The pixel width of the buffer is greater then 0
     2) The pixel height of the buffer is greater then 0
     3) The data size of the buffer is greater then 0
     4) The bytes per row value of the buffer is greater then 0
     
     All these checks are meant to guard against the crash I was seeing where the last line of the stack trace was `CVPixelBufferGetWidth + 20`. So, not a complete shot in the dark.
    */
    var isValid: Bool {
        let cvBufferWidth = CVPixelBufferGetWidth(self)
        let cvBufferHeight = CVPixelBufferGetHeight(self)
        let size = CVPixelBufferGetDataSize(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        
        guard cvBufferWidth > 0 && cvBufferHeight > 0 && size > 0 && bytesPerRow > 0 else {
            return false
        }
        
        return true
    }
    
   
    
    //https://stackoverflow.com/questions/53132611/copy-a-cvpixelbuffer-on-any-ios-device
    /// Creates a copy of the CV Pixel buffer. Can handld formates with and with out planes.
    func copy() throws -> CVPixelBuffer {
        //copy() cannot be called on a non-CVPixelBuffer
        guard CFGetTypeID(self) == CVPixelBufferGetTypeID() else {
            throw PixelBufferCopyError.notAPixelBuffer
        }
        
        var _copy: CVPixelBuffer?
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let formatType = CVPixelBufferGetPixelFormatType(self)
        let attachments = CVBufferGetAttachments(self, .shouldPropagate)
        
        CVPixelBufferCreate(nil, width, height, formatType, attachments, &_copy)
        
        guard let copy = _copy else {
            throw PixelBufferCopyError.allocationFailed
        }
        
        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(copy, [])
        
        defer {
            CVPixelBufferUnlockBaseAddress(copy, [])
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }
        
        let pixelBufferPlaneCount: Int = CVPixelBufferGetPlaneCount(self)
        
        
        if pixelBufferPlaneCount == 0 {
            let dest = CVPixelBufferGetBaseAddress(copy)
            let source = CVPixelBufferGetBaseAddress(self)
            let height = CVPixelBufferGetHeight(self)
            let bytesPerRowSrc = CVPixelBufferGetBytesPerRow(self)
            let bytesPerRowDest = CVPixelBufferGetBytesPerRow(copy)
            if bytesPerRowSrc == bytesPerRowDest {
                memcpy(dest, source, height * bytesPerRowSrc)
            }else {
                var startOfRowSrc = source
                var startOfRowDest = dest
                for _ in 0..<height {
                    memcpy(startOfRowDest, startOfRowSrc, min(bytesPerRowSrc, bytesPerRowDest))
                    startOfRowSrc = startOfRowSrc?.advanced(by: bytesPerRowSrc)
                    startOfRowDest = startOfRowDest?.advanced(by: bytesPerRowDest)
                }
            }
            
        }else {
            for plane in 0 ..< pixelBufferPlaneCount {
                let dest        = CVPixelBufferGetBaseAddressOfPlane(copy, plane)
                let source      = CVPixelBufferGetBaseAddressOfPlane(self, plane)
                let height      = CVPixelBufferGetHeightOfPlane(self, plane)
                let bytesPerRowSrc = CVPixelBufferGetBytesPerRowOfPlane(self, plane)
                let bytesPerRowDest = CVPixelBufferGetBytesPerRowOfPlane(copy, plane)
                
                if bytesPerRowSrc == bytesPerRowDest {
                    memcpy(dest, source, height * bytesPerRowSrc)
                }else {
                    var startOfRowSrc = source
                    var startOfRowDest = dest
                    for _ in 0..<height {
                        memcpy(startOfRowDest, startOfRowSrc, min(bytesPerRowSrc, bytesPerRowDest))
                        startOfRowSrc = startOfRowSrc?.advanced(by: bytesPerRowSrc)
                        startOfRowDest = startOfRowDest?.advanced(by: bytesPerRowDest)
                    }
                }
            }
        }
        return copy
    }
}
