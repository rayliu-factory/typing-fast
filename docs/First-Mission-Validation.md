# First Contact milestone validation

Date: 12 November 2026. Scope: approved release plan R01–R05, one complete playable mission.

## Delivered

- First Contact entry, eight authored words, one slow target, immediate optional hints, explicit victory and loss, optional accuracy medal, results insight, retry and return to menu.
- Endless mode selection and existing scoring remain available. Mission runs cannot replace endless best scores.
- Local mission progress and last result, atomic solo checkpoints, explicit paused recovery, corrupt-save fallback and protection of unsupported versions.
- Touch and hardware input-source tags in the versioned arcade result. Planned practice, assessment and competition contracts are documented separately.
- Fixed two UI defects found during simulator play: SPACE previously consumed the bottom row and hid MODE/LOCK NEXT; underlying gameplay controls remained accessible while menus covered them.

## Automated checks

- 25 Swift package tests passed, including all 17 original arcade tests.
- Mission tests cover eight-word victory, frozen final results, passing without a medal, mixed input, one-target pacing, no UFOs, loss and retry.
- Storage tests cover partial-word restoration, same run identity, completion/medal after reopening, idempotent rewards, malformed JSON, malformed and unsafe checkpoints, unknown versions and recovery after a failed write.
- Debug build for iOS Simulator passed. Unsigned Release build for physical iOS passed. These are build checks, not device-signing or App Store checks.

## Interactive simulator observations

Device: iPhone 18 Pro simulator, iOS 27.2, Xcode 27.2.

| Check | Observed result |
| --- | --- |
| Start First Contact and tap on-screen keys | Words cleared and progress advanced; next-key hints visible |
| Pause after two words | Paused at 360 points, two words, 100% accuracy |
| Terminate/relaunch during that run | Restored paused with the same score and word count |
| Rotate during play | Landscape moved the keyboard beside the arena; controls remained usable |
| Bottom keyboard row | MODE, SPACE and LOCK NEXT all visible after layout fix |
| Menu accessibility | Covered game controls absent from the accessibility tree after fix |
| Lose and retry | Loss result and practice suggestion shown; retry reset score/word count |
| Complete a fresh run through touch controls | Victory at eight words; accuracy medal and useful results displayed |
| Relaunch after victory | Home marked First Contact completed; saved medal retained by storage tests |

Simulator interaction includes automation delays and is not a typing-speed benchmark. One target fell after partial input during a tool interruption; its correct letters remained counted, consistent with the documented arcade metric.

## Remaining release gates

R01 is **partial**, because no physical iPhone was connected. R03 and R04 have automated evidence. R05 has simulator evidence, but the full M1 user-experience gate still needs a new player on hardware. R02 defines all category contracts; only solo arcade is implemented.

Before expanding to the six-mission beta:

1. Install a signed build on a real iPhone. Observe a new player completing First Contact without coaching.
2. Check two-thumb latency and reach, simultaneous taps, sustained play, interruptions, audio and haptics.
3. Check a compact iPhone, iPad, supported older OS, larger text, VoiceOver navigation and Reduced Motion. The live arcade is not yet a full nonvisual game.
4. Test a physical external keyboard and confirm source labeling and pause behavior.
5. Tune pacing from observed play. Do not interpret arcade accuracy or automated simulator WPM as evidence of typing improvement.

Six missions, native-keyboard assessments, per-key practice recommendations, Game Center, purchases and App Store submission remain future milestones. No backend or live service has been added.
