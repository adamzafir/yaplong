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
            progressTimer?.invalidate()
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                guard let player = audioPlayer, !isScrubbing else { return }
                currentTime = player.currentTime
                if !player.isPlaying || currentTime >= duration {
                    progressTimer?.invalidate()
                    progressTimer = nil
                }
            }
        } catch {
            print("AVAudioPlayer init error:", error)
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
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
                        Label("Back 15s", systemImage: "gobackward.15")
                    }

                    Button {
                        let newTime = min(duration, currentTime + 15)
                        currentTime = newTime
                        if let player = audioPlayer {
                            player.currentTime = newTime
                        }
                    } label: {
                        Label("Forward 15s", systemImage: "goforward.15")
                    }
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
                        } else {
                            // Resume from currentTime
                            player.currentTime = currentTime
                            player.play()
                        }
                    } else {
                        // No player yet: start playback
                        currentTime = 0
                        playSound(sound: "cooked-dog-meme", type: "mp3")
                    }
                } label: {
                    let isPlaying = audioPlayer?.isPlaying == true
                    Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .font(.headline)
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

#Preview {
    Screen5()
}

