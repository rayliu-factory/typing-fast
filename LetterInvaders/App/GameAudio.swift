import AVFoundation

/// Locally synthesized PCM effects: no network, audio files, or microphone permission.
@MainActor final class GameAudio {
    enum Effect {
        case hit(Int, Bool), mistake, clear(Bool), impact
    }
    var enabled = true { didSet { if !enabled { stop() } } }
    private var players: [AVAudioPlayer] = []
    private var cache: [String: Data] = [:]

    init() {
        // Ambient respects the silent switch and lets the player's music continue.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
    }
    func stop() { players.forEach { $0.stop() }; players.removeAll() }
    func play(_ effect: Effect) {
        guard enabled else { return }
        let key: String
        let notes: [Double]
        let duration: Double
        let sweep: Double
        switch effect {
        case let .hit(combo, ufo):
            key = "hit-\(combo)-\(ufo)"; notes = [ufo ? 580 : 320 + Double(min(combo * 18, 420))]; duration = 0.095; sweep = 1.65
        case .mistake: key = "jam"; notes = [150]; duration = 0.19; sweep = 0.63
        case let .clear(ufo):
            key = "clear-\(ufo)"; notes = ufo ? [523.25, 659.25, 783.99, 1046.5] : [440, 554.37, 659.25]; duration = 0.32; sweep = 1
        case .impact: key = "impact"; notes = [110]; duration = 0.37; sweep = 0.35
        }
        if cache[key] == nil { cache[key] = makeWave(notes: notes, duration: duration, sweep: sweep) }
        guard let data = cache[key], let player = try? AVAudioPlayer(data: data) else { return }
        players.removeAll { !$0.isPlaying }
        if players.count >= 12 { players.removeFirst().stop() }
        player.volume = 0.32
        players.append(player)
        player.play()
    }
    private func makeWave(notes: [Double], duration: Double, sweep: Double) -> Data {
        let rate = 22050
        let count = Int(duration * Double(rate))
        var pcm = Data(capacity: count * 2)
        for i in 0..<count {
            let time = Double(i) / Double(rate)
            var sample = 0.0
            for (n, note) in notes.enumerated() {
                let t = time - Double(n) * 0.045
                guard t >= 0 else { continue }
                let phase = 2 * Double.pi * note * (t + (sweep - 1) * t * t / (2 * duration))
                let envelope = min(1, t * 900) * exp(-t / duration * 6)
                sample += (sin(phase) + 0.18 * sin(phase * 3)) * envelope / Double(notes.count)
            }
            var value = Int16(max(-1, min(1, sample)) * 24000).littleEndian
            withUnsafeBytes(of: &value) { pcm.append(contentsOf: $0) }
        }
        var result = Data()
        func string(_ text: String) { result.append(contentsOf: text.utf8) }
        func uint32(_ number: UInt32) { var n = number.littleEndian; withUnsafeBytes(of: &n) { result.append(contentsOf: $0) } }
        func uint16(_ number: UInt16) { var n = number.littleEndian; withUnsafeBytes(of: &n) { result.append(contentsOf: $0) } }
        string("RIFF"); uint32(UInt32(36 + pcm.count)); string("WAVEfmt "); uint32(16)
        uint16(1); uint16(1); uint32(UInt32(rate)); uint32(UInt32(rate * 2)); uint16(2); uint16(16)
        string("data"); uint32(UInt32(pcm.count)); result.append(pcm)
        return result
    }
}
