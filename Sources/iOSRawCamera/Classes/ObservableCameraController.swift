//
//  ObservableCameraController.swift
//  
//
//  Created by Nomad Company on 4/14/20.
//

import Combine
import AVFoundation
import UIKit

public class ObservableCameraController: ObservableObject {
    //MARK: @Published properties
    @Published public private(set) var cameraAuthorizationStatus: AVAuthorizationStatus = CameraAuthorizationController().authorizationStatus()
    
    @Published public private(set) var videoState: VideoFeedState = VideoFeedState.notPrepared(nil)
    
    @Published public var videoRoute: iOSRawCameraRoute = iOSRawCameraRoute.front
    
    @Published public private(set) var currentVideoFrame: UIImage?
    
    @Published public private(set) var currentPixelBuffer: CVPixelBuffer?
    
    /// When the delegate receives a `CVPixelBuffer`should we make a copy of it before sending it into the the `NewCameraBufferNotification`
    @Published public var shouldCopyBuffer: Bool = true
    
    //MARK: Other public properties
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
    public internal(set) var currentCameraPosition: iOSRawCameraRoute = iOSRawCameraRoute.front {
        didSet {
            self.notificationCenter.post(name: CameraRouteChangedNotification, object: self.currentCameraPosition)
        }
    }
    
    /// The camera position opposite the `.currentCameraPosition`
    public var oppositeCameraPosition: iOSRawCameraRoute {
        switch self.currentCameraPosition {
        case .back:
            return iOSRawCameraRoute.front
        case .front:
            return iOSRawCameraRoute.back
        }
    }
    
    /// The current `AVCaptureDeviceInput` that is feeding the camera. If this changes internally, ususlly by the user switching cameras, it will fire a `DeviceInputChangedNotification` notification
    public private(set) var currentCameraInput: AVCaptureDeviceInput? {
        didSet {
            self.notificationCenter.post(name: DeviceInputChangedNotification, object: self.currentCameraInput)
        }
    }
    
   
    
    //MARK: Private properties
    //The object that conforms to NSObject so that it can receive Buffers through the delegate
    let bufferReceiver: BufferReceiver = BufferReceiver()
    // A tuple that represents the front and back cameras that I expect to discover.
    typealias DesiredDevices = (front: AVCaptureDevice?, back: AVCaptureDevice?)
    // The `AVCaptureSession` that is running the show.
    private let captureSession: AVCaptureSession = AVCaptureSession()
    
    //The video output stream. This is where we get the raw buffer.
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var desiredDevices: DesiredDevices = (front: nil, back: nil)
    
    var notificationCenter: NotificationCenter = NotificationCenter.default
    
    var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    let context = CIContext()
    
    //MARK: Combine Subscriptions
    var deviceOrientationSubscription: AnyCancellable?
    var authorizationSubscription: AnyCancellable?
    var videoFeedStateChangedSubscription: AnyCancellable?
    var videoRouteChangedSubscription: AnyCancellable?
    var newBufferSubscription: AnyCancellable?
    var shouldCopyBufferSubscription: AnyCancellable?
    
    //MARK: Init
    public init() {
        self.currentDeviceOrientation = UIDevice.current.orientation
        self.notificationCenter = NotificationCenter.default
        self.deviceOrientationSubscription = self.notificationCenter.publisher(for: UIDevice.orientationDidChangeNotification).sink { self.orientationChanged($0) }
        self.authorizationSubscription = self.notificationCenter.publisher(for: CameraAuthorizationStateChangedNotification).sink { self.authorizationChange($0) }
        self.videoFeedStateChangedSubscription = self.notificationCenter.publisher(for: VideoFeedStateChangedNotification).sink { self.videoFeedStateChanged($0) }
        self.videoRouteChangedSubscription = self.notificationCenter.publisher(for: CameraRouteChangedNotification).sink { self.videoRouteChanged($0) }
        self.newBufferSubscription = self.notificationCenter.publisher(for: NewCameraBufferNotification).sink { self.newBuffer($0) }
        self.shouldCopyBufferSubscription = self.$shouldCopyBuffer.sink { self.shouldCopyBufferChanged($0) }
    }
    
    //MARK: Sunk Functions
    func orientationChanged(_ notification: Notification) {
        guard let device = notification.object as? UIDevice else {
            return
        }
        
        self.currentDeviceOrientation = device.orientation
        
        do {
            try self.updateCaptureConnections(forOrientation: device.orientation)
        }catch{
            self.change(videoState: VideoFeedState.notPrepared(error))
        }
    }
    
    func authorizationChange(_ notification: Notification) {
        guard let state = notification.object as? AVAuthorizationStatus else {
            return
        }
        
        self.cameraAuthorizationStatus = state
    }
    
    func videoFeedStateChanged(_ notification: Notification) {
        guard let _ = notification.object as? VideoFeedState else {
            return
        }
        
        self.resetBufferState()
    }
    
    func videoRouteChanged(_ notification: Notification) {
        guard let _ = notification.object as? iOSRawCameraRoute else {
            return
        }
        self.resetBufferState()
    }
    
    func newBuffer(_ notification: Notification) {
        let buffer = notification.object as! CVPixelBuffer
        
        //https://stackoverflow.com/questions/58239980/generating-qr-code-with-swiftui-shows-empty-picture
        let ciImage = buffer.ciImage
        guard let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        let image = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async {
            self.currentVideoFrame = image
            self.notificationCenter.post(name: NewDisplayImageNotification, object: self.currentVideoFrame)
            self.currentPixelBuffer = buffer
        }
    }
    
    func shouldCopyBufferChanged(_ shouldCopy: Bool) {
        self.bufferReceiver.shouldCopyBuffer = shouldCopy
    }
    
    
    //MARK: Public Functions
    
    /// Abstraction over the `AVCaptureSession` to make it start collecting video frames.
    public func startRunning() {
        self.captureSession.startRunning()
        self.change(videoState: .running)
    }
    
    /// Abstraction over the `AVCaptureSession` to make it stop collecting video frames.
    public func stopRunning() {
        self.captureSession.stopRunning()
        self.change(videoState: .prepared)
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
    
    // returns the current screen resolution (differs by device type)
    open func getCaptureResolution() -> CGSize {
        // Define default resolution
        var resolution = CGSize(width: 0, height: 0)
        
        // Get video dimensions
        if (cameraDevice == nil){
            log.warning("Camera not allocated")
            selectedCamera = getCamera()
        }
        
        if let formatDescription = CameraManager.cameraDevice?.activeFormat.formatDescription {
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
        } else {
            log.warning("formatDescription error. Setting resolution to screen default")
            resolution = CGSize(width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(UIScreen.main.bounds.height))
        }
        
        if (self.currentDeviceOrientation == .portrait) {
            resolution = CGSize(width: resolution.height, height: resolution.width)
        }
        
        // Return resolution
        return resolution
    }
    
    
    
    
    /// After initalization this object needs to go configure the `AVCaptureSession`. This function checks authorization, initalizes the `AVCaptureSession`, discovers available devices, sets them according to the desired comera position, orients the flow of data according to the UIDeviceOrientation, and sets the video feed state to `.prepared`
    /// - Parameters:
    ///   - sessionPreset: The `AVCaptureSession.Preset` you want. Defaults to `.vga640x480`
    ///   - desiredCameraPosition: The `iOSRawCameraRoute` you want initalized first. Defaults to `.front`
    ///   - authorization: An object that can determine authorization. Conforms to `AVCaptureDeviceCameraAuthorizationInterface` defaults to `AVCaptureDevice.self`
    public func setUp(sessionPreset: AVCaptureSession.Preset = .vga640x480, desiredCameraPosition: iOSRawCameraRoute = .front, authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, authorizationController: CameraAuthorizationController = CameraAuthorizationController()) throws {
        // We want to intercept the Error so that we can set the state of the `CameraController`.
        do {
            //We don't want to continue with the `AVFoundation` set up if we are not authorized
            try self.preSetupAuthorizationCheck(authorization: authorization, authorizationController: authorizationController)

            //Change the state object to 'preparing'
            self.change(videoState: .preparing)
            
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
            self.change(videoState: VideoFeedState.prepared)
        } catch {
            //Call the completion with the error object
            self.change(videoState: VideoFeedState.notPrepared(error))
            throw error
        }
    }
    
    
    /// Function that calls `.stopRunning()` on the `AVCaptureSession` and removes the current video output. After this is called the `.state` property will be of type `.notPrepared(nil)`. You will have to call `.setUP()` again to set the camera back up.
    public func tearDown() {
        self.captureSession.stopRunning()
        self.removeAllOutputs()
        self.removeAllInputs()
        self.change(videoState: .notPrepared(nil))
    }
    
    
    //MARK: Internal Functions
    
    private func change(videoState: VideoFeedState) {
        DispatchQueue.main.async {
            self.videoState = videoState
        }
    }
    
    private func resetBufferState() {
        DispatchQueue.main.async {
            self.currentVideoFrame = nil
            self.currentPixelBuffer = nil
        }
    }
        
    
     private func
         preSetupAuthorizationCheck(authorization: AVCaptureDeviceCameraAuthorizationInterface.Type = AVCaptureDevice.self, authorizationController: CameraAuthorizationController = CameraAuthorizationController()) throws {
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
        output.setSampleBufferDelegate(self.bufferReceiver, queue: queue)
         //Return the output
         return output
     }
     
     private func getVideoFileOutput() -> AVCaptureMovieFileOutput? {
         let output: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
         guard let connection = output.connection(with: AVMediaType.video) else {
             return nil
         }
         if output.availableVideoCodecTypes.contains(AVVideoCodecType.h264) {
             let outputSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264]
             output.setOutputSettings(outputSettings, for: connection)
         }
     
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
    
    //MARK: Deinit
    deinit {
        self.deviceOrientationSubscription?.cancel()
        self.deviceOrientationSubscription = nil
    }
}

class BufferReceiver: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //MARK: Properties
    let notificationCenter: NotificationCenter = NotificationCenter.default
    
    var shouldCopyBuffer: Bool = true
    
    //MARK: Init
    
    
    //MARK: AVCaptureVideoDataOutputSampleBufferDelegate conformance
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
