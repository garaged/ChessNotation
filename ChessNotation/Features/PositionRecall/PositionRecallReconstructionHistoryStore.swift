import Foundation

protocol PositionRecallReconstructionHistoryStoring {
    func loadResults() throws -> [PositionRecallSessionResult]
    func saveResult(_ result: PositionRecallSessionResult) throws
}

enum PositionRecallHistoryStoreError: Error, Equatable {
    case fileTooLarge(actualBytes: Int, maximumBytes: Int)
    case tooManyRecords(actualCount: Int, maximumCount: Int)
    case unsupportedSchemaVersion(actualVersion: Int, maximumSupportedVersion: Int)
    case corruptPayload
}

struct PositionRecallReconstructionHistoryStore: PositionRecallReconstructionHistoryStoring {
    static let currentSchemaVersion = 1
    static let maximumFileSize = 2 * 1_024 * 1_024
    static let maximumRecordCount = 5_000

    private struct HistoryEnvelope: Codable {
        let schemaVersion: Int
        let results: [PositionRecallSessionResult]
    }

    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.fileURL = supportDirectory
                .appendingPathComponent("ChessNotation", isDirectory: true)
                .appendingPathComponent("position-recall-reconstruction-history.json")
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadResults() throws -> [PositionRecallSessionResult] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }

        let fileSize = try persistedFileSize()
        guard fileSize <= Self.maximumFileSize else {
            preserveCorruptEvidenceIfNeeded()
            throw PositionRecallHistoryStoreError.fileTooLarge(
                actualBytes: fileSize,
                maximumBytes: Self.maximumFileSize
            )
        }

        let data = try Data(contentsOf: fileURL, options: [.mappedIfSafe])
        let results: [PositionRecallSessionResult]
        do {
            if let envelope = try? decoder.decode(HistoryEnvelope.self, from: data) {
                guard envelope.schemaVersion <= Self.currentSchemaVersion else {
                    preserveCorruptEvidenceIfNeeded()
                    throw PositionRecallHistoryStoreError.unsupportedSchemaVersion(
                        actualVersion: envelope.schemaVersion,
                        maximumSupportedVersion: Self.currentSchemaVersion
                    )
                }
                guard envelope.schemaVersion >= 1 else {
                    preserveCorruptEvidenceIfNeeded()
                    throw PositionRecallHistoryStoreError.corruptPayload
                }
                results = envelope.results
            } else {
                // Legacy schema 0 stored the history directly as a JSON array.
                results = try decoder.decode([PositionRecallSessionResult].self, from: data)
            }
        } catch let error as PositionRecallHistoryStoreError {
            throw error
        } catch {
            preserveCorruptEvidenceIfNeeded()
            throw PositionRecallHistoryStoreError.corruptPayload
        }

        guard results.count <= Self.maximumRecordCount else {
            preserveCorruptEvidenceIfNeeded()
            throw PositionRecallHistoryStoreError.tooManyRecords(
                actualCount: results.count,
                maximumCount: Self.maximumRecordCount
            )
        }
        return results
    }

    func saveResult(_ result: PositionRecallSessionResult) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        var results = try loadResults()
        guard results.count < Self.maximumRecordCount else {
            throw PositionRecallHistoryStoreError.tooManyRecords(
                actualCount: results.count + 1,
                maximumCount: Self.maximumRecordCount
            )
        }

        results.append(result)
        let envelope = HistoryEnvelope(schemaVersion: Self.currentSchemaVersion, results: results)
        let data = try encoder.encode(envelope)
        guard data.count <= Self.maximumFileSize else {
            throw PositionRecallHistoryStoreError.fileTooLarge(
                actualBytes: data.count,
                maximumBytes: Self.maximumFileSize
            )
        }
        try data.write(to: fileURL, options: [.atomic])
    }

    func resetHistory() throws {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }

    var preservedCorruptPayloadURL: URL {
        fileURL.appendingPathExtension("corrupt")
    }

    private func persistedFileSize() throws -> Int {
        let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        return (attributes[.size] as? NSNumber)?.intValue ?? 0
    }

    private func preserveCorruptEvidenceIfNeeded() {
        let evidenceURL = preservedCorruptPayloadURL
        guard !fileManager.fileExists(atPath: evidenceURL.path) else { return }
        try? fileManager.copyItem(at: fileURL, to: evidenceURL)
    }
}
