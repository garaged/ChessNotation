import Foundation

enum SANBuilderParser {
    static func parse(_ san: String) -> SANBuilderChallenge? {
        let value = san.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }

        let normalizedCastle = value.replacingOccurrences(of: "0", with: "O")
        if normalizedCastle == "O-O" || normalizedCastle == "O-O-O" {
            return SANBuilderChallenge(
                expectedSAN: normalizedCastle,
                components: [SANBuilderComponent(kind: .castling, value: normalizedCastle)]
            )
        }

        var working = value
        var suffix: String?
        if working.hasSuffix("+") || working.hasSuffix("#") {
            suffix = String(working.removeLast())
        }

        var promotion: String?
        if let index = working.lastIndex(of: "=") {
            promotion = String(working[index...])
            working = String(working[..<index])
        }

        guard working.count >= 2 else { return nil }
        let destination = String(working.suffix(2))
        guard ChessSquare(destination) != nil else { return nil }
        working.removeLast(2)

        var components: [SANBuilderComponent] = []
        if let first = working.first, "KQRBN".contains(first) {
            components.append(SANBuilderComponent(kind: .piece, value: String(first)))
            working.removeFirst()
        }

        let capture = working.contains("x")
        working.removeAll { $0 == "x" }
        if !working.isEmpty {
            components.append(SANBuilderComponent(kind: .disambiguation, value: working))
        }
        if capture {
            components.append(SANBuilderComponent(kind: .capture, value: "x"))
        }
        components.append(SANBuilderComponent(kind: .destination, value: destination))
        if let promotion {
            components.append(SANBuilderComponent(kind: .promotion, value: promotion))
        }
        if let suffix {
            components.append(SANBuilderComponent(kind: .suffix, value: suffix))
        }

        return SANBuilderChallenge(expectedSAN: value, components: components)
    }
}
