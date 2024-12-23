import SwiftUI
import AVFoundation
import Speech

// MARK: - Model
struct ArabicLetter: Identifiable {
    let id = UUID()
    let symbol: String
    let sound: String
}

// MARK: - ViewModel
class ArabicPronunciationViewModel: ObservableObject {
    @Published var letters: [ArabicLetter] = [
        ArabicLetter(symbol: "ب", sound: "باء"),
        ArabicLetter(symbol: "أ", sound: "اه"),
        ArabicLetter(symbol: "ث", sound: "ثاء"),
        ArabicLetter(symbol: "ت", sound: "تاء"),
        ArabicLetter(symbol: "ح", sound: "حاء"),
        ArabicLetter(symbol: "ج", sound: "جا"),
        ArabicLetter(symbol: "د", sound: "دا"),
        ArabicLetter(symbol: "خ", sound: "خاء"),
        ArabicLetter(symbol: "ر", sound: "راء"),
        ArabicLetter(symbol: "ذ", sound: "ذا"),
        ArabicLetter(symbol: "س", sound: "‎سا"),
        ArabicLetter(symbol: "ز", sound: "زاء"),
        ArabicLetter(symbol: "ص", sound: "صا"),
        ArabicLetter(symbol: "ش", sound: "شا"),
        ArabicLetter(symbol: "ط", sound: "طا"),
        ArabicLetter(symbol: "ض", sound: "ضاء"),
        ArabicLetter(symbol: "ع", sound: "عا"),
        ArabicLetter(symbol: "ظ", sound: "ظاء"),
        ArabicLetter(symbol: "ف", sound: "فاء"),
        ArabicLetter(symbol: "غ", sound: "غا"),
        ArabicLetter(symbol: "ك", sound: "‎كاء"),
        ArabicLetter(symbol: "ق", sound: "قاء"),
        ArabicLetter(symbol: "م", sound: "ماء"),
        ArabicLetter(symbol: "ل", sound: "كاء"),
        ArabicLetter(symbol: "و", sound: "واء"),
        ArabicLetter(symbol: "ن", sound: "نا"),
        ArabicLetter(symbol: "ي", sound: "يا"),
        ArabicLetter(symbol: "هـ", sound: "هاء"),
        
    ]
    
    private var synthesizer = AVSpeechSynthesizer()
    
    func pronounce(letter: ArabicLetter) {
        let utterance = AVSpeechUtterance(string: letter.sound)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA") // Arabic language voice
        utterance.rate = 0.45 // Set to natural speed
        synthesizer.speak(utterance)
    }
}

// MARK: - View
struct ArabicPronunciationView: View {
    @StateObject private var viewModel = ArabicPronunciationViewModel()
    
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView { // Add the ScrollView here to make the content scrollable
            VStack(alignment: .leading) {
                // Title and description
                VStack(alignment: .leading, spacing: 8) {
                  HStack {
                      Spacer()
                      Text("نطق الأحرف")
                          .font(.largeTitle)
                          .bold()
                    }
                    HStack{
                        Spacer()
                        Text("تعرَّف على نطق الأحرف عند الضغط على كل حرف")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                   
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Grid of letters
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(viewModel.letters) { letter in
                        Button(action: {
                            viewModel.pronounce(letter: letter)
                        }) {
                            ZStack {
                                // Linear gradient background for each letter button
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("B1"), Color("B2")]),
                                            //startPoint: .topLeading,
                                            startPoint: .leading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 170, height: 170)
                                
                                VStack {
                                    Text(letter.symbol)
                                        .font(.system(size: 50))
                                        .foregroundColor(Color("TextColor2"))
                                        .offset(y: 25)
                                        .offset(x: 0)
                                    // Circle background behind the speaker icon
                                    ZStack {
                                        Circle()
                                            .fill(Color("B4"))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundColor(Color("TextColor2"))
                                            .font(.system(size: 18))
                                            
                                    }
                                   
                                    .offset(y: 8)
                                    .offset(x: 53) /// Position the speaker below the letter symbol
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.bottom)
            .background( Color("BGC")) // Apply red background here
        }
        .background( Color("BGC")) // Also add a red background to the scroll view
    }
}

// MARK: - Preview
struct ArabicPronunciationView_Previews: PreviewProvider {
    static var previews: some View {
        ArabicPronunciationView()
    }
}

