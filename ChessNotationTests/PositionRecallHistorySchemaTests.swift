import Foundation
import Testing
@testable import ChessNotation

struct PositionRecallHistorySchemaTests {
    private func temporaryFileURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PositionRecallHistorySchemaTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("history.json")
    }

    private func result(promptCount: Int = 1) -> PositionRecallSessionResult {
        PositionRecallSessionResult(
            difficulty: .beginner,
            orientation: .white,
            promptCount: promptCount,
            exactCount: promptCount,
            partialCount: 0,
            missingCount: 0,
            extraCount: 0,
            wrongPieceCount: 0,
            wrongSideCount: 0,
            averageLatency: 1.0,
            bestStreak: promptCount,
            finishReason: .completed
        )
    }

    @Test
    func legacyArrayPayloadLoadsAndMigratesOnNextSave() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        try JSONEncoder().encode([result()]).write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        #expect(try store.loadResults().map(\.promptCount) == [1])

        try store.saveResult(result(promptCount: 2))
        let object = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: fileURL)) as? [String: Any])
        #expect(object["schemaVersion"] as? Int == PositionRecallReconstructionHistoryStore.currentSchemaVersion)
        #expect((object["results"] as? [[String: Any]])?.count == 2)
        #expect(try store.loadResults().map(\.promptCount) == [1, 2])
    }

    @Test
    func currentEnvelopeRoundTrips() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        try store.saveResult(result(promptCount: 3))

        #expect(try store.loadResults().map(\.promptCount) == [3])
        let object = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: fileURL)) as? [String: Any])
        #expect(object["schemaVersion"] as? Int == 1)
    }

    @Test
    func futureSchemaIsRejectedAndPreserved() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let payload = Data(
            """
            {
              "schemaVersion": 99,
              "results": []
            }
            """.utf8
        )
        try payload.write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        #expect(throws: PositionRecallHistoryStoreError.unsupportedSchemaVersion(
            actualVersion: 99,
            maximumSupportedVersion: PositionRecallReconstructionHistoryStore.currentSchemaVersion
        )) {
            _ = try store.loadResults()
        }
        #expect(try Data(contentsOf: fileURL) == payload)
        #expect(try Data(contentsOf: store.preservedCorruptPayloadURL) == payload)
    }

    @Test
    func invalidNonpositiveSchemaIsRejectedAsCorrupt() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        try Data("{\"schemaVersion\":0,\"results\":[]}".utf8).write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        #expect(throws: PositionRecallHistoryStoreError.corruptPayload) {
            _ = try store.loadResults()
        }
        #expect(FileManager.default.fileExists(atPath: store.preservedCorruptPayloadURL.path))
    }
}
