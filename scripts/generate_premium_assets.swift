import AppKit
import CoreGraphics
import Foundation

struct Canvas {
    let size: CGSize
    let context: CGContext
}

struct Palette {
    static let black = NSColor(calibratedRed: 0.02, green: 0.024, blue: 0.028, alpha: 1)
    static let charcoal = NSColor(calibratedRed: 0.075, green: 0.082, blue: 0.09, alpha: 1)
    static let gold = NSColor(calibratedRed: 0.96, green: 0.68, blue: 0.26, alpha: 1)
    static let ivory = NSColor(calibratedRed: 0.92, green: 0.82, blue: 0.62, alpha: 1)
    static let green = NSColor(calibratedRed: 0.11, green: 0.42, blue: 0.28, alpha: 1)
    static let blue = NSColor(calibratedRed: 0.12, green: 0.28, blue: 0.54, alpha: 1)
    static let purple = NSColor(calibratedRed: 0.27, green: 0.13, blue: 0.42, alpha: 1)
    static let amber = NSColor(calibratedRed: 0.46, green: 0.27, blue: 0.09, alpha: 1)
}

@inline(__always)
func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha).cgColor
}

func drawImage(width: Int, height: Int, _ draw: (Canvas) -> Void) -> NSImage {
    let size = CGSize(width: width, height: height)
    let image = NSImage(size: size)
    image.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        fatalError("Unable to create graphics context")
    }
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    draw(Canvas(size: size, context: context))
    image.unlockFocus()
    return image
}

func save(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "PremiumAssetGenerator", code: 1)
    }
    try data.write(to: url, options: .atomic)
}

func writeContentsJSON(to url: URL, filename: String) throws {
    let json = """
    {
      "images" : [
        {
          "filename" : "\(filename)",
          "idiom" : "universal"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }

    """
    try json.write(to: url, atomically: true, encoding: .utf8)
}

func drawLinearGradient(_ context: CGContext, rect: CGRect, colors: [CGColor], start: CGPoint, end: CGPoint) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) else { return }
    context.drawLinearGradient(gradient, start: start, end: end, options: [])
}

func drawRadialGlow(_ context: CGContext, center: CGPoint, radius: CGFloat, color: NSColor, alpha: CGFloat) {
    let transparent = color.withAlphaComponent(0).cgColor
    let visible = color.withAlphaComponent(alpha).cgColor
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [visible, transparent] as CFArray, locations: [0, 1]) else { return }
    context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: .drawsAfterEndLocation)
}

func drawNoise(_ context: CGContext, rect: CGRect, count: Int, alpha: CGFloat) {
    for index in 0..<count {
        let x = CGFloat((index * 97) % Int(rect.width))
        let y = CGFloat((index * 193) % Int(rect.height))
        let value = CGFloat((index * 37) % 100) / 100
        context.setFillColor(NSColor.white.withAlphaComponent(alpha * value).cgColor)
        context.fill(CGRect(x: rect.minX + x, y: rect.minY + y, width: 1, height: 1))
    }
}

func drawBoard(_ context: CGContext, rect: CGRect, tint: NSColor, perspective: CGFloat = 0, alpha: CGFloat = 1) {
    let rows = 8
    let columns = 8
    let squareWidth = rect.width / CGFloat(columns)
    let squareHeight = rect.height / CGFloat(rows)
    for row in 0..<rows {
        for column in 0..<columns {
            let mixed = (row + column).isMultiple(of: 2)
            let baseAlpha = mixed ? 0.22 : 0.09
            let shade = tint.withAlphaComponent(baseAlpha * alpha)
            context.setFillColor(shade.cgColor)
            let inset = perspective * CGFloat(row) / CGFloat(rows)
            context.fill(CGRect(
                x: rect.minX + CGFloat(column) * squareWidth + inset,
                y: rect.minY + CGFloat(row) * squareHeight,
                width: squareWidth - inset * 0.2,
                height: squareHeight
            ))
        }
    }
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.045 * alpha).cgColor)
    context.stroke(rect, width: 1)
}

func drawCrown(_ context: CGContext, center: CGPoint, scale: CGFloat, color: NSColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: center.x - 48 * scale, y: center.y - 18 * scale))
    path.addLine(to: CGPoint(x: center.x - 34 * scale, y: center.y + 30 * scale))
    path.addLine(to: CGPoint(x: center.x - 10 * scale, y: center.y - 2 * scale))
    path.addLine(to: CGPoint(x: center.x, y: center.y + 42 * scale))
    path.addLine(to: CGPoint(x: center.x + 10 * scale, y: center.y - 2 * scale))
    path.addLine(to: CGPoint(x: center.x + 34 * scale, y: center.y + 30 * scale))
    path.addLine(to: CGPoint(x: center.x + 48 * scale, y: center.y - 18 * scale))
    path.closeSubpath()

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -5 * scale), blur: 14 * scale, color: color.withAlphaComponent(0.5).cgColor)
    context.setFillColor(color.cgColor)
    context.addPath(path)
    context.fillPath()
    context.restoreGState()
}

func drawKnight(_ context: CGContext, origin: CGPoint, scale: CGFloat, color: NSColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: origin.x + 15 * scale, y: origin.y + 5 * scale))
    path.addCurve(to: CGPoint(x: origin.x + 38 * scale, y: origin.y + 88 * scale), control1: CGPoint(x: origin.x + 4 * scale, y: origin.y + 42 * scale), control2: CGPoint(x: origin.x + 12 * scale, y: origin.y + 72 * scale))
    path.addCurve(to: CGPoint(x: origin.x + 74 * scale, y: origin.y + 138 * scale), control1: CGPoint(x: origin.x + 48 * scale, y: origin.y + 112 * scale), control2: CGPoint(x: origin.x + 56 * scale, y: origin.y + 128 * scale))
    path.addCurve(to: CGPoint(x: origin.x + 116 * scale, y: origin.y + 122 * scale), control1: CGPoint(x: origin.x + 92 * scale, y: origin.y + 154 * scale), control2: CGPoint(x: origin.x + 112 * scale, y: origin.y + 145 * scale))
    path.addLine(to: CGPoint(x: origin.x + 96 * scale, y: origin.y + 98 * scale))
    path.addCurve(to: CGPoint(x: origin.x + 112 * scale, y: origin.y + 48 * scale), control1: CGPoint(x: origin.x + 108 * scale, y: origin.y + 82 * scale), control2: CGPoint(x: origin.x + 116 * scale, y: origin.y + 64 * scale))
    path.addCurve(to: CGPoint(x: origin.x + 82 * scale, y: origin.y + 20 * scale), control1: CGPoint(x: origin.x + 106 * scale, y: origin.y + 30 * scale), control2: CGPoint(x: origin.x + 96 * scale, y: origin.y + 20 * scale))
    path.addLine(to: CGPoint(x: origin.x + 120 * scale, y: origin.y + 5 * scale))
    path.closeSubpath()
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -9 * scale), blur: 22 * scale, color: NSColor.black.withAlphaComponent(0.5).cgColor)
    context.setFillColor((color.highlight(withLevel: 0.08) ?? color).cgColor)
    context.addPath(path)
    context.fillPath()
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.22).cgColor)
    context.addPath(path)
    context.strokePath()
    context.restoreGState()
}

func drawPawn(_ context: CGContext, center: CGPoint, scale: CGFloat, color: NSColor) {
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -8 * scale), blur: 18 * scale, color: NSColor.black.withAlphaComponent(0.45).cgColor)
    context.setFillColor(color.cgColor)
    context.fillEllipse(in: CGRect(x: center.x - 24 * scale, y: center.y + 45 * scale, width: 48 * scale, height: 48 * scale))
    context.fillEllipse(in: CGRect(x: center.x - 34 * scale, y: center.y + 8 * scale, width: 68 * scale, height: 48 * scale))
    context.fill(CGRect(x: center.x - 32 * scale, y: center.y - 4 * scale, width: 64 * scale, height: 24 * scale))
    context.fillEllipse(in: CGRect(x: center.x - 50 * scale, y: center.y - 20 * scale, width: 100 * scale, height: 28 * scale))
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.22).cgColor)
    context.setLineWidth(2 * scale)
    context.strokeEllipse(in: CGRect(x: center.x - 24 * scale, y: center.y + 45 * scale, width: 48 * scale, height: 48 * scale))
    context.restoreGState()
}

func drawKing(_ context: CGContext, center: CGPoint, scale: CGFloat, color: NSColor) {
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -8 * scale), blur: 22 * scale, color: NSColor.black.withAlphaComponent(0.65).cgColor)
    context.setFillColor(color.cgColor)
    context.fill(CGRect(x: center.x - 12 * scale, y: center.y + 126 * scale, width: 24 * scale, height: 54 * scale))
    context.fill(CGRect(x: center.x - 28 * scale, y: center.y + 144 * scale, width: 56 * scale, height: 16 * scale))
    context.fillEllipse(in: CGRect(x: center.x - 38 * scale, y: center.y + 80 * scale, width: 76 * scale, height: 56 * scale))
    context.fill(CGRect(x: center.x - 26 * scale, y: center.y + 20 * scale, width: 52 * scale, height: 78 * scale))
    context.fillEllipse(in: CGRect(x: center.x - 58 * scale, y: center.y, width: 116 * scale, height: 32 * scale))
    context.fillEllipse(in: CGRect(x: center.x - 72 * scale, y: center.y - 24 * scale, width: 144 * scale, height: 34 * scale))
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.16).cgColor)
    context.setLineWidth(1.5 * scale)
    context.strokeEllipse(in: CGRect(x: center.x - 38 * scale, y: center.y + 80 * scale, width: 76 * scale, height: 56 * scale))
    context.restoreGState()
}

func drawHero(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [rgba(0.02, 0.025, 0.03), rgba(0.005, 0.007, 0.01)], start: CGPoint(x: 0, y: rect.maxY), end: CGPoint(x: rect.maxX, y: 0))
    drawRadialGlow(context, center: CGPoint(x: rect.midX, y: rect.height * 0.68), radius: 430, color: Palette.gold, alpha: 0.24)
    drawBoard(context, rect: CGRect(x: -120, y: -30, width: rect.width + 240, height: rect.height * 0.52), tint: Palette.gold, perspective: 16, alpha: 0.8)
    drawCrown(context, center: CGPoint(x: rect.midX, y: rect.height * 0.66), scale: 1.1, color: Palette.gold)
    drawKnight(context, origin: CGPoint(x: rect.width * 0.13, y: rect.height * 0.12), scale: 1.55, color: Palette.ivory)
    drawKing(context, center: CGPoint(x: rect.width * 0.80, y: rect.height * 0.13), scale: 1.2, color: NSColor(calibratedRed: 0.035, green: 0.038, blue: 0.044, alpha: 1))
    drawNoise(context, rect: rect, count: 1800, alpha: 0.055)
}

func drawNotationTile(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [Palette.green.cgColor, Palette.black.cgColor], start: CGPoint(x: rect.maxX, y: rect.maxY), end: .zero)
    drawRadialGlow(context, center: CGPoint(x: rect.width * 0.72, y: rect.height * 0.66), radius: 300, color: Palette.gold, alpha: 0.23)
    drawBoard(context, rect: CGRect(x: 0, y: rect.height * 0.56, width: rect.width, height: rect.height * 0.44), tint: Palette.green, alpha: 0.5)
    context.saveGState()
    context.translateBy(x: rect.width * 0.60, y: rect.height * 0.52)
    context.rotate(by: -0.18)
    context.setShadow(offset: CGSize(width: 0, height: -16), blur: 28, color: NSColor.black.withAlphaComponent(0.48).cgColor)
    let book = CGRect(x: -150, y: -100, width: 300, height: 210)
    context.setFillColor(NSColor(calibratedRed: 0.09, green: 0.22, blue: 0.16, alpha: 1).cgColor)
    context.fill(book)
    context.setStrokeColor(Palette.gold.withAlphaComponent(0.35).cgColor)
    context.stroke(book, width: 4)
    drawBoard(context, rect: book.insetBy(dx: 30, dy: 34), tint: Palette.gold, alpha: 0.22)
    context.setFillColor(Palette.gold.cgColor)
    context.fill(CGRect(x: -120, y: -2, width: 260, height: 16))
    context.setFillColor(NSColor.black.cgColor)
    context.fill(CGRect(x: -112, y: 1, width: 228, height: 10))
    context.restoreGState()
    drawNoise(context, rect: rect, count: 1100, alpha: 0.045)
}

func drawTimedTile(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [Palette.blue.cgColor, Palette.black.cgColor], start: CGPoint(x: rect.maxX, y: rect.maxY), end: .zero)
    drawBoard(context, rect: CGRect(x: 0, y: rect.height * 0.54, width: rect.width, height: rect.height * 0.46), tint: Palette.blue, alpha: 0.4)
    for index in 0..<6 {
        context.setFillColor(Palette.blue.withAlphaComponent(0.12).cgColor)
        context.fill(CGRect(x: rect.width * 0.12 + CGFloat(index * 28), y: rect.height * 0.55 + CGFloat(index * 18), width: 250, height: 8))
    }
    let center = CGPoint(x: rect.width * 0.68, y: rect.height * 0.54)
    drawRadialGlow(context, center: center, radius: 270, color: Palette.gold, alpha: 0.22)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -18), blur: 30, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    context.setFillColor(Palette.gold.cgColor)
    context.fillEllipse(in: CGRect(x: center.x - 145, y: center.y - 145, width: 290, height: 290))
    context.setFillColor(NSColor(calibratedRed: 0.025, green: 0.028, blue: 0.034, alpha: 1).cgColor)
    context.fillEllipse(in: CGRect(x: center.x - 124, y: center.y - 124, width: 248, height: 248))
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.18).cgColor)
    context.setLineWidth(3)
    context.strokeEllipse(in: CGRect(x: center.x - 124, y: center.y - 124, width: 248, height: 248))
    context.setStrokeColor(Palette.gold.cgColor)
    context.setLineWidth(9)
    context.move(to: center)
    context.addLine(to: CGPoint(x: center.x + 24, y: center.y + 82))
    context.move(to: center)
    context.addLine(to: CGPoint(x: center.x + 76, y: center.y - 38))
    context.strokePath()
    context.restoreGState()
    drawNoise(context, rect: rect, count: 1000, alpha: 0.035)
}

func drawSquareTile(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [Palette.purple.cgColor, Palette.black.cgColor], start: CGPoint(x: rect.maxX, y: rect.maxY), end: .zero)
    let board = CGRect(x: rect.width * 0.30, y: rect.height * 0.16, width: rect.width * 0.60, height: rect.height * 0.68)
    drawBoard(context, rect: board, tint: Palette.purple, alpha: 1)
    let square = CGRect(x: board.midX - board.width / 16, y: board.midY - board.height / 16, width: board.width / 8, height: board.height / 8)
    drawRadialGlow(context, center: CGPoint(x: square.midX, y: square.midY), radius: 190, color: Palette.gold, alpha: 0.45)
    context.setFillColor(Palette.gold.withAlphaComponent(0.7).cgColor)
    context.fill(square.insetBy(dx: -6, dy: -6))
    drawPawn(context, center: CGPoint(x: square.midX, y: square.midY - 22), scale: 0.78, color: Palette.ivory)
    drawNoise(context, rect: rect, count: 900, alpha: 0.04)
}

func drawInstructionsTile(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [Palette.amber.cgColor, Palette.black.cgColor], start: CGPoint(x: rect.maxX, y: rect.maxY), end: .zero)
    drawRadialGlow(context, center: CGPoint(x: rect.width * 0.66, y: rect.height * 0.58), radius: 300, color: Palette.gold, alpha: 0.26)
    context.saveGState()
    context.translateBy(x: rect.width * 0.64, y: rect.height * 0.52)
    context.rotate(by: 0.08)
    context.setShadow(offset: CGSize(width: 0, height: -18), blur: 28, color: NSColor.black.withAlphaComponent(0.5).cgColor)
    let left = CGRect(x: -190, y: -92, width: 180, height: 210)
    let right = CGRect(x: 10, y: -92, width: 180, height: 210)
    context.setFillColor(NSColor(calibratedRed: 0.82, green: 0.72, blue: 0.55, alpha: 1).cgColor)
    context.fill(left)
    context.fill(right)
    context.setStrokeColor(Palette.gold.withAlphaComponent(0.24).cgColor)
    context.stroke(left, width: 2)
    context.stroke(right, width: 2)
    for index in 0..<6 {
        context.setFillColor(NSColor.black.withAlphaComponent(0.07).cgColor)
        context.fill(CGRect(x: -160, y: -45 + CGFloat(index * 24), width: 110, height: 4))
        context.fill(CGRect(x: 42, y: -45 + CGFloat(index * 24), width: 110, height: 4))
    }
    context.restoreGState()
    drawPawn(context, center: CGPoint(x: rect.width * 0.78, y: rect.height * 0.18), scale: 0.6, color: NSColor(calibratedRed: 0.04, green: 0.035, blue: 0.03, alpha: 1))
    drawNoise(context, rect: rect, count: 900, alpha: 0.04)
}

func drawRandomBanner(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [Palette.charcoal.cgColor, Palette.black.cgColor], start: CGPoint(x: 0, y: rect.maxY), end: CGPoint(x: rect.maxX, y: 0))
    drawBoard(context, rect: CGRect(x: 0, y: 0, width: rect.width * 0.70, height: rect.height), tint: Palette.gold, alpha: 0.42)
    drawRadialGlow(context, center: CGPoint(x: rect.width * 0.22, y: rect.height * 0.56), radius: 220, color: Palette.gold, alpha: 0.3)
    context.saveGState()
    context.translateBy(x: rect.width * 0.22, y: rect.height * 0.50)
    context.rotate(by: -0.15)
    context.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    let die = CGRect(x: -78, y: -78, width: 156, height: 156)
    context.setFillColor(Palette.ivory.cgColor)
    context.fill(die)
    context.setStrokeColor(Palette.gold.withAlphaComponent(0.35).cgColor)
    context.stroke(die, width: 4)
    let pipPoints = [CGPoint(x: -34, y: -34), CGPoint(x: 0, y: 0), CGPoint(x: 34, y: 34), CGPoint(x: -34, y: 34), CGPoint(x: 34, y: -34)]
    context.setFillColor(NSColor.black.withAlphaComponent(0.58).cgColor)
    for point in pipPoints {
        context.fillEllipse(in: CGRect(x: point.x - 9, y: point.y - 9, width: 18, height: 18))
    }
    context.restoreGState()
}

func drawDarkBoardTexture(canvas: Canvas) {
    let context = canvas.context
    let rect = CGRect(origin: .zero, size: canvas.size)
    drawLinearGradient(context, rect: rect, colors: [rgba(0.055, 0.05, 0.045), rgba(0.012, 0.014, 0.016)], start: CGPoint(x: 0, y: rect.maxY), end: CGPoint(x: rect.maxX, y: 0))
    drawBoard(context, rect: rect, tint: NSColor(calibratedRed: 0.28, green: 0.23, blue: 0.18, alpha: 1), alpha: 0.55)
    drawNoise(context, rect: rect, count: 5500, alpha: 0.045)
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetRoot = root.appendingPathComponent("ChessNotation/Assets.xcassets")
let assets: [(String, String, Int, Int, (Canvas) -> Void)] = [
    ("HomeHeroPremium.imageset", "home-hero-premium.png", 1290, 900, drawHero),
    ("TileNotationTraining.imageset", "tile-notation-training.png", 900, 700, drawNotationTile),
    ("TileTimedNotation.imageset", "tile-timed-notation.png", 900, 700, drawTimedTile),
    ("TileSquareRecognition.imageset", "tile-square-recognition.png", 900, 700, drawSquareTile),
    ("TileInstructions.imageset", "tile-instructions.png", 900, 700, drawInstructionsTile),
    ("LibraryRandomGame.imageset", "library-random-game.png", 900, 360, drawRandomBanner),
    ("DarkBoardTexture.imageset", "dark-board-texture.png", 900, 900, drawDarkBoardTexture)
]

for asset in assets {
    let directory = assetRoot.appendingPathComponent(asset.0)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let image = drawImage(width: asset.2, height: asset.3, asset.4)
    try save(image, to: directory.appendingPathComponent(asset.1))
    try writeContentsJSON(to: directory.appendingPathComponent("Contents.json"), filename: asset.1)
    print("Generated \(asset.0)/\(asset.1)")
}
