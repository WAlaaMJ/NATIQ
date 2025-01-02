import SwiftUI

struct Favorite: View {
    @ObservedObject var viewModel: CustomCardsViewModel
    @State private var searchText: String = ""
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
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
            
            // Search Bar
            TextField("ما هو الدرس الذي تبحث عنه؟", text: $searchText)
                .padding()
                .background(Color("SearchBar"))
                .cornerRadius(10)
                .shadow(radius: 0.2)
                .padding(.horizontal, 18)
                .padding(.top, 53)
            
            // Horizontal Scroll of Favorite Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(filteredFavoriteCards(), id: \.id) { card in
                        CustomCardView(
                            card: card,
                            pronunciationResult: card.pronunciationResult,
                            showResult: card.showResult,
                            isActive: false // Card title remains gray
                        )
                        .frame(width: 300, height: 420)
                    }
                }
                // 1) Force the HStack to expand and center its contents horizontally
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            // 2) If you also want the entire scroll area centered vertically, you can do:
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .background(Color("BGC").ignoresSafeArea())
    }
    
    /// Filters the favorite cards based on the search text
    private func filteredFavoriteCards() -> [CustomCard] {
        if searchText.isEmpty {
            return viewModel.favoriteCards
        } else {
            return viewModel.favoriteCards.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Preview
struct Favorite_Previews: PreviewProvider {
    static var previews: some View {
        let previewVM = CustomCardsViewModel()
        previewVM.toggleFavorite(for: previewVM.cards[0])
        return Favorite(viewModel: previewVM)
            .previewDisplayName("Favorite Preview")
    }
}
