import Foundation

nonisolated struct PerformanceRegressionBudget: Hashable, Sendable {
    let name: String
    let maximumOperationCount: Int
    let toleranceFraction: Double
    let remediation: String

    init(
        name: String,
        maximumOperationCount: Int,
        toleranceFraction: Double = 0.10,
        remediation: String
    ) {
        self.name = name
        self.maximumOperationCount = max(0, maximumOperationCount)
        self.toleranceFraction = max(0, toleranceFraction)
        self.remediation = remediation
    }

    var toleratedMaximum: Int {
        let tolerance = Int((Double(maximumOperationCount) * toleranceFraction).rounded(.up))
        return maximumOperationCount + tolerance
    }

    func evaluate(actualOperationCount: Int) -> PerformanceRegressionResult {
        let actual = max(0, actualOperationCount)
        guard actual <= toleratedMaximum else {
            return PerformanceRegressionResult(
                passed: false,
                message: "\(name) used \(actual) operations; budget is \(maximumOperationCount) with a tolerated maximum of \(toleratedMaximum). \(remediation)"
            )
        }

        return PerformanceRegressionResult(
            passed: true,
            message: "\(name) used \(actual) operations within the tolerated maximum of \(toleratedMaximum)."
        )
    }
}

nonisolated struct PerformanceRegressionResult: Hashable, Sendable {
    let passed: Bool
    let message: String
}

nonisolated enum ChessNotationPerformanceBudgets {
    static let repeatedFENLookupMisses = PerformanceRegressionBudget(
        name: "Repeated FEN lookup misses",
        maximumOperationCount: 1,
        toleranceFraction: 0,
        remediation: "Check FEN normalization and cache reuse before parsing."
    )

    static let repeatedLibraryResourceDecodes = PerformanceRegressionBudget(
        name: "Repeated library resource decodes",
        maximumOperationCount: 4,
        toleranceFraction: 0,
        remediation: "Check the repository cache key and ensure bundled resources are decoded only on the initial load."
    )

    static let timerTimeoutTransitions = PerformanceRegressionBudget(
        name: "Timer timeout transitions",
        maximumOperationCount: 1,
        toleranceFraction: 0,
        remediation: "Check terminal-state idempotence and prevent repeated refresh callbacks from finishing the session again."
    )

    static func challengeGenerationAttempts(maximumAttempts: Int) -> PerformanceRegressionBudget {
        PerformanceRegressionBudget(
            name: "Challenge generation attempts",
            maximumOperationCount: max(1, maximumAttempts),
            toleranceFraction: 0,
            remediation: "Check filter acceptance and ensure generation exits after the configured attempt limit."
        )
    }

    static func retainedChallengeCycle(sourceCount: Int) -> PerformanceRegressionBudget {
        PerformanceRegressionBudget(
            name: "Retained shuffled challenges",
            maximumOperationCount: max(0, sourceCount - 1),
            toleranceFraction: 0,
            remediation: "Check that resolved challenges are removed from the current shuffled cycle instead of accumulating."
        )
    }
}
