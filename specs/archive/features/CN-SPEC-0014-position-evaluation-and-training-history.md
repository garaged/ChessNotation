# CN-SPEC-0014: Position Evaluation and Training History

Status: Accepted
Owner: Project
Last updated: 2026-06-28

## Intent

Players should see the stored engine evaluation for the current notation
position when a bundled game includes evaluated move data, and every training
mode should persist enough history to make progress visible over useful time
ranges. History should emphasize the metrics that fit each mode instead of
forcing the same dashboard onto notation games and square-recognition drills.

## Scope

In scope:

- Showing stored engine evaluation for the current notation board position when
  bundled game data provides it.
- Persisting completed history for untimed notation, timed notation, and square
  recognition sessions.
- Defining shared history fields that support filtering, sorting, and future
  migration.
- Showing mode-appropriate summary metrics and plots.
- Providing today, last week, last month, and last year range controls for history
  views.
- Preserving square-recognition result history while extending it with trend
  views.

Out of scope:

- Running an engine locally or remotely.
- Generating new evaluations for positions that do not already have bundled
  evaluation data.
- Cloud sync, accounts, leaderboards, export, or import.
- Opening-analysis lines, best-move suggestions, or principal variation display.
- Replacing existing result screens beyond the additions required for history
  and current-position evaluation.

## Functional Requirements

- CN-SPEC-0014-FR001: The notation game screen must show a current-position evaluation only when the current visible board position has bundled engine evaluation data.
- CN-SPEC-0014-FR002: Current-position evaluation must be derived from stored game data, not from runtime engine analysis.
- CN-SPEC-0014-FR003: For evaluated games, before the first evaluated move is completed, the notation game screen must show the evaluation bar from the start with a neutral `0.0` placeholder so the board layout remains stable.
- CN-SPEC-0014-FR004: After a move advances, the current-position evaluation must update to the evaluation attached to the reached position.
- CN-SPEC-0014-FR005: Evaluation display must include the engine score text, an advantage visualization for White versus Black, and the engine/depth metadata when available.
- CN-SPEC-0014-FR006: Evaluation display must not reveal the SAN answer, source square, destination square, or any best-move hint for the current prompt.
- CN-SPEC-0014-FR007: Completed untimed notation sessions must be persisted locally with game id, game title, finish timestamp, completed moves, total moves, correct moves, incorrect moves, accuracy, first-try correct count, average move time, attempts distribution, skipped-or-revealed count, and mistake counts by move tag.
- CN-SPEC-0014-FR008: Completed timed notation sessions must be persisted locally with the untimed notation fields plus selected duration, time used, finish reason, moves per minute, and completion percentage.
- CN-SPEC-0014-FR009: Completed square-recognition sessions must continue to persist locally with initial time, variant, score, total prompts, correct count, incorrect count, accuracy, average latency, fastest correct latency, slowest latency, and finish timestamp.
- CN-SPEC-0014-FR010: History records must include a stable schema version, unique id, game type, and enough source configuration to segment results by notation game, timed duration, square-recognition initial time, and square-recognition variant.
- CN-SPEC-0014-FR011: Notation histories for a specific game must emphasize accuracy, first-try rate, completion percentage, average move time, and recurring weak move tags.
- CN-SPEC-0014-FR012: Timed notation histories must emphasize accuracy, completed moves, moves per minute, completion percentage, finish reason, and selected duration.
- CN-SPEC-0014-FR013: Square-recognition histories must emphasize score, accuracy, average latency, fastest correct latency, initial time, and variant.
- CN-SPEC-0014-FR014: History views must offer today, last week, last month, and last year range controls and filter the displayed summaries, plots, and lists to the selected range from the current date.
- CN-SPEC-0014-FR015: Each history view must choose a default range that contains useful data, preferring today, then last week, then last month, then last year when the shorter range is empty.
- CN-SPEC-0014-FR016: Notation game detail history must show a trend plot for accuracy and first-try rate when at least two sessions for the selected game exist in the selected range.
- CN-SPEC-0014-FR017: Timed notation history must show a trend plot for completed moves or moves per minute and a secondary accuracy signal when at least two timed sessions exist in the selected range.
- CN-SPEC-0014-FR018: Square-recognition history must show score and average-latency trend plots when at least two sessions exist in the selected range.
- CN-SPEC-0014-FR019: When the selected range has too little data for a meaningful plot, the history view must show the latest session metrics and a clear empty-or-insufficient-data state instead of an empty chart.
- CN-SPEC-0014-FR020: Result screens must save the completed session once and must not duplicate records when the player restarts, returns to the library, or revisits results.
- CN-SPEC-0014-FR021: History storage failures must not prevent the current results screen from being shown or the player from starting another game.
- CN-SPEC-0014-FR022: Existing square-recognition history data must remain readable after the history model is extended.
- CN-SPEC-0014-FR023: Trend plots must show sparse x-axis labels that communicate the selected time range without crowding the chart.
- CN-SPEC-0014-FR024: Trend plots must let players reveal the value for a plotted data point with a simple temporary overlay.

## Acceptance Criteria

- CN-SPEC-0014-AC001: Given a notation game has stored evaluation for the position reached after move one, when the player completes move one and the board advances, then the game screen shows that evaluation score, advantage visualization, engine, and depth.
- CN-SPEC-0014-AC002: Given a notation game has no stored evaluated data at all, when the game screen renders, then no fabricated evaluation bar is shown.
- CN-SPEC-0014-AC021: Given a notation game has stored evaluations but no stored score for the starting visible position, when the game screen first renders, then the evaluation bar is visible as a neutral `0.0` placeholder until the first reached-position evaluation is available.
- CN-SPEC-0014-AC003: Given a player is answering a notation prompt, when current-position evaluation is visible, then it does not expose the SAN answer, source square, destination square, or a best-move hint.
- CN-SPEC-0014-AC004: Given an untimed notation session completes, when results are shown, then one history record is saved with game identity, completion, accuracy, first-try count, average move time, attempts distribution, skipped-or-revealed count, and mistakes by tag.
- CN-SPEC-0014-AC005: Given a timed notation session times out, when results are shown, then one history record is saved with selected duration, time used, finish reason `timedOut`, completed moves, moves per minute, completion percentage, and accuracy.
- CN-SPEC-0014-AC006: Given a square-recognition run ends, when results are shown, then the saved history preserves score, accuracy, latency fields, initial time, variant, and finish timestamp.
- CN-SPEC-0014-AC007: Given a completed session was already saved, when the player restarts from results or navigates away and back, then no duplicate history record is created.
- CN-SPEC-0014-AC008: Given history records exist inside and outside the last week, when last week is selected, then summaries, plots, and session lists include only records from the last seven days.
- CN-SPEC-0014-AC009: Given history records exist inside and outside the last month, when last month is selected, then summaries, plots, and session lists include only records from the trailing one-month window.
- CN-SPEC-0014-AC010: Given history records exist inside and outside the last year, when last year is selected, then summaries, plots, and session lists include only records from the trailing one-year window.
- CN-SPEC-0014-AC011: Given today contains no records but a longer range does, when a history view first opens, then the shortest range containing records is selected by default.
- CN-SPEC-0014-AC012: Given a specific notation game has at least two sessions in the selected range, when its history is shown, then accuracy and first-try rate trends are plotted and weak move tags are summarized.
- CN-SPEC-0014-AC013: Given timed notation has at least two sessions in the selected range, when timed history is shown, then completed moves or moves per minute are plotted with accuracy visible as a companion metric.
- CN-SPEC-0014-AC014: Given square-recognition has at least two sessions in the selected range, when square-recognition history is shown, then score and average-latency trends are plotted.
- CN-SPEC-0014-AC015: Given a selected range has fewer than two records for a plot, when history is shown, then the latest metrics remain visible and the chart area communicates that more sessions are needed.
- CN-SPEC-0014-AC016: Given pre-existing square-recognition history exists in the current JSON shape, when the updated app loads history, then those results still appear with their original metrics.
- CN-SPEC-0014-AC017: Given history storage fails, when any training mode finishes, then the current result screen still appears and reports the save problem without blocking further play.
- CN-SPEC-0014-AC018: Given history records exist inside and outside today, when today is selected, then summaries, plots, and session lists include only records from the current calendar day.
- CN-SPEC-0014-AC019: Given a trend plot is shown, when x-axis labels render, then the plot shows no more than three compact labels for the selected range.
- CN-SPEC-0014-AC020: Given a trend plot is shown, when the player taps the plot area, then a readable value overlay appears for the nearest data point and disappears automatically after a few seconds.

## Coverage

- `ChessNotationTests/GameViewModelIntegrationTests.swift`: CN-SPEC-0014-AC001, CN-SPEC-0014-AC002, CN-SPEC-0014-AC003, CN-SPEC-0014-AC004, CN-SPEC-0014-AC005, CN-SPEC-0014-AC007, CN-SPEC-0014-AC008, CN-SPEC-0014-AC009, CN-SPEC-0014-AC010, CN-SPEC-0014-AC018, CN-SPEC-0014-AC019
- `ChessNotationUITests/ChessNotationUITests.swift`: CN-SPEC-0014-AC002, CN-SPEC-0014-AC021
- `ChessNotationTests/SquareRecognitionTests.swift`: CN-SPEC-0014-AC006, CN-SPEC-0014-AC016
- `ChessNotation/Features/Game/GameViewModel.swift`: CN-SPEC-0014-AC001, CN-SPEC-0014-AC002, CN-SPEC-0014-AC003, CN-SPEC-0014-AC004, CN-SPEC-0014-AC005, CN-SPEC-0014-AC007
- `ChessNotation/Features/Game/ChessBoardView.swift`: CN-SPEC-0014-AC001, CN-SPEC-0014-AC002, CN-SPEC-0014-AC003, CN-SPEC-0014-AC021
- `ChessNotation/Features/Game/GameTrainingView.swift`: CN-SPEC-0014-AC004, CN-SPEC-0014-AC005, CN-SPEC-0014-AC007, CN-SPEC-0014-AC017
- `ChessNotation/Domain/TrainingSession.swift`: CN-SPEC-0014-AC004, CN-SPEC-0014-AC005, CN-SPEC-0014-AC007, CN-SPEC-0014-AC008, CN-SPEC-0014-AC009, CN-SPEC-0014-AC010, CN-SPEC-0014-AC018, CN-SPEC-0014-AC019
- `ChessNotation/Features/Results/ResultsView.swift`: CN-SPEC-0014-AC017
- `ChessNotation/Features/Home/HomeView.swift`: CN-SPEC-0014-AC008, CN-SPEC-0014-AC009, CN-SPEC-0014-AC010, CN-SPEC-0014-AC011, CN-SPEC-0014-AC012, CN-SPEC-0014-AC013, CN-SPEC-0014-AC015, CN-SPEC-0014-AC018, CN-SPEC-0014-AC019, CN-SPEC-0014-AC020
- `ChessNotation/Features/Home/PremiumDesign.swift`: CN-SPEC-0014-AC019, CN-SPEC-0014-AC020
- `ChessNotation/Features/SquareRecognition/SquareRecognitionModels.swift`: CN-SPEC-0014-AC006, CN-SPEC-0014-AC016
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViewModel.swift`: CN-SPEC-0014-AC006, CN-SPEC-0014-AC017
- `ChessNotation/Features/SquareRecognition/SquareRecognitionHistoryStore.swift`: CN-SPEC-0014-AC006, CN-SPEC-0014-AC016
- `ChessNotation/Features/SquareRecognition/SquareRecognitionViews.swift`: CN-SPEC-0014-AC008, CN-SPEC-0014-AC009, CN-SPEC-0014-AC010, CN-SPEC-0014-AC011, CN-SPEC-0014-AC014, CN-SPEC-0014-AC015, CN-SPEC-0014-AC017, CN-SPEC-0014-AC018, CN-SPEC-0014-AC019, CN-SPEC-0014-AC020

## Open Questions

- Resolved: Notation history is a dedicated Game Library destination for the selected launch mode.
- Resolved: Clear-history controls are deferred.
- Resolved: Timed notation history compares all durations together in the first implementation while preserving duration on each record.
- Resolved: Current-position evaluation is shown consistently across notation modes when the per-difficulty evaluation setting allows it.

## Revision Notes

- 2026-06-28: Initial proposed spec for stored current-position evaluation, all-mode training history, and mode-specific trend views.
- 2026-06-28: Accepted after implementing reached-position evaluation, notation history persistence, range-filtered history summaries, trend views, and backward-compatible square-recognition history.
- 2026-06-28: Added today filtering, sparse x-axis labels, and temporary tap overlays for trend values.
- 2026-06-28: Updated evaluated-game board behavior so the evaluation bar appears from the start with a neutral placeholder.
- 2026-07-07: Archived after completion before opening the training-expansion roadmap.