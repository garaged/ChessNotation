import Foundation

enum SANBuilderComponentKind: String, Codable, CaseIterable {
    case piece
    case disambiguation
    case capture
    case destination
    case promotion
    case castling
    case suffix
}

struct SANBuilderComponent: Hashable, Codable {
    let kind: SANBuilderComponentKind
    let value: String
}

struct SANBuilderChallenge: Hashable, Codable {
    let expectedSAN: String
    let components: [SANBuilderComponent]

    func assembledAnswer(from selected: [SANBuilderComponent]) -> String {
        selected.map { $0.value }.joined()
    }

    func isCorrect(_ selected: [SANBuilderComponent]) -> Bool {
        normalize(assembledAnswer(from: selected)) == normalize(expectedSAN)
    }

    func firstMistake(in selected: [SANBuilderComponent]) -> SANBuilderComponentKind? {
        let count = max(components.count, selected.count)
        for index in 0..<count {
            if index >= components.count { return selected[index].kind }
            if index >= selected.count { return components[index].kind }
            if components[index] != selected[index] { return components[index].kind }
        }
        return nil
    }

    private func normalize(_ value: String) -> String {
        value.replacingOccurrences(of: "0", with: "O")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
