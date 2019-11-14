//
//  PixelBufferCopyError.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

/// An error that can happen when trying to copy the Pixel Buffer to new memory.
public enum PixelBufferCopyError: Error {
    case allocationFailed
}
