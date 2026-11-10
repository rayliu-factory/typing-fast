import Foundation

enum TrainingMode: String, CaseIterable, Identifiable {
    case thumb, classic, layers
    var id: String { rawValue }
    var title: String {
        switch self {
        case .thumb: return "Thumb Rhythm"
        case .classic: return "Arcade Waves"
        case .layers: return "Layer Drills"
        }
    }
    var detail: String {
        switch self {
        case .thumb: return "Find your flow with alternating left and right thumbs."
        case .classic: return "Survive waves of increasingly challenging words."
        case .layers: return "Switch between letters, numbers and symbols."
        }
    }
    var symbol: String {
        switch self {
        case .thumb: return "hand.draw"
        case .classic: return "sparkles"
        case .layers: return "number"
        }
    }
}

enum GamePhase { case ready, playing, paused, gameOver }
enum ThumbZone { case left, right, neutral }
enum KeyLayer { case letters, symbols }

enum KeyboardLayout {
    static let letters: [[String]] = [Array("qwertyuiop").map { String($0) }, Array("asdfghjkl").map { String($0) },
                          ["?123"] + Array("zxcvbnm").map { String($0) } + ["⌫"],
                          ["MODE", "SPACE", "LOCK NEXT"]]
    static let symbols: [[String]] = [Array("1234567890").map { String($0) }, Array("@#$%&-+()/").map { String($0) },
                          ["ABC"] + Array("!\"':;?.").map { String($0) } + ["⌫"],
                          ["MODE", "SPACE", "LOCK NEXT"]]
    static func zone(_ key: String) -> ThumbZone {
        guard key.count == 1 else { return .neutral }
        if "qwertasdfgzxcvb12345!@#$%".contains(key.lowercased()) { return .left }
        if "yuiophjklnm67890^&*()-/?".contains(key.lowercased()) { return .right }
        return .neutral
    }
    static func rows(_ layer: KeyLayer) -> [[String]] { layer == .letters ? letters : symbols }
    static func contains(_ key: String, in layer: KeyLayer) -> Bool { rows(layer).joined().contains(key) }
}

struct Invader: Identifiable {
    let id: Int
    let word: String
    var typed = 0
    // Positions use a fixed 390 × 400 playfield, mapped into the actual screen.
    var x: Double
    var y: Double
    var speed: Double
    var dome: Int
    var isUFO = false
    var next: String { typed < word.count ? String(Array(word)[typed]) : "" }
}

enum GameEvent {
    case hit(Invader, String, Int)
    case mistake(String, String)
    case cleared(Invader, Int, Bool)
    case impact(Int)
    case wave(Int)
    case gameOver
}

/// Deterministic simulation, independent of rendering, audio and the system clock.
/// Time advances only while playing; backgrounding and pausing cannot change WPM.
struct GameEngine {
    var phase: GamePhase = .ready
    var mode: TrainingMode = .thumb
    var targets: [Invader] = []
    var shields = Array(repeating: 3, count: 6)
    var lockedID: Int?
    var score = 0
    var wave = 1
    var combo = 1
    var maxCombo = 1
    var wordsCleared = 0
    var correctKeys = 0
    var totalKeys = 0
    var leftHits = 0
    var rightHits = 0
    var elapsed: Double = 0
    var peakWPM = 0
    var spawnTimer: Double = 1.8
    var ufoTimer: Double = 0
    var spawnInterval: Double = 2.2
    var events: [GameEvent] = []
    private var nextID = 1
    private var random: SeededRandom

    init(seed: UInt64 = UInt64.random(in: 1...UInt64.max)) { random = SeededRandom(seed: seed) }
    var accuracy: Int { totalKeys == 0 ? 100 : Int((Double(correctKeys) / Double(totalKeys) * 100).rounded()) }
    var wpm: Int { Int((Double(correctKeys) / 5 / max(elapsed / 60, 0.05)).rounded()) }
    var lowest: Invader? { targets.filter { !$0.isUFO }.max { $0.y < $1.y } }
    var locked: Invader? { targets.first { $0.id == lockedID } }
    var preview: Invader? { locked ?? lowest ?? targets.first }
    var ufo: Invader? { targets.first { $0.isUFO } }

    mutating func start() {
        let selectedMode = mode
        let generator = random
        self = GameEngine(seed: 1)
        mode = selectedMode
        random = generator
        phase = .playing
    }

    mutating func pause() { if phase == .playing { phase = .paused } }
    mutating func resume() { if phase == .paused { phase = .playing } }

    mutating func cycleLock() {
        guard phase == .playing, !targets.isEmpty else { return }
        let candidates = targets.filter(\.isUFO) + targets.filter { !$0.isUFO }
        let current = candidates.firstIndex { $0.id == lockedID } ?? -1
        lockedID = candidates[(current + 1) % candidates.count].id
    }

    func hintKey(layer: KeyLayer, enabled: Bool) -> String? {
        guard enabled, phase == .playing, let target = preview,
              target.y >= 192 || mode == .layers else { return nil }
        return KeyboardLayout.contains(target.next, in: layer) ? target.next : (layer == .letters ? "?123" : "ABC")
    }

    mutating func input(_ text: String) {
        guard phase == .playing, text.count == 1 else { return }
        let key = text.lowercased()
        // Empty-sky taps are ignored rather than silently lowering accuracy.
        guard !targets.isEmpty else { return }
        totalKeys += 1
        var index = targets.firstIndex { $0.id == lockedID }
        if index == nil {
            index = targets.firstIndex { $0.isUFO && $0.next == key }
            if index == nil {
                index = targets.indices.filter { !targets[$0].isUFO && targets[$0].next == key }
                    .max { targets[$0].y < targets[$1].y }
            }
            if let index { lockedID = targets[index].id }
        }
        if index == nil {
            index = targets.indices.filter { !targets[$0].isUFO }.max { targets[$0].y < targets[$1].y }
                ?? targets.startIndex
        }
        guard let index else { return }
        let expected = targets[index].next
        guard key == expected else {
            combo = 1
            if !targets[index].isUFO { targets[index].y = min(targets[index].y + 9, 335) }
            events.append(.mistake(key, expected))
            return
        }
        correctKeys += 1
        if KeyboardLayout.zone(key) == .left { leftHits += 1 }
        if KeyboardLayout.zone(key) == .right { rightHits += 1 }
        targets[index].typed += 1
        score += 10 * combo
        events.append(.hit(targets[index], key, combo))
        combo = min(combo + 1, 25)
        maxCombo = max(maxCombo, combo)
        peakWPM = max(peakWPM, wpm)
        if targets[index].typed == targets[index].word.count { clear(at: index) }
    }

    private mutating func clear(at index: Int) {
        let target = targets.remove(at: index)
        wordsCleared += 1
        let bonus = target.isUFO ? 250 * wave : target.word.count * 25
        score += bonus
        var repaired = false
        if target.isUFO, let damaged = shields.firstIndex(where: { $0 < 3 }) {
            shields[damaged] += 1
            repaired = true
        }
        events.append(.cleared(target, bonus, repaired))
        if wordsCleared % 8 == 0 {
            wave += 1
            spawnInterval = max(0.95, 2.3 - Double(wave) * 0.135)
            events.append(.wave(wave))
        }
        lockedID = lowest?.id ?? ufo?.id
    }

    mutating func advance(by delta: Double) {
        guard phase == .playing, delta > 0, delta.isFinite else { return }
        let dt = min(delta, 0.1)
        elapsed += dt
        spawnTimer += dt
        ufoTimer += dt
        if spawnTimer >= spawnInterval {
            spawnTimer = 0
            if targets.filter({ !$0.isUFO }).count < 7 { spawnWord() }
        }
        if ufoTimer >= 14 {
            ufoTimer = 0
            if ufo == nil { spawnUFO() }
        }
        for i in targets.indices.reversed() {
            if targets[i].isUFO {
                targets[i].x += targets[i].speed * dt
                if targets[i].x < -140 || targets[i].x > 530 { remove(at: i) }
            } else {
                targets[i].y += targets[i].speed * dt
                let destination = (Double(targets[i].dome) + 0.5) * 65
                targets[i].x += (destination - targets[i].x) * 0.35 * dt
                if targets[i].y >= 362 {
                    let dome = targets[i].dome
                    shields[dome] = max(0, shields[dome] - 1)
                    combo = 1
                    events.append(.impact(dome))
                    remove(at: i)
                    if shields.allSatisfy({ $0 == 0 }) {
                        phase = .gameOver
                        events.append(.gameOver)
                        return
                    }
                }
            }
        }
    }

    private mutating func remove(at index: Int) {
        if targets[index].id == lockedID { lockedID = nil }
        targets.remove(at: index)
    }

    private mutating func choose(_ values: [String]) -> String {
        values[Int(random.next() % UInt64(values.count))]
    }
    private mutating func spawnWord() {
        let alive = shields.indices.filter { shields[$0] > 0 }
        guard !alive.isEmpty else { return }
        let dome = alive[Int(random.next() % UInt64(alive.count))]
        let pool: [String]
        switch mode {
        case .thumb: pool = WordBanks.thumb
        case .layers: pool = random.unit() < 0.65 ? WordBanks.layers : WordBanks.thumb
        case .classic:
            pool = wave <= 2 ? WordBanks.classicShort + WordBanks.thumb.prefix(15)
                : wave <= 5 ? WordBanks.classicMedium : WordBanks.classicMedium + WordBanks.classicLong
        }
        let active = Set(targets.map(\.next))
        let unique = pool.filter { !active.contains(String($0.prefix(1))) }
        let word = choose(unique.isEmpty ? pool : unique)
        let x = max(65, min(325, (Double(dome) + 0.5) * 65 + random.unit() * 50 - 25))
        targets.append(Invader(id: nextID, word: word, x: x, y: -24,
                               speed: 28 + min(Double(wave) * 4.5, 42) + random.unit() * 10 - 5, dome: dome))
        nextID += 1
    }
    private mutating func spawnUFO() {
        let word = choose(mode == .layers ? WordBanks.layers : WordBanks.ufoBonus)
        let leftToRight = random.unit() < 0.5
        targets.append(Invader(id: nextID, word: word, x: leftToRight ? -90 : 480, y: 44,
                               speed: (68 + Double(wave) * 3) * (leftToRight ? 1 : -1), dome: 0, isUFO: true))
        nextID += 1
    }
}

private struct SeededRandom {
    var seed: UInt64
    mutating func next() -> UInt64 {
        seed &+= 0x9e3779b97f4a7c15
        var z = seed
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
    mutating func unit() -> Double { Double(next() >> 11) / Double(UInt64(1) << 53) }
}
