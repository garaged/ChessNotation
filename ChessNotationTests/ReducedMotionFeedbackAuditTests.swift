import Foundation
import Testing

struct ReducedMotionFeedbackAuditTests {
    private struct FlowRequirement {
        let path: String
        let visibleFeedbackIdentifier: String
        let completionIdentifier: String
    }

    private static let flows = [
        FlowRequirement(
            path: "ChessNotation/Features/PieceMovement/PieceMovementFeature.swift",
            visibleFeedbackIdentifier: "pieceMovement.feedback",
            completionIdentifier: "pieceMovement.resultsTitle"
        ),
        FlowRequirement(
            path: "ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift",
            visibleFeedbackIdentifier: "positionRecall.feedback",
            completionIdentifier: "positionRecall.resultsTitle"
        )
    ]

    @Test
    func primaryMiniGamesDoNotRequireAnimationOrHapticsForFeedback() throws {
        let root = try repositoryRoot()
        let optionalEffectMarkers = [
            "withAnimation(",
            ".animation(",
            ".sensoryFeedback(",
            "UIImpactFeedbackGenerator",
            "UINotificationFeedbackGenerator",
            "UISelectionFeedbackGenerator",
            "AudioServicesPlaySystemSound"
        ]

        for flow in Self.flows {
            let source = try source(at: flow.path, root: root)

            for marker in optionalEffectMarkers {
                #expect(
                    !source.contains(marker),
                    Comment(rawValue: "\(flow.path) uses \(marker). Primary gameplay feedback must remain complete when Reduce Motion is enabled or haptics/audio are unavailable; guard optional effects and preserve visible/spoken feedback before adding them.")
                )
            }
        }
    }

    @Test
    func everyPrimaryMiniGameHasVisibleAndSpokenFeedbackFallbacks() throws {
        let root = try repositoryRoot()

        for flow in Self.flows {
            let source = try source(at: flow.path, root: root)

            #expect(
                source.contains("Text(feedback)"),
                Comment(rawValue: "\(flow.path) must render textual gameplay feedback independent of color, motion, haptics, or audio.")
            )
            #expect(
                source.contains("\"\(flow.visibleFeedbackIdentifier)\""),
                Comment(rawValue: "\(flow.path) is missing stable feedback identifier \(flow.visibleFeedbackIdentifier).")
            )
            #expect(
                source.contains("\"\(flow.completionIdentifier)\""),
                Comment(rawValue: "\(flow.path) is missing stable completion identifier \(flow.completionIdentifier).")
            )
            #expect(
                source.contains("accessibilitySummary") || source.contains("accessibilityLabel"),
                Comment(rawValue: "\(flow.path) must expose feedback or completion state to assistive technologies.")
            )
        }
    }

    @Test
    func decorativeCompletionSymbolsRemainHiddenFromVoiceOver() throws {
        let root = try repositoryRoot()

        for flow in Self.flows {
            let source = try source(at: flow.path, root: root)
            let completionSymbol = "Image(systemName: \"checkmark.circle.fill\")"

            guard let symbolRange = source.range(of: completionSymbol) else {
                Issue.record("Missing expected decorative completion symbol in \(flow.path)")
                continue
            }

            let suffix = source[symbolRange.lowerBound...]
            let nearby = String(suffix.prefix(320))
            #expect(
                nearby.contains(".accessibilityHidden(true)"),
                Comment(rawValue: "The decorative completion symbol in \(flow.path) should stay hidden so VoiceOver announces the textual result once instead of duplicating it.")
            )
        }
    }

    private func source(at path: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }

    private func repositoryRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

        while candidate.path != "/" {
            let project = candidate.appendingPathComponent("ChessNotation.xcodeproj/project.pbxproj")
            if FileManager.default.fileExists(atPath: project.path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }

        throw ReducedMotionFeedbackAuditError.repositoryRootNotFound
    }
}

private enum ReducedMotionFeedbackAuditError: Error {
    case repositoryRootNotFound
}
