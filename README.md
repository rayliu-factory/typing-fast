# Letter Invaders — native iOS

A Swift / SwiftUI version of **Letter Invaders · Cyber Softkey Edition**, based on the original HTML prototype in `Prototype/`. Runs entirely on-device, with no web view, web dependencies, account, or network requirement.

## Play in Xcode

1. Open **LetterInvaders.xcodeproj** in Xcode 15 or newer with an iOS SDK installed.
2. Choose the **LetterInvaders** scheme and an iPhone simulator.
3. Press **Run** (⌘R).

To run on your own iPhone, select your phone as the destination and choose your Apple development team in **Signing & Capabilities**. Change the bundle identifier if your team needs a different one. No development team or signing credentials are committed to this repository.

Minimum OS: **iOS / iPadOS 17**. Supports portrait and landscape, with a side-by-side keyboard layout in landscape.

## Gameplay

- **First Contact:** an introductory mission with eight short words, one slow target at a time, immediate optional key hints, and an optional 90% accuracy medal. A missed word returns until cleared. Completing the mission does not require the medal.
- **Endless Defense:** the three original modes remain available below the mission card. Wave escalation and UFO bonuses apply to these modes.

- **Thumb Rhythm:** the original alternating-thumb word bank, with cyan left-thumb and pink right-thumb keys.
- **Arcade Waves:** short words first, then medium and longer words as waves advance.
- **Layer Drills:** mixed letters, numbers and symbols, with immediate key hints.
- Six city domes, each starting with three shield points.
- Type a matching first letter to lock a target. Finish the word to destroy it.
- Mistypes reset the combo and nudge a falling word down, but keep typed progress.
- Correct keys score `10 × current combo`, with the combo capped at 25. A completed falling word adds `25 × word length`.
- A completed UFO awards `250 × wave` and restores one shield point to the first damaged city, including a destroyed city.
- In endless modes, every eight cleared words/UFOs advances the wave. UFOs arrive every 14 seconds of active play.
- SPACE, backspace and LOCK NEXT cycle targets. ?123 / ABC switch touch-keyboard layers.
- External keyboards: type normally; Space / Tab / Backspace cycle targets; Escape pauses/resumes; Enter starts/resumes.

## Native additions and deliberate differences

- Local endless high scores per training mode; mission scores are separate. Persistent sound, haptic and hint preferences.
- Mission completion, accuracy medal and the most recent result are saved locally. Interrupted solo runs restore paused with their current word progress.
- Atomic checkpoints save on start, word completion, impact, pause/background and every three active seconds. An abrupt force-quit can lose changes since the most recent checkpoint.
- Results include score, words, arcade accuracy, touch/external-keyboard input source and a simple practice suggestion. They do not claim improvement on a standard typing assessment.
- Native synthesized sound effects and haptics. Sound respects the silent switch and mixes with background music.
- Automatic pause when the app becomes inactive. Resume is explicit; paused time never changes WPM or moves enemies.
- A fixed logical playfield keeps reaction time consistent across screen sizes. Falling word labels are clamped inside the visible playfield.
- WPM updates continuously, and peak WPM is tracked separately. Empty-sky taps do not count as errors.
- MODE opens the pause menu; changing training mode starts a new run, so best scores stay comparable.
- Reduced Motion suppresses the star drift, particle bursts and damage flash. The live arcade itself remains visual and is not a complete nonvisual game mode.
- Original web fonts are replaced with system rounded and monospaced fonts. The app ships an original geometric icon.

## Build and test

The game simulation has no UI dependency and can be tested on a Mac:

```sh
swift test
```

If the Mac is configured to use standalone Command Line Tools rather than Xcode:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift test
```

Build for the simulator without signing:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -project LetterInvaders.xcodeproj -scheme LetterInvaders \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

## Project structure

| Path | Purpose |
| --- | --- |
| `LetterInvaders/Core` | Deterministic gameplay, keyboard layouts, original word banks |
| `LetterInvaders/App` | SwiftUI screens, Canvas renderer, display loop, audio/haptics, external-keyboard input |
| `LetterInvaders/Assets.xcassets` | App icon |
| `LetterInvaders/PrivacyInfo.xcprivacy` | Local preferences API declaration; no data collection or tracking |
| `Tests` | Gameplay regression tests, runnable with Swift Package Manager |
| `Prototype` | Unmodified supplied HTML reference; not included in the iOS app |

## Validation and remaining release work

Validated on 12 November 2026 with Xcode 27.2:

- 25 core tests passed: the original 17 arcade regressions plus mission victory/loss/retry, input sources, partial-word recovery, saved rewards, corrupt saves, unsupported versions and failed-write recovery.
- iOS Simulator Debug and unsigned physical-iOS Release builds passed.
- Interactive iPhone 18 Pro simulator checks covered touch typing, portrait/landscape layouts, pause, process relaunch recovery, mission loss/retry, victory, medal display and persisted completion.
- Fixed the bottom-row layout that hid MODE and LOCK NEXT. Hidden gameplay controls no longer appear in the menu's accessibility tree.
- No physical iPhone was connected. Real two-thumb feel, audio/haptics, hardware keyboards, older OS versions, compact devices and full accessibility remain unverified.

See [first-mission validation](docs/First-Mission-Validation.md), [run contracts](docs/Run-Contracts.md) and the [approved release plan](docs/Release-Plan.md).

Before TestFlight or App Store distribution, test touch and external-keyboard controls, rotation, compact iPhones and iPads, audio, haptics, interruptions, and accessibility on actual devices. Configure signing, confirm final branding, and prepare the store listing and screenshots. This repository is a playable first native implementation, not an App Store submission.

Scores and preferences stay on the device. There are no analytics, ads, purchases, cloud saves or background network calls.
