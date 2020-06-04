//
//  UIImage_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/27/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import UIKit

extension UIImage {
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    public func jpeg(_ quality: JPEGQuality) -> Data? {
        let compressed = self.jpegData(compressionQuality: quality.rawValue)
        return compressed
    }
    
    
    /// Function that lets you retrieve a UIImage for display in SwiftUI
    /// - Parameter context: The context to render the Image
    /// - Returns: A UIImage with the data loaded.
    
    public func load(withContext context: CIContext) -> UIImage {
        guard let ciImage = self.ciImage else {
            return self
        }
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return self
        }
        let loadedImage = UIImage(cgImage: cgImage)
        return loadedImage
    }
}
