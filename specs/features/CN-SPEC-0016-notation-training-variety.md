# CN-SPEC-0016: Notation Training Variety

Status: Accepted
Owner: Project
Last updated: 2026-07-07

## Intent

Turn notation practice into a configurable training system that preserves full-game play while adding varied, focused, and history-informed drills with precise, non-spoiling feedback.

## Scope

In scope:

- Full game, random position, focused drill, opening drill, and mistake review session styles.
- Filters by opening, difficulty, move tag, and eligible phase where data supports them.
- One-attempt and three-attempt answer policies.
- Immediate-next and short-feedback-pause progression.
- Semantic SAN feedback and mode-specific results/history metadata.
- Safe fallback when a requested drill has insufficient eligible material.

Out of scope:

- Runtime engine analysis, best-move discovery, or tactics verification.
- Deriving complete chess legality beyond the trusted bundled move records.
- Timed scoring variants owned by CN-SPEC-0017.
- New SAN component UI owned by CN-SPEC-0020.

## Functional Requirements

- CN-SPEC-0016-FR001: Existing full-game notation behavior must remain available and preserve move order, attempts, hints, reveal/skip behavior, evaluation visibility, completion, and existing history compatibility.
- CN-SPEC-0016-FR002: Random-position sessions must select eligible moves across the configured library and render each prompt from that move's `fenBefore`.
- CN-SPEC-0016-FR003: Independent-drill sessions must move to a newly generated challenge after resolution instead of continuing automatically through the source game's next move.
- CN-SPEC-0016-FR004: Focused drills must support captures, checks, checkmates, castling, promotions, pawn moves, piece moves, and SAN disambiguation when those categories can be identified reliably from bundled data.
- CN-SPEC-0016-FR005: Opening drills must restrict candidates to selected opening metadata and an explicitly defined opening-ply boundary.
- CN-SPEC-0016-FR006: Mistake review must prioritize previously missed challenge identities or move categories and fall back to a general eligible drill when history is absent, stale, or insufficient.
- CN-SPEC-0016-FR007: Difficulty profiles must influence candidate complexity, eligible depth, attempt count, and hint availability rather than only changing a displayed label.
- CN-SPEC-0016-FR008: Players must be able to choose one-attempt or three-attempt answer policy where the selected session style permits it.
- CN-SPEC-0016-FR009: Semantic SAN feedback may identify wrong piece, destination, capture marker, check/checkmate suffix, castling form, promotion, or required disambiguation only when determinable from the expected move and entered answer.
- CN-SPEC-0016-FR010: Feedback before final resolution must not reveal the complete SAN answer, source square, destination square, or an equivalent reconstruction of the answer.
- CN-SPEC-0016-FR011: SAN normalization rules already accepted by the app must continue to apply consistently in every notation session style.
- CN-SPEC-0016-FR012: Session setup must show a recoverable no-challenges state when filters produce zero candidates and must offer a direct way to relax or reset filters.
- CN-SPEC-0016-FR013: Results must distinguish full-game completion from fixed-count drill completion, user exit, unavailable content, and other supported finish reasons.
- CN-SPEC-0016-FR014: Saved results must include session style, difficulty, filters, answer policy, prompt count, correctness, first-try count, attempts, hints/reveals, mistake categories, and source game identities where applicable.
- CN-SPEC-0016-FR015: Prompt generation must use CN-SPEC-0015 boundaries, avoid immediate duplicates when possible, and never synchronously rebuild the complete library index from a view body.
- CN-SPEC-0016-FR016: Existing history files must remain readable, and older records without new configuration fields must receive documented defaults.
- CN-SPEC-0016-FR017: VoiceOver must announce board orientation, prompt context that is safe to expose, answer controls, feedback, attempts remaining, and session progress without announcing the solution.

## Acceptance Criteria

- CN-SPEC-0016-AC001: Given full-game style is selected, when a known fixture is played, then its prompts advance in source move order and existing full-game regression behavior remains unchanged.
- CN-SPEC-0016-AC002: Given random-position style and a deterministic seed, when multiple prompts are resolved, then prompts come from eligible `fenBefore` positions and do not simply continue one source game.
- CN-SPEC-0016-AC003: Given a capture-focused drill, when challenges are generated, then every expected move is tagged or reliably classified as a capture.
- CN-SPEC-0016-AC004: Given an opening and opening-ply limit are selected, when an opening drill runs, then every challenge belongs to that opening and falls within the limit.
- CN-SPEC-0016-AC005: Given mistake history contains eligible missed categories, when mistake review starts, then those categories are prioritized; given no usable history, then a general drill starts without failure.
- CN-SPEC-0016-AC006: Given one-attempt policy, when the first answer is wrong, then the challenge resolves according to the configured reveal/feedback behavior without granting extra attempts.
- CN-SPEC-0016-AC007: Given three-attempt policy, when an answer is wrong, then attempts decrement and the challenge remains active until correct or exhausted.
- CN-SPEC-0016-AC008: Given an answer omits a required capture marker, when submitted, then feedback identifies that category without displaying the complete expected SAN.
- CN-SPEC-0016-AC009: Given an answer differs in a way that cannot be classified safely, when submitted, then generic non-spoiling feedback is shown.
- CN-SPEC-0016-AC010: Given filters yield no eligible candidates, when the player starts, then no crash or infinite loading occurs and reset/relax-filter action is available.
- CN-SPEC-0016-AC011: Given a drill completes, when its result is encoded and loaded, then its style, configuration, counts, mistakes, and source metadata are preserved.
- CN-SPEC-0016-AC012: Given an existing pre-expansion notation history file, when loaded, then prior records remain visible with legacy-compatible defaults.
- CN-SPEC-0016-AC013: Given VoiceOver is active, when a prompt is presented and answered, then controls and state are understandable without exposing the answer before resolution.
- CN-SPEC-0016-AC014: Given a long random drill on representative fixtures, when prompts are generated and answered, then memory remains bounded and the library index is reused.

## Coverage

- `ChessNotationTests/NotationTrainingVarietyTests.swift`: CN-SPEC-0016-AC001, CN-SPEC-0016-AC002, CN-SPEC-0016-AC003, CN-SPEC-0016-AC004, CN-SPEC-0016-AC005, CN-SPEC-0016-AC006, CN-SPEC-0016-AC007, CN-SPEC-0016-AC008, CN-SPEC-0016-AC009, CN-SPEC-0016-AC010, CN-SPEC-0016-AC011, CN-SPEC-0016-AC013, CN-SPEC-0016-AC014
- `ChessNotationTests/NotationTrainingHistoryCompatibilityTests.swift`: CN-SPEC-0016-AC011, CN-SPEC-0016-AC012
- `ChessNotationTests/GameViewModelIntegrationTests.swift`: CN-SPEC-0016-AC001
- `ChessNotation/Domain/NotationTraining.swift`: CN-SPEC-0016-AC002, CN-SPEC-0016-AC003, CN-SPEC-0016-AC004, CN-SPEC-0016-AC005, CN-SPEC-0016-AC008, CN-SPEC-0016-AC009, CN-SPEC-0016-AC010, CN-SPEC-0016-AC011, CN-SPEC-0016-AC014
- `ChessNotation/Features/Game/NotationDrillSession.swift`: CN-SPEC-0016-AC006, CN-SPEC-0016-AC007, CN-SPEC-0016-AC010, CN-SPEC-0016-AC011, CN-SPEC-0016-AC013
- `ChessNotation/Services/NotationTrainingHistoryCompatibility.swift`: CN-SPEC-0016-AC012

## Open Questions

- None. Exact opening-ply defaults and difficulty thresholds are constants covered by tests, not undocumented UI behavior.

## Revision Notes

- 2026-07-07: Initial proposed spec for PR2.
- 2026-07-07: Accepted after implementing configurable drill planning, independent prompt generation, answer policies, semantic SAN feedback, result metadata, legacy history defaults, accessibility-safe status text, and bounded long-session coverage.
