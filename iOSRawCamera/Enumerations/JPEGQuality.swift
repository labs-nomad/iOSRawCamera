//
//  JPEGQuality.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/27/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//


/// Enumeration that gives you better description for JPEG compression
///
/// - lowest: 0 is the compression value
/// - low: 0.25 is the compression value
/// - medium: 0.5 is the compression value
/// - high: 0.75 is the compression value
/// - highest: 1.0 is the compression value
public enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
    
    //MARK: Functions
    
    /// <#Description#>
    func string() -> String {
        switch self {
        case .lowest:
            return "Smallest Size"
        case .low:
            return "Small Size"
        case .medium:
            return "Medium Size"
        case .high:
            return "Large Size"
        case .highest:
            return "Largest Size"
        }
    }
}
