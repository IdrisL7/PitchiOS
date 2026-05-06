import Foundation
@preconcurrency import Speech
@preconcurrency import AVFoundation

enum SpeechServiceError: LocalizedError {
    case speechUnavailable
    case microphoneDenied
    case recorderDidNotStart

    var errorDescription: String? {
        switch self {
        case .speechUnavailable:
            "Speech recognition is not available right now."
        case .microphoneDenied:
            "Microphone access is required for voice-to-text."
        case .recorderDidNotStart:
            "Voice input could not start."
        }
    }
}

@MainActor
@Observable
final class SpeechService {
    var isRecording = false
    var transcript = ""
    var error: String?

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var recognitionTask: SFSpeechRecognitionTask?

    var isAuthorized: Bool {
        SFSpeechRecognizer.authorizationStatus() == .authorized
            && AVAudioApplication.shared.recordPermission == .granted
    }

    func requestAuthorization() async -> Bool {
        let speechAuthorized = await Self.requestSpeechAuthorization()

        guard speechAuthorized else { return false }

        return await Self.requestMicrophoneAuthorization()
    }

    nonisolated private static func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    nonisolated private static func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording() throws {
        guard !isRecording else { return }

        cleanupRecordingSession(removeFile: true)

        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            error = "Speech recognition is not available."
            throw SpeechServiceError.speechUnavailable
        }

        do {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")
            try configureAudioSession()

            let recorder = try AVAudioRecorder(url: url, settings: recordingSettings)
            recorder.prepareToRecord()
            guard recorder.record() else {
                throw SpeechServiceError.recorderDidNotStart
            }

            audioRecorder = recorder
            recordingURL = url
            transcript = ""
            error = nil
            isRecording = true
        } catch {
            cleanupRecordingSession(removeFile: true)
            self.error = "Voice input could not start. Please type your notes instead."
            throw error
        }
    }

    private var recordingSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    private func configureAudioSession() throws {
        guard AVAudioApplication.shared.recordPermission == .granted else {
            throw SpeechServiceError.microphoneDenied
        }

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .spokenAudio,
                options: [.duckOthers, .defaultToSpeaker, .allowBluetoothHFP]
            )
            try audioSession.setActive(true)
        } catch {
            try audioSession.setCategory(.record, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true)
        }
    }

    func stopRecording() async {
        guard isRecording || audioRecorder != nil else { return }

        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        guard let url = recordingURL else { return }
        await transcribeRecording(at: url)
        cleanupRecordingSession(removeFile: true)
    }

    func cancelRecording() {
        cleanupRecordingSession(removeFile: true)
    }

    private func transcribeRecording(at url: URL) async {
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            error = "Speech recognition is not available."
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        request.addsPunctuation = true

        await withCheckedContinuation { continuation in
            var didResume = false
            recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, recognitionError in
                let shouldFinish = result?.isFinal == true || recognitionError != nil
                guard shouldFinish else { return }

                Task { @MainActor in
                    guard !didResume else { return }
                    didResume = true

                    if let result {
                        self?.transcript = result.bestTranscription.formattedString
                    }
                    if let recognitionError {
                        self?.error = recognitionError.localizedDescription
                    }

                    continuation.resume()
                }
            }
        }
    }

    private func cleanupRecordingSession(removeFile: Bool) {
        audioRecorder?.stop()
        recognitionTask?.cancel()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        if removeFile, let recordingURL {
            try? FileManager.default.removeItem(at: recordingURL)
        }

        audioRecorder = nil
        recordingURL = nil
        recognitionTask = nil
        isRecording = false
    }
}
