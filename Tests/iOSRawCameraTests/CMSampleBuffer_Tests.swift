//
//  CMSampleBuffer_Tests.swift
//  iOSRawCameraTests
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import XCTest
@testable import iOSRawCamera

class CMSampleBuffer_Tests: XCTestCase {
    //MARK: Variables
    
    
    //MARK: Overrides
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: Tests
    func testConversion() {
        let mocker = MockSampleBuffer()
        let buffer = mocker.getCMSampleBuffer()
        let cvBuffer = try? buffer.cvPixelBuffer()
        XCTAssertNotNil(cvBuffer)
    }
}
