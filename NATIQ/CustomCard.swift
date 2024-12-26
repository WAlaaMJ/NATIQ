import SwiftUI
import Speech

// MARK: - Model
struct CustomCard: Identifiable {
    let id = UUID()
    let title: String
    let letters: String
    var pronunciationResult: String = ""
    var showResult: Bool = false
}

// MARK: - ViewModel
class CustomCardsViewModel: ObservableObject {
    @Published var cards: [CustomCard] = [
        CustomCard(title: "جَيّد", letters: "د ي ج"),
        CustomCard(title: "بخير", letters: "ر ي خ ب"),
        CustomCard(title: "سعيد", letters: "د ي ع س")
    ]
    @Published var searchText: String = ""
    @Published var pronunciationResult: String = ""
    @Published var isListening = false
    @Published var showResult = false
    @Published var activeCardIndex: Int = 0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func toggleVoiceRecognition() {
        if isListening {
            stopVoiceRecognition()
        } else {
            cards[activeCardIndex].showResult = false // Reset result for active card
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
        if recognizedWord.range(of: cards[activeCardIndex].title, options: .caseInsensitive) != nil {
            cards[activeCardIndex].showResult = true
            cards[activeCardIndex].pronunciationResult = "✅ صحيح!"
        } else {
            cards[activeCardIndex].showResult = true
            cards[activeCardIndex].pronunciationResult = """
            ❌ حاول مجددًا!
            تم التعرف على: \(recognizedWord)
            الكلمة المستهدفة: \(cards[activeCardIndex].title)
            """
        }
        moveToNextCard()
    }

    func moveToNextCard() {
        if activeCardIndex < cards.count - 1 {
            activeCardIndex += 1
        } else {
            pronunciationResult = "🎉 لقد انتهيت من جميع الكلمات!"
        }
    }
}

// MARK: - Views
struct CustomCardsPage: View {
    @StateObject private var viewModel = CustomCardsViewModel()

    var body: some View {
        VStack {
            headerView
            cardsView
            voiceControlButton
            additionalIcons
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
        .animation(.easeInOut, value: viewModel.activeCardIndex)
    }

    private var voiceControlButton: some View {
        Button(action: {
            viewModel.toggleVoiceRecognition()
        }) {
            VoiceControlButton(
                iconName: viewModel.isListening ? "mic.fill" : "mic.slash.fill",
                color: Color("P3"),
                size: 35
            )
        }
        .padding()
    }

    private var additionalIcons: some View {
        VStack {
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .foregroundColor(Color("P3"))
                    .frame(width: 32, height: 30)
                    .padding(.leading, 60)
                    .padding(.top, -75)
                Spacer()
            }
            HStack {
                Image(systemName: "play.fill")
                    .resizable()
                    .foregroundColor(Color("P3"))
                    .frame(width: 22, height: 25)
                    .padding(.top, -75)
                    .padding(.leading, 230)
            }
        }
    }
}

struct CustomCardView: View {
    let card: CustomCard
    let pronunciationResult: String
    let showResult: Bool
    let isActive: Bool

    var body: some View {
        VStack {
            titleView
            if isActive && showResult {
                resultView
            }
            lettersView
        }
        .frame(width: 300, height: 420)
        .padding()
        .background(cardBackground)
    }

    private var titleView: some View {
        Text(card.title)
            .font(.system(size: 55, weight: .bold))
            .foregroundColor(isActive ? .black : .gray)
            .padding(.vertical, 20)
    }

    private var resultView: some View {
        Text(pronunciationResult)
            .font(.headline)
            .foregroundColor(pronunciationResult.contains("✅") ? .green : .red)
            .padding(.bottom, 10)
    }

    private var lettersView: some View {
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

    private var cardBackground: some View {
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
    }
}

struct VoiceControlButton: View {
    let iconName: String
    let color: Color
    let size: CGFloat

    var body: some View {
        Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .padding(size / 4)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Circle())
            .shadow(color: color.opacity(0.4), radius: 5)
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
