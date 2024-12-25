//
//  Voice2SignVM.swift
//  NATIQ
//
//  Created by Raghad on 23/06/1446 AH.
//

import Foundation
import Speech
import AVFoundation

class Voice2SignVM: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var recognizedText: String = ""
    @Published var audioLevels: [CGFloat] = Array(repeating: 50, count: 30)
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var timer: Timer?

    init() {
        requestPermissions()
    }
    
    // MARK: - Permissions
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized.")
                case .denied:
                    self.recognizedText = "تم رفض إذن التعرف على الكلام. فعلها من الإعدادات."
                case .restricted, .notDetermined:
                    self.recognizedText = "التعرف على الكلام غير متاح."
                @unknown default:
                    self.recognizedText = "حدث خطأ غير متوقع في الإذن."
                }
            }
        }
        
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.recognizedText = "تم رفض إذن الميكروفون. فعلها من الإعدادات."
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.recognizedText = "تم رفض إذن الميكروفون. فعلها من الإعدادات."
                    }
                }
            }
        }
    }
    
    // MARK: - Start Recording
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            self.recognizedText = "التعرف على الكلام غير متاح."
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
                self.analyzeAudio(buffer: buffer)
            }
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                }
                
                if error != nil {
                    self.stopRecording()
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
                self.recognizedText = "استمع الآن..."
            }
        } catch {
            recognizedText = "فشل إعداد المحرك الصوتي: \(error.localizedDescription)"
            stopRecording()
        }
    }
    
    // MARK: - Analyze Audio Buffer
    private func analyzeAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frameLength = Int(buffer.frameLength)
        var sumOfSquares: Float = 0
        
        for i in 0..<frameLength {
            sumOfSquares += channelData[i] * channelData[i]
        }
        
        let rms = sqrt(sumOfSquares / Float(frameLength))

        let threshold: Float = 0.01

        if rms > threshold {
            let scaledAmplitude = CGFloat(min(max(rms * 1000, 10), 100))
            
            DispatchQueue.main.async {
                self.audioLevels = self.audioLevels.map { previousHeight in
                    CGFloat((previousHeight + scaledAmplitude) / 2)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.audioLevels = self.audioLevels.map { _ in
                    20
                }
            }
        }
    }
    
    // MARK: - Stop Recording
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.recognizedText = ""
            self.audioLevels = Array(repeating: 50, count: 30)
        }
    }
}
