import AppKit
import Foundation

let outputPath = CommandLine.arguments.dropFirst().first
    ?? "output/linkedin/dheerix-linkedin-banner.png"
let outputURL = URL(fileURLWithPath: outputPath)
try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)

let width = 1584
let height = 396

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fatalError("Unable to create bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
guard let context = NSGraphicsContext.current?.cgContext else {
    fatalError("Unable to create graphics context")
}

let canvas = NSRect(x: 0, y: 0, width: width, height: height)
let background = NSGradient(colors: [
    NSColor(calibratedRed: 5/255, green: 14/255, blue: 31/255, alpha: 1),
    NSColor(calibratedRed: 9/255, green: 30/255, blue: 63/255, alpha: 1),
    NSColor(calibratedRed: 12/255, green: 48/255, blue: 91/255, alpha: 1)
])!
background.draw(in: canvas, angle: 0)

// Quiet engineering grid: visible enough to add depth, subtle enough for type.
context.saveGState()
context.setStrokeColor(NSColor.white.withAlphaComponent(0.045).cgColor)
context.setLineWidth(1)
for x in stride(from: 0, through: width, by: 44) {
    context.move(to: CGPoint(x: x, y: 0))
    context.addLine(to: CGPoint(x: x, y: height))
}
for y in stride(from: 0, through: height, by: 44) {
    context.move(to: CGPoint(x: 0, y: y))
    context.addLine(to: CGPoint(x: width, y: y))
}
context.strokePath()
context.restoreGState()

// Profile-photo-safe area on the left fades into the visual field.
let glow = NSGradient(
    starting: NSColor(calibratedRed: 24/255, green: 111/255, blue: 196/255, alpha: 0.17),
    ending: NSColor(calibratedRed: 24/255, green: 111/255, blue: 196/255, alpha: 0)
)!
glow.draw(
    in: NSBezierPath(ovalIn: NSRect(x: 270, y: -180, width: 720, height: 720)),
    relativeCenterPosition: .zero
)

// Technical traces reinforce the engineering identity.
context.saveGState()
context.setStrokeColor(NSColor(calibratedRed: 70/255, green: 163/255, blue: 235/255, alpha: 0.22).cgColor)
context.setLineWidth(2)
let traces: [[CGPoint]] = [
    [CGPoint(x: 36, y: 318), CGPoint(x: 310, y: 318), CGPoint(x: 365, y: 263), CGPoint(x: 480, y: 263)],
    [CGPoint(x: 80, y: 76), CGPoint(x: 300, y: 76), CGPoint(x: 358, y: 134), CGPoint(x: 485, y: 134)],
    [CGPoint(x: 1220, y: 324), CGPoint(x: 1415, y: 324), CGPoint(x: 1470, y: 269), CGPoint(x: 1560, y: 269)],
    [CGPoint(x: 1260, y: 72), CGPoint(x: 1435, y: 72), CGPoint(x: 1490, y: 127), CGPoint(x: 1570, y: 127)]
]
for trace in traces {
    guard let first = trace.first else { continue }
    context.move(to: first)
    trace.dropFirst().forEach { context.addLine(to: $0) }
}
context.strokePath()
context.setFillColor(NSColor(calibratedRed: 81/255, green: 177/255, blue: 243/255, alpha: 0.55).cgColor)
for trace in traces {
    for point in trace {
        context.fillEllipse(in: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6))
    }
}
context.restoreGState()

// Established DHEERIX mark.
let markRect = NSRect(x: 560, y: 116, width: 164, height: 164)
let markGradient = NSGradient(
    starting: NSColor(calibratedRed: 11/255, green: 23/255, blue: 48/255, alpha: 1),
    ending: NSColor(calibratedRed: 31/255, green: 95/255, blue: 173/255, alpha: 1)
)!
markGradient.draw(in: markRect, angle: -45)

NSColor(calibratedRed: 86/255, green: 189/255, blue: 246/255, alpha: 1).setFill()
NSRect(x: markRect.minX, y: markRect.maxY - 7, width: markRect.width, height: 7).fill()

let markText = "DX" as NSString
let markAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 59, weight: .heavy),
    .foregroundColor: NSColor.white,
    .kern: 2.5
]
let markSize = markText.size(withAttributes: markAttributes)
markText.draw(
    at: NSPoint(
        x: markRect.midX - markSize.width / 2,
        y: markRect.midY - markSize.height / 2
    ),
    withAttributes: markAttributes
)

("DHEERIX" as NSString).draw(
    at: NSPoint(x: 772, y: 190),
    withAttributes: [
        .font: NSFont.systemFont(ofSize: 66, weight: .bold),
        .foregroundColor: NSColor.white,
        .kern: 8.5
    ]
)

("ENGINEERING  •  SYSTEMS  •  LEADERSHIP" as NSString).draw(
    at: NSPoint(x: 778, y: 142),
    withAttributes: [
        .font: NSFont.systemFont(ofSize: 19, weight: .semibold),
        .foregroundColor: NSColor(calibratedRed: 161/255, green: 205/255, blue: 235/255, alpha: 1),
        .kern: 2.4
    ]
)

NSColor(calibratedRed: 76/255, green: 174/255, blue: 237/255, alpha: 0.9).setFill()
NSRect(x: 778, y: 126, width: 442, height: 3).fill()

NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode PNG")
}
try png.write(to: outputURL)
print(outputURL.path)
