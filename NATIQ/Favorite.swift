import SwiftUI

struct Favorite: View {
    @ObservedObject var viewModel: CustomCardsViewModel
    @State private var activeCardIndex: Int = 0 // Tracks the active card
    @State private var localFavoriteCards: [CustomCard] = [] // Local state for results

    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Spacer()
                Text("المفضلة ⭐️")
                    .font(.system(size: 29))
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
                    .padding(.trailing, 26)
            }
            .padding(.horizontal, 26)
            .padding(.top, 19)

            if localFavoriteCards.isEmpty {
                // Show a message if no favorite cards exist
                Text("لا توجد بطاقات مفضلة حاليًا")
                    .font(.headline)
                    .foregroundColor(Color.gray)
                    .padding()
            } else {
                // Horizontal Swipeable Favorite Cards
                TabView(selection: $activeCardIndex) {
                    ForEach(localFavoriteCards.indices, id: \.self) { index in
                        CustomCardView(
                            card: localFavoriteCards[index],
                            pronunciationResult: localFavoriteCards[index].pronunciationResult,
                            showResult: localFavoriteCards[index].showResult,
                            isActive: index == activeCardIndex
                        )
                        .tag(index) // Associate each card with its index for TabView
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: activeCardIndex) { newValue in
                    if newValue < localFavoriteCards.count {
                        viewModel.activeCardIndex = newValue
                    }
                }

                // Buttons Aligned Below Cards
                buttonsAligned
            }
        }
        .background(Color("BGC").ignoresSafeArea())
        .onAppear {
            // Sync local favorite cards with the view model
            localFavoriteCards = viewModel.favoriteCards
        }
    }

    private var buttonsAligned: some View {
        HStack(spacing: 65) {
            if !localFavoriteCards.isEmpty {
                // Favorite Button
                ZStack {
                    Circle()
                        .fill(Color("white"))
                        .frame(width: 50, height: 50)
                    Image(systemName: localFavoriteCards[activeCardIndex].isStarFilled ? "star.fill" : "star")
                        .foregroundColor(Color("P3"))
                        .font(.system(size: 30))
                }
                .onTapGesture {
                    let card = localFavoriteCards[activeCardIndex]
                    viewModel.toggleFavorite(for: card)
                    localFavoriteCards = viewModel.favoriteCards // Sync local favorites
                }

                // Voice Recognition Button
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

                // Speak Text Button
                ZStack {
                    Circle()
                        .fill(Color("white"))
                        .frame(width: 50, height: 50)
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(Color("P3"))
                        .font(.system(size: 30))
                }
                .onTapGesture {
                    viewModel.speakText(for: localFavoriteCards[activeCardIndex])
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview
struct Favorite_Previews: PreviewProvider {
    static var previews: some View {
        let previewVM = CustomCardsViewModel()
        previewVM.toggleFavorite(for: previewVM.cards[0]) // Add a favorite for preview
        previewVM.toggleFavorite(for: previewVM.cards[1]) // Add another favorite
        return Favorite(viewModel: previewVM)
            .previewDisplayName("Favorite Preview")
    }
}
