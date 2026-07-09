# CN-SPEC-0020: Position Recall Game

Status: Proposed
Owner: Project
Last updated: 2026-07-08

## Intent

Add a board-memory mini-game that briefly shows a legal-looking training position, hides one or more pieces or squares, and asks the player to reconstruct what was shown without requiring full engine legality.

## Scope

In scope:

- Position snapshots made from side, piece, and square occupancy.
- Masked-piece and masked-square recall prompts.
- Difficulty-based mask counts, orientation, prompt generation, scoring, history, and accessibility.
- Pure snapshot validation and answer evaluation outside SwiftUI.

Out of scope:

- Full legal-position validation, checkmate/stalemate detection, engine analysis, or best-move tactics.
- Long-term blindfold chess courses beyond short position recall drills.
- Network content or remote leaderboards.

## Functional Requirements

- CN-SPEC-0020-FR001: A recall prompt must preserve board orientation, a complete visible snapshot, one or more masked squares, difficulty, and expected hidden pieces.
- CN-SPEC-0020-FR002: Snapshot validation must reject duplicate occupied squares and positions without enough pieces to mask.
- CN-SPEC-0020-FR003: Beginner difficulty must mask one piece; intermediate and advanced difficulties may mask larger bounded sets.
- CN-SPEC-0020-FR004: Answer validation must compare piece type, side, and square, independent of selection order.
- CN-SPEC-0020-FR005: Feedback must distinguish exact recall, missing pieces, wrong pieces, wrong side, and extra pieces without relying only on color.
- CN-SPEC-0020-FR006: Prompt generation must be deterministic when seeded and must avoid unbounded attempts.
- CN-SPEC-0020-FR007: Results must preserve difficulty, orientation, prompt count, exact/partial correctness, missing/extra/wrong counts, average latency, streak, and finish reason.
- CN-SPEC-0020-FR008: VoiceOver must identify the board orientation, known pieces, masked squares, current reconstructed pieces, feedback, and progress.
- CN-SPEC-0020-FR009: Board rendering must reuse existing square mapping and lightweight board UI patterns without engine, network, or large asset dependencies.

## Acceptance Criteria

- CN-SPEC-0020-AC001: Given a snapshot with duplicate occupied squares, when validated, then it is rejected.
- CN-SPEC-0020-AC002: Given beginner difficulty and a valid snapshot, when a prompt is generated, then exactly one occupied square is masked.
- CN-SPEC-0020-AC003: Given intermediate and advanced difficulty, when prompts are generated, then mask counts are bounded and never exceed occupied-piece count.
- CN-SPEC-0020-AC004: Given an exact answer in any order, when evaluated, then it is correct.
- CN-SPEC-0020-AC005: Given missing, extra, wrong-piece, and wrong-side answers, when evaluated, then each category is recorded and communicated textually.
- CN-SPEC-0020-AC006: Given the same seed and fixtures, when prompts are generated repeatedly, then prompt sequence is deterministic.
- CN-SPEC-0020-AC007: Given black orientation, when masked squares are displayed or selected, then mapping still refers to the same chess coordinates.
- CN-SPEC-0020-AC008: Given a completed session, when saved and restored, then position-recall metrics are preserved.
- CN-SPEC-0020-AC009: Given VoiceOver, when the player explores and submits a recall, then visible pieces, masked squares, reconstructed pieces, feedback, and progress are understandable.
- CN-SPEC-0020-AC010: Given one thousand generated prompts from representative snapshots, when generation runs, then it terminates within documented bounds and retains bounded state.

## Coverage

- Pending coverage: CN-SPEC-0020-AC001
- Pending coverage: CN-SPEC-0020-AC002
- Pending coverage: CN-SPEC-0020-AC003
- Pending coverage: CN-SPEC-0020-AC004
- Pending coverage: CN-SPEC-0020-AC005
- Pending coverage: CN-SPEC-0020-AC006
- Pending coverage: CN-SPEC-0020-AC007
- Pending coverage: CN-SPEC-0020-AC008
- Pending coverage: CN-SPEC-0020-AC009
- Pending coverage: CN-SPEC-0020-AC010

## Open Questions

- None. This release is memory recall only and does not claim complete chess legality.

## Revision Notes

- 2026-07-08: Recreated missing proposed spec for the corrective CN-SPEC-0020 path.
