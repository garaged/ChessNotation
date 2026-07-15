import Foundation
import Testing

struct DynamicTypeReachabilityAuditTests {
    private struct FlowRequirement {
        let path: String
        let requiredActionIdentifiers: [String]
    }

    private static let flows = [
        FlowRequirement(
            path: "ChessNotation/Features/PieceMovement/PieceMovementFeature.swift",
            requiredActionIdentifiers: [
                "pieceMovement.submit",
                "pieceMovement.next",
                "pieceMovement.finish",
                "pieceMovement.playAgain"
            ]
        ),
        FlowRequirement(
            path: "ChessNotation/Features/PositionRecall/PositionRecallReconstructionView.swift",
            requiredActionIdentifiers: [
                "positionRecall.hideNow",
                "positionRecall.submit",
                "positionRecall.next",
                "positionRecall.finish",
                "positionRecall.playAgain"
            ]
        )
    ]

    @Test
    func primaryGameFlowsRemainScrollableAtAccessibilityTextSizes() throws {
        let root = try repositoryRoot()

        for flow in Self.flows {
            let source = try String(contentsOf: root.appendingPathComponent(flow.path), encoding: .utf8)

            #expect(
                source.contains("ScrollView") || source.contains("Form") || source.contains("List"),
                Comment(rawValue: "\(flow.path) must keep its primary content in a scrollable container so large Dynamic Type content and actions remain reachable.")
            )

            for identifier in flow.requiredActionIdentifiers {
                #expect(
                    source.contains("\"\(identifier)\""),
                    Comment(rawValue: "\(flow.path) is missing the stable critical-action identifier \(identifier).")
                )
            }
        }
    }

    @Test
    func criticalFlowsDoNotCapDynamicTypeOrForceSingleLineActions() throws {
        let root = try repositoryRoot()
        let forbiddenMarkers = [
            ".dynamicTypeSize(",
            ".lineLimit(1)",
            ".fixedSize(horizontal: true",
            ".minimumScaleFactor("
        ]

        for flow in Self.flows {
            let source = try String(contentsOf: root.appendingPathComponent(flow.path), encoding: .utf8)
            for marker in forbiddenMarkers {
                #expect(
                    !source.contains(marker),
                    Comment(rawValue: "\(flow.path) contains \(marker), which can hide or compress critical content at accessibility text sizes. Prefer wrapping, vertical layout, and scrolling.")
                )
            }
        }
    }

    @Test
    func primaryActionsAreNotPlacedInsideFixedHeightContainers() throws {
        let root = try repositoryRoot()

        for flow in Self.flows {
            let source = try String(contentsOf: root.appendingPathComponent(flow.path), encoding: .utf8)
            let lines = source.components(separatedBy: .newlines)

            for identifier in flow.requiredActionIdentifiers {
                guard let actionLine = lines.firstIndex(where: { $0.contains("\"\(identifier)\"") }) else {
                    Issue.record("Missing critical-action identifier \(identifier) in \(flow.path)")
                    continue
                }

                let lowerBound = max(0, actionLine - 8)
                let upperBound = min(lines.count - 1, actionLine + 3)
                let nearbySource = lines[lowerBound...upperBound].joined(separator: "\n")

                #expect(
                    !nearbySource.contains(".frame(height:"),
                    Comment(rawValue: "\(identifier) is near a fixed-height frame in \(flow.path). Fixed heights can clip wrapped labels and controls at large Dynamic Type sizes.")
                )
            }
        }
    }

    @Test
    func sourceUsesSemanticFontsForCriticalFlowText() throws {
        let root = try repositoryRoot()

        for flow in Self.flows {
            let source = try String(contentsOf: root.appendingPathComponent(flow.path), encoding: .utf8)
            #expect(
                source.contains(".font(.headline") || source.contains(".font(.title") || source.contains(".font(.subheadline"),
                Comment(rawValue: "\(flow.path) should use semantic text styles that scale with Dynamic Type.")
            )
        }
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

        throw DynamicTypeAuditError.repositoryRootNotFound
    }
}

private enum DynamicTypeAuditError: Error {
    case repositoryRootNotFound
}
