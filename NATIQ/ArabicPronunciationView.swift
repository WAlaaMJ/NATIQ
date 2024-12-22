//
//  PronunciationViewModel.swift
//  NATIQ
//
//  Created by Walaa on 19/12/2024.
//

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
        ArabicLetter(symbol: "أ", sound: "اه"),
        ArabicLetter(symbol: "ر", sound: "راء"),
        ArabicLetter(symbol: "ت", sound: "تاء"),
        ArabicLetter(symbol: "ش", sound: "شاء"),
        ArabicLetter(symbol: "م", sound: "ما"),
        ArabicLetter(symbol: "ي", sound: "ياء"),
        ArabicLetter(symbol: "خ", sound: "خاء"),
        ArabicLetter(symbol: "ب", sound: "باء"),
        ArabicLetter(symbol: "و", sound: "وا"),
        ArabicLetter(symbol: "ك", sound: "كاء"),
       
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
        VStack(alignment: .leading) {
            // Title and description
            VStack(alignment: .leading, spacing: 28) {
                Text("نطق الأحرف")
                    .font(.largeTitle)
                    .bold()
                Text("تعرَّف على نطق الصوت عند الضغط على كل حرف.")
                    .font(.body)
                    .foregroundColor(.gray)
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.15))
                                .frame(height: 120)
                            
                            VStack {
                                Text(letter.symbol)
                                    .font(.system(size: 50))
                                    .foregroundColor(.black)
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 24))
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
    }
}

// MARK: - Preview
struct ArabicPronunciationView_Previews: PreviewProvider {
    static var previews: some View {
        ArabicPronunciationView()
    }
}

