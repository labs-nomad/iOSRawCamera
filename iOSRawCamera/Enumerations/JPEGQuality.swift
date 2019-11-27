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
    
    /// Initalizer that will map the postgres enum string from our database to the correct swift enum
    ///
    /// - Parameter string: The postgres string from the database
    public init?(postgresString string: String) {
        switch string {
        case "lowest":
            self = .lowest
        case "low":
            self = .low
        case "medium":
            self = .medium
        case "high":
            self = .high
        case "highest":
            self = .highest
        default:
            return nil
        }
    }
    
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
    
    func postgresString() -> String {
        switch self {
        case .lowest:
            return "lowest"
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        case .highest:
            return "highest"
        }
    }
}
