import Foundation

protocol PositionRecallReconstructionHistoryStoring {
    func loadResults() throws -> [PositionRecallSessionResult]
    func saveResult(_ result: PositionRecallSessionResult) throws
}

enum PositionRecallHistoryStoreError: Error, Equatable {
    case fileTooLarge(actualBytes: Int, maximumBytes: Int)
    case tooManyRecords(actualCount: Int, maximumCount: Int)
    case corruptPayload
}

struct PositionRecallReconstructionHistoryStore: PositionRecallReconstructionHistoryStoring {
    static let maximumFileSize = 2 * 1_024 * 1_024
    static let maximumRecordCount = 5_000

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
            results = try decoder.decode([PositionRecallSessionResult].self, from: data)
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
        let data = try encoder.encode(results)
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
