# Letter Invaders — native iOS

A Swift / SwiftUI version of **Letter Invaders · Cyber Softkey Edition**, based on the original HTML prototype in `Prototype/`. Runs entirely on-device, with no web view, web dependencies, account, or network requirement.

## Play in Xcode

1. Open **LetterInvaders.xcodeproj** in Xcode 15 or newer with an iOS SDK installed.
2. Choose the **LetterInvaders** scheme and an iPhone simulator.
3. Press **Run** (⌘R).

To run on your own iPhone, select your phone as the destination and choose your Apple development team in **Signing & Capabilities**. Change the bundle identifier if your team needs a different one. No development team or signing credentials are committed to this repository.

Minimum OS: **iOS / iPadOS 17**. Supports portrait and landscape, with a side-by-side keyboard layout in landscape.

## Gameplay

- **Thumb Rhythm:** the original alternating-thumb word bank, with cyan left-thumb and pink right-thumb keys.
- **Arcade Waves:** short words first, then medium and longer words as waves advance.
- **Layer Drills:** mixed letters, numbers and symbols, with immediate key hints.
- Six city domes, each starting with three shield points.
- Type a matching first letter to lock a target. Finish the word to destroy it.
- Mistypes reset the combo and nudge a falling word down, but keep typed progress.
- Correct keys score `10 × current combo`, with the combo capped at 25. A completed falling word adds `25 × word length`.
- A completed UFO awards `250 × wave` and restores one shield point to the first damaged city, including a destroyed city.
- Every eight cleared words/UFOs advances the wave. UFOs arrive every 14 seconds of active play.
- SPACE, backspace and LOCK NEXT cycle targets. ?123 / ABC switch touch-keyboard layers.
- External keyboards: type normally; Space / Tab / Backspace cycle targets; Escape pauses/resumes; Enter starts/resumes.

## Native additions and deliberate differences

- Local high scores per training mode; persistent sound, haptic and hint preferences.
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

Validated on 11 November 2026 with Xcode 27.2:

- 17 gameplay tests passed, including scoring, locks, UFO repair, pause, restart, hints and a full no-input game-over simulation.
- iOS Simulator Debug build passed and the app installed/launched on the iPhone 17 simulator (iOS 27.2).
- Unsigned Release build for physical iOS devices passed. Signing and physical-device installation were not performed.
- Visual inspection and interactive simulator checks were blocked by the desktop control tool timing out. These are still required before calling the UI verified.

Before TestFlight or App Store distribution, test touch and external-keyboard controls, rotation, compact iPhones and iPads, audio, haptics, interruptions, and accessibility on actual devices. Configure signing, confirm final branding, and prepare the store listing and screenshots. This repository is a playable first native implementation, not an App Store submission.

Scores and preferences stay on the device. There are no analytics, ads, purchases, cloud saves or background network calls.
