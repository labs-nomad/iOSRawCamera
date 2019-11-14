//
//  CameraRoute.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//


public enum CameraRoute: Int {
    case front = 0
    case back = 1
    
    public init?(postgresString string: String) {
        switch string {
        case "front":
            self = .front
        case "back":
            self = .back
        default:
            return nil
        }
    }
}
