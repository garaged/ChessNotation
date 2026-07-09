import Foundation

protocol PositionRecallReconstructionHistoryStoring {
    func loadResults() throws -> [PositionRecallSessionResult]
    func saveResult(_ result: PositionRecallSessionResult) throws
}

struct PositionRecallReconstructionHistoryStore: PositionRecallReconstructionHistoryStoring {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = supportDirectory
                .appendingPathComponent("ChessNotation", isDirectory: true)
                .appendingPathComponent("position-recall-reconstruction-history.json")
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadResults() throws -> [PositionRecallSessionResult] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([PositionRecallSessionResult].self, from: data)
    }

    func saveResult(_ result: PositionRecallSessionResult) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        var results = (try? loadResults()) ?? []
        results.append(result)
        let data = try encoder.encode(results)
        try data.write(to: fileURL, options: [.atomic])
    }
}
