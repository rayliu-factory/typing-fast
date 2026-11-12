# Run, result and input contracts

Status: First Contact implementation, 12 November 2026.

## Shipped solo rules

`RunRules` distinguishes First Contact from endless play. First Contact uses the authored sequence sun, cat, run, red, map, top, win, joy. It allows one target, moves at 16 logical points per active second, suppresses UFOs and wave escalation, and completes after eight cleared words. Missed words repeat. Six cities each begin with three shield points. All cities falling ends the run. The accuracy medal is optional and requires a completed mission with at least 90% correct counted letter inputs, using the unrounded ratio.

Endless retains the original three word-bank modes, score formula, wave escalation, UFO repair and loss condition. First Contact cannot update an endless high score. Both solo modes pause explicitly and when the app becomes inactive. Restored runs remain paused until the player resumes.

Every start creates one UUID. One immutable final result is produced on victory or loss. Further input and time updates cannot change it. Retrying creates a new UUID. Repeated saves cannot multiply rewards; completion and medal flags are monotonic.

## Input and metrics

`InputSource` records touch and hardware sources for counted single-character input; a run can contain both. Empty-sky taps are ignored. Incorrect keys while a target exists count as attempts, reset combo and preserve typed progress. Space, Tab, backspace and LOCK NEXT change the target; they do not enter or erase text. This is an arcade input contract.

`RunResult` schema version 1 records run ID, rules, training mode, outcome, score, cleared words, correct keys, total keys, active elapsed time and input sources. Accuracy is correct keys divided by counted keys. With no counted input, the results UI displays a dash and gives a first-step instruction. Missed targets are not letter errors, and correct letters on a subsequently missed target remain counted. The UI labels these as arcade results, not a standard typing assessment.

The insight is a simple suggestion based on aggregate accuracy and outcome. It is not a diagnosis of weak keys, finger assignment or measured skill transfer. Left/right keyboard colors indicate key zones, not observed thumb usage.

## Persistence and compatibility

`ProgressStore` owns one atomic JSON file under Application Support/LetterInvaders. `SavedProgress` schema version 1 contains completion, medal, the last result and an optional solo checkpoint. Checkpoints include the random generator and partially typed target state. Feedback events are transient and never replay on restoration.

Checkpoint boundaries are start, cleared word, city impact, pause/background and every three active seconds. Force termination may roll back work since the last successful checkpoint. Failed writes surface a notice and retain earned rewards in memory for the next save attempt. Periodic retry is limited to once per three active seconds. This does not guarantee survival if the process exits while every write is failing.

Malformed JSON starts fresh with a notice. A malformed or invalid checkpoint is dropped while independently decodable mission rewards are retained. Unknown save versions are preserved and writing is disabled, rather than overwriting a newer save. There is no earlier file schema to migrate: existing best scores and preferences remain in their original UserDefaults keys. A future schema change must supply an explicit migration or preserve the unsupported file.

## Reserved boundaries for later milestones

| Run category | Input | Pause and persistence | Result boundary |
| --- | --- | --- | --- |
| Solo arcade, implemented | Custom keys or external keys; source recorded | Pause/resume, local checkpoint | Victory or cities lost; no ranked submission |
| Focus practice, planned | Selected key/word drills with assist policy recorded | Untimed or explicitly timed; safe pause | Separate practice record, no competitive score |
| Typing assessment, planned | Native text editing, insertion/deletion/replacement and composition | Assessment-specific interruption rule | Separate passage metrics; never reuse arcade accuracy |
| Friend competition, planned | Fixed eligible input and hint policy | Fixed course and deadline; interruption ends attempt | Versioned course/scoring, one actual attempt submission |

These future categories have no enabled buttons, storage implementation or network service yet. The current variable-step clock caps updates at 0.1 seconds and is unsuitable for ranked comparisons. Fixed-step replay equivalence and Game Center feasibility remain release-plan gates.
