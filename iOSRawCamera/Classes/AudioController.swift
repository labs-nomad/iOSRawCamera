//
//  AudioController.swift
//  iOSRawCamera
//
//  Created by Nomad Company on 2/15/20.
//  Copyright © 2020 Nomad Company. All rights reserved.
//


public class AudioController: NSObject {
    
    //MARK: Public Properties
    
    //MARK: Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    //MARK: Init
    public override init() {
        super.init()
        
    }
    
    //MARK: Public functions
    
    
    
    //MARK: Private functions
    
}



