//
//  Words.swift
//  NATIQ
//
//  Created by Walaa on 19/12/2024.
//

import SwiftUI
import Speech

// MARK: - Model
struct CustomCard: Identifiable {
    let id = UUID()
    let title: String
    let letters: String
}

// MARK: - ViewModel
class CustomCardsViewModel: ObservableObject {
    @Published var cards: [CustomCard] = [
        CustomCard(title: "جيد", letters: "ج ي د")
    ]
    
    @Published var searchText: String = ""
    @Published var pronunciationResult: String = "" // Holds the pronunciation result message
    @Published var isListening = false // Changed to @Published to observe in view

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA")) // Use Arabic locale
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Toggle voice recognition on mic button press
    func toggleVoiceRecognition() {
        if isListening {
            stopVoiceRecognition()
        } else {
            startVoiceRecognition()
        }
        isListening.toggle()
    }
    
    // Starts speech recognition
    func startVoiceRecognition() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.startRecording()
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition authorization denied.")
                @unknown default:
                    print("Unknown authorization status.")
                }
            }
        }
    }
    
    private func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            return
        }
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0) // Remove any existing tap before adding a new one
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.searchText = result.bestTranscription.formattedString
                    // Check pronunciation against the first card's title for simplicity
                    if let firstCard = self.cards.first {
                        self.checkPronunciation(for: firstCard.title)
                    }
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine failed to start: \(error.localizedDescription)")
        }
    }
    
    func stopVoiceRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    func checkPronunciation(for word: String) {
        let recognizedWord = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let targetWord = word.lowercased()
        
        if recognizedWord == targetWord {
            pronunciationResult = "✅ صحيح!"
        } else {
            pronunciationResult = "❌ حاول مجددًا! تم التعرف على: \(recognizedWord)"
        }
    }
    
    var filteredCards: [CustomCard] {
        if searchText.isEmpty {
            return cards
        } else {
            return cards.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
}

// MARK: - Views
struct CustomCardsPage: View {
    @StateObject private var viewModel = CustomCardsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                VStack(alignment: .leading) {
                    Text("جرّب نطقك، ولا تستسلم 💪")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .padding(.vertical, 15)
                }
                .environment(\.layoutDirection, .rightToLeft) // Right-to-left for header text
                
                // Search Bar
                TextField("ابحث عن كلمة...", text: $viewModel.searchText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .environment(\.layoutDirection, .rightToLeft) // Right-to-left for search bar text
                
                // Cards Section
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredCards) { card in
                            CustomCardView(card: card, action: viewModel.toggleVoiceRecognition, pronunciationResult: $viewModel.pronunciationResult)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Voice Control Buttons
                HStack(spacing: 5) {
                    Button(action: {
                        viewModel.toggleVoiceRecognition()
                    }) {
                        VoiceControlButton(iconName: viewModel.isListening ? "mic.slash.fill" : "mic.fill", color: .purple)
                    }
                }
                .environment(\.layoutDirection, .rightToLeft) // Right-to-left for voice control buttons
                
                // Display voice-to-text output under the mic button
                Text(viewModel.searchText)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, .rightToLeft) // Right-to-left for voice-to-text output
            }
            .background(Color(hex: "#F5F8FF"))
            .navigationTitle("أختبر نطقك للكلمات")
            .environment(\.layoutDirection, .rightToLeft) // Right-to-left for the entire page (except cards)
        }
    }
}

struct CustomCardView: View {
    let card: CustomCard
    let action: () -> Void
    @Binding var pronunciationResult: String // Bind to pronunciation result
    
    var body: some View {
        VStack {
            Text(card.title)
                .font(.system(size: 30, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            
            Text(pronunciationResult)
                .font(.headline)
                .foregroundColor(pronunciationResult.contains("✅") ? .green : .red)
                .padding()
                .environment(\.layoutDirection, .rightToLeft)
            
            HStack(spacing: 10) {
                ForEach(card.letters.split(separator: " "), id: \.self) { letter in
                    Text(String(letter))
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 44, height: 49)
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
            }
            .padding(.top, 10)
        }
        .frame(width: 301, height: 429) // Set the width and height of the card here
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 200 / 255, green: 212 / 255, blue: 247 / 255),
                        Color(red: 177 / 255, green: 191 / 255, blue: 224 / 255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        )
    }
}

struct VoiceControlButton: View {
    let iconName: String
    let color: Color
    
    var body: some View {
        Image(systemName: iconName)
            .resizable()
            .frame(width: 24, height: 24)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

// MARK: - Color Extension to Support Hex Colors
extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexSanitized)
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        
        let red = Double((hexValue & 0xFF0000) >> 16) / 255.0
        let green = Double((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(hexValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct CustomCardsPage_Previews: PreviewProvider {
    static var previews: some View {
        CustomCardsPage()
    }
}


