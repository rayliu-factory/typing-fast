import SwiftUI
import UIKit
import QuartzCore

struct Beam {
    let from: Double
    let x: Double
    let y: Double
    let color: Color
    var life: Double = 1
}
struct Spark {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    let color: Color
    var life: Double = 1
}

@MainActor final class GameModel: NSObject, ObservableObject {
    @Published private(set) var frame = 0
    var engine = GameEngine()
    var selectedRules: RunRules = .firstContact
    var progress: SavedProgress { progressStore.progress }
    var saveNotice: String?
    private let progressStore: ProgressStore
    private var checkpointElapsed: Double = 0
    var layer: KeyLayer = .letters
    var beams: [Beam] = []
    var sparks: [Spark] = []
    var message = ""
    var messageLife: Double = 0
    var errorKey: String?
    var intendedKey: String?
    var pressedKey: String?
    var keyFlash: Double = 0
    var damageFlash: Double = 0
    var bestScore: Int { defaults.integer(forKey: "best.\(engine.mode.rawValue)") }
    var hints: Bool { didSet { defaults.set(hints, forKey: "hints"); refresh() } }
    var sound: Bool { didSet { defaults.set(sound, forKey: "sound"); audio.enabled = sound; refresh() } }
    var haptics: Bool { didSet { defaults.set(haptics, forKey: "haptics"); refresh() } }
    private let defaults = UserDefaults.standard
    private let audio = GameAudio()
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let notificationHaptic = UINotificationFeedbackGenerator()
    private var displayLink: CADisplayLink?
    private var previousTime: CFTimeInterval = 0

    override init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LetterInvaders", isDirectory: true)
        progressStore = ProgressStore(url: directory.appendingPathComponent("progress.json"))
        defaults.register(defaults: ["hints": true, "sound": true, "haptics": true])
        hints = defaults.bool(forKey: "hints")
        sound = defaults.bool(forKey: "sound")
        haptics = defaults.bool(forKey: "haptics")
        super.init()
        audio.enabled = sound
        saveNotice = progressStore.notice
        if let checkpoint = progressStore.progress.checkpoint {
            engine = checkpoint
            selectedRules = checkpoint.rules
        }
    }

    func connect() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.preferredFramesPerSecond = 60
        link.add(to: .main, forMode: .common)
        link.isPaused = engine.phase != .playing
        displayLink = link
    }
    func disconnect() { displayLink?.invalidate(); displayLink = nil; previousTime = 0 }
    func refresh() { frame &+= 1 }

    func start() {
        engine.start(rules: selectedRules)
        checkpointElapsed = 0
        saveProgress()
        layer = .letters
        beams = []; sparks = []
        message = ""; messageLife = 0; keyFlash = 0; damageFlash = 0
        errorKey = nil; intendedKey = nil; pressedKey = nil
        previousTime = 0
        displayLink?.isPaused = false
        lightHaptic.prepare()
        refresh()
    }
    func pause() {
        engine.pause()
        saveBest()
        saveProgress()
        displayLink?.isPaused = true
        audio.stop()
        previousTime = 0
        refresh()
    }
    func resume() {
        engine.resume()
        previousTime = 0
        displayLink?.isPaused = engine.phase != .playing
        refresh()
    }
    func selectMode(_ mode: TrainingMode) {
        guard engine.phase == .ready else { return }
        engine.mode = mode
        selectedRules = .endless
        refresh()
    }
    func selectMission() {
        guard engine.phase == .ready else { return }
        selectedRules = .firstContact
        refresh()
    }
    func returnToMenu() {
        pause()
        do { try progressStore.discardRun() }
        catch { saveNotice = "Progress could not be saved. Your previous save has been kept." }
        let mode = engine.mode
        engine = GameEngine()
        engine.mode = mode
        beams = []; sparks = []; messageLife = 0
        refresh()
    }
    func key(_ key: String, hardware: Bool = false) {
        if key == "ESC" { engine.phase == .playing ? pause() : resume(); return }
        if key == "ENTER" {
            if engine.phase == .paused { resume() }
            else if engine.phase != .playing { start() }
            return
        }
        guard engine.phase == .playing else { return }
        if key == "MODE" { pause(); return }
        if key == "?123" { layer = .symbols; refresh(); return }
        if key == "ABC" { layer = .letters; refresh(); return }
        if ["SPACE", "LOCK NEXT", "⌫", "\t", " "].contains(key) {
            engine.cycleLock(); refresh(); return
        }
        let key = key.lowercased()
        if hardware {
            if KeyboardLayout.contains(key, in: .symbols) { layer = .symbols }
            else if KeyboardLayout.contains(key, in: .letters) { layer = .letters }
        }
        pressedKey = key
        keyFlash = 0.18
        engine.input(key, source: hardware ? .hardware : .touch)
        consumeEvents()
        refresh()
    }
    @objc private func tick(_ link: CADisplayLink) {
        let dt = previousTime == 0 ? 1 / 60.0 : min(link.timestamp - previousTime, 0.1)
        previousTime = link.timestamp
        engine.advance(by: dt)
        for i in beams.indices { beams[i].life -= dt * 6.5 }
        beams.removeAll { $0.life <= 0 }
        for i in sparks.indices {
            sparks[i].x += sparks[i].vx * dt
            sparks[i].y += sparks[i].vy * dt
            sparks[i].vy += 120 * dt
            sparks[i].life -= dt * 1.9
        }
        sparks.removeAll { $0.life <= 0 }
        messageLife = max(0, messageLife - dt)
        damageFlash = max(0, damageFlash - dt)
        keyFlash = max(0, keyFlash - dt)
        if keyFlash == 0 { errorKey = nil; intendedKey = nil; pressedKey = nil }
        consumeEvents()
        if engine.phase == .playing && engine.elapsed - checkpointElapsed >= 3 { saveProgress() }
        refresh()
    }
    private func consumeEvents() {
        let events = engine.events
        engine.events.removeAll(keepingCapacity: true)
        for event in events {
            switch event {
            case let .hit(target, key, combo):
                let color: Color = target.isUFO ? Palette.amber : KeyboardLayout.zone(key) == .right ? Palette.pink : Palette.cyan
                let rows = KeyboardLayout.rows(layer)
                var origin = 195.0
                if let row = rows.first(where: { $0.contains(key) }), let column = row.firstIndex(of: key) {
                    origin = (Double(column) + 0.5) / Double(row.count) * 390
                }
                beams.append(Beam(from: origin, x: target.x, y: target.y, color: color))
                burst(x: target.x, y: target.y, color: color, count: 7)
                audio.play(.hit(combo, target.isUFO))
                if haptics { lightHaptic.impactOccurred(intensity: 0.45) }
            case let .mistake(tapped, expected):
                errorKey = tapped; intendedKey = expected; keyFlash = 0.45
                message = "SHIELD JAM  ·  \(tapped.uppercased()) → \(expected.uppercased())"
                messageLife = 0.9
                audio.play(.mistake)
                if haptics { notificationHaptic.notificationOccurred(.warning) }
            case let .cleared(target, bonus, repaired):
                burst(x: target.x, y: target.y, color: target.isUFO ? Palette.amber : Palette.green, count: 24)
                message = target.isUFO ? "+\(bonus)  ·  \(repaired ? "SHIELD REPAIRED" : "UFO CLEARED")" : "+\(bonus)  ·  WORD CLEARED"
                messageLife = 1.1
                audio.play(.clear(target.isUFO))
                saveBest()
                saveProgress()
            case let .impact(dome):
                damageFlash = 0.3
                burst(x: (Double(dome) + 0.5) * 65, y: 370, color: Palette.red, count: 24)
                audio.play(.impact)
                if haptics { notificationHaptic.notificationOccurred(.error) }
                saveProgress()
            case let .wave(number):
                message = "WAVE \(number) INCOMING"; messageLife = 1.8
            case .gameOver, .victory:
                saveBest()
                saveProgress()
                displayLink?.isPaused = true
            }
        }
    }
    private func burst(x: Double, y: Double, color: Color, count: Int) {
        for _ in 0..<count {
            let angle = Double.random(in: 0...Double.pi * 2)
            let speed = Double.random(in: 25...110)
            sparks.append(Spark(x: x, y: y, vx: cos(angle) * speed, vy: sin(angle) * speed, color: color))
        }
    }
    private func saveProgress() {
        guard engine.phase != .ready else { return }
        checkpointElapsed = engine.elapsed
        do {
            try progressStore.save(engine)
            saveNotice = nil
        } catch {
            saveNotice = progressStore.notice ?? "Progress could not be saved. Keep the app open and try again from the pause screen."
        }
    }
    private func saveBest() {
        guard engine.rules == .endless else { return }
        if engine.score > bestScore { defaults.set(engine.score, forKey: "best.\(engine.mode.rawValue)") }
    }
}

enum Palette {
    static let background = Color(red: 0.025, green: 0.03, blue: 0.065)
    static let panel = Color(red: 0.045, green: 0.06, blue: 0.12)
    static let cyan = Color(red: 0.15, green: 0.91, blue: 1)
    static let pink = Color(red: 1, green: 0.24, blue: 0.62)
    static let green = Color(red: 0.2, green: 1, blue: 0.67)
    static let amber = Color(red: 1, green: 0.75, blue: 0.2)
    static let red = Color(red: 1, green: 0.23, blue: 0.35)
    static let muted = Color(red: 0.53, green: 0.6, blue: 0.72)
    static func zone(_ key: String) -> Color {
        switch KeyboardLayout.zone(key) {
        case .left: return cyan
        case .right: return pink
        case .neutral: return amber
        }
    }
}
