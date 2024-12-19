//
//  ContentView.swift
//  NATIQ
//
//  Created by Walaa on 19/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
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
                            .padding(.vertical, 20)
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
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(false)  // Make sure the navigation bar is visible
        }
    }
}

struct CardView: View {
    var index: Int
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors()), startPoint: .top, endPoint: .bottom)
                .cornerRadius(15)
            
            // جعل العنوان في أقصى اليمين داخل الكارد
            Text(cardTitle())
                .font(.title)
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(.top, 10)  // تعديل المسافة العلوية للعنوان داخل الكارد
                .padding(.trailing, 15)  // إضافة مسافة من اليمين
            
            // إضافة الصورة
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

