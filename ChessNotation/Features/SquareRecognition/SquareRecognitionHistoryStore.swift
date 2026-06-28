import Foundation

protocol SquareRecognitionHistoryStoring {
    func loadResults() throws -> [SquareRecognitionResult]
    func saveResult(_ result: SquareRecognitionResult) throws
}

struct SquareRecognitionHistoryStore: SquareRecognitionHistoryStoring {
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
                .appendingPathComponent("square-recognition-history.json")
        }

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadResults() throws -> [SquareRecognitionResult] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([SquareRecognitionResult].self, from: data)
            .sorted { $0.finishedAt > $1.finishedAt }
    }

    func saveResult(_ result: SquareRecognitionResult) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        var results = (try? loadResults()) ?? []
        results.append(result)
        results.sort { $0.finishedAt > $1.finishedAt }
        let data = try encoder.encode(results)
        try data.write(to: fileURL, options: [.atomic])
    }
}
