//
//  CIImage_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/27/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

public extension CIImage {
    /// For convenience, we simply return a UIImage with the constructor that takes a CIImage.
    var uiImage: UIImage {
        return UIImage(ciImage: self)
    }
    /// Function that will turn a `CIImage` into a a `Data` representation of a JPEG Image.
    ///
    /// - Parameter quality: The compression quality that you want
    /// - Returns: The Data that represents the JPEG Image
    func jpegData(_ quality: JPEGQuality = .low, contextToUse context: CIContext = CIContext(options: nil)) -> Data? {
        //Make sure we have a color space associated with the `CIImage`
        guard let colorSpace = self.colorSpace else {
            //If not return nil
            return nil
        }
        //Make the options with the quality raw value
        //Old code, keepign for reference -> [kCGImageDestinationLossyCompressionQuality: quality.rawValue]
        let options: [CIImageRepresentationOption: Any] = [CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String): quality.rawValue]
        //Make the data from this function on the CIContext
        let data = context.jpegRepresentation(of: self, colorSpace: colorSpace, options: options)
        //Return the data
        return data
    }
    
}
