import SwiftUI

struct SquareRecognitionSetupView: View {
    let historyStore: SquareRecognitionHistoryStoring

    @State private var selectedTime: SquareRecognitionTimeLimit = .tenSeconds
    @State private var selectedVariant: SquareRecognitionVariant = .bonus
    @State private var activeConfiguration: SquareRecognitionConfiguration?

    var body: some View {
        List {
            Section("Setup") {
                Picker("Initial time", selection: $selectedTime) {
                    ForEach(SquareRecognitionTimeLimit.allCases) { timeLimit in
                        Text(timeLimit.displayName).tag(timeLimit)
                    }
                }
                .accessibilityIdentifier("squareRecognition.timePicker")

                Picker("Variant", selection: $selectedVariant) {
                    ForEach(SquareRecognitionVariant.allCases) { variant in
                        Text(variant.displayName).tag(variant)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("squareRecognition.variantPicker")
            }

            Section {
                Button {
                    activeConfiguration = SquareRecognitionConfiguration(
                        initialTime: selectedTime.seconds,
                        variant: selectedVariant
                    )
                } label: {
                    Label("Start square recognition", systemImage: "play.fill")
                }
                .accessibilityIdentifier("squareRecognition.startButton")

                NavigationLink("History") {
                    SquareRecognitionHistoryView(historyStore: historyStore)
                }
                .accessibilityIdentifier("squareRecognition.historyLink")
            }
        }
        .listStyle(.insetGrouped)
        .premiumScreenBackground()
        .navigationTitle("Square Recognition")
        .navigationDestination(item: $activeConfiguration) { configuration in
            SquareRecognitionGameView(
                viewModel: SquareRecognitionViewModel(
                    initialTime: configuration.initialTime,
                    variant: configuration.variant,
                    historyStore: historyStore
                )
            )
        }
    }
}

struct SquareRecognitionGameView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: SquareRecognitionViewModel

    var body: some View {
        Group {
            if viewModel.isFinished, let result = viewModel.result {
                SquareRecognitionResultsView(result: result, saveError: viewModel.saveError) {
                    viewModel.reset()
                } newGame: {
                    dismiss()
                }
            } else {
                gameContent
            }
        }
        .navigationTitle("Squares")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.isFinished) {
            await runTimeoutLoop()
        }
        .task(id: viewModel.answers.count) {
            await advanceAfterFeedbackDelay()
        }
    }

    private var gameContent: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Text(viewModel.timerText)
                        .font(.title2.monospacedDigit().weight(.bold))
                        .foregroundStyle(viewModel.remainingTime <= 3 ? PremiumDesign.Accent.danger.color : PremiumDesign.primaryText)
                        .accessibilityIdentifier("squareRecognition.timerText")
                        .accessibilityLabel("Square recognition timer")

                    Text(viewModel.targetCoordinate)
                        .font(.largeTitle.monospaced().weight(.bold))
                        .foregroundStyle(PremiumDesign.Accent.square.color)
                        .accessibilityIdentifier("squareRecognition.promptText")
                }

                VStack(spacing: 6) {
                    SquareSelectionBoardView(
                        showsCoordinates: appSettings.showBoardCoordinates,
                        selectedCoordinate: viewModel.feedback == nil ? nil : viewModel.answers.last?.selected,
                        targetCoordinate: viewModel.feedback == nil ? nil : viewModel.answers.last?.target,
                        selectSquare: { coordinate in
                            viewModel.selectSquare(coordinate)
                        }
                    )

                    Label("White side", systemImage: "arrow.down.to.line.compact")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PremiumDesign.secondaryText)
                        .accessibilityIdentifier("squareRecognition.whiteSideLabel")
                }
                .padding(.horizontal)

                HStack(spacing: 8) {
                    PremiumMetricPill(title: "Score", value: "\(viewModel.score)", accent: .square, identifier: "squareRecognition.scoreValue")
                    PremiumMetricPill(title: "Correct", value: "\(viewModel.correctCount)", accent: .practice, identifier: "squareRecognition.correctValue")
                    PremiumMetricPill(title: "Accuracy", value: viewModel.accuracyText, accent: .brand, identifier: "squareRecognition.accuracyValue")
                }
                .padding(.horizontal)

                Text(viewModel.feedback ?? "Tap the prompted square.")
                    .font(.headline)
                    .foregroundStyle(viewModel.feedback == "Correct" ? PremiumDesign.Accent.practice.color : PremiumDesign.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .premiumPanel(accent: .square)
                    .padding(.horizontal)
                    .accessibilityIdentifier("squareRecognition.feedbackText")
            }
            .padding(.vertical, 12)
        }
        .premiumScreenBackground()
    }

    private func statPill(title: String, value: String, identifier: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityIdentifier(identifier)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func runTimeoutLoop() async {
        guard !viewModel.isFinished else { return }

        while !Task.isCancelled && !viewModel.isFinished {
            try? await Task.sleep(for: .milliseconds(100))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                viewModel.expireIfNeeded()
            }
        }
    }

    private func advanceAfterFeedbackDelay() async {
        guard viewModel.feedback != nil, !viewModel.isFinished else { return }
        let delay = UInt64(viewModel.feedbackDelay * 1_000_000_000)
        try? await Task.sleep(nanoseconds: delay)
        guard !Task.isCancelled else { return }
        await MainActor.run {
            viewModel.showNextPrompt()
        }
    }
}

struct SquareSelectionBoardView: View {
    @Environment(AppSettings.self) private var appSettings

    let showsCoordinates: Bool
    let selectedCoordinate: String?
    let targetCoordinate: String?
    let selectSquare: (String) -> Void

    private var palette: ChessVisualPalette {
        appSettings.visualTheme.palette
    }

    var body: some View {
        GeometryReader { proxy in
            let boardSize = min(proxy.size.width, proxy.size.height)
            let squareSize = boardSize / 8

            ZStack(alignment: .topLeading) {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(squareSize), spacing: 0), count: 8), spacing: 0) {
                    ForEach(0..<64, id: \.self) { index in
                        let file = index % 8
                        let rank = 8 - (index / 8)
                        let coordinate = Self.coordinate(file: file, rank: rank)
                        Button {
                            selectSquare(coordinate)
                        } label: {
                            Rectangle()
                                .fill(palette.squareStyle(isLight: Self.isLightSquare(file: file, rank: rank)))
                                .overlay {
                                    if coordinate == selectedCoordinate {
                                        Rectangle()
                                            .stroke(coordinate == targetCoordinate ? Color.green : Color.red, lineWidth: 4)
                                    } else if coordinate == targetCoordinate {
                                        Rectangle()
                                            .stroke(Color.green.opacity(0.8), lineWidth: 4)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .frame(width: squareSize, height: squareSize)
                        .accessibilityIdentifier("squareRecognition.square.\(coordinate)")
                    }
                }

                if showsCoordinates {
                    SquareBoardCoordinatesOverlay(squareSize: squareSize, palette: palette)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: boardSize, height: boardSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(palette.boardBorder, lineWidth: 1.2)
            }
            .shadow(color: palette.boardShadow, radius: 10, x: 0, y: 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private static func coordinate(file: Int, rank: Int) -> String {
        let fileScalar = UnicodeScalar(97 + file)!
        return "\(Character(fileScalar))\(rank)"
    }

    fileprivate static func isLightSquare(file: Int, rank: Int) -> Bool {
        (file + rank - 1).isMultiple(of: 2)
    }
}

private struct SquareBoardCoordinatesOverlay: View {
    let squareSize: CGFloat
    let palette: ChessVisualPalette

    private let files = ["a", "b", "c", "d", "e", "f", "g", "h"]

    var body: some View {
        let boardSize = squareSize * 8
        let inset = max(squareSize * 0.16, 7)

        ZStack(alignment: .topLeading) {
            ForEach(0..<8, id: \.self) { file in
                coordinateLabel(files[file], isLightSquare: SquareSelectionBoardView.isLightSquare(file: file, rank: 1))
                    .position(x: CGFloat(file + 1) * squareSize - inset, y: boardSize - inset)
            }

            ForEach(0..<8, id: \.self) { rankIndex in
                let rank = 8 - rankIndex
                coordinateLabel("\(rank)", isLightSquare: SquareSelectionBoardView.isLightSquare(file: 0, rank: rank))
                    .position(x: inset, y: CGFloat(rankIndex) * squareSize + inset)
            }
        }
        .frame(width: boardSize, height: boardSize)
    }

    private func coordinateLabel(_ text: String, isLightSquare: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .serif))
            .foregroundStyle(palette.coordinateLabelColor(isLightSquare: isLightSquare))
            .shadow(color: Color.black.opacity(isLightSquare ? 0.0 : 0.18), radius: 0.5, x: 0, y: 0.5)
            .lineLimit(1)
    }
}

struct SquareRecognitionResultsView: View {
    let result: SquareRecognitionResult
    let saveError: String?
    let restart: () -> Void
    let newGame: () -> Void

    var body: some View {
        List {
            Section("Result") {
                metricRow("Score", "\(result.score)")
                metricRow("Total prompts", "\(result.totalPrompts)")
                metricRow("Correct", "\(result.correctCount)")
                metricRow("Incorrect", "\(result.incorrectCount)")
                metricRow("Accuracy", result.accuracy.formatted(.percent.precision(.fractionLength(0))))
                metricRow("Average latency", result.averageLatency.formattedTenths)
                metricRow("Fastest correct", result.fastestCorrectLatency?.formattedTenths ?? "-")
                metricRow("Slowest answer", result.slowestLatency?.formattedTenths ?? "-")
                metricRow("Initial time", result.initialTime.formattedTenths)
                metricRow("Variant", result.variant.displayName)
                metricRow("Finished", result.finishedAt.formatted(date: .abbreviated, time: .shortened))
            }

            if let saveError {
                Section("History") {
                    Text("This result could not be saved: \(saveError)")
                        .foregroundStyle(PremiumDesign.Accent.danger.color)
                }
            }

            Section {
                Button("Play again", action: restart)
                    .accessibilityIdentifier("squareRecognition.restartButton")
                Button("New square game", action: newGame)
                    .accessibilityIdentifier("squareRecognition.newGameButton")
            }
        }
        .listStyle(.insetGrouped)
        .premiumScreenBackground()
        .navigationTitle("Results")
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(PremiumDesign.primaryText)
            Spacer()
            Text(value)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
    }
}

struct SquareRecognitionHistoryView: View {
    let historyStore: SquareRecognitionHistoryStoring
    @State private var results: [SquareRecognitionResult] = []
    @State private var selectedRange: HistoryRange = .lastWeek
    @State private var loadError: String?

    private var filteredResults: [SquareRecognitionResult] {
        results.filter { selectedRange.contains($0.finishedAt) }
    }

    private var chronologicalResults: [SquareRecognitionResult] {
        filteredResults.sorted { $0.finishedAt < $1.finishedAt }
    }

    var body: some View {
        List {
            Section {
                Picker("Range", selection: $selectedRange) {
                    ForEach(HistoryRange.allCases) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("squareRecognition.historyRangePicker")
            }

            if filteredResults.isEmpty, loadError == nil {
                ContentUnavailableView("No Results", systemImage: "clock.arrow.circlepath", description: Text("Completed square-recognition runs will appear here."))
            } else {
                summarySection
                trendSection
                sessionsSection
            }

            if let loadError {
                Text(loadError)
                    .foregroundStyle(.red)
            }
        }
        .listStyle(.insetGrouped)
        .premiumScreenBackground()
        .navigationTitle("History")
        .task {
            loadHistory()
        }
    }

    private var summarySection: some View {
        Section("Summary") {
            metricRow("Sessions", "\(filteredResults.count)")
            metricRow("Best score", "\(filteredResults.map(\.score).max() ?? 0)")
            metricRow("Average score", averageScore.formatted(.number.precision(.fractionLength(1))))
            metricRow("Accuracy", average(\.accuracy).formatted(.percent.precision(.fractionLength(0))))
            metricRow("Average latency", average(\.averageLatency).formattedTenths)
            metricRow("Fastest correct", fastestCorrectText)
        }
    }

    private var trendSection: some View {
        Section("Trends") {
            if chronologicalResults.count >= 2 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Score")
                        .font(.headline)
                    PremiumTrendLine(
                        values: chronologicalResults.map { Double($0.score) },
                        xAxisLabels: selectedRange.axisLabels(for: chronologicalResults.map(\.finishedAt)),
                        accent: .square,
                        valueFormatter: { value in
                            value.formatted(.number.precision(.fractionLength(0)))
                        }
                    )

                    Text("Average latency")
                        .font(.headline)
                    PremiumTrendLine(
                        values: chronologicalResults.map(\.averageLatency),
                        xAxisLabels: selectedRange.axisLabels(for: chronologicalResults.map(\.finishedAt)),
                        accent: .timed,
                        valueFormatter: { value in
                            value.formattedTenths
                        }
                    )
                }
            } else if let latest = filteredResults.first {
                metricRow("Latest score", "\(latest.score)")
                metricRow("Latest latency", latest.averageLatency.formattedTenths)
                Text("Complete at least two sessions in this range to draw trends.")
                    .font(.caption)
                    .foregroundStyle(PremiumDesign.secondaryText)
            }
        }
    }

    private var sessionsSection: some View {
        Section("Sessions") {
            ForEach(filteredResults) { result in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(result.finishedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        Spacer()
                        Text("Score \(result.score)")
                            .font(.headline.monospacedDigit())
                    }

                    HStack {
                        Label(result.accuracy.formatted(.percent.precision(.fractionLength(0))), systemImage: "target")
                        Label(result.averageLatency.formattedTenths, systemImage: "speedometer")
                        Label(result.initialTime.formattedTenths, systemImage: "timer")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text(result.variant.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PremiumDesign.secondaryText)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var averageScore: Double {
        guard !filteredResults.isEmpty else { return 0 }
        return Double(filteredResults.map(\.score).reduce(0, +)) / Double(filteredResults.count)
    }

    private var fastestCorrectText: String {
        let fastest = filteredResults.compactMap(\.fastestCorrectLatency).min()
        return fastest?.formattedTenths ?? "-"
    }

    private func average(_ keyPath: KeyPath<SquareRecognitionResult, Double>) -> Double {
        guard !filteredResults.isEmpty else { return 0 }
        return filteredResults.map { $0[keyPath: keyPath] }.reduce(0, +) / Double(filteredResults.count)
    }

    private func loadHistory() {
        do {
            results = try historyStore.loadResults()
            selectedRange = defaultRange(for: results.map(\.finishedAt))
            loadError = nil
        } catch {
            results = []
            loadError = error.localizedDescription
        }
    }

    private func defaultRange(for dates: [Date]) -> HistoryRange {
        HistoryRange.allCases.first { range in
            dates.contains { range.contains($0) }
        } ?? .lastWeek
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(PremiumDesign.primaryText)
            Spacer()
            Text(value)
                .foregroundStyle(PremiumDesign.secondaryText)
        }
    }
}

struct SquareRecognitionConfiguration: Identifiable, Hashable {
    let initialTime: TimeInterval
    let variant: SquareRecognitionVariant

    var id: String { "\(initialTime)-\(variant.rawValue)" }
}

enum SquareRecognitionTimeLimit: TimeInterval, CaseIterable, Identifiable {
    case tenSeconds = 10
    case thirtySeconds = 30
    case sixtySeconds = 60

    var id: TimeInterval { rawValue }
    var seconds: TimeInterval { rawValue }

    var displayName: String {
        switch self {
        case .tenSeconds: return "10 seconds"
        case .thirtySeconds: return "30 seconds"
        case .sixtySeconds: return "60 seconds"
        }
    }
}
