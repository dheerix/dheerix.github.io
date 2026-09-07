import AppKit
import Foundation

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: create-linkedin-banner-premium.swift background.png output.png\n", stderr)
    exit(2)
}

let backgroundURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)

guard let background = NSImage(contentsOf: backgroundURL),
      let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: 1584,
        pixelsHigh: 396,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
      ) else {
    fatalError("Unable to load background or create canvas")
}

let gold = NSColor(calibratedRed: 225/255, green: 168/255, blue: 82/255, alpha: 1)
let paleGold = NSColor(calibratedRed: 247/255, green: 209/255, blue: 142/255, alpha: 1)
let white = NSColor(calibratedWhite: 0.97, alpha: 1)
let muted = NSColor(calibratedRed: 209/255, green: 215/255, blue: 221/255, alpha: 1)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

// The generated reference artwork is 2:1. Crop a 4:1 band that preserves the summit.
let sourceSize = background.size
let sourceHeight = sourceSize.width / 4
let sourceRect = NSRect(
    x: 0,
    y: max(0, sourceSize.height - sourceHeight - 36),
    width: sourceSize.width,
    height: min(sourceHeight, sourceSize.height)
)
background.draw(
    in: NSRect(x: 0, y: 0, width: 1584, height: 396),
    from: sourceRect,
    operation: .copy,
    fraction: 1
)

// Dark veil behind the identity area keeps the wordmark crisp.
let veil = NSGradient(
    starting: NSColor(calibratedWhite: 0, alpha: 0.56),
    ending: NSColor(calibratedWhite: 0, alpha: 0)
)!
veil.draw(in: NSRect(x: 185, y: 0, width: 1050, height: 396), angle: 0)

// Signature DX monogram: gold D + white X, inspired by the supplied reference.
let dAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 132, weight: .heavy),
    .foregroundColor: gold,
    .kern: -10
]
let xAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 132, weight: .heavy),
    .foregroundColor: white,
    .kern: 0
]
("D" as NSString).draw(at: NSPoint(x: 278, y: 204), withAttributes: dAttributes)
("X" as NSString).draw(at: NSPoint(x: 346, y: 188), withAttributes: xAttributes)

// Small brand identifier plus primary wordmark.
("DX" as NSString).draw(
    at: NSPoint(x: 492, y: 280),
    withAttributes: [
        .font: NSFont.systemFont(ofSize: 46, weight: .bold),
        .foregroundColor: gold,
        .kern: 1.5
    ]
)
("DHEERIX" as NSString).draw(
    at: NSPoint(x: 582, y: 274),
    withAttributes: [
        .font: NSFont.systemFont(ofSize: 54, weight: .medium),
        .foregroundColor: white,
        .kern: 8.5
    ]
)
("ENGINEER.  BUILDER.  TEACHER." as NSString).draw(
    at: NSPoint(x: 498, y: 235),
    withAttributes: [
        .font: NSFont.systemFont(ofSize: 17, weight: .medium),
        .foregroundColor: paleGold,
        .kern: 5.2
    ]
)

gold.withAlphaComponent(0.7).setFill()
NSRect(x: 496, y: 220, width: 610, height: 1).fill()

let pillars: [(short: String, title: String)] = [
    ("AI", "AI & LLM"),
    ("DS", "DISTRIBUTED\nSYSTEMS"),
    ("CL", "CLOUD\nARCHITECTURE"),
    ("SE", "SOFTWARE\nENGINEERING"),
    ("YG", "YOGA")
]

for (index, pillar) in pillars.enumerated() {
    let centerX = 535 + CGFloat(index) * 150
    gold.withAlphaComponent(0.95).setStroke()
    let ring = NSBezierPath(ovalIn: NSRect(x: centerX - 20, y: 153, width: 40, height: 40))
    ring.lineWidth = 1
    ring.stroke()
    let short = pillar.short as NSString
    let shortAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
        .foregroundColor: paleGold,
        .kern: 0.8
    ]
    let shortSize = short.size(withAttributes: shortAttributes)
    short.draw(
        at: NSPoint(x: centerX - shortSize.width / 2, y: 166),
        withAttributes: shortAttributes
    )

    let title = pillar.title as NSString
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 12.5, weight: .medium),
        .foregroundColor: muted,
        .paragraphStyle: {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.lineSpacing = 0
            return style
        }()
    ]
    title.draw(
        in: NSRect(x: centerX - 67, y: 116, width: 134, height: 35),
        withAttributes: attributes
    )

    if index < pillars.count - 1 {
        NSColor.white.withAlphaComponent(0.13).setFill()
        NSRect(x: centerX + 74, y: 116, width: 1, height: 77).fill()
    }
}

// Bottom mission capsule.
let capsule = NSBezierPath(
    roundedRect: NSRect(x: 280, y: 28, width: 1030, height: 55),
    xRadius: 28,
    yRadius: 28
)
NSColor(calibratedRed: 4/255, green: 16/255, blue: 28/255, alpha: 0.72).setFill()
capsule.fill()
gold.withAlphaComponent(0.32).setStroke()
capsule.lineWidth = 1
capsule.stroke()

("SOLVING COMPLEX PROBLEMS   •   BUILDING SCALABLE SYSTEMS   •   SHARING KNOWLEDGE" as NSString).draw(
    at: NSPoint(x: 354, y: 47),
    withAttributes: [
        .font: NSFont.systemFont(ofSize: 13.5, weight: .medium),
        .foregroundColor: white,
        .kern: 2.2
    ]
)

NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode PNG")
}
try png.write(to: outputURL)
print(outputURL.path)
