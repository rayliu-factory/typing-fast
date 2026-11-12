import Foundation

struct SavedProgress: Codable {
    var schemaVersion = 1
    var firstContactCompleted = false
    var firstContactAccuracyMedal = false
    var lastResult: RunResult?
    var checkpoint: GameEngine?
    var recoveredDamagedRun = false

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, firstContactCompleted, firstContactAccuracyMedal, lastResult, checkpoint
    }
    init() {}
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try data.decode(Int.self, forKey: .schemaVersion)
        firstContactCompleted = try data.decode(Bool.self, forKey: .firstContactCompleted)
        firstContactAccuracyMedal = try data.decode(Bool.self, forKey: .firstContactAccuracyMedal)
        lastResult = try? data.decode(RunResult.self, forKey: .lastResult)
        if data.contains(.checkpoint), try !data.decodeNil(forKey: .checkpoint) {
            checkpoint = try? data.decode(GameEngine.self, forKey: .checkpoint)
            if checkpoint?.isResumable != true { checkpoint = nil; recoveredDamagedRun = true }
            checkpoint?.pause()
        }
    }
}

/// One atomic local file owns mission rewards and the current solo checkpoint.
/// Preferences and existing endless high scores remain in UserDefaults.
final class ProgressStore {
    private struct SaveHeader: Decodable { let schemaVersion: Int }
    private enum SaveError: Error { case unsupportedVersion }
    private let url: URL
    private var canWrite = true
    private(set) var progress: SavedProgress
    private(set) var notice: String?

    init(url: URL) {
        self.url = url
        progress = SavedProgress()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let header = try JSONDecoder().decode(SaveHeader.self, from: data)
            guard header.schemaVersion == 1 else {
                canWrite = false
                notice = "This save needs a different app version. Your existing save is protected; new progress cannot be saved."
                return
            }
            progress = try JSONDecoder().decode(SavedProgress.self, from: data)
            if progress.recoveredDamagedRun {
                notice = "The interrupted run could not be restored. Your mission progress is safe."
            }
        } catch {
            notice = "The local save could not be read. You can start a fresh run."
        }
    }

    func save(_ game: GameEngine) throws {
        var next = progress
        if let result = game.result {
            next.lastResult = result
            if result.rules == .firstContact && result.outcome == .completed {
                next.firstContactCompleted = true
                next.firstContactAccuracyMedal = next.firstContactAccuracyMedal || result.earnedAccuracyMedal
            }
            next.checkpoint = nil
        } else if game.phase == .playing || game.phase == .paused {
            var checkpoint = game
            checkpoint.pause()
            checkpoint.events = []
            next.checkpoint = checkpoint
        }
        try write(next)
    }

    func discardRun() throws {
        var next = progress
        next.checkpoint = nil
        try write(next)
    }

    private func write(_ next: SavedProgress) throws {
        guard canWrite else { throw SaveError.unsupportedVersion }
        // Keep earned rewards in memory if storage is temporarily unavailable.
        // The next successful save must include them, even after starting a retry.
        progress = next
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(next).write(to: url, options: .atomic)
    }
}
