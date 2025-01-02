import SwiftUI

struct ContentView: View {
    // 1) Create one shared CustomCardsViewModel here.
    @StateObject private var viewModel = CustomCardsViewModel()
    
    @State private var searchText: String = ""  // الحالة التي تحتفظ بالنص المدخل في شريط البحث
    let allCards = ["الاماكن العامة", "العمل والتدريب", "المحادثات اليومية", "نطق الاحرف"]  // جميع العناوين
    
    var filteredCards: [String] {
        // تصفية الكروت بناءً على النص المدخل في شريط البحث
        if searchText.isEmpty {
            return allCards
        } else {
            return allCards.filter { $0.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // خلفية
                Color("BGC")
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Text("أهلاً كيفك اليوم 👋")
                            .font(.system(size: 30))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))
                            .padding(.trailing, 18)
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Spacer()
                        Text("تعرف على طريقة النطق ومخارج الاصوات")
                            .font(.system(size: 18))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextColor"))
                            .padding(.trailing, 18)
                    }
                    
                    // شريط البحث
                    HStack {
                        TextField("ما هو الدرس الذي تبحث عنه؟", text: $searchText) // ربط شريط البحث مع النص
                            .padding()
                            .background(Color("SearchBar"))
                            .cornerRadius(10)
                            .shadow(radius: 0.2)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                    }
                    
                    HStack {
                        Spacer()
                        Text("دروسي")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Color("TextColor"))
                            .padding(.trailing, 18)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 45) {
                            ForEach(filteredCards, id: \.self) { cardTitle in
                                if cardTitle == "الاماكن العامة" {
                                    // Example: Navigate to your existing CustomCardsPage
                        NavigationLink(destination: CustomCardsPage(viewModel: viewModel)) {
                                        CardView(cardTitle: cardTitle)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else if cardTitle == "نطق الاحرف" {
                                    // Example: Navigate to your ArabicPronunciationView
                                    NavigationLink(destination: ArabicPronunciationView()) {
                                        CardView(cardTitle: cardTitle)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    CardView(cardTitle: cardTitle)
                                        .frame(width: 260, height: 330)
                                        .padding(.leading, 15)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 10)
                        .edgesIgnoringSafeArea(.horizontal)
                    }
                }
                
                // أيقونة النجمة في الزاوية العلوية اليسرى
                VStack {
                    HStack {
                        // 2) Make the star a NavigationLink to Favorite, passing the SAME viewModel
                        NavigationLink(
                            destination: Favorite(viewModel: viewModel)
                        ) {
                            Image(systemName: "star.fill")
                                .resizable()
                                .foregroundColor(.yellow)
                                .frame(width: 32, height: 30)
                                .padding(.leading, 25)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                
                // الزر الذي ينقلك إلى TrackerView في الأسفل
                VStack {
                    Spacer()
                    NavigationLink(destination: Tracker()) {
                        Image("Icon1")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .scaledToFit()
                            .padding()
                            .background(Color("P3"))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 1)
                }
            }
            .navigationBarHidden(false)
        }
    }
}

// MARK: - CardView (Unchanged)
struct CardView: View {
    var cardTitle: String
    
    var body: some View {
        ZStack {
            // الخلفية المتدرجة
            LinearGradient(gradient: Gradient(colors: gradientColors()), startPoint: .top, endPoint: .bottom)
                .cornerRadius(15)
            
            // العنوان على الكارد
            VStack {
                Spacer()
                Text(cardTitle)
                    .font(.title)
                    .foregroundColor(Color("TextColor"))
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(.bottom, 249)
                    .padding(.trailing, 15)
            }
            
            // الصورة داخل الكارد
            Image(imageName())
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth(), height: imageHeight())
                .offset(x: imageOffsetX(), y: imageOffsetY())
        }
        .frame(width: 260, height: 330)
    }
    
    func gradientColors() -> [Color] {
        switch cardTitle {
        case "الاماكن العامة":
            return [Color("P1"), Color("P2")]
        case "العمل والتدريب":
            return [Color("G1"), Color("G2")]
        case "المحادثات اليومية":
            return [Color("Y1"), Color("Y2")]
        case "نطق الاحرف":
            return [Color("B1"), Color("B2")]
        default:
            return [Color.gray, Color.gray]
        }
    }
    
    func imageName() -> String {
        switch cardTitle {
        case "الاماكن العامة":
            return "Image3"
        case "العمل والتدريب":
            return "Image4"
        case "المحادثات اليومية":
            return "Image2"
        case "نطق الاحرف":
            return "Image1"
        default:
            return "image1"
        }
    }
    
    func imageWidth() -> CGFloat {
        switch cardTitle {
        case "الاماكن العامة":
            return 250
        case "العمل والتدريب":
            return 260
        case "المحادثات اليومية":
            return 240
        case "نطق الاحرف":
            return 230
        default:
            return 200
        }
    }
    
    func imageHeight() -> CGFloat {
        switch cardTitle {
        case "الاماكن العامة":
            return 200
        case "العمل والتدريب":
            return 200
        case "المحادثات اليومية":
            return 230
        case "نطق الاحرف":
            return 210
        default:
            return 180
        }
    }
    
    func imageOffsetX() -> CGFloat {
        switch cardTitle {
        case "الاماكن العامة":
            return -80
        case "العمل والتدريب":
            return -75
        case "المحادثات اليومية":
            return -100
        case "نطق الاحرف":
            return -100
        default:
            return 0
        }
    }
    
    func imageOffsetY() -> CGFloat {
        switch cardTitle {
        case "الاماكن العامة":
            return 75
        case "العمل والتدريب":
            return 90
        case "المحادثات اليومية":
            return 85
        case "نطق الاحرف":
            return 60
        default:
            return -50
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
