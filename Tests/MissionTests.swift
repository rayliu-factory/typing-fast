import XCTest
@testable import LetterInvadersCore

final class MissionTests: XCTestCase {
    func testMissedWordsStaySingleAndEventuallyLoseThenRetryStartsFresh() throws {
        var game = GameEngine(seed: 42)
        game.start(rules: .firstContact)
        let firstRunID = game.runID
        for _ in 0..<10_000 where game.phase == .playing {
            game.advance(by: 0.1)
            XCTAssertLessThanOrEqual(game.targets.count, 1)
            XCTAssertNil(game.ufo)
        }
        XCTAssertEqual(game.phase, .gameOver)
        let result = try XCTUnwrap(game.result)
        XCTAssertEqual(result.outcome, .lost)
        XCTAssertFalse(result.earnedAccuracyMedal)
        XCTAssertEqual(result.totalKeys, 0)
        game.start(rules: .firstContact)
        XCTAssertNotEqual(game.runID, firstRunID)
        XCTAssertEqual(game.phase, .playing)
        XCTAssertEqual(game.wordsCleared, 0)
        XCTAssertNil(game.result)
        XCTAssertEqual(game.shields, [3, 3, 3, 3, 3, 3])
    }

    func testMissionCanPassWithoutAccuracyMedalAndRecordsMixedInput() throws {
        var game = GameEngine(seed: 7)
        game.start(rules: .firstContact)
        for _ in 0..<1000 where game.phase == .playing {
            if let next = game.preview?.next {
                game.input("!", source: .hardware)
                game.input(next, source: .touch)
            } else { game.advance(by: 0.1) }
        }
        let result = try XCTUnwrap(game.result)
        XCTAssertEqual(result.outcome, .completed)
        XCTAssertEqual(result.correctKeys, 24)
        XCTAssertEqual(result.totalKeys, 48)
        XCTAssertEqual(result.accuracy, 50)
        XCTAssertEqual(result.inputSources, [.touch, .hardware])
        XCTAssertFalse(result.earnedAccuracyMedal)
    }

    func testFirstContactClearsEightWordsThenFreezesWithAResult() throws {
        var game = GameEngine(seed: 42)
        game.start(rules: .firstContact)
        for count in 0..<8 {
            for _ in 0..<30 where game.targets.isEmpty { game.advance(by: 0.1) }
            let target = try XCTUnwrap(game.preview)
            XCTAssertEqual(game.targets.count, 1)
            XCTAssertFalse(target.isUFO)
            XCTAssertEqual(game.hintKey(layer: .letters, enabled: true), target.next)
            XCTAssertEqual(game.wordsCleared, count)
            for character in target.word { game.input(String(character)) }
        }
        XCTAssertEqual(game.phase, .victory)
        let result = try XCTUnwrap(game.result)
        XCTAssertEqual(result.wordsCleared, 8)
        XCTAssertEqual(result.outcome, .completed)
        XCTAssertTrue(result.earnedAccuracyMedal)
        XCTAssertEqual(game.wave, 1)
        let elapsed = game.elapsed
        game.advance(by: 0.1)
        game.input("x")
        XCTAssertEqual(game.elapsed, elapsed)
        XCTAssertEqual(game.result, result)
    }
}
