import Foundation

nonisolated enum TrainingFamilyID: String, CaseIterable, Codable, Sendable {
    case notationTraining
    case timedTraining
    case boardSkills
    case positionRecall
}

nonisolated enum TrainingGameEntryID: String, CaseIterable, Codable, Sendable {
    case fullGame
    case randomPositions
    case focusedDrill
    case openingDrill
    case mistakeReview
    case sanBuilder
    case classicTimed
    case sprint
    case accuracyRace
    case survival
    case combo
    case squareRecognition
    case expandedSquareRecognition
    case pieceMovement
    case locatePiece
    case squareOccupant
    case occupiedSquares
    case reconstruction
}

nonisolated enum TrainingGameAvailability: Hashable, Codable, Sendable {
    case playable
    case unavailable(reason: String, recoveryAction: String)

    var isPlayable: Bool {
        if case .playable = self { return true }
        return false
    }
}

nonisolated struct TrainingGameEntry: Hashable, Codable, Sendable {
    let id: TrainingGameEntryID
    let title: String
    let purpose: String
    let availability: TrainingGameAvailability

    init(
        id: TrainingGameEntryID,
        title: String,
        purpose: String,
        availability: TrainingGameAvailability = .playable
    ) {
        self.id = id
        self.title = title
        self.purpose = purpose
        self.availability = availability
    }
}

nonisolated struct TrainingFamily: Hashable, Codable, Sendable {
    let id: TrainingFamilyID
    let title: String
    let purpose: String
    let quickStartEntryID: TrainingGameEntryID
    let entries: [TrainingGameEntry]

    init(
        id: TrainingFamilyID,
        title: String,
        purpose: String,
        quickStartEntryID: TrainingGameEntryID,
        entries: [TrainingGameEntry]
    ) {
        self.id = id
        self.title = title
        self.purpose = purpose
        self.quickStartEntryID = quickStartEntryID
        self.entries = entries
    }

    var quickStartEntry: TrainingGameEntry? {
        entries.first { $0.id == quickStartEntryID }
    }
}

nonisolated enum GameFamilyCatalogValidationError: Error, Equatable, CustomStringConvertible {
    case familyOrderMismatch(expected: [TrainingFamilyID], actual: [TrainingFamilyID])
    case duplicateEntry(TrainingGameEntryID)
    case orphanEntry(TrainingGameEntryID)
    case missingQuickStart(TrainingFamilyID, TrainingGameEntryID)
    case unavailableQuickStart(TrainingFamilyID, TrainingGameEntryID)

    var description: String {
        switch self {
        case .familyOrderMismatch(let expected, let actual):
            return "Expected family order \(expected.map(\.rawValue)), found \(actual.map(\.rawValue))."
        case .duplicateEntry(let id):
            return "Game entry \(id.rawValue) appears in more than one family."
        case .orphanEntry(let id):
            return "Game entry \(id.rawValue) has no family."
        case .missingQuickStart(let familyID, let entryID):
            return "Family \(familyID.rawValue) references missing quick start \(entryID.rawValue)."
        case .unavailableQuickStart(let familyID, let entryID):
            return "Family \(familyID.rawValue) references unavailable quick start \(entryID.rawValue)."
        }
    }
}

nonisolated enum GameFamilyCatalog {
    static let requiredFamilyOrder: [TrainingFamilyID] = [
        .notationTraining,
        .timedTraining,
        .boardSkills,
        .positionRecall
    ]

    static let productionFamilies: [TrainingFamily] = [
        TrainingFamily(
            id: .notationTraining,
            title: "Notation Training",
            purpose: "Practice SAN from real games.",
            quickStartEntryID: .fullGame,
            entries: [
                TrainingGameEntry(id: .fullGame, title: "Full Game", purpose: "Play through complete games move by move."),
                unavailable(.randomPositions, "Random Positions", "Practice positions are still served through filtered full-game training."),
                unavailable(.focusedDrill, "Focused Drill", "Use game filters and move feedback until dedicated focused drills are surfaced."),
                unavailable(.openingDrill, "Opening Drill", "Use the opening filter in the game library."),
                unavailable(.mistakeReview, "Mistake Review", "Review weak move tags in notation history."),
                unavailable(.sanBuilder, "SAN Builder", "SAN component parsing is implemented, but the player-facing builder is not surfaced in this release.")
            ]
        ),
        TrainingFamily(
            id: .timedTraining,
            title: "Timed Training",
            purpose: "Build speed under a clock.",
            quickStartEntryID: .classicTimed,
            entries: [
                TrainingGameEntry(id: .classicTimed, title: "Classic Timed", purpose: "Choose a game and train with a time limit."),
                unavailable(.sprint, "Sprint", "Timed variant rules are implemented for future drills; use Classic Timed for this release."),
                unavailable(.accuracyRace, "Accuracy Race", "Timed variant rules are implemented for future drills; use Classic Timed for this release."),
                unavailable(.survival, "Survival", "Timed variant rules are implemented for future drills; use Classic Timed for this release."),
                unavailable(.combo, "Combo", "Timed variant rules are implemented for future drills; use Classic Timed for this release.")
            ]
        ),
        TrainingFamily(
            id: .boardSkills,
            title: "Board Skills",
            purpose: "Build board fluency with short, focused exercises.",
            quickStartEntryID: .squareRecognition,
            entries: [
                TrainingGameEntry(id: .squareRecognition, title: "Square Recognition", purpose: "Find coordinates quickly and accurately."),
                TrainingGameEntry(id: .expandedSquareRecognition, title: "Expanded Square Recognition", purpose: "Use setup variants to tune square-recognition drills."),
                TrainingGameEntry(id: .pieceMovement, title: "Piece Movement", purpose: "Identify every geometric destination.")
            ]
        ),
        TrainingFamily(
            id: .positionRecall,
            title: "Position Recall",
            purpose: "Rebuild positions from memory.",
            quickStartEntryID: .reconstruction,
            entries: [
                unavailable(.locatePiece, "Locate Piece", "Recall question rules are implemented for future drills; use Reconstruction for this release."),
                unavailable(.squareOccupant, "Square Occupant", "Recall question rules are implemented for future drills; use Reconstruction for this release."),
                unavailable(.occupiedSquares, "Occupied Squares", "Recall question rules are implemented for future drills; use Reconstruction for this release."),
                TrainingGameEntry(id: .reconstruction, title: "Reconstruction", purpose: "Study a position, then rebuild every piece.")
            ]
        )
    ]

    static func validate(_ families: [TrainingFamily] = productionFamilies) -> [GameFamilyCatalogValidationError] {
        var errors: [GameFamilyCatalogValidationError] = []

        let actualOrder = families.map(\.id)
        if actualOrder != requiredFamilyOrder {
            errors.append(.familyOrderMismatch(expected: requiredFamilyOrder, actual: actualOrder))
        }

        var entryOwners: [TrainingGameEntryID: TrainingFamilyID] = [:]
        for family in families {
            let entryIDs = Set(family.entries.map(\.id))
            guard let quickStart = family.entries.first(where: { $0.id == family.quickStartEntryID }) else {
                errors.append(.missingQuickStart(family.id, family.quickStartEntryID))
                continue
            }
            if !quickStart.availability.isPlayable {
                errors.append(.unavailableQuickStart(family.id, quickStart.id))
            }

            for entry in family.entries {
                if entryOwners[entry.id] != nil {
                    errors.append(.duplicateEntry(entry.id))
                }
                entryOwners[entry.id] = family.id
            }

            if !entryIDs.contains(family.quickStartEntryID) {
                errors.append(.missingQuickStart(family.id, family.quickStartEntryID))
            }
        }

        for entryID in TrainingGameEntryID.allCases where entryOwners[entryID] == nil {
            errors.append(.orphanEntry(entryID))
        }

        return errors
    }

    private static func unavailable(
        _ id: TrainingGameEntryID,
        _ title: String,
        _ purpose: String
    ) -> TrainingGameEntry {
        TrainingGameEntry(
            id: id,
            title: title,
            purpose: purpose,
            availability: .unavailable(
                reason: "Not surfaced as a standalone game in this release.",
                recoveryAction: purpose
            )
        )
    }
}
