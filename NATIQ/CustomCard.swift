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
    @Published var pronunciationResult: String = ""
    @Published var isListening = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-DZ"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Toggles speech recognition
    func toggleVoiceRecognition() {
        if isListening {
            stopVoiceRecognition()
        } else {
            startVoiceRecognition()
        }
        isListening.toggle()
    }
    
    // Starts speech recognition authorization
    private func startVoiceRecognition() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.startRecording()
                default:
                    self.pronunciationResult = "❌ الإذن مرفوض."
                }
            }
        }
    }
    
    // Starts recording audio and processing speech
    private func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            pronunciationResult = "❌ فشل إعداد الجلسة الصوتية: \(error.localizedDescription)"
            return
        }
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.searchText = result.bestTranscription.formattedString
                    if let firstCard = self.cards.first {
                        self.checkPronunciation(for: firstCard.title)
                    }
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopVoiceRecognition()
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
            pronunciationResult = "❌ فشل تشغيل المحرك الصوتي: \(error.localizedDescription)"
        }
    }
    
    // Stops speech recognition
    private func stopVoiceRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    // Compares recognized text with the target word
    func checkPronunciation(for word: String) {
        let recognizedWord = searchText.normalizedArabic()
        let targetWord = word.normalizedArabic()

        if recognizedWord.range(of: targetWord, options: .caseInsensitive) != nil {
            pronunciationResult = "✅ صحيح!"
        } else {
               pronunciationResult = """
               ❌ حاول مجددًا!
               تم التعرف على: \(recognizedWord)
               الكلمة المستهدفة: \(targetWord)
               """
           }

        searchText = "" // Clear search text after comparison
    }
}

// MARK: - Views
struct CustomCardsPage: View {
    @StateObject private var viewModel = CustomCardsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("جرّب نطقك، ولا تستسلم 💪")
                    .font(.title2)
                    .padding()
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, .rightToLeft)
                
                // Cards Section
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.cards) { card in
                            CustomCardView(card: card, pronunciationResult: $viewModel.pronunciationResult)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Voice Control Button
                Button(action: viewModel.toggleVoiceRecognition) {
                    VoiceControlButton(iconName: viewModel.isListening ? "mic.slash.fill" : "mic.fill", color: .purple)
                }
                .padding()
                
                // Voice-to-text output
                if !viewModel.searchText.isEmpty {
                    Text(viewModel.searchText)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .multilineTextAlignment(.center)
                }
            }
            .background(Color(hex: "#F5F8FF").ignoresSafeArea())
            .navigationTitle("أختبر نطقك للكلمات")
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

struct CustomCardView: View {
    let card: CustomCard
    @Binding var pronunciationResult: String
    
    var body: some View {
        VStack {
            Text(card.title)
                .font(.title)
                .padding()
            
            if !pronunciationResult.isEmpty {
                Text(pronunciationResult)
                    .font(.headline)
                    .foregroundColor(pronunciationResult.contains("✅") ? .green : .red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct VoiceControlButton: View {
    let iconName: String
    let color: Color
    
    var body: some View {
        Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Circle())
    }
}

// MARK: - Extensions
extension String {
    func normalizedArabic() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "ى", with: "ي")
            .replacingOccurrences(of: "ة", with: "ه")
            .replacingOccurrences(of: "ـ", with: "")       // Remove tatweel
            .applyingTransform(.stripCombiningMarks, reverse: false) ?? self
    }
}

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
