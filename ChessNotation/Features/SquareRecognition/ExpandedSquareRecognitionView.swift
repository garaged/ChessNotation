import Observation
import SwiftUI

@Observable
final class ExpandedSquareRecognitionViewModel {
    private let clock: MonotonicTimeProviding
    private let generator: SquareRecognitionPromptGenerator
    private(set) var session: SquareRecognitionSession
    private(set) var presentation: SquareRecognitionPresentation
    private(set) var routeSelection: [ChessSquare] = []
    var coordinateEntry = ""

    let configuration: SquareRecognitionDrillConfiguration

    init(
        configuration: SquareRecognitionDrillConfiguration,
        randomizer: ChallengeRandomizing,
        clock: MonotonicTimeProviding = SystemMonotonicClock()
    ) {
        let sanitized = SquareRecognitionSession.sanitized(configuration)
        self.configuration = sanitized
        self.clock = clock
        self.generator = SquareRecognitionPromptGenerator(
            zone: sanitized.zone,
            orientationPolicy: sanitized.orientation,
            randomizer: randomizer
        )
        let basePrompt = generator.next() ?? SquareRecognitionPrompt(
            target: ChessSquare("a1")!,
            orientation: .white,
            route: []
        )
        let initialPrompt = Self.adapt(basePrompt, for: sanitized)
        self.session = SquareRecognitionSession(
            configuration: sanitized,
            prompt: initialPrompt,
            clock: clock
        )
        self.presentation = SquareRecognitionPresentation.make(
            configuration: sanitized,
            prompt: initialPrompt,
            completed: 0,
            total: nil,
            feedback: nil
        )
    }

    var prompt: SquareRecognitionPrompt { session.currentPrompt }
    var inputLocked: Bool { session.inputLocked }
    var result: SquareRecognitionDrillResult { session.result }

    func submitSquare(_ square: ChessSquare) {
        switch configuration.drill {
        case .route:
            routeSelection.append(square)
            if routeSelection.count >= prompt.route.count {
                resolve(.route(routeSelection))
            }
        case .findSquare, .relativeSquare:
            resolve(.square(square))
        case .nameSquare, .squareColor:
            break
        }
    }

    func submitCoordinate() {
        resolve(.coordinate(coordinateEntry))
    }

    func submitColor(_ color: ChessSquareColor) {
        resolve(.color(color))
    }

    func advance() {
        guard let basePrompt = generator.next() else { return }
        let next = Self.adapt(basePrompt, for: configuration)
        session.advance(to: next)
        routeSelection = []
        coordinateEntry = ""
        presentation = SquareRecognitionPresentation.make(
            configuration: configuration,
            prompt: next,
            completed: result.totalPrompts,
            total: nil,
            feedback: nil
        )
    }

    private func resolve(_ submission: SquareRecognitionSubmission) {
        guard let evaluation = session.submit(submission, at: clock.now) else { return }
        presentation = SquareRecognitionPresentation.make(
            configuration: configuration,
            prompt: prompt,
            completed: result.totalPrompts,
            total: nil,
            feedback: evaluation.isCorrect ? "Correct" : "Incorrect"
        )
    }

    private static func adapt(
        _ prompt: SquareRecognitionPrompt,
        for configuration: SquareRecognitionDrillConfiguration
    ) -> SquareRecognitionPrompt {
        guard configuration.drill == .route else { return prompt }
        let eligible = SquareRecognitionPromptFactory.squares(in: configuration.zone)
        guard !eligible.isEmpty else { return prompt }
        let startIndex = eligible.firstIndex(of: prompt.target) ?? 0
        let length = min(SquareRecognitionPromptFactory.routeLength(for: configuration.difficulty), eligible.count)
        let route = (0..<length).map { eligible[(startIndex + $0) % eligible.count] }
        return SquareRecognitionPrompt(target: prompt.target, orientation: prompt.orientation, route: route)
    }
}

struct ExpandedSquareRecognitionView: View {
    @State var viewModel: ExpandedSquareRecognitionViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(viewModel.presentation.task)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("squareRecognition.expanded.task")

                Text(viewModel.presentation.orientation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                board
                responseControls

                HStack {
                    Label("\(viewModel.result.correctPrompts) correct", systemImage: "checkmark.circle")
                    Spacer()
                    Text(viewModel.presentation.progress)
                }
                .font(.subheadline)

                if let feedback = viewModel.presentation.feedback {
                    Text(feedback)
                        .font(.headline)
                        .accessibilityIdentifier("squareRecognition.expanded.feedback")

                    Button("Next prompt") {
                        viewModel.advance()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("squareRecognition.expanded.next")
                }
            }
            .padding()
        }
        .navigationTitle("Square Drill")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.presentation.accessibilitySummary)
    }

    private var board: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
            ForEach(0..<64, id: \.self) { index in
                let orientation = viewModel.prompt.orientation
                let square = SquareBoardMapping.square(forDisplayIndex: index, orientation: orientation)!
                Button(square.description) {
                    viewModel.submitSquare(square)
                }
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(square.color == .light ? Color.secondary.opacity(0.15) : Color.secondary.opacity(0.35))
                .buttonStyle(.plain)
                .disabled(viewModel.inputLocked || viewModel.configuration.drill == .nameSquare || viewModel.configuration.drill == .squareColor)
                .accessibilityLabel(SquareRecognitionAccessibility.squareLabel(square, orientation: orientation))
                .accessibilityIdentifier("squareRecognition.expanded.square.\(square.description)")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var responseControls: some View {
        switch viewModel.configuration.drill {
        case .nameSquare:
            HStack {
                TextField("Coordinate", text: $viewModel.coordinateEntry)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("squareRecognition.expanded.coordinate")
                Button("Submit") { viewModel.submitCoordinate() }
                    .disabled(viewModel.inputLocked)
            }
        case .squareColor:
            HStack {
                Button("Light") { viewModel.submitColor(.light) }
                Button("Dark") { viewModel.submitColor(.dark) }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.inputLocked)
        case .route:
            Text("Selected \(viewModel.routeSelection.count) of \(viewModel.prompt.route.count) squares")
                .foregroundStyle(.secondary)
        case .findSquare, .relativeSquare:
            Text("Tap the answer on the board")
                .foregroundStyle(.secondary)
        }
    }
}
