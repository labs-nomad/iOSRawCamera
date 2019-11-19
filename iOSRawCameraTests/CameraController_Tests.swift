//
//  CameraController_Tests.swift
//  iOSRawCameraTests
//
//  Created by Nomad Company on 11/19/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//
import XCTest
@testable import iOSRawCamera

class CameraController_Tests: XCTestCase {
    //MARK: Variables
    let asyncController = CameraAsyncController()
    let cameraController = CameraController()
    
    //MARK: Overrides
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: Tests
    func testCameraControllerInit() {
        let promise = self.expectation(description: "Camera Set Up")
        asyncController.setUpAsync(cameraController: self.cameraController, finished: { (p_error) in
            XCTAssertNotNil(p_error)
            let error = p_error as! CameraControllerError
            XCTAssertEqual(error, CameraControllerError.permissionDenied)
            promise.fulfill()
        })
        wait(for: [promise], timeout: 5)
    }
}
