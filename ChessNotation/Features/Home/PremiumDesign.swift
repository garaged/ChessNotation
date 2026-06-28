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
