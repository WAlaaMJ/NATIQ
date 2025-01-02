/*
 import SwiftUI

struct ContentView: View {
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
                    
                    HStack {
                        
                        TextField("ما هو الدرس الذي تبحث عنه؟", text: .constant(""))
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
                            ForEach(0..<4) { index in
                                if index == 0 {
                                    // First card navigation
                                    NavigationLink(destination: CustomCardsPage()) {
                                        CardView(index: index)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else if index == 3 {
                                    // Last card navigation to ArabicPronunciationView
                                    NavigationLink(destination: ArabicPronunciationView()) {
                                        CardView(index: index)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // Other cards
                                    CardView(index: index)
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
                
                // Yellow star from SF Symbols in the top-left corner
                VStack {
                    HStack {
                        Image(systemName: "star.fill")  // SF Symbol for a filled star
                            .resizable()
                            .foregroundColor(.yellow)  // Set the color to yellow
                            .frame(width: 32, height: 30) // Adjust the size
                            .padding(.leading, 25) // Adjust padding to position the star
                            .padding(.top, 0) // Adjust padding for top margin
                        Spacer()
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        // Action for the button
                    }) {
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
            .navigationBarHidden(false)  // Ensure the navigation bar is visible
        }
    }
}

// Card View with Left Arrow (Chevron) in Top-Left Corner (relative to the card itself)
struct CardView: View {
    var index: Int
    
    var body: some View {
        ZStack {
            // الخلفية المتدرجة للكارد
            LinearGradient(gradient: Gradient(colors: gradientColors()), startPoint: .top, endPoint: .bottom)
                .cornerRadius(15)
            
            // السهم في الزاوية العلوية اليسرى من الكارد
            VStack {
               /* HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 12, height:20)
                        .foregroundColor(.white)
                        .padding(8)
                        
                    Spacer()
                }*/
                Spacer()
                Text(cardTitle())
                    .font(.title)
                    .foregroundColor(Color("TextColor2"))
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(.bottom, 249)
                    .padding(.trailing, 15)
            }
            
            // نص العنوان داخل الكارد
           /* Text(cardTitle())
                .font(.title)
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, 10)
                .padding(.trailing, 15) */
            
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
        switch index {
        case 0:
            return [Color("P1"), Color("P2")]
        case 1:
            return [Color("G1"), Color("G2")]
        case 2:
            return [Color("Y1"), Color("Y2")]
        case 3:
            return [Color("B1"), Color("B2")]
        default:
            return [Color.gray, Color.gray]
        }
    }
    
    func cardTitle() -> String {
        switch index {
        case 0:
            return "الاماكن العامة"
        case 1:
            return "العمل والتدريب"
        case 2:
            return "المحادثات اليومية"
        case 3:
            return "نطق الاحرف"
        default:
            return "عنوان غير معروف"
        }
    }
    
    func imageName() -> String {
        switch index {
        case 0:
            return "Image3"
        case 1:
            return "Image4"
        case 2:
            return "Image2"
        case 3:
            return "Image1"
        default:
            return "image1"
        }
    }
    
    func imageWidth() -> CGFloat {
        switch index {
        case 0:
            return 250
        case 1:
            return 260
        case 2:
            return 240
        case 3:
            return 230
        default:
            return 200
        }
    }
    
    func imageHeight() -> CGFloat {
        switch index {
        case 0:
            return 200
        case 1:
            return 200
        case 2:
            return 230
        case 3:
            return 210
        default:
            return 180
        }
    }
    
    func imageOffsetX() -> CGFloat {
        switch index {
        case 0:
            return -80
        case 1:
            return -75
        case 2:
            return -100
        case 3:
            return -100
        default:
            return 0
        }
    }
    
    func imageOffsetY() -> CGFloat {
        switch index {
        case 0:
            return 75
        case 1:
            return 90
        case 2:
            return 85
        case 3:
            return 60
        default:
            return -50
        }
    }
}

#Preview {
    ContentView()
}

*/

/*
import SwiftUI

struct ContentView: View {
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
                    
                    HStack {
                        TextField("ما هو الدرس الذي تبحث عنه؟", text: .constant(""))
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
                            ForEach(0..<4) { index in
                                if index == 0 {
                                    // First card navigation
                                    NavigationLink(destination: CustomCardsPage()) {
                                        CardView(index: index)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else if index == 3 {
                                    // Last card navigation to ArabicPronunciationView
                                    NavigationLink(destination: ArabicPronunciationView()) {
                                        CardView(index: index)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // Other cards
                                    CardView(index: index)
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
                
                // Yellow star from SF Symbols in the top-left corner
                VStack {
                    HStack {
                        Image(systemName: "star.fill")  // SF Symbol for a filled star
                            .resizable()
                            .foregroundColor(.yellow)  // Set the color to yellow
                            .frame(width: 32, height: 30) // Adjust the size
                            .padding(.leading, 25) // Adjust padding to position the star
                            .padding(.top, 0) // Adjust padding for top margin
                        Spacer()
                    }
                    Spacer()
                }
                
                // Navigate to TrackerView when the button is clicked
                VStack {
                    Spacer()
                    NavigationLink(destination: Tracker()) {  // NavigationLink to TrackerView
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
            .navigationBarHidden(false)  // Ensure the navigation bar is visible
        }
    }
}

// Tracker View (The destination you want to navigate to)


struct CardView: View {
    var index: Int
    
    var body: some View {
        ZStack {
            // الخلفية المتدرجة للكارد
            LinearGradient(gradient: Gradient(colors: gradientColors()), startPoint: .top, endPoint: .bottom)
                .cornerRadius(15)
            
            // السهم في الزاوية العلوية اليسرى من الكارد
            VStack {
                Spacer()
                Text(cardTitle())
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
        switch index {
        case 0:
            return [Color("P1"), Color("P2")]
        case 1:
            return [Color("G1"), Color("G2")]
        case 2:
            return [Color("Y1"), Color("Y2")]
        case 3:
            return [Color("B1"), Color("B2")]
        default:
            return [Color.gray, Color.gray]
        }
    }
    
    func cardTitle() -> String {
        switch index {
        case 0:
            return "الاماكن العامة"
        case 1:
            return "العمل والتدريب"
        case 2:
            return "المحادثات اليومية"
        case 3:
            return "نطق الاحرف"
        default:
            return "عنوان غير معروف"
        }
    }
    
    func imageName() -> String {
        switch index {
        case 0:
            return "Image3"
        case 1:
            return "Image4"
        case 2:
            return "Image2"
        case 3:
            return "Image1"
        default:
            return "image1"
        }
    }
    
    func imageWidth() -> CGFloat {
        switch index {
        case 0:
            return 250
        case 1:
            return 260
        case 2:
            return 240
        case 3:
            return 230
        default:
            return 200
        }
    }
    
    func imageHeight() -> CGFloat {
        switch index {
        case 0:
            return 200
        case 1:
            return 200
        case 2:
            return 230
        case 3:
            return 210
        default:
            return 180
        }
    }
    
    func imageOffsetX() -> CGFloat {
        switch index {
        case 0:
            return -80
        case 1:
            return -75
        case 2:
            return -100
        case 3:
            return -100
        default:
            return 0
        }
    }
    
    func imageOffsetY() -> CGFloat {
        switch index {
        case 0:
            return 75
        case 1:
            return 90
        case 2:
            return 85
        case 3:
            return 60
        default:
            return -50
        }
    }
}

#Preview {
    ContentView()
}

*/


import SwiftUI

struct ContentView: View {
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
                                    NavigationLink(destination: CustomCardsPage()) {
                                        CardView(cardTitle: cardTitle)
                                            .frame(width: 260, height: 330)
                                            .padding(.leading, 15)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else if cardTitle == "نطق الاحرف" {
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
                        Circle()
                            .fill(Color("white"))
                            .frame(width:10 , height: 10)
                        Image(systemName: "star.fill")
                            .foregroundColor(Color("P3"))
                            .font(.system(size: 30))

                        Spacer()
                    }
                    Spacer()
                }
                
                // الزر الذي ينقلك إلى TrackerView
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

#Preview {
    ContentView()
}

