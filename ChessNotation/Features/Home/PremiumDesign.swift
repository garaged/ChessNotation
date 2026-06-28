import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum PremiumAssetName {
    static let homeHero = "HomeHeroPremium"
    static let notationTrainingTile = "TileNotationTraining"
    static let timedNotationTile = "TileTimedNotation"
    static let squareRecognitionTile = "TileSquareRecognition"
    static let instructionsTile = "TileInstructions"
    static let libraryRandomGame = "LibraryRandomGame"
    static let darkBoardTexture = "DarkBoardTexture"
}

enum PremiumDesign {
    enum Accent {
        case brand
        case practice
        case timed
        case square
        case learning
        case danger
        case neutral

        var color: Color {
            switch self {
            case .brand: return Color(red: 0.95, green: 0.73, blue: 0.38)
            case .practice: return Color(red: 0.24, green: 0.78, blue: 0.43)
            case .timed: return Color(red: 0.30, green: 0.55, blue: 0.95)
            case .square: return Color(red: 0.62, green: 0.36, blue: 0.92)
            case .learning: return Color(red: 0.94, green: 0.58, blue: 0.18)
            case .danger: return Color(red: 0.95, green: 0.26, blue: 0.28)
            case .neutral: return Color(red: 0.68, green: 0.72, blue: 0.78)
            }
        }
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 8
        static let large: CGFloat = 8
    }

    enum Spacing {
        static let xsmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    static let backgroundTop = Color(red: 0.045, green: 0.055, blue: 0.065)
    static let backgroundBottom = Color(red: 0.015, green: 0.018, blue: 0.022)
    static let surface = Color.white.opacity(0.075)
    static let elevatedSurface = Color.white.opacity(0.105)
    static let stroke = Color.white.opacity(0.12)
    static let primaryText = Color.white.opacity(0.94)
    static let secondaryText = Color.white.opacity(0.66)
    static let mutedText = Color.white.opacity(0.48)

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .top, endPoint: .bottom)
    }

    static func modeAccent(for launchMode: GameLibraryLaunchMode) -> Accent {
        switch launchMode {
        case .practice: return .practice
        case .timed: return .timed
        }
    }

    static func difficultyAccent(for difficulty: Difficulty) -> Accent {
        switch difficulty {
        case .beginner: return .practice
        case .intermediate: return .learning
        case .advanced: return .danger
        }
    }
}

enum PremiumAssetAvailability {
    static func hasImage(named name: String) -> Bool {
        #if canImport(UIKit)
        UIImage(named: name) != nil
        #elseif canImport(AppKit)
        NSImage(named: name) != nil
        #else
        false
        #endif
    }
}

struct PremiumArtworkView<Fallback: View>: View {
    let assetName: String
    let fallbackIdentifier: String
    let fallback: Fallback

    init(assetName: String, fallbackIdentifier: String, @ViewBuilder fallback: () -> Fallback) {
        self.assetName = assetName
        self.fallbackIdentifier = fallbackIdentifier
        self.fallback = fallback()
    }

    var body: some View {
        if PremiumAssetAvailability.hasImage(named: assetName) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            fallback
                .accessibilityIdentifier(fallbackIdentifier)
        }
    }
}

struct PremiumScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                ZStack {
                    PremiumDesign.backgroundGradient.ignoresSafeArea()
                    PremiumBoardTexture()
                        .opacity(0.12)
                        .ignoresSafeArea()
                }
            }
            .preferredColorScheme(.dark)
    }
}

extension View {
    func premiumScreenBackground() -> some View {
        modifier(PremiumScreenBackground())
    }

    func premiumPanel(accent: PremiumDesign.Accent = .neutral) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium)
                    .fill(PremiumDesign.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium)
                            .stroke(accent.color.opacity(0.2), lineWidth: 1)
                    }
            )
    }

    func premiumPrimaryButton(accent: PremiumDesign.Accent) -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                LinearGradient(
                    colors: [accent.color.opacity(0.95), accent.color.opacity(0.62)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            }
    }
}

struct PremiumBoardTexture: View {
    var body: some View {
        if PremiumAssetAvailability.hasImage(named: PremiumAssetName.darkBoardTexture) {
            Image(PremiumAssetName.darkBoardTexture)
                .resizable()
                .scaledToFill()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        } else {
            GeometryReader { proxy in
                let square = max(proxy.size.width / 12, 28)
                let columns = max(Int(proxy.size.width / square), 1)
                let rows = max(Int(proxy.size.height / square), 1)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(square), spacing: 0), count: columns), spacing: 0) {
                    ForEach(0..<(columns * rows), id: \.self) { index in
                        Rectangle()
                            .fill((index + index / columns).isMultiple(of: 2) ? Color.white.opacity(0.045) : Color.clear)
                            .frame(width: square, height: square)
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

struct PremiumBadge: View {
    let text: String
    let accent: PremiumDesign.Accent

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(accent.color)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(accent.color.opacity(0.16))
            .clipShape(Capsule())
    }
}

struct PremiumMetricPill: View {
    let title: String
    let value: String
    var accent: PremiumDesign.Accent = .neutral
    var identifier: String?

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.headline.monospacedDigit().weight(.semibold))
                .foregroundStyle(PremiumDesign.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .accessibilityIdentifier(identifier ?? "")
            Text(title)
                .font(.caption2)
                .foregroundStyle(PremiumDesign.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .premiumPanel(accent: accent)
    }
}

struct PremiumTrendLine: View {
    let values: [Double]
    var xAxisLabels: [String] = []
    var accent: PremiumDesign.Accent = .brand
    var valueFormatter: (Double) -> String = { value in
        value.formatted(.number.precision(.fractionLength(1)))
    }

    @State private var selectedPointIndex: Int?
    @State private var overlayDismissTask: Task<Void, Never>?

    private var domain: ClosedRange<Double> {
        guard let minValue = values.min(), let maxValue = values.max() else { return 0...1 }
        guard minValue != maxValue else {
            let padding = max(abs(minValue) * 0.2, 1)
            return max(0, minValue - padding)...(maxValue + padding)
        }

        let padding = (maxValue - minValue) * 0.12
        return max(0, minValue - padding)...(maxValue + padding)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .trailing) {
                    Text(valueFormatter(domain.upperBound))
                    Spacer()
                    Text(valueFormatter(domain.lowerBound))
                }
                .font(.caption2.monospacedDigit())
                .foregroundStyle(PremiumDesign.secondaryText)
                .frame(width: 44)

                GeometryReader { proxy in
                    let points = chartPoints(in: proxy.size)

                    ZStack {
                        VStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle()
                                    .fill(PremiumDesign.stroke)
                                    .frame(height: index == 1 ? 1 : 0.7)
                                if index < 2 {
                                    Spacer()
                                }
                            }
                        }

                        Path { path in
                            guard let first = points.first else { return }
                            path.move(to: first)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(accent.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                            Circle()
                                .fill(selectedPointIndex == index ? PremiumDesign.primaryText : accent.color)
                                .frame(width: selectedPointIndex == index ? 10 : 7, height: selectedPointIndex == index ? 10 : 7)
                                .position(point)
                                .shadow(color: accent.color.opacity(0.35), radius: 3)
                        }

                        if let selectedPointIndex, points.indices.contains(selectedPointIndex) {
                            valueOverlay(
                                value: values[selectedPointIndex],
                                index: selectedPointIndex,
                                point: points[selectedPointIndex],
                                chartSize: proxy.size
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture(coordinateSpace: .local) { location in
                        selectNearestPoint(to: location, points: points)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 2)
                    .accessibilityHidden(true)
                }
                .frame(height: 64)
            }

            if !xAxisLabels.isEmpty {
                HStack {
                    ForEach(Array(xAxisLabels.enumerated()), id: \.offset) { index, label in
                        Text(label)
                            .frame(
                                maxWidth: .infinity,
                                alignment: xAxisLabelAlignment(for: index, count: xAxisLabels.count)
                            )
                    }
                }
                .font(.caption2.monospacedDigit())
                .foregroundStyle(PremiumDesign.mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.leading, 52)
            }

            HStack {
                if let first = values.first {
                    Text("Oldest \(valueFormatter(first))")
                }
                Spacer()
                if let last = values.last {
                    Text("Latest \(valueFormatter(last))")
                }
            }
            .font(.caption2.monospacedDigit())
            .foregroundStyle(PremiumDesign.secondaryText)
            .padding(.leading, 52)
        }
        .padding(12)
        .background(PremiumDesign.surface)
        .clipShape(RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: PremiumDesign.Radius.medium)
                .stroke(accent.color.opacity(0.2), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trend chart")
        .accessibilityValue(accessibilitySummary)
        .onDisappear {
            overlayDismissTask?.cancel()
        }
    }

    private func chartPoints(in size: CGSize) -> [CGPoint] {
        let range = max(domain.upperBound - domain.lowerBound, 0.0001)
        return values.enumerated().map { index, value in
            let x = values.count == 1 ? size.width / 2 : size.width * CGFloat(index) / CGFloat(values.count - 1)
            let normalizedY = (value - domain.lowerBound) / range
            let y = size.height * CGFloat(1 - normalizedY)
            return CGPoint(x: x, y: y)
        }
    }

    private func showOverlay(for index: Int) {
        selectedPointIndex = index
        overlayDismissTask?.cancel()
        overlayDismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                selectedPointIndex = nil
                overlayDismissTask = nil
            }
        }
    }

    private func selectNearestPoint(to location: CGPoint, points: [CGPoint]) {
        guard let nearest = points.enumerated().min(by: { lhs, rhs in
            abs(lhs.element.x - location.x) < abs(rhs.element.x - location.x)
        }) else { return }
        showOverlay(for: nearest.offset)
    }

    private func xAxisLabelAlignment(for index: Int, count: Int) -> Alignment {
        if count == 1 { return .center }
        if index == 0 { return .leading }
        if index == count - 1 { return .trailing }
        return .center
    }

    private func valueOverlay(value: Double, index: Int, point: CGPoint, chartSize: CGSize) -> some View {
        Text("Point \(index + 1): \(valueFormatter(value))")
            .font(.caption2.weight(.semibold).monospacedDigit())
            .foregroundStyle(PremiumDesign.primaryText)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.thinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(accent.color.opacity(0.35), lineWidth: 1)
            }
            .position(
                x: min(max(point.x, 58), max(58, chartSize.width - 58)),
                y: point.y < 24 ? min(point.y + 24, chartSize.height - 14) : max(point.y - 20, 14)
            )
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
            .accessibilityHidden(true)
    }

    private var accessibilitySummary: Text {
        guard let first = values.first, let last = values.last else {
            return Text("No values")
        }
        return Text("Oldest \(valueFormatter(first)), latest \(valueFormatter(last)), range \(valueFormatter(domain.lowerBound)) to \(valueFormatter(domain.upperBound))")
    }
}
