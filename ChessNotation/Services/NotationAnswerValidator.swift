import Foundation

enum NotationAnswerValidator {
    static func isCorrect(_ answer: String, for move: NotationMove) -> Bool {
        normalize(answer) == normalize(move.san)
    }

    static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "0-0-0", with: "O-O-O")
            .replacingOccurrences(of: "0-0", with: "O-O")
    }
}
