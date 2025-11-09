//
//  5.swift
//  lyiglyuvgylu
//
//  Created by Chan Yap Long on 5/11/25.
//

import SwiftUI
import AVFoundation

struct Screen5: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var progressTimer: Timer?
    @State private var isScrubbing = false

    // Gauge progress (0.0 ... 1.0). Replace with your real metric when available
    @State private var gaugeProgress: Double = 0.67

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let player = audioPlayer, !isScrubbing else { return }
            currentTime = player.currentTime
            if !player.isPlaying || currentTime >= duration {
                progressTimer?.invalidate()
                progressTimer = nil
            }
        }
    }

    func playSound(sound: String, type: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: type) else {
            print("Audio file not found:", sound, ".", type)
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            startProgressTimer()
        } catch {
            print("AVAudioPlayer init error:", error)
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                // Gauge from Screen 4
                SemiCircleGauge(progress: gaugeProgress)
                    .frame(height: 160)
                    .padding(.horizontal)
                    .padding(.top, 8)
                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: {
                            duration > 0 ? currentTime : 0
                        },
                        set: { newValue in
                            currentTime = min(max(0, newValue), duration)
                        }
                    ), in: 0...max(duration, 0.001), onEditingChanged: { editing in
                        isScrubbing = editing
                        if !editing, let player = audioPlayer {
                            player.currentTime = currentTime
                            if !player.isPlaying {
                                player.play()
                            }
                            startProgressTimer()
                        }
                    })
                    .padding(.horizontal)
                    .padding(.horizontal)
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption)
                    .monospacedDigit()
                }
                HStack(spacing: 24) {
                    Button {
                        let newTime = max(0, currentTime - 15)
                        currentTime = newTime
                        if let player = audioPlayer {
                            player.currentTime = newTime
                        }
                    } label: {
                        Label("", systemImage: "gobackward.15")
                    }
                    Button {
                        // Ensure audio session is ready
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                            try AVAudioSession.sharedInstance().setActive(true)
                        } catch {
                            print("Audio session setup failed:", error)
                        }

                        if let player = audioPlayer {
                            if player.isPlaying {
                                player.pause()
                                progressTimer?.invalidate()
                                progressTimer = nil
                            } else {
                                // Resume from currentTime
                                player.currentTime = currentTime
                                player.play()
                                startProgressTimer()
                            }
                        } else {
                            // No player yet: start playback
                            currentTime = 0
                            playSound(sound: "cooked-dog-meme", type: "mp3")
                        }
                    } label: {
                        let isPlaying = audioPlayer?.isPlaying == true
                        Label(isPlaying ? "" : "", systemImage: isPlaying ? "pause.fill" : "play.fill")
                            .font(.headline)
                    }
                    Button {
                        let newTime = min(duration, currentTime + 15)
                        currentTime = newTime
                        if let player = audioPlayer {
                            player.currentTime = newTime
                        }
                    } label: {
                        Label("", systemImage: "goforward.15")
                    }
                }
            }.navigationTitle(Text("Review"))
             .onDisappear {
                 progressTimer?.invalidate()
                 progressTimer = nil
             }
             .padding()
        }
    }
    private func formatTime(_ t: TimeInterval) -> String {
        guard t.isFinite && !t.isNaN else { return "0:00" }
        let total = Int(t.rounded())
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension Screen5 {
    struct SemiCircleGauge: View {
        // progress expected 0.0 ... 1.0
        var progress: Double
        var lineWidth: CGFloat = 16
        
        var body: some View {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let radius = size / 2
                ZStack {
                    // Background arc (gray)
                    Arc(startAngle: .degrees(180), endAngle: .degrees(360))
                        .stroke(Color.gray.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    // Progress arc (blue)
                    Arc(startAngle: .degrees(180), endAngle: .degrees(180 + 180 * progress))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .animation(.easeInOut(duration: 0.4), value: progress)
                    // Optional percentage label
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                        .offset(y: size * 0.15)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    // A simple arc shape that draws from startAngle to endAngle with center at bottom of the view to make a semicircle
    struct Arc: Shape {
        var startAngle: Angle
        var endAngle: Angle
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height
            let center = CGPoint(x: rect.midX, y: rect.maxY)
            let radius = min(width, height)
            path.addArc(center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
            return path
        }
    }
}

#Preview {
    Screen5()
}
