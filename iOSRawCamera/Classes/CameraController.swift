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
                NotificationCenter.default.post(name: VideoFeedStateChangedNotification, object: self.videoState)
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
    
    /// Conveniently get the latest `CVPixelBuffer`
    public var currentBuffer: CVPixelBuffer?
    
    /// Get the current camera route
    public internal(set) var currentCameraPosition: CameraRoute = CameraRoute.front
    
    /// This is a static variable so we can put the sort of intensive camera set up process on this queue if needed.
    public static let cameraConfigurationQueue = DispatchQueue(label: "CameraConfigurationQueue")
    
    //MARK: Private properties
    // The `AVCaptureSession` that is running the show.
    private let captureSession: AVCaptureSession = AVCaptureSession()
    
    //The video output stream. This is where we get the raw buffer
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var frontCameraDevice: AVCaptureDevice?
    
    private var rearCameraDevice: AVCaptureDevice?
    
    private var currentCameraInput: AVCaptureDeviceInput?
    
    private var oppositeCameraPosition: CameraRoute {
        switch self.currentCameraPosition {
        case .back:
            return CameraRoute.front
        case .front:
            return CameraRoute.back
        }
    }
    
    var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    //MARK: Init
    public override init() {
        super.init()
        self.currentDeviceOrientation = UIDevice.current.orientation
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotated(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
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
            NotificationCenter.default.post(name: CameraControllerErrorNotification, object: error)
        }
    }

    
    //MARK: Public Functions
    
    /// Abstraction over the `AVCaptureSession` to make it start collecting video frames. The `.state` property of
    public func startRunning() {
        self.captureSession.startRunning()
        self.videoState = .running
    }
    
    public func stopRunning() {
        self.captureSession.stopRunning()
        self.videoState = .prepared
        self.currentBuffer = nil
    }
    
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
    
    public func resetCaptureSession() {
        guard self.videoState == VideoFeedState.running else {
            return
        }
        self.stopRunning()
        self.startRunning()
    }
    
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
        switch self.currentCameraPosition {
        case .back:
            guard let front = self.frontCameraDevice else {
                throw CameraControllerError.noCamerasAvailable
            }
            let input = try AVCaptureDeviceInput(device: front)
            try self.add(input: input)
            self.currentCameraInput = input
        case .front:
            guard let rear = self.rearCameraDevice else {
                throw CameraControllerError.noCamerasAvailable
            }
            let input = try AVCaptureDeviceInput(device: rear)
            try self.add(input: input)
            self.currentCameraInput = input
        }
        let newOutPut = self.createVideoDataOutput()
        self.videoOutput = newOutPut
        self.captureSession.addOutput(newOutPut)
        try self.updateCaptureConnections(forOrientation: self.currentDeviceOrientation)
        self.captureSession.commitConfiguration()
        self.currentCameraPosition = self.oppositeCameraPosition
    }
    
    public func setFrameRate(rate: Int32) throws {
        let newTime = CMTimeMake(value: 1, timescale: rate)
        let seconds = CMTimeGetSeconds(newTime)
        print("New Frame Rate; \(seconds)")
        try self.currentCameraInput?.device.lockForConfiguration()
        self.currentCameraInput?.device.activeVideoMaxFrameDuration = newTime
        self.currentCameraInput?.device.activeVideoMinFrameDuration = newTime
        self.currentCameraInput?.device.unlockForConfiguration()
    }
    
    public typealias FrameRateRange = (min: Float64, max: Float64)
    
    //https://warrenmoore.net/understanding-cmtime
    public func currentFrameRate() -> FrameRateRange? {
        guard let min = self.currentCameraInput?.device.activeVideoMinFrameDuration, let max = self.currentCameraInput?.device.activeVideoMaxFrameDuration else {
            return nil
        }
        return (CMTimeGetSeconds(min), CMTimeGetSeconds(max))
    }
    
    public func availableFrameRateRange() {
        guard let frameRateRanges = self.currentCameraInput?.device.activeFormat.videoSupportedFrameRateRanges else {
            print("No Frame Rate info available")
            return
        }
        
        for range in frameRateRanges {
            print("Max Frame Rate: \(CMTimeGetSeconds(range.maxFrameDuration))")
            print("Min Frame Rate: \(CMTimeGetSeconds(range.minFrameDuration))")
            print("Max Frame Rate: \(range.maxFrameDuration)")
            print("Min Frame Rate: \(range.minFrameDuration)")
        }
    }
    
    public func getSystemPressureReading() -> (AVCaptureDevice.SystemPressureState.Factors, AVCaptureDevice.SystemPressureState.Level)? {
        guard let factor = self.currentCameraInput?.device.systemPressureState.factors, let level = self.currentCameraInput?.device.systemPressureState.level else {
            return nil
        }
        return (factor, level)
    }
    

    
    
    /// Function that calls `.stopRunning()` on the `AVCaptureSession` and removes the current video output. After this is called the `.state` property will be of type `.notPrepared(nil)`. You will have to call `.prepare` again to set the camera back up.
    public func tearDown() {
        self.captureSession.stopRunning()
        if let output = self.videoOutput {
            self.captureSession.removeOutput(output)
        }
        
        if let input = self.currentCameraInput {
            self.captureSession.removeInput(input)
        }
        self.videoState = .notPrepared(nil)
    }
    

    
    public func setUp(sessionPreset: AVCaptureSession.Preset = .vga640x480, desiredCameraPosition: CameraRoute = .front) throws {
        /*
         Use the object that conforms to AVCaptureDeviceAuthorization to check the state of the camera authorization.
         
         If it is not authorized then lets check the state with more detail. Set the state of the camera controller with the error that we encountered.
         */
        let authorizationController = CameraAuthorizationController()
        guard authorizationController.isCameraAuthorized() == true else {
            switch authorizationController.authorizationStatus() {
            case .denied:
                let error = CameraControllerError.permissionDenied
                self.videoState = .notPrepared(error)
                throw error
            case .notDetermined:
                let error = CameraControllerError.permissionNotDetermined
                self.videoState = .notPrepared(error)
                throw error
            default:
                let error = CameraControllerError.badPermissions
                self.videoState = .notPrepared(error)
                throw error
            }
        }
        //Change the state object to 'preparing'
        self.videoState = VideoFeedState.preparing
        
        //Begin the configuration and set the presets.
        
        self.captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        //Remove outputs so they can be re-prepared
        for output in self.captureSession.outputs {
            self.captureSession.removeOutput(output)
        }
        //Remove inputs so they can be re-prepared
        for input in self.captureSession.inputs {
            self.captureSession.removeInput(input)
        }
        
        //Call function that sets up and returns an AVCaptureVideoDataOutput
        self.videoOutput = self.createVideoDataOutput()
        //Add the output to the capture session
        self.captureSession.addOutput(self.videoOutput!)
        
        do {
            //Configure all the capture devices
            let inputs = try self.configureCaptureDevices()
            self.frontCameraDevice = inputs.front
            self.rearCameraDevice = inputs.back
            //If the user passed in a desired Camera Route then set the current camera position varaible here.
            self.currentCameraPosition = desiredCameraPosition
            //Configure the current input device. Front or Back camera.
            switch self.currentCameraPosition {
            case .back:
                if let back = self.rearCameraDevice {
                    let input = try AVCaptureDeviceInput(device: back)
                    try self.add(input: input)
                    self.currentCameraInput = input
                }
            case .front:
                if let front = self.frontCameraDevice {
                    let input = try AVCaptureDeviceInput(device: front)
                    try self.add(input: input)
                    self.currentCameraInput = input
                }
            }
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
    
    //MARK: Internal Functions
    private func configureCaptureDevices(captureDevice: AVCaptureDevice.Type = AVCaptureDevice.self) throws -> (front: AVCaptureDevice?, back: AVCaptureDevice?) {
        //Discover the devices.
        let session = captureDevice.DiscoverySession.init(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        //Remove the nil values
        let cameras = session.devices.compactMap { $0 }
        
        //Make sure we have cameras. If we don't throw the error.
        guard cameras.isEmpty == false else {
            throw CameraControllerError.noCamerasAvailable
        }
        
        var returnTuple: (front: AVCaptureDevice?, back: AVCaptureDevice?) = (front: nil, back: nil)
        
        /*
         According to the Apple documentation around the discovery session the order of the array is preserved according to the requested device types. This means that you can ask for the best / latest camera first and expect that to be listed before the least performing camera.
         https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/choosing_a_capture_device
         We also need to configure the devices properties
         https://developer.apple.com/documentation/avfoundation/avcapturedevice
         */
        if let frontCamera = cameras.first(where: { (device) -> Bool in
            return device.position == AVCaptureDevice.Position.front
        }) {
            try frontCamera.lockForConfiguration()
            
            if frontCamera.isExposureModeSupported(.continuousAutoExposure) {
                frontCamera.exposureMode = .continuousAutoExposure
            }
            if frontCamera.isFocusModeSupported(.continuousAutoFocus) {
                frontCamera.focusMode = .continuousAutoFocus
            }
            if frontCamera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                frontCamera.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            frontCamera.unlockForConfiguration()
            returnTuple.front = frontCamera
        }
        
        if let rearCamera = cameras.first(where: { (device) -> Bool in
            return device.position == AVCaptureDevice.Position.back
        }) {
            try rearCamera.lockForConfiguration()
            if rearCamera.isExposureModeSupported(.continuousAutoExposure) {
                rearCamera.exposureMode = .continuousAutoExposure
            }
            if rearCamera.isFocusModeSupported(.continuousAutoFocus) {
                rearCamera.focusMode = .continuousAutoFocus
            }
            if rearCamera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                rearCamera.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            rearCamera.unlockForConfiguration()
            returnTuple.back = rearCamera
        }
        
        return returnTuple
        
    }
    private func createVideoDataOutput(onQueue queue: DispatchQueue = DispatchQueue(label: "com.tucan9389.camera-queue")) -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        //Set the format to 32BGRA
        let settings: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        output.videoSettings = settings
        //This is true by default.
        output.alwaysDiscardsLateVideoFrames = true
        //The queue has to be a serial dispatch queue.
        output.setSampleBufferDelegate(self, queue: queue)
        //Return the output
        return output
    }
    
    private func add(input: AVCaptureDeviceInput) throws {
        guard self.captureSession.canAddInput(input) else {
            throw CameraControllerError.inputsAreInvalid
        }
        self.captureSession.addInput(input)
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
            let buffer = try sampleBuffer.cvPixelBuffer().copy()
            self.currentBuffer = buffer
            NotificationCenter.default.post(name: NewCameraBufferNotification, object: buffer)
        }catch{
            NotificationCenter.default.post(name: CameraControllerErrorNotification, object: error)
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       //print("Dropped Sample Buffer")
    }
}

