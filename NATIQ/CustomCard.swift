import SwiftUI
import Speech
import AVFoundation

// MARK: - Model
struct CustomCard: Identifiable {
    let id = UUID()
    let title: String
    let letters: String
    var pronunciationResult: String = ""
    var showResult: Bool = false
    var isStarFilled: Bool
}

// MARK: - ViewModel
class CustomCardsViewModel: NSObject, ObservableObject, 
    AVSpeechSynthesizerDelegate {
        @Published var cards: [CustomCard] = [
            CustomCard(title: "أنا جيد", letters: "د يِّ جَ ا نَ أَ", isStarFilled: false),
            CustomCard(title: "بخير", letters: "ر يْ خَ بِ", isStarFilled: false),
            CustomCard(title: "سعيد", letters: "د ي عِ سَ", isStarFilled: false)
        ]
    @Published var favoriteCards: [CustomCard] = []
        


    @Published var searchText: String = ""
    @Published var pronunciationResult: String = ""
    @Published var isListening = false
    @Published var showResult = false
    @Published var activeCardIndex: Int = 0
    @Published var isSpeaking = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

   // MARK: - Favorite Toggle
        func toggleFavorite(for card: CustomCard) {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].isStarFilled.toggle()
                
                if cards[index].isStarFilled {
                    // Add to favorites
                    favoriteCards.append(cards[index])
                } else {
                    // Remove from favorites
                    favoriteCards.removeAll { $0.id == card.id }
                }
            }
        }

    func toggleVoiceRecognition() {
        if isListening {
            stopVoiceRecognition()
        } else {
            cards[activeCardIndex].showResult = false
            pronunciationResult = ""
            startVoiceRecognition()
        }
        isListening.toggle()
    }

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
        inputNode.removeTap(onBus: 0)

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.searchText = result.bestTranscription.formattedString
                    self.checkPronunciation(for: self.searchText)
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

    func checkPronunciation(for recognizedWord: String) {
        let targetText = cards[activeCardIndex].title
        cards[activeCardIndex].showResult = false
        cards[activeCardIndex].pronunciationResult = ""

        let recognizedWords = recognizedWord.split(separator: " ")
        let targetWords = targetText.split(separator: " ")

        let isMatch = recognizedWords.contains { word in
            targetWords.contains { $0.caseInsensitiveCompare(String(word)) == .orderedSame }
        }

        if isMatch {
            cards[activeCardIndex].showResult = true
            cards[activeCardIndex].pronunciationResult = "✅ صحيح!"
            moveToNextCard()
        } else {
            cards[activeCardIndex].showResult = true
            cards[activeCardIndex].pronunciationResult = """
            ❌ حاول مجددًا!
            تم التعرف على: \(recognizedWord)
            الكلمة المستهدفة: \(targetText)
            """
        }
    }

    func moveToNextCard() {
        guard cards[activeCardIndex].showResult,
              cards[activeCardIndex].pronunciationResult.contains("✅") else { return }

        if activeCardIndex < cards.count - 1 {
            activeCardIndex += 1
        } else {
            pronunciationResult = "🎉 لقد انتهيت من جميع الكلمات!"
        }
    }

    func speakText(for card: CustomCard) {
        let utterance = AVSpeechUtterance(string: card.title)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        isSpeaking = true
        speechSynthesizer.speak(utterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}

// MARK: - Views
struct CustomCardsPage: View {
    @ObservedObject var viewModel: CustomCardsViewModel

    var body: some View {
           ZStack {
               // Set the background color of the page
               Color("BGC")
                   .edgesIgnoringSafeArea(.all)

               VStack {
                   headerView
                   cardsView
                   buttonsAligned // Buttons aligned in one line
               }
           }
       }


    private var headerView: some View {
        VStack {
            HStack {
                Spacer()
                Text("أهلاً كيفك اليوم 👋")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
                    .padding(.trailing, 18)
                    .padding(.top, 50)
            }
            .padding(.bottom, 5)

            HStack {
                Spacer()
                Text("تعرف على طريقة النطق ومخارج الاصوات")
                    .font(.system(size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextColor"))
                    .padding(.trailing, 18)
            }
        }
    }
/////change maybe from my side
    private var cardsView: some View {
        TabView(selection: $viewModel.activeCardIndex) {
            ForEach(viewModel.cards.indices, id: \.self) { index in
                CustomCardView(
                    card: viewModel.cards[index],
                    pronunciationResult: viewModel.cards[index].pronunciationResult,
                    showResult: viewModel.cards[index].showResult,
                    isActive: index == viewModel.activeCardIndex
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    private var buttonsAligned: some View {
        HStack(spacing: 65) {
            
            ZStack {
                Circle()
                    .fill(Color("white"))
                    .frame(width: 50, height: 50)
              Image(systemName: viewModel.cards[viewModel.activeCardIndex].isStarFilled ? "star.fill" : "star")
                    .foregroundColor(Color("P3"))
                    .font(.system(size: 30))
            }
            .onTapGesture {
        viewModel.toggleFavorite(for: viewModel.cards[viewModel.activeCardIndex])
            }
            ZStack {
                Circle()
                    .fill(Color("white"))
                    .frame(width: 50, height: 50)
                Image(systemName: viewModel.isListening ? "mic.fill" : "mic.slash.fill")
                    .foregroundColor(Color("P3"))
                    .font(.system(size: 30))
            }
            .onTapGesture {
                viewModel.toggleVoiceRecognition()
            }

            ZStack {
                Circle()
                    .fill(Color("white"))
                    .frame(width: 50, height: 50)
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(Color("P3"))
                    .font(.system(size: 30))
            }
            .onTapGesture {
                viewModel.speakText(for: viewModel.cards[viewModel.activeCardIndex])
            }

         
        }
        .padding()
    }
}

// MARK: - Card View (Unchanged)
struct CustomCardView: View {
    let card: CustomCard
    let pronunciationResult: String
    let showResult: Bool
    let isActive: Bool
// let speakAction: () -> Void

    var body: some View {
        VStack {
            Text(card.title)
                .font(.system(size: 55, weight: .bold))
                .foregroundColor(isActive ? .black : .gray)
                .padding(.vertical, 20)

            if isActive && showResult {
                Text(pronunciationResult)
                    .font(.headline)
                    .foregroundColor(pronunciationResult.contains("✅") ? .green : .red)
                    .padding(.bottom, 10)
            }

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
        }
        .frame(width: 300, height: 420)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 200 / 255, green: 212 / 255, blue: 247 / 255),
                            Color(red: 177 / 255, green: 191 / 255, blue: 224 / 255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Preview
struct CustomCardsPage_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a new or sample CustomCardsViewModel instance here
        CustomCardsPage(viewModel: CustomCardsViewModel())
    }
}
