//taken from speech workshop

import SwiftUI
import AVFoundation
import Speech

struct Screen3: View {
    let synthesiser = AVSpeechSynthesizer()

    let audioEngine = AVAudioEngine()
    let speechRecogniser = SFSpeechRecognizer(locale: .current)
    @State var transcription = ""

    var body: some View {
        VStack {
            Button("Recognise") {
                
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
            }
            Text(transcription)
        }
        .padding()
    }
}

#Preview {
    Screen3()
}
