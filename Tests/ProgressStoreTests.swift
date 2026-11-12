import XCTest
@testable import LetterInvadersCore

final class ProgressStoreTests: XCTestCase {
    func testInvalidSaveAndUnsafeCheckpointCanBothStartFresh() throws {
        let url = try temporarySave()
        try Data("not json".utf8).write(to: url)
        let corrupted = ProgressStore(url: url)
        XCTAssertNil(corrupted.progress.checkpoint)
        XCTAssertNotNil(corrupted.notice)
        var game = GameEngine(seed: 42)
        game.start(rules: .firstContact)
        try corrupted.save(game)
        var document = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        var checkpoint = try XCTUnwrap(document["checkpoint"] as? [String: Any])
        checkpoint["shields"] = [] // Valid JSON, but unsafe for the simulation.
        document["checkpoint"] = checkpoint
        try JSONSerialization.data(withJSONObject: document).write(to: url)
        let recovered = ProgressStore(url: url)
        XCTAssertNil(recovered.progress.checkpoint)
        XCTAssertNotNil(recovered.notice)
        try recovered.save(game)
        XCTAssertNotNil(ProgressStore(url: url).progress.checkpoint)
    }

    func testFailedWriteKeepsEarnedProgressForTheNextSaveAttempt() throws {
        let blocker = try temporarySave()
        try Data("file blocks directory".utf8).write(to: blocker)
        let url = blocker.appendingPathComponent("progress.json")
        let store = ProgressStore(url: url)
        var game = GameEngine(seed: 42)
        game.start(rules: .firstContact)
        for _ in 0..<1000 where game.phase == .playing {
            if let next = game.preview?.next { game.input(next) }
            else { game.advance(by: 0.1) }
        }
        XCTAssertThrowsError(try store.save(game))
        try FileManager.default.removeItem(at: blocker)
        game.start(rules: .firstContact)
        try store.save(game)
        XCTAssertTrue(ProgressStore(url: url).progress.firstContactCompleted)
    }

    func testNewerSaveIsPreservedUntilTheAppCanReadIt() throws {
        let url = try temporarySave()
        let original = Data("{\"schemaVersion\":99,\"futureData\":true}".utf8)
        try original.write(to: url)
        let store = ProgressStore(url: url)
        XCTAssertNotNil(store.notice)
        XCTAssertThrowsError(try store.discardRun())
        XCTAssertEqual(try Data(contentsOf: url), original)
    }

    func testDamagedCheckpointFallsBackWithoutLosingEarnedMissionProgress() throws {
        let url = try temporarySave()
        try Data("{\"schemaVersion\":1,\"firstContactCompleted\":true,\"firstContactAccuracyMedal\":true,\"checkpoint\":{\"phase\":\"paused\"}}".utf8).write(to: url)
        let store = ProgressStore(url: url)
        XCTAssertTrue(store.progress.firstContactCompleted)
        XCTAssertTrue(store.progress.firstContactAccuracyMedal)
        XCTAssertNil(store.progress.checkpoint)
        XCTAssertNotNil(store.notice)
        var game = GameEngine(seed: 42)
        game.start()
        try store.save(game)
        XCTAssertNotNil(ProgressStore(url: url).progress.checkpoint)
    }

    func temporarySave() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock { try FileManager.default.removeItem(at: directory) }
        return directory.appendingPathComponent("progress.json")
    }

    func testRelaunchRestoresPartialWordPausedThenPersistsCompletion() throws {
        let url = try temporarySave()
        let store = ProgressStore(url: url)
        var game = GameEngine(seed: 42)
        game.start(rules: .firstContact)
        for _ in 0..<10 where game.preview == nil { game.advance(by: 0.1) }
        game.input(try XCTUnwrap(game.preview).next)
        try store.save(game)
        let reopened = ProgressStore(url: url)
        var resumed = try XCTUnwrap(reopened.progress.checkpoint)
        XCTAssertEqual(resumed.phase, .paused)
        XCTAssertEqual(resumed.runID, game.runID)
        XCTAssertEqual(resumed.preview?.typed, 1)
        XCTAssertEqual(resumed.elapsed, game.elapsed)
        XCTAssertTrue(resumed.events.isEmpty)
        resumed.resume()
        for _ in 0..<1000 where resumed.phase == .playing {
            if let next = resumed.preview?.next { resumed.input(next) }
            else { resumed.advance(by: 0.1) }
        }
        XCTAssertEqual(resumed.phase, .victory)
        try reopened.save(resumed)
        try reopened.save(resumed) // Repeated background saves cannot duplicate rewards.
        let completed = ProgressStore(url: url).progress
        XCTAssertTrue(completed.firstContactCompleted)
        XCTAssertTrue(completed.firstContactAccuracyMedal)
        XCTAssertEqual(completed.lastResult?.id, game.runID)
        XCTAssertNil(completed.checkpoint)
    }
}
