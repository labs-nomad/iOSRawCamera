//
//  VideoFeedState_Tests.swift
//  iOSRawCameraTests
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import XCTest
@testable import iOSRawCamera

class VideoFeedState_Tests: XCTestCase {
    //MARK: Variables
    
    
    //MARK: Overrides
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: Tests
    func testEquality() {
        let errorValue = NSError(domain: "Error", code: 100, userInfo: nil) as Error
        let error = VideoFeedState.notPrepared(errorValue)
        let notPrepared = VideoFeedState.notPrepared(nil)
        let preparing = VideoFeedState.preparing
        let prepared = VideoFeedState.prepared
        let running = VideoFeedState.running
        XCTAssertEqual(error, error)
        XCTAssertEqual(notPrepared, notPrepared)
        XCTAssertEqual(prepared, prepared)
        XCTAssertEqual(preparing, preparing)
        XCTAssertEqual(running, running)
        XCTAssertNotEqual(prepared, running)
    }
    
}
