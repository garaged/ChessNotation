import Foundation

enum SquareRecognitionDrillKind: String, Codable, CaseIterable, Sendable {
    case findSquare
    case nameSquare
    case squareColor
    case relativeSquare
    case route
}

enum BoardOrientationPolicy: String, Codable, CaseIterable, Sendable {
    case white
    case black
    case alternating
}

enum SquareRecognitionZone: Hashable, Codable, Sendable {
    case all
    case center
    case corners
    case edges
    case file(Character)
    case rank(Int)
    case quadrant(Int)
}

enum ChessSquareColor: String, Codable, Sendable {
    case light
    case dark
}

struct ChessSquare: Hashable, Codable, Sendable, CustomStringConvertible {
    let file: Int
    let rank: Int

    init?(file: Int, rank: Int) {
        guard (0..<8).contains(file), (0..<8).contains(rank) else { return nil }
        self.file = file
        self.rank = rank
    }

    init?(_ coordinate: String) {
        guard coordinate.count == 2,
              let fileScalar = coordinate.unicodeScalars.first?.value,
              let rank = Int(String(coordinate.last!)) else { return nil }
        self.init(file: Int(fileScalar - UnicodeScalar("a").value), rank: rank - 1)
    }

    var description: String {
        let fileScalar = UnicodeScalar(Int(UnicodeScalar("a").value) + file)!
        return "\(Character(fileScalar))\(rank + 1)"
    }

    var color: ChessSquareColor {
        (file + rank).isMultiple(of: 2) ? .dark : .light
    }

    func offset(file fileDelta: Int, rank rankDelta: Int) -> ChessSquare? {
        ChessSquare(file: file + fileDelta, rank: rank + rankDelta)
    }
}

struct SquareRecognitionPrompt: Hashable, Sendable {
    let target: ChessSquare
    let orientation: BoardOrientationPolicy
    let route: [ChessSquare]
}

struct SquareRecognitionPromptFactory {
    static let allSquares: [ChessSquare] = (0..<8).flatMap { rank in
        (0..<8).compactMap { ChessSquare(file: $0, rank: rank) }
    }

    static func squares(in zone: SquareRecognitionZone) -> [ChessSquare] {
        switch zone {
        case .all:
            return allSquares
        case .center:
            return allSquares.filter { (2...5).contains($0.file) && (2...5).contains($0.rank) }
        case .corners:
            return allSquares.filter { [$0.file, $0.rank].allSatisfy { $0 == 0 || $0 == 7 } }
        case .edges:
            return allSquares.filter { $0.file == 0 || $0.file == 7 || $0.rank == 0 || $0.rank == 7 }
        case let .file(character):
            guard let scalar = character.unicodeScalars.first?.value else { return [] }
            let file = Int(scalar - UnicodeScalar("a").value)
            return allSquares.filter { $0.file == file }
        case let .rank(rank):
            return allSquares.filter { $0.rank == rank - 1 }
        case let .quadrant(index):
            guard (1...4).contains(index) else { return [] }
            let highFile = index == 2 || index == 4
            let highRank = index == 3 || index == 4
            return allSquares.filter {
                (highFile ? $0.file >= 4 : $0.file < 4) &&
                (highRank ? $0.rank >= 4 : $0.rank < 4)
            }
        }
    }

    static func relative(from origin: ChessSquare, fileDelta: Int, rankDelta: Int) -> ChessSquare? {
        origin.offset(file: fileDelta, rank: rankDelta)
    }

    static func routeLength(for difficulty: TrainingDifficulty) -> Int {
        switch difficulty {
        case .beginner: 2
        case .intermediate: 3
        case .advanced: 4
        }
    }
}

final class SquareRecognitionPromptGenerator {
    private let bag: ShuffledChallengeBag
    private let orientationPolicy: BoardOrientationPolicy
    private var promptIndex = 0

    init(
        zone: SquareRecognitionZone,
        orientationPolicy: BoardOrientationPolicy,
        randomizer: ChallengeRandomizing
    ) {
        self.orientationPolicy = orientationPolicy
        let challenges = SquareRecognitionPromptFactory.squares(in: zone).map {
            TrainingChallenge(
                id: TrainingChallengeID($0.description),
                kind: .squareRecognition,
                difficulty: .beginner,
                promptReference: $0.description
            )
        }
        bag = ShuffledChallengeBag(challenges: challenges, randomizer: randomizer)
    }

    func next() -> SquareRecognitionPrompt? {
        guard let challenge = bag.next(), let target = ChessSquare(challenge.promptReference) else { return nil }
        defer { promptIndex += 1 }
        let orientation: BoardOrientationPolicy
        switch orientationPolicy {
        case .white, .black:
            orientation = orientationPolicy
        case .alternating:
            orientation = promptIndex.isMultiple(of: 2) ? .white : .black
        }
        return SquareRecognitionPrompt(target: target, orientation: orientation, route: [])
    }
}

struct SquareRouteAttempt: Hashable, Sendable {
    let expected: [ChessSquare]
    private(set) var selected: [ChessSquare] = []
    private(set) var isResolved = false

    mutating func select(_ square: ChessSquare) {
        guard !isResolved else { return }
        selected.append(square)
        if selected.count == expected.count { isResolved = true }
    }

    var isCorrect: Bool { isResolved && selected == expected }
}

struct SquareRecognitionConfiguration: Hashable, Codable, Sendable {
    let drill: SquareRecognitionDrillKind
    let orientation: BoardOrientationPolicy
    let zone: SquareRecognitionZone
    let difficulty: TrainingDifficulty
    let variant: SquareRecognitionVariant
}

struct SquareRecognitionDrillResult: Hashable, Codable, Sendable {
    let configuration: SquareRecognitionConfiguration
    let score: Int
    let totalPrompts: Int
    let correctPrompts: Int
    let averageLatency: TimeInterval
    let routeCount: Int
    let correctRoutes: Int
}

enum SquareRecognitionAccessibility {
    static func squareLabel(_ square: ChessSquare, orientation: BoardOrientationPolicy) -> String {
        "Square \(square.description), \(orientation == .black ? "Black" : "White") orientation"
    }

    static func feedback(correct: Bool) -> String {
        correct ? "Correct" : "Incorrect"
    }
}
