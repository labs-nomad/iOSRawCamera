//
//  FrameRateManagable.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/21/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import Foundation

public protocol FrameRateManagable {
    func setFrameRate(rate: Int32) throws
    func currentFrameRate() -> FrameRateRange
    func availableFrameRateRange() throws -> FrameRateRange
    func validate(desiredFrameRate rate: Float64) throws
    func startObserving() -> [NSKeyValueObservation]
}
