//
//  AVCaptureVideoOrientation_Tests.swift
//  iOSRawCameraTests
//
//  Created by Nomad Company on 11/18/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//
import XCTest
import AVFoundation
@testable import iOSRawCamera

class AVCaptureVideoOrientation_Tests: XCTestCase {
    //MARK: Variables
    
    
    //MARK: Overrides
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: Tests
    
    func testInitalizationWithDeviceOrientation() {
        let portrait = AVCaptureVideoOrientation(deviceOrientation: UIDeviceOrientation.portrait)
        let upsideDown = AVCaptureVideoOrientation(deviceOrientation: UIDeviceOrientation.portraitUpsideDown)
        let faceUp = AVCaptureVideoOrientation(deviceOrientation: UIDeviceOrientation.faceUp)
        let left = AVCaptureVideoOrientation(deviceOrientation: UIDeviceOrientation.landscapeRight)
        let right = AVCaptureVideoOrientation(deviceOrientation: UIDeviceOrientation.landscapeLeft)
        XCTAssertEqual(portrait, AVCaptureVideoOrientation.portrait)
        XCTAssertEqual(upsideDown, AVCaptureVideoOrientation.portraitUpsideDown)
        XCTAssertEqual(faceUp, AVCaptureVideoOrientation.portrait)
        XCTAssertEqual(left, AVCaptureVideoOrientation.landscapeLeft)
        XCTAssertEqual(right, AVCaptureVideoOrientation.landscapeRight)
    }
    
    func testInitalizationWithStatusBarOrientation() {
        let portrait = AVCaptureVideoOrientation(interfaceOrientation: UIInterfaceOrientation.portrait)
        let upsideDown = AVCaptureVideoOrientation(interfaceOrientation: UIInterfaceOrientation.portraitUpsideDown)
        let left = AVCaptureVideoOrientation(interfaceOrientation: UIInterfaceOrientation.landscapeLeft)
        let right = AVCaptureVideoOrientation(interfaceOrientation: UIInterfaceOrientation.landscapeRight)
        let unknown = AVCaptureVideoOrientation(interfaceOrientation: UIInterfaceOrientation.unknown)
        let unknownDefault = AVCaptureVideoOrientation(interfaceOrientation: UIInterfaceOrientation.init(rawValue: 10)!)
        XCTAssertEqual(portrait, AVCaptureVideoOrientation.portrait)
        XCTAssertEqual(upsideDown, AVCaptureVideoOrientation.portraitUpsideDown)
        XCTAssertEqual(left, AVCaptureVideoOrientation.landscapeLeft)
        XCTAssertEqual(right, AVCaptureVideoOrientation.landscapeRight)
        XCTAssertEqual(unknown, AVCaptureVideoOrientation.portrait)
        XCTAssertEqual(unknownDefault, AVCaptureVideoOrientation.portrait)
    }
    
    func testString() {
        let portraitString = AVCaptureVideoOrientation.portrait.string()
        let upsideDown = AVCaptureVideoOrientation.portraitUpsideDown.string()
        let leftString = AVCaptureVideoOrientation.landscapeLeft.string()
        let rightString = AVCaptureVideoOrientation.landscapeRight.string()
        let unknown = AVCaptureVideoOrientation.init(rawValue: 10)!.string()
        XCTAssertEqual(portraitString, "Portrait")
        XCTAssertEqual(upsideDown, "Portrait Upside Down")
        XCTAssertEqual(leftString, "Landscape Left")
        XCTAssertEqual(rightString, "Landscape Right")
        XCTAssertEqual(unknown, "Unknown Default")
    }
    
}
