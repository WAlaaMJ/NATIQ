import SwiftUI
import AVFoundation

struct Tracker: View {
    @StateObject private var audioManager = AudioManager()  // AudioManager instance for noise feedback
    @Environment(\.dismiss) var dismiss
    
    @State private var feedbackMessage = ""
    @State private var backgroundColor: Color = Color("BGC")
    
    var body: some View {
        NavigationStack {
            VStack {
                // العنوان والرجوع
                HStack {
                   
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 100)
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Frequency animation (shorter bars based on decibel levels)
                HStack(spacing: 4) {
                    ForEach(0..<10) { index in
                        let barHeight = CGFloat(max(min(audioManager.decibelLevel + 100, 100), 0)) / 100 * 100 // Scale height to 100
                        RoundedRectangle(cornerRadius: 3)
                            .fill(audioManager.decibelLevel > -10 ? Color.red : (audioManager.decibelLevel > -30 ? Color.green : Color.gray))
                            .frame(width: 10, height: audioManager.isMonitoring ? barHeight : 5) // Stop animation when not monitoring
                            .animation(
                                audioManager.isMonitoring
                                    ? .easeInOut(duration: 0.1 + Double(index) * 0.05)
                                    : .default, // No animation when not monitoring
                                value: barHeight
                            )
                    }
                }
                .frame(height: 100) // Adjust overall frame height
                .padding(.vertical, 20)

                // Feedback message
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 20)

                Spacer()

                // زر المايك في الأسفل
                VStack {
                    Button(action: {
                        if audioManager.isMonitoring {
                            audioManager.stopMonitoring()
                            feedbackMessage = ""
                            backgroundColor = Color("BGC")
                        } else {
                            audioManager.startMonitoring()
                        }
                    }) {
                        Image(systemName: audioManager.isMonitoring ? "mic.fill" : "mic")
                            .font(.system(size: 80))
                            .foregroundColor(Color("P3"))
                            .padding()
                    }
                    
                    Text(audioManager.isMonitoring ? "تسجيل جاري..." : "اضغط للتسجيل")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
                .padding(.bottom, 50) // وضع زر المايك في الأسفل
            }
            .navigationBarBackButtonHidden(true)
            .onReceive(audioManager.$decibelLevel) { decibelLevel in
                // Update the feedback message based on decibel level
                if decibelLevel > -10 {
                    feedbackMessage = "الصوت مرتفع جدًا 🚨"
                    backgroundColor = .red
                } else if decibelLevel > -30 {
                    feedbackMessage = "الصوت جيد 🎙"
                    backgroundColor = Color("BGC")
                } else {
                    feedbackMessage = "الصوت منخفض جدًا 📉"
                    backgroundColor = Color("BGC") // Use natural color for low voice level
                }
            }
            .background(backgroundColor)  // Change background color based on voice level
        }
    }
}

class AudioManager: ObservableObject {
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    @Published var decibelLevel: Float = -100
    var isMonitoring = false
    
    func startMonitoring() {
        isMonitoring = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            let rms = self.calculateRMS(from: buffer)
            let avgPower = rms > 0 ? 20 * log10(rms) : -100
            DispatchQueue.main.async {
                self.decibelLevel = avgPower
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        decibelLevel = -100
    }
    
    private func calculateRMS(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        return rms
    }
}

#Preview {
    Tracker()
}
