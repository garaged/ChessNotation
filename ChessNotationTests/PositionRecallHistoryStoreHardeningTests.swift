import Foundation
import Testing
@testable import ChessNotation

struct PositionRecallHistoryStoreHardeningTests {
    private func temporaryFileURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PositionRecallHistoryStoreTests-\(UUID().uuidString)", isDirectory: true)
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
            averageLatency: 1.25,
            bestStreak: promptCount,
            finishReason: .completed
        )
    }

    @Test
    func saveAndLoadRoundTripUsesCompleteAtomicPayload() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        try store.saveResult(result())
        try store.saveResult(result(promptCount: 2))

        let loaded = try store.loadResults()
        #expect(loaded.map(\.promptCount) == [1, 2])
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test
    func corruptPayloadIsPreservedAndNotSilentlyOverwritten() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let corruptData = Data("{not-json".utf8)
        try corruptData.write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        #expect(throws: PositionRecallHistoryStoreError.corruptPayload) {
            _ = try store.loadResults()
        }
        #expect(try Data(contentsOf: fileURL) == corruptData)
        #expect(try Data(contentsOf: store.preservedCorruptPayloadURL) == corruptData)

        #expect(throws: PositionRecallHistoryStoreError.corruptPayload) {
            try store.saveResult(result())
        }
        #expect(try Data(contentsOf: fileURL) == corruptData)
    }

    @Test
    func oversizedPayloadIsRejectedBeforeDecodeAndPreserved() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let oversized = Data(repeating: 0x41, count: PositionRecallReconstructionHistoryStore.maximumFileSize + 1)
        try oversized.write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        #expect(throws: PositionRecallHistoryStoreError.fileTooLarge(
            actualBytes: oversized.count,
            maximumBytes: PositionRecallReconstructionHistoryStore.maximumFileSize
        )) {
            _ = try store.loadResults()
        }
        #expect(FileManager.default.fileExists(atPath: store.preservedCorruptPayloadURL.path))
    }

    @Test
    func excessiveRecordCountIsRejectedWithinConfiguredBound() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let records = Array(
            repeating: result(),
            count: PositionRecallReconstructionHistoryStore.maximumRecordCount + 1
        )
        let data = try JSONEncoder().encode(records)
        try data.write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)

        #expect(throws: PositionRecallHistoryStoreError.tooManyRecords(
            actualCount: records.count,
            maximumCount: PositionRecallReconstructionHistoryStore.maximumRecordCount
        )) {
            _ = try store.loadResults()
        }
    }

    @Test
    func resetRemovesPrimaryHistoryButKeepsPreservedEvidence() throws {
        let fileURL = try temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }
        let corruptData = Data("invalid".utf8)
        try corruptData.write(to: fileURL)
        let store = PositionRecallReconstructionHistoryStore(fileURL: fileURL)
        _ = try? store.loadResults()

        try store.resetHistory()

        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
        #expect(FileManager.default.fileExists(atPath: store.preservedCorruptPayloadURL.path))
        #expect(try store.loadResults().isEmpty)
    }
}
