import Foundation
import AVFoundation
import Speech
import SwiftUI
import Combine

class VoiceRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {
    // Published properties for UI updates
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var transcribedText = ""
    @Published var recordingTime: TimeInterval = 0
    @Published var permissionDenied = false
    @Published var errorMessage: String? = nil
    
    // Audio recording properties
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    
    // Speech recognition properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    // Timer for recording duration
    private var timer: Timer?
    
    override init() {
        super.init()
        setupRecordingSession()
        speechRecognizer?.delegate = self
    }
    
    deinit {
        stopRecording()
        timer?.invalidate()
    }
    
    // MARK: - Setup Methods
    
    private func setupRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            errorMessage = "Failed to set up recording session: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Permission Methods
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        // Request microphone permission
        AVAudioApplication.requestRecordPermission { [weak self] allowed in
            if !allowed {
                self?.permissionDenied = true
                completion(false)
                return
            }
            
            // Request speech recognition permission
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    let speechAllowed = status == .authorized
                    if !speechAllowed {
                        self?.permissionDenied = true
                    }
                    completion(speechAllowed)
                }
            }
        }
    }
    
    // MARK: - Recording Methods
    
    func startRecording() {
        // Reset state
        transcribedText = ""
        recordingTime = 0
        errorMessage = nil
        
        // Check permissions first
        requestPermissions { [weak self] allowed in
            guard let self = self, allowed else { return }
            
            // Create recording URL in temporary directory
            let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
            self.recordingURL = audioFilename
            
            // Configure recording settings
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                // Create and start the audio recorder
                self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                self.audioRecorder?.delegate = self
                self.audioRecorder?.record()
                self.isRecording = true
                
                // Start timer to track recording duration
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.recordingTime += 0.1
                }
                
                // Start speech recognition
                self.startSpeechRecognition()
            } catch {
                self.errorMessage = "Failed to start recording: \(error.localizedDescription)"
            }
        }
    }
    
    func stopRecording() {
        // Stop audio recorder
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Stop speech recognition
        stopSpeechRecognition()
    }
    
    // MARK: - Speech Recognition Methods
    
    private func startSpeechRecognition() {
        // Check if recognition is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is not available"
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Configure audio session for recognition
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
            return
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        
        // Configure recognition request
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create speech recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        isTranscribing = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Recognition error: \(error.localizedDescription)"
                self.stopSpeechRecognition()
                return
            }
            
            if let result = result {
                // Update transcribed text
                self.transcribedText = result.bestTranscription.formattedString
            }
            
            // If task is finished, stop recognition
            if result?.isFinal == true {
                self.stopSpeechRecognition()
            }
        }
        
        // Configure audio format and install tap on input node
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            stopSpeechRecognition()
        }
    }
    
    private func stopSpeechRecognition() {
        // Stop audio engine and remove tap
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isTranscribing = false
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            errorMessage = "Recording failed"
        }
        
        isRecording = false
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            errorMessage = "Speech recognition is no longer available"
            stopRecording()
        }
    }
    
    // MARK: - Helper Methods
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 