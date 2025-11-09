//taken from speech workshop

import SwiftUI
import AVFoundation
import Speech

struct Screen3: View {
    let synthesiser = AVSpeechSynthesizer()

    let audioEngine = AVAudioEngine()
    let speechRecogniser = SFSpeechRecognizer(locale: .current)
    @State var transcription = ""
    @State var isRecording = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    isRecording.toggle()
                } label: {
                    RecordButtonView(isRecording: $isRecording)
                }
                Text(transcription)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Label("Back", systemImage: "chevron.backward")
                    }
                }
            }
            .onChange(of: isRecording) { recording in
                if recording {
                    SFSpeechRecognizer.requestAuthorization { status in
                        guard status == .authorized else { return }
                    }

                    Task {
                        let micGranted = await AVAudioApplication.requestRecordPermission()
                        guard micGranted else { return }
                    }

                    guard let recogniser = speechRecogniser, recogniser.isAvailable else { return }

                    let audioSession = AVAudioSession.sharedInstance()
                    try? audioSession.setCategory(.record, mode: .measurement)
                    try? audioSession.setActive(true)

                    let request = SFSpeechAudioBufferRecognitionRequest()
                    request.shouldReportPartialResults = true

                    let inputNode = audioEngine.inputNode
                    let format = inputNode.outputFormat(forBus: 0)

                    inputNode.removeTap(onBus: 0)
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                        request.append(buffer)
                    }
                    audioEngine.prepare()
                    try? audioEngine.start()

                    recogniser.recognitionTask(with: request) { result, _ in
                        if let result {
                            transcription = result.bestTranscription.formattedString
                        }
                    }
                } else {
                    
                    audioEngine.stop()
                    audioEngine.inputNode.removeTap(onBus: 0)
                   
                }
            }
        }
    }
}

#Preview {
    Screen3()
}

struct RecordButtonView: View {
    
    @Binding var isRecording: Bool
    @State private var buttonCircle: CGFloat = 60
    @State private var buttonSquare: CGFloat = 30
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 5)
                    .frame(width: 75, height: 75)
                
                RoundedRectangle(cornerRadius: isRecording ? 5 : 50)
                    .foregroundStyle(.red)
                    .frame(
                        maxWidth: isRecording ? buttonSquare : buttonCircle,
                        maxHeight: isRecording ? buttonSquare : buttonCircle)
            }
        }
        .padding(.vertical, 20)
        .animation(.snappy, value: isRecording)
    }
}

#Preview {
    RecordButtonView(isRecording: .constant(false))
}
