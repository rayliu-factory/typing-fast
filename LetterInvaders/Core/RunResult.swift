import Foundation

enum RunRules: String, Codable {
    case endless, firstContact

    static let firstContactWords = ["sun", "cat", "run", "red", "map", "top", "win", "joy"]
    var wordGoal: Int? { self == .firstContact ? 8 : nil }
    var maxTargets: Int { self == .firstContact ? 1 : 7 }
    var immediateHints: Bool { self == .firstContact }
    var title: String { self == .firstContact ? "First Contact" : "Endless Defense" }
}

enum InputSource: String, Codable { case touch, hardware }

enum RunOutcome: String, Codable { case completed, lost }

/// Versioned arcade metrics. These are not a standard typing assessment.
struct RunResult: Codable, Equatable, Identifiable {
    var schemaVersion = 1
    let id: UUID
    let rules: RunRules
    let mode: TrainingMode
    let outcome: RunOutcome
    let score: Int
    let wordsCleared: Int
    let correctKeys: Int
    let totalKeys: Int
    let elapsed: Double
    let inputSources: Set<InputSource>

    var accuracy: Int {
        totalKeys == 0 ? 100 : Int((Double(correctKeys) / Double(totalKeys) * 100).rounded())
    }
    var earnedAccuracyMedal: Bool {
        rules == .firstContact && outcome == .completed && totalKeys > 0
            && Double(correctKeys) / Double(totalKeys) >= 0.9
    }
    var insight: String {
        if totalKeys == 0 { return "Follow the highlighted key. Finish one word before moving to the next." }
        if accuracy < 90 { return "Slow down slightly. Look at the next highlighted letter before tapping." }
        if outcome == .lost { return "Your taps were accurate. Start each word sooner to protect your cities." }
        return "Accurate work. Try another run with Ghost key hints off when you feel ready."
    }
}
