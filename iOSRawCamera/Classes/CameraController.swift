//
//  iOSRawCamera.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 11/14/19.
//  Copyright © 2019 Nomad Company. All rights reserved.
//

/// Class that combines the video feed from AVFoundation and the inference using the vertigo c library.
public class CameraController: NSObject {
    //MARK: Public properties
    /// The `VideoFeedState`. Will change as the camera is prepared or errors out. When changed internally it fires off a VideoFeedStateChangedNotification for UI to do stuff with.
    public private(set) var videoState = VideoFeedState.notPrepared(nil) {
        didSet {
            DispatchQueue.main.async {
                self.notificationCenter.post(name: VideoFeedStateChangedNotification, object: self.videoState)
            }
        }
    }
    

    /// Convenience variable to check to see if the camera is running or not.
    public var isVideoRunning: Bool {
        return (self.videoState == VideoFeedState.running && self.captureSession.isRunning)
    }
    
    
    /// Convenience variable to check to see if the capture session is running or not.
    public var isCaptureSessionRunning: Bool {
        return self.captureSession.isRunning
    }
    
    /// Convenience varaible to check to see if the capture session was interrupted or not
    public var isCaptureSessionInterrupted: Bool {
        return self.captureSession.isInterrupted
    }
    
    /// Get the current camera route
    public internal(set) var currentCameraPosition: CameraRoute = CameraRoute.front
    
    /// The camera position opposite the `.currentCameraPosition`
    public var oppositeCameraPosition: CameraRoute {
        switch self.currentCameraPosition {
        case .back:
            return CameraRoute.front
        case .front:
            return CameraRoute.back
        }
    }
    
    /// The current `AVCaptureDeviceInput` that is feeding the camera. If this changes internally, ususlly by the user switching cameras, it will fire a `DeviceInputChangedNotification` notification
    public private(set) var currentCameraInput: AVCaptureDeviceInput? {
        didSet {
            self.notificationCenter.post(name: DeviceInputChangedNotification, object: self.currentCameraInput)
        }
    }
    
    /// When the delegate receives a `CVPixelBuffer`should we make a copy of it before sending it into the the `NewCameraBufferNotification`
    public var shouldCopyBuffer: Bool = true
    
    //MARK: Private properties
    // A tuple that represents the front and back cameras that I expect to discover.
    typealias DesiredDevices = (front: AVCaptureDevice?, back: AVCaptureDevice?)
    // The `AVCaptureSession` that is running the show.
    private let captureSession: AVCaptureSession = AVCaptureSession()
    
    //The video output stream. This is where we get the raw buffer.
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var desiredDevices: DesiredDevices = (front: nil, back: nil)
    
    var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    weak var notificationCenter: NotificationCenter!
    //MARK: Init
    public override init() {
        super.init()
        self.currentDeviceOrientation = UIDevice.current.orientation
        self.notificationCenter = NotificationCenter.default
        self.notificationCenter.addObserver(self, selector: #selector(self.deviceRotated(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    //MARK: Notifications
    @objc func deviceRotated(_ sender: Notification) {
        guard let device = sender.object as? UIDevice else {
            return
        }
        
        self.currentDeviceOrientation = device.orientation
        
        do {
            try self.updateCaptureConnections(forOrientation: device.orientation)
        }catch{
            self.notificationCenter.post(name: CameraControllerErrorNotification, object: error)
        }
    }

    
    //MARK: Public Functions
    
    /// Abstraction over the `AVCaptureSession` to make it start collecting video frames.
    public func startRunning() {
        self.captureSession.startRunning()
        self.videoState = .running
    }
    
    /// Abstraction over the `AVCaptureSession` to make it stop collecting video frames.
    public func stopRunning() {
        self.captureSession.stopRunning()
        self.videoState = .prepared
    }
    
    /// Convenience function that will switch the session from running to prepared or vice versa.
    public func toggleRunning() {
        switch self.videoState {
        case .prepared:
            self.startRunning()
        case .running:
            self.stopRunning()
        default:
            break
        }
    }
    
    /// Checks to make sure the video state is `.running` then calls stop and start to reset the flow of data.
    public func resetCaptureSession() {
        guard self.videoState == VideoFeedState.running else {
            return
        }
        self.stopRunning()
        self.startRunning()
    }
    
    /// Conveniently switch the cameras from front to back
    public func switchCameras() throws {
        guard self.captureSession.inputs.count > 0 else {
            return
        }
        self.captureSession.beginConfiguration()
        if let currentInput = self.currentCameraInput {
            self.captureSession.removeInput(currentInput)
        }
        if let output = self.videoOutput {
            self.captureSession.removeOutput(output)
        }
        self.currentCameraInput = try self.swapInputs(desiredDevices: self.desiredDevices)
        let newOutPut = self.createVideoDataOutput()
        self.videoOutput = newOutPut
        self.captureSession.addOutput(newOutPut)
        try self.updateCaptureConnections(forOrientation: self.currentDeviceOrientation)
        self.captureSession.commitConfiguration()
        self.currentCameraPosition = self.oppositeCameraPosition
    }
    
    
    
    
    /// After initalization this object needs to go configure the `AVCaptureSession`. This function checks authorization, initalizes the `AVCaptureSession`, discovers available devices, sets them according to the desired comera position, orients the flow of data according to the UIDeviceOrientation, and sets the video feed state to `.prepared`
    /// - Parameters:
    ///   - sessionPreset: The `AVCaptureSession.Preset` you want. Defaults to `.vga640x480`
    ///   - desiredCameraPosition: The `CameraRoute` you want initalized first. Defaults to `.front`
    ///   - authorization: An object that can determine authorization. Conforms to `AVCaptureDeviceCameraAuthorizationInterface` defaults to `AVCaptureDevice.self`
    public func setUp(sessionPreset: AVCaptureSession.Preset = .vga640x480, desiredCameraPosition: CameraRoute = .front, authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, authorizationController: CameraAuthorizationController = CameraAuthorizationController()) throws {
        // We want to intercept the Error so that we can set the state of the `CameraController`.
        do {
            //We don't want to continue with the `AVFoundation` set up if we are not authorized
            try self.preSetupAuthorizationCheck(authorization: authorization, authorizationController: authorizationController)

            //Change the state object to 'preparing'
            self.videoState = VideoFeedState.preparing
            
            //Call this so that we can be atomic about the updates.
            self.captureSession.beginConfiguration()
            captureSession.sessionPreset = sessionPreset
            
            //Make sure we are starting from a fresh configuration.
            self.removeAllInputs()
            self.removeAllOutputs()
            
            //Call function that sets up and returns an AVCaptureVideoDataOutput
            let videoOutPut = self.createVideoDataOutput()
            //Add the output to the capture session
            self.captureSession.addOutput(videoOutPut)
            //Store it as a local variable for reference later.
            self.videoOutput = videoOutPut
            
            //Discover and configure all the capture devices
            self.desiredDevices = try self.discoverCaptureDevices()
            try self.configure(desiredDevices: self.desiredDevices)
            //If the user passed in a desired Camera Route then set the current camera position varaible here.
            self.currentCameraPosition = desiredCameraPosition
            //Configure the current input device. Front or Back camera.
            self.currentCameraInput = try self.resetInputs(desiredDevices: self.desiredDevices)
            
            try self.updateCaptureConnections(forOrientation: self.currentDeviceOrientation)
            self.captureSession.commitConfiguration()
            // Call the completion for setting up the camera
            self.videoState = VideoFeedState.prepared
        } catch {
            //Call the completion with the error object
            self.videoState = VideoFeedState.notPrepared(error)
            throw error
        }
    }
    
    
    /// Function that calls `.stopRunning()` on the `AVCaptureSession` and removes the current video output. After this is called the `.state` property will be of type `.notPrepared(nil)`. You will have to call `.setUP()` again to set the camera back up.
    public func tearDown() {
        self.captureSession.stopRunning()
        self.removeAllOutputs()
        self.removeAllInputs()
        self.videoState = .notPrepared(nil)
    }
    
    
    
    
    //MARK: Internal Functions
    
    private func preSetupAuthorizationCheck(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, authorizationController: CameraAuthorizationController = CameraAuthorizationController()) throws {
        /*
         Use the object that conforms to AVCaptureDeviceAuthorization to check the state of the camera authorization.
         
         If it is not authorized then lets check the state with more detail. Set the state of the camera controller with the error that we encountered.
         */
        
        guard authorizationController.isCameraAuthorized(authorization: authorization) == true else {
            switch authorizationController.authorizationStatus(authorization: authorization) {
            case .denied:
                let error = CameraControllerError.permissionDenied
                throw error
            case .notDetermined:
                let error = CameraControllerError.permissionNotDetermined
                throw error
            default:
                let error = CameraControllerError.badPermissions
                throw error
            }
        }
    }
    
    private func removeAllOutputs() {
        //Remove outputs so they can be re-prepared
        for output in self.captureSession.outputs {
            self.captureSession.removeOutput(output)
        }
    }
    
    private func removeAllInputs() {
        //Remove inputs so they can be re-prepared
        for input in self.captureSession.inputs {
            self.captureSession.removeInput(input)
        }
    }
    
    private func discoverCaptureDevices(captureDevice: AVCaptureDevice.Type = AVCaptureDevice.self) throws -> DesiredDevices {
        //Discover the devices.
        let session = captureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        //Remove the nil values
        let cameras: [AVCaptureDevice] = session.devices.compactMap { $0 }
        
        //Make sure we have cameras. If we don't throw the error.
        guard cameras.isEmpty == false else {
            throw CameraControllerError.noCamerasAvailable
        }
        
        let desiredDevices: DesiredDevices = (front: cameras.front, back: cameras.back)
        
        return desiredDevices
    }
    
    private func configure(desiredDevices devices: DesiredDevices) throws {
        
        try devices.front?.lockForConfiguration()
        devices.front?.automaticConfiguration()
        devices.front?.unlockForConfiguration()
        
        try devices.back?.lockForConfiguration()
        devices.back?.automaticConfiguration()
        devices.back?.unlockForConfiguration()
    }
    
    
    private func createVideoDataOutput(onQueue queue: DispatchQueue = DispatchQueue(label: QueueNames().videoFrameOutputQueue)) -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        //Set the format to 32BGRA
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        output.videoSettings = settings
        //This is true by default.
        output.alwaysDiscardsLateVideoFrames = true
        //The queue has to be a serial dispatch queue and this class is the delegate.
        output.setSampleBufferDelegate(self, queue: queue)
        //Return the output
        return output
    }
    
    
    private func resetInputs(desiredDevices: DesiredDevices) throws -> AVCaptureDeviceInput {
        switch self.currentCameraPosition {
         case .back:
            guard let back = desiredDevices.back else {
                throw CameraControllerError.noCamerasAvailable
            }
            let input = try self.add(device: back)
            return input
         case .front:
            guard let front = desiredDevices.front else {
                throw CameraControllerError.noCamerasAvailable
            }
            let input = try self.add(device: front)
            return input
         }
    }
    
    private func swapInputs(desiredDevices: DesiredDevices) throws -> AVCaptureDeviceInput {
        switch self.currentCameraPosition {
        case .back:
            guard let front = desiredDevices.front else {
                throw CameraControllerError.noCamerasAvailable
            }
            let input = try self.add(device: front)
            return input
        case .front:
            guard let rear = desiredDevices.back else {
                throw CameraControllerError.noCamerasAvailable
            }
            let input = try self.add(device: rear)
            return input
        }
    }
    
    private func add(device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        let input = try AVCaptureDeviceInput(device: device)
        guard self.captureSession.canAddInput(input) else {
            throw CameraControllerError.inputsAreInvalid
        }
        self.captureSession.addInput(input)
        return input
    }
    
    private func updateCaptureConnections(forOrientation orientation: UIDeviceOrientation) throws {
        guard let connections = self.videoOutput?.connections else {
            throw CameraControllerError.noConnections
        }
        for captureConnection in connections {
            guard captureConnection.isVideoOrientationSupported == true else {
                throw CameraControllerError.videoOrientationChangesNotSupported
            }
            guard let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: orientation) else {
                throw CameraControllerError.couldNotMakeNewVideoOrientation
            }
            
            captureConnection.videoOrientation = videoOrientation
        }
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        do {
            let buffer = try sampleBuffer.cvPixelBuffer()
            if self.shouldCopyBuffer == true {
                let bufferCopy = try buffer.copy()
                self.notificationCenter.post(name: NewCameraBufferNotification, object: bufferCopy)
            }else {
                self.notificationCenter.post(name: NewCameraBufferNotification, object: buffer)
            }
        }catch{
            self.notificationCenter.post(name: CameraControllerErrorNotification, object: error)
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       
    }
}

