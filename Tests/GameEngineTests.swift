import XCTest
@testable import LetterInvadersCore

final class GameEngineTests: XCTestCase {
    func game(_ targets: [Invader] = []) -> GameEngine {
        var game = GameEngine(seed: 42)
        game.start()
        game.targets = targets
        game.spawnTimer = -1000
        return game
    }
    func word(_ id: Int = 1, _ text: String = "city", y: Double = 100, ufo: Bool = false) -> Invader {
        Invader(id: id, word: text, x: 195, y: y, speed: 30, dome: 0, isUFO: ufo)
    }
    func type(_ text: String, into game: inout GameEngine) { for char in text { game.input(String(char)) } }

    func testCompleteWordScoreComboAndProgress() {
        var game = game([word()])
        type("city", into: &game)
        XCTAssertEqual(game.score, 200) // 10+20+30+40, plus 4×25.
        XCTAssertEqual(game.combo, 5)
        XCTAssertEqual(game.wordsCleared, 1)
        XCTAssertTrue(game.targets.isEmpty)
        XCTAssertEqual(game.accuracy, 100)
    }
    func testMistypeKeepsProgressAndResetsCombo() {
        var game = game([word()])
        type("cix", into: &game)
        XCTAssertEqual(game.targets[0].typed, 2)
        XCTAssertEqual(game.targets[0].y, 109)
        XCTAssertEqual(game.combo, 1)
        XCTAssertEqual(game.accuracy, 67)
        XCTAssertEqual(game.score, 30)
    }
    func testLockDoesNotJumpToAnotherMatchingWord() {
        var game = game([word(), word(2, "rock", y: 200)])
        type("cr", into: &game)
        XCTAssertEqual(game.lockedID, 1)
        XCTAssertEqual(game.targets[0].typed, 1)
        XCTAssertEqual(game.targets[1].typed, 0)
    }
    func testMatchingUFOPrecedesLowestWord() {
        var game = game([word(1, "city", y: 240), word(2, "cyber", ufo: true)])
        game.input("c")
        XCTAssertEqual(game.lockedID, 2)
    }
    func testAutoLockPicksClosestMatchingWord() {
        var game = game([word(1, "city", y: 100), word(2, "cyber", y: 240)])
        game.input("c")
        XCTAssertEqual(game.lockedID, 2)
    }
    func testUFORepairsDestroyedCityAndAddsBonus() {
        var game = game([word(1, "@", ufo: true)])
        game.shields[0] = 0
        game.input("@")
        XCTAssertEqual(game.shields[0], 1)
        XCTAssertEqual(game.score, 260)
    }
    func testUFOCannotOverfillShields() {
        var game = game([word(1, "@", ufo: true)])
        game.input("@")
        XCTAssertEqual(game.shields, Array(repeating: 3, count: 6))
    }
    func testEveryEightWordsAdvancesWaveAndCapsSpawnRate() {
        var game = game()
        for id in 1...160 {
            game.targets = [word(id, "a")]
            game.input("a")
        }
        XCTAssertEqual(game.wave, 21)
        XCTAssertEqual(game.spawnInterval, 0.95)
        XCTAssertEqual(game.combo, 25)
    }
    func testPauseFreezesSimulationAndInput() {
        var game = game([word()])
        game.advance(by: 0.1)
        let elapsed = game.elapsed
        let y = game.targets[0].y
        game.pause()
        for _ in 0..<100 { game.advance(by: 0.1); game.input("c") }
        XCTAssertEqual(game.elapsed, elapsed)
        XCTAssertEqual(game.targets[0].y, y)
        XCTAssertEqual(game.totalKeys, 0)
        game.resume()
        game.input("c")
        XCTAssertEqual(game.correctKeys, 1)
    }
    func testLastImpactEndsGameAndClearsLock() {
        var game = game([word(y: 361)])
        game.shields = [1, 0, 0, 0, 0, 0]
        game.lockedID = 1
        game.advance(by: 0.1)
        XCTAssertEqual(game.phase, .gameOver)
        XCTAssertNil(game.lockedID)
        XCTAssertEqual(game.shields, Array(repeating: 0, count: 6))
    }
    func testGhostHintsAndLayerSwitching() {
        var game = game([word(1, "@dev", y: 200)])
        XCTAssertEqual(game.hintKey(layer: .letters, enabled: true), "?123")
        XCTAssertEqual(game.hintKey(layer: .symbols, enabled: true), "@")
        XCTAssertNil(game.hintKey(layer: .letters, enabled: false))
        game.targets[0].y = 10
        XCTAssertNil(game.hintKey(layer: .letters, enabled: true))
        game.mode = .layers
        XCTAssertEqual(game.hintKey(layer: .letters, enabled: true), "?123")
    }
    func testCycleLockPreservesPartialWords() {
        var game = game([word(), word(2, "rock")])
        game.input("c")
        game.cycleLock()
        game.input("r")
        game.cycleLock()
        game.input("i")
        XCTAssertEqual(game.targets.map(\.typed), [2, 1])
    }
    func testEmptySkyDoesNotPenalizeAccuracy() {
        var game = game()
        game.input("x")
        XCTAssertEqual(game.totalKeys, 0)
        XCTAssertEqual(game.accuracy, 100)
    }
    func testRestartResetsStatsButPreservesMode() {
        var game = game([word()])
        game.mode = .layers
        type("city", into: &game)
        game.start()
        XCTAssertEqual(game.mode, .layers)
        XCTAssertEqual(game.maxCombo, 1)
        XCTAssertEqual(game.score, 0)
        XCTAssertEqual(game.peakWPM, 0)
        XCTAssertEqual(game.shields.reduce(0, +), 18)
    }
    func testAllDictionaryCharactersExistOnKeyboard() {
        let words = WordBanks.thumb + WordBanks.classicShort + WordBanks.classicMedium + WordBanks.classicLong + WordBanks.layers + WordBanks.ufoBonus
        for char in Set(words.joined()) {
            XCTAssertTrue(KeyboardLayout.contains(String(char), in: .letters) || KeyboardLayout.contains(String(char), in: .symbols), "Missing \(char)")
        }
    }
    func testSeededSimulationEventuallyEndsWithoutInput() {
        var game = GameEngine(seed: 42)
        game.start()
        for _ in 0..<20000 {
            game.advance(by: 0.1)
            game.events.removeAll()
            if game.phase == .gameOver { break }
        }
        XCTAssertEqual(game.phase, .gameOver)
        XCTAssertEqual(game.shields.reduce(0, +), 0)
    }
    func testUFOExitClearsLockWithoutDamagingCities() {
        var target = word(1, "@", ufo: true)
        target.x = 529
        var game = game([target])
        game.lockedID = 1
        game.advance(by: 0.1)
        XCTAssertTrue(game.targets.isEmpty)
        XCTAssertNil(game.lockedID)
        XCTAssertEqual(game.shields.reduce(0, +), 18)
    }
}
