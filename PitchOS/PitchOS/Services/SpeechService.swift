import Foundation
@preconcurrency import Speech
@preconcurrency import AVFoundation

@MainActor
@Observable
final class SpeechService {
    var isRecording = false
    var transcript = ""
    var error: String?

    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var hasInstalledTap = false

    var isAuthorized: Bool {
        SFSpeechRecognizer.authorizationStatus() == .authorized
            && AVAudioSession.sharedInstance().recordPermission == .granted
    }

    func requestAuthorization() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        guard speechAuthorized else { return false }

        let microphoneAuthorized = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        return microphoneAuthorized
    }

    func startRecording() throws {
        guard !isRecording else { return }

        // Cancel any existing task
        stopRecording()

        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            error = "Speech recognition is not available."
            return
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        transcript = ""
        error = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.recognitionRequest = request

        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        hasInstalledTap = true

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if let error {
                    self.error = error.localizedDescription
                    self.stopRecording()
                }
                if result?.isFinal == true {
                    self.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        if hasInstalledTap {
            audioEngine?.inputNode.removeTap(onBus: 0)
            hasInstalledTap = false
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
