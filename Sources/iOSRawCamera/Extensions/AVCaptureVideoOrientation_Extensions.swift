//
//  AVCaptureVideoOrientation_Extensions.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//
import AVFoundation
import UIKit

public extension AVCaptureVideoOrientation {
    
    /// This initalizer will construct the appropriate `AVCaptureVideoOrientation` from the `UIDeviceOrientation`. The main catch is that the left and right cases are mirrored. For example `UIDeviceOrientation.landscapeLeft` turns out `AVCaptureVideoOrientation.landscapeRight`. This constructor was observed to be present in multiple projects from Apple to random git hub projects.
    /// - Parameter deviceOrientation: A correctly constructed `AVCaptureVideoOrientation`
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        default:
            self = .portrait
        }
    }
    
    /// This initalizer will construct the appropriate `AVCaptureVideoOrientation` from the `UIInterfaceOrientation`. Unlike the `UIDeviceOrientation` all the enum cases line up correctly.
    /// - Parameter interfaceOrientation: A correctly constructed `AVCaptureVideoOrientation`
    init(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        case .unknown:
            self = .portrait
        @unknown default:
            self = .portrait
        }
    }
    
    /// Function that will return a human readable string for the `AVCaptureVideoOrientation`
    func string() -> String {
        switch self {
        case .landscapeLeft:
            return "Landscape Left"
        case .landscapeRight:
            return "Landscape Right"
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "Portrait Upside Down"
        @unknown default:
            return "Unknown Default"
        }
    }
}
