import AppKit
import Foundation

guard CommandLine.arguments.count == 3 else {
	fputs("Usage: render-brand.swift input.png output.png\n", stderr)
	exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard let poster = NSImage(contentsOf: inputURL) else {
	fputs("Unable to load poster\n", stderr)
	exit(3)
}

guard let bitmap = NSBitmapImageRep(
	bitmapDataPlanes: nil,
	pixelsWide: 1080,
	pixelsHigh: 1350,
	bitsPerSample: 8,
	samplesPerPixel: 4,
	hasAlpha: true,
	isPlanar: false,
	colorSpaceName: .deviceRGB,
	bytesPerRow: 0,
	bitsPerPixel: 0
) else {
	fputs("Unable to create bitmap\n", stderr)
	exit(4)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor.white.setFill()
NSRect(x: 0, y: 0, width: 1080, height: 1350).fill()
poster.draw(
	in: NSRect(x: 0, y: 50, width: 1080, height: 1300),
	from: .zero,
	operation: .copy,
	fraction: 1
)

NSColor(calibratedRed: 248/255, green: 250/255, blue: 252/255, alpha: 1).setFill()
NSRect(x: 0, y: 0, width: 1080, height: 50).fill()
NSColor(calibratedRed: 215/255, green: 224/255, blue: 234/255, alpha: 1).setStroke()
let divider = NSBezierPath()
divider.move(to: NSPoint(x: 0, y: 50))
divider.line(to: NSPoint(x: 1080, y: 50))
divider.stroke()

let markRect = NSRect(x: 20, y: 8, width: 34, height: 34)
let gradient = NSGradient(
	starting: NSColor(calibratedRed: 11/255, green: 23/255, blue: 48/255, alpha: 1),
	ending: NSColor(calibratedRed: 31/255, green: 95/255, blue: 173/255, alpha: 1)
)!
gradient.draw(in: markRect, angle: -45)

let white = NSColor.white
let navy = NSColor(calibratedRed: 11/255, green: 23/255, blue: 48/255, alpha: 1)
let slate = NSColor(calibratedRed: 66/255, green: 86/255, blue: 111/255, alpha: 1)
let markText = "DX" as NSString
let markAttributes: [NSAttributedString.Key: Any] = [
	.font: NSFont.boldSystemFont(ofSize: 13),
	.foregroundColor: white,
	.kern: 0.8
]
let markTextSize = markText.size(withAttributes: markAttributes)
markText.draw(
	at: NSPoint(
		x: markRect.midX - markTextSize.width / 2,
		y: markRect.midY - markTextSize.height / 2
	),
	withAttributes: markAttributes
)
("DHEERIX" as NSString).draw(
	at: NSPoint(x: 64, y: 16),
	withAttributes: [
		.font: NSFont.boldSystemFont(ofSize: 14),
		.foregroundColor: navy,
		.kern: 1.2
	]
)

let linkedIn = "linkedin.com/in/dheerajbharatsethi" as NSString
let linkedInAttributes: [NSAttributedString.Key: Any] = [
	.font: NSFont.systemFont(ofSize: 13, weight: .semibold),
	.foregroundColor: slate
]
let linkedInSize = linkedIn.size(withAttributes: linkedInAttributes)
linkedIn.draw(
	at: NSPoint(x: 1060 - linkedInSize.width, y: 16),
	withAttributes: linkedInAttributes
)
NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
	fputs("Unable to encode PNG\n", stderr)
	exit(5)
}

try png.write(to: outputURL)
