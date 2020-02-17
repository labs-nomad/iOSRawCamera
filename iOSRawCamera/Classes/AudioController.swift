//
//  AudioController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 2/15/20.
//  Copyright © 2020 Nomad Company. All rights reserved.
//


public class AudioController: NSObject {
    
    //MARK: Public Properties
    /// The `AudioState` helps guide you through the process of gettign the audio -> Speech inference engine up and reporting things.
    var audioState: AudioState = AudioState.notPrepared(nil) {
        didSet {
            OperationQueue.main.addOperation {
                self.notificationCenter.post(name: AudioStateChangedNotification, object: self.audioState)
            }
        }
    }
    
    /// Is the audio session running
    public var isAudioRunning: Bool {
        return self.audioEngine.isRunning
    }
    
    //MARK: Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // The audio session for the app.
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let audioEngine = AVAudioEngine()
    
    weak var notificationCenter: NotificationCenter!
    
    //MARK: Init
    public override init() {
        super.init()
        self.notificationCenter = NotificationCenter.default
    }
    
    //MARK: Public functions
    /// Abstraction over the `AVCaptureSession` to make it start collecting video frames.
    public func startRunning() throws {
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        self.recognitionTask = self.speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)
        
        self.audioEngine.prepare()
        try audioEngine.start()
            
        self.audioState = .running
    }
    
    /// Abstraction over the `AVCaptureSession` to make it stop collecting video frames.
    public func stopRunning() {
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        self.audioState = .prepared
    }
    
    /// Convenience function that will switch the session from running to prepared or vice versa.
    public func toggleRunning() throws {
        switch self.audioState {
        case .prepared:
            try self.startRunning()
        case .running:
            self.stopRunning()
        default:
            break
        }
    }
    public func setUp(authorization: SFAudioAuthorizationInterface.Type = SFSpeechRecognizer.self, authorizationConroller: AudioAuthorizationController = AudioAuthorizationController()) throws {
        
        //We want to intercept the error to set the state of the controller. DEF throw that error though.
        do {
            //Check Authorization
            try self.preSetupAuthorizationCheck(authorization: authorization, authorizationController: authorizationConroller)
            
            //Set the state to preparing
            
            self.audioState = AudioState.preparing
            
            self.speechRecognizer.delegate = self
            
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            
            // Create and configure the speech recognition request
            self.recognitionRequest.shouldReportPartialResults = true
            
            // Keep speech recognition data on device
            if #available(iOS 13, *) {
                recognitionRequest.requiresOnDeviceRecognition = true
            }
            
            // Configure the microphone input.
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest.append(buffer)
            }
            
            self.audioState = AudioState.prepared
            
        }catch{
            self.audioState = AudioState.notPrepared(error)
            throw error
        }
    }
    
    
    //MARK: Private functions
    private func preSetupAuthorizationCheck(authorization: SFAudioAuthorizationInterface.Type = SFSpeechRecognizer.self, authorizationController: AudioAuthorizationController = AudioAuthorizationController()) throws {
        /*
        Use the object that conforms to the SFAudioAuthorizationInterface to check the state of the audio authorization
         
        If it is not authorized then check the state with more detail.
         */
        guard authorizationController.isAudioAuthorized(authorization: authorization) == true else {
            switch authorizationController.authorizationStatus(authorization: authorization) {
            case .denied:
                let error = AudioControllerError.permissionDenied
                throw error
            case .notDetermined:
                let error = AudioControllerError.permissionNotDetermined
                throw error
            default:
                let error = AudioControllerError.badPermissions
                throw error
            }
        }
    }
    
}

extension AudioController: SFSpeechRecognitionTaskDelegate {
    public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        
    }
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        
    }
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print(recognitionResult.bestTranscription)
    }
    public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        
    }
    public func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        
    }
    public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
    
    }
}

extension AudioController: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        guard available == false else{
            return
        }
        let error = AudioControllerError.becameUnavailable
        self.audioState = AudioState.notPrepared(error)
        self.notificationCenter.post(name: AudioControllerErrorNotification, object: error)
    }
}





