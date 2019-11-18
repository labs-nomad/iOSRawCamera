//
//  SetUpTests.swift
//  CameraAuthorizationController_Tests
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

import XCTest
@testable import iOSRawCamera

class CameraAuthorizationController_Tests: XCTestCase {
    //MARK: Variables
    let authorizationController = CameraAuthorizationController()
    let mockAuthorizer = StaticMockAuthorizer.self
    
    //MARK: Overrides
    
    override func setUp() {
        //Before every test reset the authorization state to the initial state
        mockAuthorizer.hasAccess = false
        mockAuthorizer.state = AVAuthorizationStatus.notDetermined
        mockAuthorizer.requestOutcome = .authorized
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: Tests
    
    func testInitalization() {
        let isAuthorized = authorizationController.isCameraAuthorized(authorization: mockAuthorizer)
        let authorizationState = authorizationController.authorizationStatus(authorization: mockAuthorizer)
        let didDeny = authorizationController.didUserDenyAuthorization(authorization: mockAuthorizer)
        XCTAssertFalse(isAuthorized)
        XCTAssertFalse(didDeny)
        XCTAssertEqual(authorizationState, AVAuthorizationStatus.notDetermined)
    }
    
    
    func testAuthorized() {
        mockAuthorizer.hasAccess = true
        mockAuthorizer.state = AVAuthorizationStatus.authorized
        let isAuthorized = authorizationController.isCameraAuthorized(authorization: mockAuthorizer)
        let authorizationState = authorizationController.authorizationStatus(authorization: mockAuthorizer)
        let didDeny = authorizationController.didUserDenyAuthorization(authorization: mockAuthorizer)
        XCTAssertTrue(isAuthorized)
        XCTAssertFalse(didDeny)
        XCTAssertEqual(authorizationState, AVAuthorizationStatus.authorized)
    }
    
    func testDenied() {
        mockAuthorizer.hasAccess = false
        mockAuthorizer.state = AVAuthorizationStatus.denied
        let isAuthorized = authorizationController.isCameraAuthorized(authorization: mockAuthorizer)
        let authorizationState = authorizationController.authorizationStatus(authorization: mockAuthorizer)
        let didDeny = authorizationController.didUserDenyAuthorization(authorization: mockAuthorizer)
        XCTAssertFalse(isAuthorized)
        XCTAssertTrue(didDeny)
        XCTAssertEqual(authorizationState, AVAuthorizationStatus.denied)
    }
    
    func testRestricted() {
        mockAuthorizer.hasAccess = false
        mockAuthorizer.state = AVAuthorizationStatus.restricted
        let isAuthorized = authorizationController.isCameraAuthorized(authorization: mockAuthorizer)
        let authorizationState = authorizationController.authorizationStatus(authorization: mockAuthorizer)
        let didDeny = authorizationController.didUserDenyAuthorization(authorization: mockAuthorizer)
        XCTAssertFalse(isAuthorized)
        XCTAssertFalse(didDeny)
        XCTAssertEqual(authorizationState, AVAuthorizationStatus.restricted)
    }
    
    func testUserAuthorized() {
        let promise = self.expectation(description: "Authorized")
        mockAuthorizer.requestOutcome = .authorized
        authorizationController.requestCameraPermission(authorization: mockAuthorizer) { (authorized) in
            XCTAssertTrue(authorized)
            let isAuthorized = self.authorizationController.isCameraAuthorized(authorization: self.mockAuthorizer)
            XCTAssertTrue(isAuthorized)
            let authorizationState = self.authorizationController.authorizationStatus(authorization: self.mockAuthorizer)
            XCTAssertEqual(authorizationState, AVAuthorizationStatus.authorized)
            promise.fulfill()
        }
        self.expectation(forNotification: CameraAuthorizationStateChangedNotification, object: nil) { (notification) -> Bool in
            let postedStatus = notification.object as! AVAuthorizationStatus
            XCTAssertEqual(postedStatus, AVAuthorizationStatus.authorized)
            return true
        }
        wait(for: [promise], timeout: 5)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUserDenied() {
        let promise = self.expectation(description: "Denied")
        mockAuthorizer.requestOutcome = .denied
        authorizationController.requestCameraPermission(authorization: mockAuthorizer) { (authorized) in
            XCTAssertFalse(authorized)
            let isAuthorized = self.authorizationController.isCameraAuthorized(authorization: self.mockAuthorizer)
            XCTAssertFalse(isAuthorized)
            let authorizationState = self.authorizationController.authorizationStatus(authorization: self.mockAuthorizer)
            XCTAssertEqual(authorizationState, AVAuthorizationStatus.denied)
            promise.fulfill()
        }
        self.expectation(forNotification: CameraAuthorizationStateChangedNotification, object: nil) { (notification) -> Bool in
            let postedStatus = notification.object as! AVAuthorizationStatus
            XCTAssertEqual(postedStatus, AVAuthorizationStatus.denied)
            return true
        }
        wait(for: [promise], timeout: 5)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRestrictedState() {
        let promise = self.expectation(description: "Restricted")
        mockAuthorizer.requestOutcome = .restricted
        authorizationController.requestCameraPermission(authorization: mockAuthorizer) { (authorized) in
            XCTAssertFalse(authorized)
            let isAuthorized = self.authorizationController.isCameraAuthorized(authorization: self.mockAuthorizer)
            XCTAssertFalse(isAuthorized)
            let authorizationState = self.authorizationController.authorizationStatus(authorization: self.mockAuthorizer)
            XCTAssertEqual(authorizationState, AVAuthorizationStatus.restricted)
            promise.fulfill()
        }
        self.expectation(forNotification: CameraAuthorizationStateChangedNotification, object: nil) { (notification) -> Bool in
            let postedStatus = notification.object as! AVAuthorizationStatus
            XCTAssertEqual(postedStatus, AVAuthorizationStatus.restricted)
            return true
        }
        wait(for: [promise], timeout: 5)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
