import Foundation
import Observation

enum ChessVisualTheme: String, CaseIterable, Identifiable {
    case current
    case marble
    case wood
    case metal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .current: return "Current"
        case .marble: return "Marble"
        case .wood: return "Wood"
        case .metal: return "Metal"
        }
    }

    var subtitle: String {
        switch self {
        case .current: return "Clean tournament colors with polished pieces."
        case .marble: return "Cool stone board with carved marble silhouettes."
        case .wood: return "Warm wooden board with hand-carved looking pieces."
        case .metal: return "Industrial steel board with machined pieces."
        }
    }
}

@Observable
final class AppSettings {
    private let defaults: UserDefaults
    private static let visualThemeKey = "visualTheme"
    private static let evaluationVisibilityPrefix = "evaluationVisibility."

    var visualTheme: ChessVisualTheme {
        didSet {
            defaults.set(visualTheme.rawValue, forKey: Self.visualThemeKey)
        }
    }

    var beginnerEvaluationEnabled: Bool {
        didSet {
            defaults.set(beginnerEvaluationEnabled, forKey: Self.evaluationVisibilityKey(for: .beginner))
        }
    }

    var intermediateEvaluationEnabled: Bool {
        didSet {
            defaults.set(intermediateEvaluationEnabled, forKey: Self.evaluationVisibilityKey(for: .intermediate))
        }
    }

    var advancedEvaluationEnabled: Bool {
        didSet {
            defaults.set(advancedEvaluationEnabled, forKey: Self.evaluationVisibilityKey(for: .advanced))
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let rawValue = defaults.string(forKey: Self.visualThemeKey),
           let storedTheme = ChessVisualTheme(rawValue: rawValue) {
            visualTheme = storedTheme
        } else {
            visualTheme = .current
        }

        beginnerEvaluationEnabled = defaults.object(forKey: Self.evaluationVisibilityKey(for: .beginner)) as? Bool ?? false
        intermediateEvaluationEnabled = defaults.object(forKey: Self.evaluationVisibilityKey(for: .intermediate)) as? Bool ?? true
        advancedEvaluationEnabled = defaults.object(forKey: Self.evaluationVisibilityKey(for: .advanced)) as? Bool ?? true
    }

    func isEvaluationEnabled(for difficulty: Difficulty) -> Bool {
        switch difficulty {
        case .beginner:
            return beginnerEvaluationEnabled
        case .intermediate:
            return intermediateEvaluationEnabled
        case .advanced:
            return advancedEvaluationEnabled
        }
    }

    func bindingValue(for difficulty: Difficulty) -> Bool {
        switch difficulty {
        case .beginner:
            return beginnerEvaluationEnabled
        case .intermediate:
            return intermediateEvaluationEnabled
        case .advanced:
            return advancedEvaluationEnabled
        }
    }

    func setEvaluationEnabled(_ isEnabled: Bool, for difficulty: Difficulty) {
        switch difficulty {
        case .beginner:
            beginnerEvaluationEnabled = isEnabled
        case .intermediate:
            intermediateEvaluationEnabled = isEnabled
        case .advanced:
            advancedEvaluationEnabled = isEnabled
        }
    }

    private static func evaluationVisibilityKey(for difficulty: Difficulty) -> String {
        evaluationVisibilityPrefix + difficulty.rawValue
    }
}
