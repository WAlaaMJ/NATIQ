//
//  SplashScreen.swift
//  NATIQ
//
//  Created by Raghad on 01/07/1446 AH.
//

import SwiftUI

struct SplashScreen: View {
    // التحكم في الوقت (الانتظار)
    @State private var isActive = false
    
    var body: some View {
        // عند تفعيل isActive، يتم الانتقال إلى ContactView
        if isActive {
            ContentView()
        } else {
            // شاشة السلاش
            VStack {
                Image("logoNatiq") // اسم الصورة التي أضفتها في Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250) // يمكنك تعديل الأبعاد
            }
            .onAppear {
                // الانتظار 3 ثوانٍ قبل الانتقال
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
#Preview {
    SplashScreen()
}
