/*import SwiftUI
import AVFoundation

// Class-based model for audio tracking
class AudioTracker: ObservableObject {
    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 100)
    @Published var frequency: Float = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    
    init() {
        // Only setup the audio engine if we're running on a real device, not in a preview
        #if targetEnvironment(simulator)
        print("Running in the simulator, skipping audio engine setup.")
        #else
        setupAudioEngine()
        #endif
    }
    
    func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        // Get the input node for audio
        audioInputNode = audioEngine?.inputNode
        audioInputNode?.installTap(onBus: 0, bufferSize: 1024, format: audioInputNode?.outputFormat(forBus: 0)) { [weak self] (buffer, time) in
            guard let self = self else { return }
            
            // Analyze the audio data to get the amplitude
            var avgPower: Float = 0.0
            let channelData = buffer.floatChannelData?[0]
            for i in 0..<Int(buffer.frameLength) {
                avgPower += channelData?[i] ?? 0.0
            }
            avgPower /= Float(buffer.frameLength)
            
            // Append amplitude and ensure we don't exceed 100 elements
            DispatchQueue.main.async {
                self.amplitudes.append(avgPower)
                if self.amplitudes.count > 100 {
                    self.amplitudes.removeFirst()
                }
            }
            
            // Extract the frequency
            self.extractFrequency(from: buffer)
        }
        
        // Start the audio engine
        do {
            try audioEngine?.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func extractFrequency(from buffer: AVAudioPCMBuffer) {
        // Analyze frequency using FFT (Fast Fourier Transform)
        let channelData = buffer.floatChannelData?[0]
        let frameLength = Int(buffer.frameLength)
        
        // Simple frequency detection based on the largest magnitude
        var highestMagnitude: Float = 0.0
        for i in 0..<frameLength {
            let magnitude = abs(channelData?[i] ?? 0.0)
            if magnitude > highestMagnitude {
                highestMagnitude = magnitude
                // Calculate frequency from FFT
                frequency = Float(i) * Float(buffer.format.sampleRate) / Float(frameLength)
            }
        }
        
        // Update frequency in the UI
        DispatchQueue.main.async {
            self.frequency = self.frequency
        }
    }
    
    func stopAudioEngine() {
        audioEngine?.stop()
    }
}

struct Tracker: View {
    @StateObject private var audioTracker = AudioTracker()
    
    var body: some View {
        VStack {
            Spacer()
            
            // Display current frequency
            Text("Current Frequency: \(audioTracker.frequency, specifier: "%.2f") Hz")
                .font(.title)
                .padding()
            
            // Display waveform
            WaveformView(amplitudes: audioTracker.amplitudes)
                .frame(maxHeight: 200)
                .padding()
            
            Spacer()
        }
        .onDisappear {
            audioTracker.stopAudioEngine()
        }
    }
}

struct WaveformView: View {
    var amplitudes: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for (index, amplitude) in self.amplitudes.enumerated() {
                    let xPosition = CGFloat(index) / CGFloat(self.amplitudes.count) * width
                    let yPosition = CGFloat(amplitude) * height / 2
                    path.addLine(to: CGPoint(x: xPosition, y: height / 2 + yPosition))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    Tracker()
}*/

/*
import SwiftUI
import AVFoundation
import Accelerate

// Class-based model for audio tracking
class AudioTracker: ObservableObject {
    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 100)
    @Published var frequency: Float = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    
    init() {
        // Only setup the audio engine if we're running on a real device, not in a preview
        #if targetEnvironment(simulator)
        print("Running in the simulator, skipping audio engine setup.")
        #else
        // Don't initialize audio engine until needed
        #endif
    }
    
    func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        // Get the input node for audio
        audioInputNode = audioEngine?.inputNode
        audioInputNode?.installTap(onBus: 0, bufferSize: 1024, format: audioInputNode?.outputFormat(forBus: 0)) { [weak self] (buffer, time) in
            guard let self = self else { return }
            
            // Analyze the audio data to get the amplitude
            var avgPower: Float = 0.0
            let channelData = buffer.floatChannelData?[0]
            for i in 0..<Int(buffer.frameLength) {
                avgPower += channelData?[i] ?? 0.0
            }
            avgPower /= Float(buffer.frameLength)
            
            // Append amplitude and ensure we don't exceed 100 elements
            DispatchQueue.main.async {
                self.amplitudes.append(avgPower)
                if self.amplitudes.count > 100 {
                    self.amplitudes.removeFirst()
                }
            }
            
            // Extract the frequency
            self.extractFrequency(from: buffer)
        }
        
        // Start the audio engine
        do {
            try audioEngine?.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func extractFrequency(from buffer: AVAudioPCMBuffer) {
        let frameLength = Int(buffer.frameLength)
        let channelData = buffer.floatChannelData?[0]
        
        // Create arrays for real and imaginary components
        var real = [Float](repeating: 0.0, count: frameLength / 2)
        var imaginary = [Float](repeating: 0.0, count: frameLength / 2)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
        
        // Convert the audio data to DSPSplitComplex format
        vDSP_ctoz(channelData, 2, &splitComplex, 1, vDSP_Length(frameLength / 2))
        
        // Create the FFT setup
        let log2n = vDSP_Length(log2(Float(frameLength)))
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        // Perform FFT (forward transform)
        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, Int32(kFFTDirection_Forward))
        
        // Calculate the magnitudes from the real and imaginary parts
        var magnitudes = [Float](repeating: 0.0, count: frameLength / 2)
        vDSP_zvabs(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameLength / 2))
        
        // Find the index of the largest magnitude
        if let maxMagIndex = magnitudes.enumerated().max(by: { $0.element < $1.element })?.offset {
            let sampleRate = Float(buffer.format.sampleRate)
            let frequency = Float(maxMagIndex) * sampleRate / Float(frameLength)
            
            // Update frequency
            DispatchQueue.main.async {
                self.frequency = frequency
            }
        }
        
        // Cleanup the FFT setup
        vDSP_destroy_fftsetup(fftSetup)
    }
    
    func stopAudioEngine() {
        audioEngine?.stop()
        audioEngine = nil
        audioInputNode = nil
    }
}

struct Tracker: View {
    @StateObject private var audioTracker = AudioTracker()
    @State private var isRecording = false  // State to track recording status
    
    var body: some View {
        VStack {
            Spacer()
            
            // Display current frequency with dynamic font size
            Text("Current Frequency: \(audioTracker.frequency, specifier: "%.2f") Hz")
                .font(.title)
                .foregroundColor(audioTracker.frequency > 1000 ? .red : .blue)  // Color change based on frequency
                .padding()
            
            // Display waveform
            WaveformView(amplitudes: audioTracker.amplitudes)
                .frame(maxHeight: 200)
                .padding()
            
            Spacer()
            
            // Start/Stop Button
            Button(action: {
                if isRecording {
                    audioTracker.stopAudioEngine()
                } else {
                    audioTracker.setupAudioEngine()
                }
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop" : "Start")
                    .font(.title2)
                    .padding()
                    .background(isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .onDisappear {
            if isRecording {
                audioTracker.stopAudioEngine()
            }
        }
    }
}

struct WaveformView: View {
    var amplitudes: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for (index, amplitude) in self.amplitudes.enumerated() {
                    let xPosition = CGFloat(index) / CGFloat(self.amplitudes.count) * width
                    let yPosition = CGFloat(amplitude) * height / 2
                    path.addLine(to: CGPoint(x: xPosition, y: height / 2 + yPosition))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    Tracker()
}*/
