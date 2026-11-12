> Approved by the project owner on 12 November 2026. This is the product roadmap; implementation status is tracked in First-Mission-Validation.md. The final approval request below is retained as planning history.

# Letter Invaders: mature release plan

**Date:** 12 November 2026  
**Status:** Recommended design for final review. Eight product decisions have been accepted; detailed defaults below are proposals for the implementation brief. No game code or repository settings have been changed by this planning work.  
**Baseline:** `rayliu-factory/typing-fast`, commit `c52f2fd`.  
**Working promise:** A short-session neon arcade where typing defends your cities, practice targets your mistakes, and friends compete on equal rules.

## 1. Decisions already accepted

1. Prioritize two-thumb phone typing; external keyboards are secondary.
2. Make an enjoyable arcade first, with optional learning support.
3. Start with teens and adults who already type and want confidence, accuracy and speed.
4. Develop as a solo indie project with Codex, validate a focused beta, then prepare a public release.
5. Add a small mission campaign while preserving endless survival; begin with six beta missions.
6. Start friend competition with identical 60-second asynchronous scenarios.
7. Add targeted practice and separate assessments using the normal iPhone keyboard.
8. Keep the beta free; propose a free core and optional one-time expansion for the public product.

The following are recommended planning defaults, not claims that the user has individually approved every detail: English QWERTY first; iPhone-first competitive play; offline solo play; Game Center for friends; no separate account system; no live multiplayer, advertising, consumables or subscriptions in version 1; all gameplay-affecting upgrades excluded from ranked play. A final confirmation of this document establishes the shared implementation brief.

## 2. Product loop and screen structure

The intended loop is: choose a mission or quick run, defend the city for 1–3 minutes, see one useful insight, optionally practice for 30–60 seconds, then retry or challenge a friend.

Use three main destinations:

- **Play:** next mission, Endless, and today's optional practice variation. The next mission is the primary action.
- **Challenge:** the free Relay 60 course, friend standings, active challenges and rematch entry points.
- **Progress:** mission medals, local personal records, practice focus and keyboard assessments.

Settings remain a utility screen. Do not turn the home screen into a dashboard of currencies, offers and notifications.

First launch should reach a playable encounter within 30 seconds. Teach target locking through one slow target; teach switching only when two targets appear. Introduce symbols later. Do not require a typing assessment, purchase decision or Game Center sign-in before the first game. Ask for Game Center only when the player chooses a social feature.

After a run show, in order: outcome, personal progress, one concrete observation, and one suggested next action. Example: “Mission cleared. Accuracy 94%. You missed I/O four times. Try a 45-second focus drill.” Also keep Retry and Continue available. Avoid unearned claims such as “Your typing improved 20%” based on an arcade score.

## 3. Scope by release

| Area | Focused TestFlight beta | Public version 1 | Later, only if validated |
| --- | --- | --- | --- |
| Campaign | One district, six missions | Free first district; expansion can bring total to three districts / 18 missions | Additional authored districts |
| Endless | Existing survival, balanced and polished | Personal bests by rules/difficulty version | Optional seasonal variations |
| Competition | One fixed Relay 60 course; test friend flow after local fairness passes | Game Center friends and compatible native challenges | Ranked daily courses, ghost replays, live duels |
| Practice | Three drill families and basic recommendations | Expanded curated material and clearer progress | More languages and layouts |
| Assessment | Native-keyboard baseline and repeat assessment | Local history, comparable-session labels | A larger controlled transfer study |
| Progress | Mission passes, optional medals, local unlocks | Cosmetic collection and a few meaningful achievements | Cross-device progress if players need it |
| Monetization | Free, no purchase requirement | Optional one-time expansion, only when its content is ready | Revisit only with evidence |

Do not let the expansion delay the free core. If the public game is ready before the extra districts, launch the free core first without a purchase button. No placeholders for unavailable paid content.

## 4. Six beta missions

All numerical difficulty values are initial tuning hypotheses. Adjust them after watching new players; do not treat them as educational standards.

| Mission | Experience | Skill focus | Completion condition | Replay objective |
| --- | --- | --- | --- | --- |
| 1. First Contact | One slow target at a time; immediate feedback | Finding keys and completing a word | Clear eight short words; generous shields and recovery | Finish with at least 90% arcade accuracy |
| 2. Crossfire | Two visible targets; optional switching | Reading ahead and choosing a target | Clear 12 words | Finish with four cities standing |
| 3. Neon Swarm | Short, clearly spaced bursts with quiet gaps | Maintaining accuracy under mild pressure | Survive 90 seconds | Clear two bursts without a mistype |
| 4. Heavy Cargo | Long targets with generous time allowances | Sustaining a longer sequence | Clear six longer words | Complete one long word without an error |
| 5. Signal Switch | Slow number/symbol UFOs mixed with letters | Switching keyboard layers | Complete four mixed targets and survive | Finish with at least 90% arcade accuracy |
| 6. Hold the Skyline | Mix of learned mechanics, without a new surprise rule | Applying target selection and typing rhythm | Survive a 120-second authored defense | Earn an optional accuracy medal |

A pass unlocks the next mission. Medals and precision goals are optional; do not gate progress on perfect accuracy or high WPM. Offer a slower assisted retry after repeated failures. Record assistance and keep those runs out of competitive rankings.

Begin with recognizable everyday words as well as the cyber vocabulary. Curate spelling, familiarity, ambiguity and symbol frequency. Review unusual prototype entries such as “visp” instead of carrying every token forward unquestioned.

## 5. New enemies and rewards

Each enemy should change the player's decision or typing task, not merely recolor a word.

| Enemy | Mechanic | Teaching/strategy purpose | Guardrail |
| --- | --- | --- | --- |
| Scout | Short, ordinary falling word | Establish the base loop | Clearly readable, predictable movement |
| Swarm | Authored cluster of short words | Target prioritization and recovery | Preserve gaps and prevent overlapping labels |
| Armored carrier | Longer word with a segmented visual shell | Sustain a sequence | Each correct letter progresses it; never require meaningless repeated keys |
| Signal UFO | Number/symbol target crossing the field | Layer switching and reward choice | Enough visible time to change layers; standard repair reward |
| District boss | Several readable word phases | Combine mastered skills | Public release candidate after beta; no tiny text or memorization-only tricks |

Keep correct-key firing automatic. Do not add an extra shooting button. Keep the locked word and next letter close to the keyboard. Use motion, audio and haptics to reinforce a hit, but preserve clear feedback when sound and haptics are disabled.

Progression should visibly rebuild districts: a passed mission restores a building, optional medals light more of the skyline, and milestones unlock a small set of city themes or laser colors. Make cosmetic unlocks direct and understandable. Avoid another spendable currency, random loot, energy timers, or penalties for missing a day.

## 6. Learning design and measurement

### Separate the three experiences

1. **Arcade:** rewards survival and target selection. Its score is not a real-world typing assessment.
2. **Focus practice:** short drills for a selected problem, with adjustable pacing and no competitive score.
3. **Keyboard check:** typing unfamiliar sentences into an ordinary iOS editable text field with the normal keyboard.

Keep SPACE and backspace target-switch behavior confined to arcade controls. In keyboard checks, space inserts a space and backspace deletes text. Display the difference clearly.

### Focus practice

Begin with accuracy, common letter transitions, and symbol switching. Suggest a focus only after enough observations—for example, at least 20 relevant attempts over three sessions. These thresholds are provisional product rules, not validated diagnosis criteria.

Record expected versus entered letters only when the player has an explicit target. Before lock, an apparent mismatch may mean the player intended another target. Say “frequently missed letters,” not “your weak thumb.” Current left/right counters describe key zones, not which physical thumb was used.

Use a mixed drill pool: approximately 60% material related to the selected focus and 40% varied familiar material. Revisit earlier material in later sessions. Start gently and adjust between drills, not mid-ranked-run. Offer one recommendation at a time and let the player dismiss it.

### Assessment contract

Use a 60-second assessment with an optional untimed warm-up. Keep assessment sentences separate from arcade and drill banks. Counterbalance matched passage sets to reduce memorization.

Report output WPM as final produced characters, including spaces, divided by five and elapsed minutes. Report final-text accuracy separately, using an explicit text-alignment method against the attempted reference span. Do not count an unseen or unattempted suffix as deletions. Test substitutions, insertions, deletions, partial last words, selection/replacement and punctuation.

Correction activity should be labeled as observed edit behavior, not physical keystroke count. Native keyboards can deliver multi-character changes through autocorrection, prediction, swipe input or composition. Do not infer thumb taps from inserted text length.

For the initial real-world check, use the normal iOS keyboard and ask players to keep the same keyboard/settings and typing method across assessments. Record a simple session label, including keyboard mode, orientation and hardware-keyboard use. Mark incomparable sessions rather than combining them. Paste or non-typing input invalidates the assessment where detectable; do not claim perfect dictation or automation detection.

Compare sessions on the same phone and orientation. Use speed together with accuracy, never speed alone. The first screen should say “Baseline recorded,” not assign a discouraging global rank.

### Validate transfer

The available research does not establish that this specific custom-keyboard arcade improves everyday iPhone typing. A large mobile transcription study measures speed, errors and correction behavior and finds different associations for typing aids; that makes input conditions important to record. [Palin et al., 2019](https://userinterfaces.aalto.fi/typing37k/resources/Mobile_typing_study.pdf)

Run a directional pilot with 20–30 adult volunteers first. Take baseline measurements, offer 5–10 minutes of play on roughly five days per week for two weeks, then repeat with unseen matched sentences. Invite a delayed check after a week without assigned practice. If recruitment permits, randomize a comparison group that completes the assessments without the game during the same interval.

Track individual change in WPM and error rate, adherence and confidence. Publish denominators, variation and incomplete participation. A small pilot guides product design; it is not proof of an educational effect. If only arcade scores improve, change the drills, keyboard behavior or claims before marketing everyday typing gains.

## 7. Friend challenges that are genuinely comparable

### Version 1 experience

A player finishes the free **Relay 60** course, opens the system challenge flow, invites a friend, and returns later to compare scores or rematch. Start with one permanent course. Keep challenge access free and available after the short tutorial, without a campaign progression gate.

Relay 60 has 60 seconds of fixed, authored encounters. Everyone receives the same words, spawn times, paths and standard assistance rules. The current engine's random seed is insufficient: spawning depends on the player's surviving cities, current target letters, clear count and active-target cap. A fixed encounter schedule must replace those dependencies for this mode.

Each course has a stable identity: course ID, content version, scoring version, duration, input category and rules. Inputs are recorded against fixed simulation ticks for local replay tests. Rendering frame rate must not alter simulation or the deadline. Future encounters must not change when a player types differently.

### Initial scoring candidate

Use a transparent candidate for beta tuning:

`score = max(0, 10 × correct characters + 25 × completed words + precision bonuses + fixed UFO bonuses − 20 × mistypes − 50 × missed targets)`

On each completed word, its precision bonus is `5 × min(current consecutive correct-key streak, 20)`. A mistype resets that streak. A completed UFO adds a fixed 100 points and repairs one shield point. The course's exact rewards and enemy schedule are frozen with the scoring version. No score is awarded for layer changes or switching targets. Correct characters count once. Test partial-word farming and target-switch strategies before adopting the formula.

This intentionally differs from the prototype's large per-character combo multiplier. It is a proposed candidate to make scoring understandable and limit one mistake's impact. Compare both formulas during beta; once a leaderboard opens, changing the formula requires a new version/board.

Use tied ranks for equal scores unless the chosen Game Center configuration explicitly supports the desired tie behavior. Accuracy and words cleared remain visible comparison statistics; do not claim an unsupported secondary ranking rule.

### Competition rules

- First public competitive category: iPhone touch input. Hardware keyboards remain available for solo practice; they do not submit to this category.
- A fixed hint policy applies to everyone; prototype the current danger-line hint for all players. Accessibility contrast, sound and motion options remain available.
- No adaptive speeds, slow-time perks, paid power, extra shields or revives in a ranked run.
- Solo runs pause and resume. Leaving a ranked run ends it with its current score; explain that before starting. Handle system interruptions gently in the wording.
- Favor repeatable best-score challenges so a dropped call or failed attempt does not consume a scarce paid resource. Force-kill handling cannot guarantee execution of a final callback.
- Client-side validation can reject malformed results; it cannot make the game cheat-proof. Keep competition friendly, with no prizes, wagering or esports claims.

### Game Center feasibility and OS support

Apple's challenge system builds on leaderboards and routes submitted attempt scores to associated challenges. Invitations, rematches and the system UI can support this social loop. Submit a run's actual result at the gameplay boundary; do not repeatedly submit a stored personal best from menus or app startup. Apple documents offline submission/error recovery, but late submissions after a challenge deadline still need an integration test. [Apple challenge integration](https://developer.apple.com/documentation/gamekit/creating-engaging-challenges-from-leaderboards)

The modern `GKChallengeDefinition` API starts at iOS 26. Keep the existing iOS 17 baseline for solo play and supported leaderboard features; gate the modern invitation UI to supported systems. On older systems, provide free Relay 60 play and supported friend standings, with clear capability labeling. Do not advertise identical social functionality on all supported OS versions. [Apple API availability](https://developer.apple.com/documentation/gamekit/gkchallengedefinition.md)

Make a small Game Center prototype before committing final social UI. Verify inviting, accepting, cold-launch routing, declined sign-in, restrictions, expired challenges and result handling. Confirm course identity is preserved across an invitation. If the native flow cannot carry arbitrary seeds, keep the single fixed course; do not build custom invitation infrastructure merely to add random courses.

A daily variation can initially be unranked solo content. Ranked daily courses wait until recurring-board windows, explicit course dates, time zones, old-client compatibility and late/offline submission behavior are proven. A shared seed in a link alone is not an authenticated competition service.

## 8. Technical plan grounded in the existing app

Keep the native SwiftUI app and the pure simulation. Refactor only where the accepted features need clear ownership.

| Component | Responsibility | Completion evidence |
| --- | --- | --- |
| Run rules and mission definitions | Content, pacing, objectives, win/loss and assist policy | Six missions run from data; endless remains a separate rules configuration |
| Simulation clock and encounter schedule | Fixed-tick updates and deterministic authored competition | Same input replay yields same result at 30/60/120 Hz and across frame stalls |
| Session recorder | Timestamped inputs and run summaries | One run ID, one final result; no duplicate counting |
| Assessment session | Normal text editing and assessment scoring | Correct handling of deletion, replacement, marked text, autocorrect and multi-character edits |
| Progress store | Mission passes, cosmetics, practice history, solo snapshots | Atomic writes, schema migrations and process-termination recovery |
| Challenge service | Game Center state, routing and submission boundaries | Two real accounts complete an invite/play/compare/rematch flow |
| Presentation/audio | SwiftUI screens, effects and native feedback | Device-tested input latency, legibility and accessibility |
| Purchase service, later | One-time expansion entitlement and restore | Sandbox purchase, cancellation, pending state, offline entitlement and restore checks |

Current facts: the app has 17 core tests, local best scores/preferences, a Canvas renderer and a working build. It has no campaign configuration, native-keyboard assessment, Game Center service, saved run history or purchase integration. Visual and interactive testing was previously blocked; resolve that before assuming the prototype's touch feel transfers perfectly to the native app.

A fixed-step clock must retain elapsed time rather than dropping long frames through the current 0.1-second cap. Set an explicit catch-up policy and use an actual challenge deadline. Never let a slow device gain thinking time or encounter fewer scheduled words. If timing integrity cannot be preserved after a severe stall, classify the attempt consistently and explain the result instead of submitting a favorable partial simulation.

Use bundled, versioned content initially. Avoid a remote-content service, login backend or live-operations panel until a proven feature requires one. Separate simulation, local storage, assessment and transport from the growing `GameModel`.

## 9. Milestones and initial work order

These are delivery gates, not calendar promises. Calendar estimates should follow the first completed vertical slice and observed capacity.

| Milestone | Main work | Exit gate |
| --- | --- | --- |
| M0: Verify the native foundation | Install on a real iPhone; check touch feel, display, lifecycle and audio; capture baseline issues | A new player completes a normal run; no blocking touch/layout defects |
| M1: One complete mission | Configurable rules, explicit victory state, result summary, saved pass and retry | First Contact works end-to-end, survives relaunch, and is understandable without coaching |
| M2: Six-mission beta | Enemy variants, curated content, assist options, local progress, endless balance | All six missions completable; passes do not require perfect typing |
| M3: Credible practice | Session records, three drill types, recommendation thresholds, native-keyboard check | Baseline/retest uses unseen text; editing metrics pass fixtures; insights do not overclaim |
| M4: Fair friend beta | Fixed Relay 60 schedule, replay tests, score versioning, Game Center feasibility and integration | Two accounts receive the same course and finish the complete social flow; failures are handled |
| M5: TestFlight learning loop | Recruit small cohort, observe onboarding, collect opt-in summaries and feedback, tune | Evidence supports repeat play; major confusion and stability failures resolved |
| M6: Public release | Device matrix, accessibility, content polish, store materials, final privacy/signing/review work | All release gates below pass; expansion included only if ready |

M3 and a small Game Center feasibility investigation can overlap once M1 establishes the model boundaries. Do not expand campaign content while input or scoring integrity is still unstable.

### Initial backlog, in dependency order

| ID | Work item | Depends on | Acceptance criterion |
| --- | --- | --- | --- |
| R01 | Native device validation and defect list | Final plan confirmation | Touch, rotation, interruption and readability observations recorded on actual hardware |
| R02 | Define run/result/input contracts | R01 | Explicit rules for solo, practice, assessment and competition; versioned result schema |
| R03 | Configurable mission and victory evaluation | R02 | First mission and endless use distinct data-driven rules; victory/loss tests pass |
| R04 | Local progress and solo recovery | R02–R03 | Completed mission persists; interrupted solo run resumes safely; corrupt save has a safe fallback |
| R05 | First mission UI and result screen | R03–R04 | Start, play, pass/fail, insight and retry flow verified |
| R06 | Six authored beta missions | R05 | Encounter files validated; words readable; difficulty reviewed with new players |
| R07 | Session recording and focus recommendations | R02 | Expected/entered-key data excludes ambiguous pre-lock guesses; insufficient-data state exists |
| R08 | Native keyboard assessment | R02 | Correct editing semantics and metric fixtures; held-out passages; no forced assessment |
| R09 | Three focus drills and progress view | R07–R08 | Suggested drill is useful and optional; game and keyboard metrics are clearly separate |
| R10 | Fixed challenge clock and schedule | R02 | Equivalent timestamped input produces equal results across update/frame partitions |
| R11 | Game Center feasibility prototype | R02 | OS support, invite routing and one fixed course verified with two test accounts |
| R12 | Relay 60 scoring and friend flow | R10–R11 | Versioned course, completion/interruption submission and rematch verified |
| R13 | TestFlight beta and tuning | R06, R09, R12 | Cohort feedback and basic metrics reviewed; blocking defects closed |
| R14 | Public-release hardening | R13 | Device/accessibility/store checklist passed; limitations described accurately |
| R15 | Optional expansion and purchase flow | R13; only after content is ready | Additional content delivers value; entitlement/restore tested; no power advantage |

## 10. What to measure

Use the smallest measurement system that answers actual product questions. Keep detailed typing events local. For the small beta, use observations, short surveys and an explicitly user-initiated export of aggregate session summaries. Do not upload typed text or activate an analytics SDK merely because a retention table exists in this plan.

| Question | Measure | Proposed beta decision rule |
| --- | --- | --- |
| Can players start? | Time to first correct hit; tutorial completion without coaching | At least 8 of the first 10 observed adults finish the tutorial unaided |
| Is it replayable? | Voluntary second run; return on another day | At least 6 of 10 observed players choose another run; examine later returns separately |
| Is practice useful? | Drill completion, dismissals, observed clarity of recommendation | Players can explain why a drill was suggested; revise unclear or repetitive drills |
| Is competition understandable? | Invite opened, correct course reached, attempt finished, result found | At least 8 of 10 observed friend pairs complete the flow unaided |
| Does ordinary typing improve? | Matched-assessment WPM and error change; retention check | Exploratory evidence only; no learning-effect claim from arcade gains or a small uncontrolled pilot |
| Is the app reliable? | Crashes, freezes, lost progress, duplicate results | Zero known blockers, data-loss bugs or reproducible fairness defects before release |

These thresholds are project hypotheses, not industry benchmarks or statistically strong conclusions. Record sample sizes and reasons for drop-off. Initial beta recruitment should focus on adults so early feedback does not depend on school/classroom arrangements; the intended public audience remains teens and adults.

## 11. Release-quality gates

**Input and feel:** Test rapid alternating touches, simultaneous touches, finger slides across keys, accidental repeated input, symbol switching, target switching and external-keyboard routing. Check that touch-down feedback remains immediate and one intentional press generates one gameplay input.

**Fairness:** Test precomputed course schedules, strict course/scoring versions, no paid advantages, interruption handling, duplicate submissions and extreme input streams. Compare replay hashes across simulator and device builds. Do not ship a public score comparison with a known deterministic mismatch.

**Lifecycle and storage:** Test background/foreground, calls, audio interruptions, memory pressure, process termination, upgrades and save migration. Solo recovery must not allow restoring an advantageous ranked snapshot.

**Device and accessibility:** Test compact and large iPhones and the oldest supported OS available to the test team. Check iPad solo layout and clearly scope iPad competitive support. Support larger text in menus, readable contrast, non-color cues, reduced motion and sound-off feedback. Make menus, results and assessments accessible with VoiceOver. The falling-word arcade remains a visual experience unless a separate nonvisual design is validated; do not advertise full accessibility prematurely.

**Performance:** Measure frame-time distribution, input-to-feedback latency, battery and heat in a sustained session. Initial target: stable 60 fps on the representative supported phone, with no scoring difference when rendering runs at another refresh rate. Use the oldest available supported device to tune particles and effects.

**Store readiness:** Use original/licensed art and audio; review final title and word banks; prepare real gameplay screenshots, support and privacy pages, accurate age-rating answers, review notes and a tested build. If selling an expansion, test its purchase and restore paths and disclose what costs extra. Apple requires complete functionality, accurate metadata and on-device stability checks; final approval is Apple's decision. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

**Release operations:** Keep versioned scoreboards/content, a reproducible build and a small regression checklist. After launch, prioritize crashes, progress loss and fairness problems before new enemies. Avoid changing live competitive rules under an existing scoreboard.

## 12. Commercial design and scope guardrails

The beta is entirely free. The proposed free public core includes the first six missions, endless play, basic focus drills, keyboard checks and Relay 60 friend competition. An optional one-time expansion can include the two additional six-mission districts and a defined cosmetic pack. A premium purchase never changes a score multiplier, shield strength or ranked encounter schedule.

Set the price after the content and beta value are clear; no price or revenue forecast is assumed here. Include standard purchase restoration and an offline entitlement state if the expansion ships. Delay monetization if its integration threatens the quality of the free core.

Do not include live multiplayer, leagues, clans, chat, public user-authored word packs, AI-generated lessons, subscriptions, consumable boosts, cloud account infrastructure, classroom reporting or a full multilingual curriculum in the first release. These features create separate product and operational obligations. Add one only when observed use justifies it.

## 13. Risks and fallback decisions

| Risk | Early test | Fallback |
| --- | --- | --- |
| Custom keyboard practice does not transfer | Native-keyboard baseline/retest pilot | Keep honest arcade positioning; revise practice before making stronger claims |
| Content feels repetitive | Watch voluntary replays across six missions | Improve encounter patterns, target choices and pacing before adding more districts |
| Friend APIs do not support the imagined flow | Two-account Game Center prototype | One permanent comparable course and supported standings; defer arbitrary challenges |
| New APIs exclude older iOS versions | Capability test on minimum supported OS | Keep solo playable and label unavailable invitation functionality |
| Competitive rules drift with device timing | Fixed-step replay fixtures and physical-device runs | Do not release ranked scores until determinism is reliable |
| Solo project grows too large | Complete M1 before expanding scope | Ship six excellent missions and one friend course; move expansion to a later update |
| Purchase work delays launch | Evaluate after beta content validation | Launch the free core without a store |
| Metrics imply more certainty than available | Review definitions and results copy | Report separate game and text-entry observations; avoid unsupported learning promises |

## 14. Proposed final decision

Approve this as the shared direction, including the explicitly labeled planning defaults, then begin R01–R05: validate real-device play and ship one complete mission with saved progress and a useful result screen. Do not begin with more cosmetic content or a backend. The first milestone should prove the full player experience and the architecture needed for the remaining features.

This plan is complete enough for review. Implementation, repository issue creation, external beta invitations, purchases and release submission have not been performed.
