//
//  AppleSpeechController.swift
//  PresentorPractice
//
//  Created by Avery Lamp on 10/23/16.
//  Copyright © 2016 Isometric. All rights reserved.
//

import UIKit
import Speech


protocol appleSpeechFeedbackProtocall: class {
    func finalAppleRecognitionRecieved( phrase: String)
    func partialAppleRecognitionRecieved(phrase:String)
    func errorAppleRecieved(error:String)
}
//@protocol googleSpeechFeedbackProtocall <NSObject>
//
//@end


class AppleSpeechController: NSObject, SFSpeechRecognizerDelegate {
    // MARK: Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    let audioEngine = AVAudioEngine()
    var delegate:appleSpeechFeedbackProtocall?

    
    // MARK: UIViewController
    

    
    func setupRecognizer() {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Recording Authorized")
                case .denied:
                    print("Recording Denied")
                    
                case .restricted:
                    print("Recording Restricted")
                    
                case .notDetermined:
                    print("Recording Not Determined")
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                for transcription in result.transcriptions{
                    print(transcription.formattedString)
                }
                let partialText = result.bestTranscription.formattedString
                self.delegate?.partialAppleRecognitionRecieved(phrase: partialText)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                if error != nil{
                    self.delegate?.errorAppleRecieved(error: (error?.localizedDescription)!)
                }else{
                    let finalText = result?.bestTranscription.formattedString
                    self.delegate?.finalAppleRecognitionRecieved(phrase: finalText!)
                }
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("Availability Changed to Available")
        } else {
            print("Availability Changed to Not Available")
        }
    }
    
    // MARK: Interface Builder actions
    
    func startSpeech(){
        try! startRecording()
    }
    
    func endSpeech(){
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.recognitionRequest = nil
            
        }
    }
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            try! startRecording()
            
        }
    }
    
    
    
}
