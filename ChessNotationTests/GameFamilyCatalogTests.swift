import Testing
@testable import ChessNotation

struct GameFamilyCatalogTests {
    @Test
    func productionCatalogHasExpectedFamilyOrderAndNoValidationErrors() {
        #expect(GameFamilyCatalog.productionFamilies.map(\.id) == GameFamilyCatalog.requiredFamilyOrder)
        #expect(GameFamilyCatalog.validate().isEmpty)
    }

    @Test
    func everyCatalogGameAppearsExactlyOnce() {
        let entryIDs = GameFamilyCatalog.productionFamilies.flatMap { family in
            family.entries.map(\.id)
        }

        #expect(Set(entryIDs) == Set(TrainingGameEntryID.allCases))
        #expect(entryIDs.count == Set(entryIDs).count)
    }

    @Test
    func quickStartsResolveToPlayableCurrentPresets() throws {
        for family in GameFamilyCatalog.productionFamilies {
            let quickStart = try #require(family.quickStartEntry)
            #expect(quickStart.availability.isPlayable)
        }

        #expect(GameFamilyCatalog.productionFamilies.first { $0.id == .notationTraining }?.quickStartEntryID == .fullGame)
        #expect(GameFamilyCatalog.productionFamilies.first { $0.id == .timedTraining }?.quickStartEntryID == .classicTimed)
        #expect(GameFamilyCatalog.productionFamilies.first { $0.id == .boardSkills }?.quickStartEntryID == .squareRecognition)
        #expect(GameFamilyCatalog.productionFamilies.first { $0.id == .positionRecall }?.quickStartEntryID == .reconstruction)
    }

    @Test
    func validationRejectsUnexpectedFamilyOrder() {
        let reversed = Array(GameFamilyCatalog.productionFamilies.reversed())
        let errors = GameFamilyCatalog.validate(reversed)

        #expect(errors.contains(.familyOrderMismatch(
            expected: GameFamilyCatalog.requiredFamilyOrder,
            actual: reversed.map(\.id)
        )))
    }

    @Test
    func validationRejectsDuplicateAndOrphanEntries() throws {
        var families = GameFamilyCatalog.productionFamilies
        let notation = try #require(families.firstIndex { $0.id == .notationTraining })
        let timed = try #require(families.firstIndex { $0.id == .timedTraining })
        let duplicated = try #require(families[notation].entries.first)
        var timedEntries = families[timed].entries
        timedEntries[1] = duplicated
        families[timed] = TrainingFamily(
            id: families[timed].id,
            title: families[timed].title,
            purpose: families[timed].purpose,
            quickStartEntryID: families[timed].quickStartEntryID,
            entries: timedEntries
        )

        let errors = GameFamilyCatalog.validate(families)
        #expect(errors.contains(.duplicateEntry(duplicated.id)))
        #expect(errors.contains(.orphanEntry(.sprint)))
    }
}
