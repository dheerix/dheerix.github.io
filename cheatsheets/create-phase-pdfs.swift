import AppKit
import CoreGraphics
import Foundation

let fileManager = FileManager.default
let workspace = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let inputRoot = workspace.appendingPathComponent("cheatsheets/generated", isDirectory: true)
let outputRoot = workspace.appendingPathComponent("output/pdf", isDirectory: true)

try fileManager.createDirectory(at: outputRoot, withIntermediateDirectories: true)

let phaseFolders = try fileManager.contentsOfDirectory(
    at: inputRoot,
    includingPropertiesForKeys: [.isDirectoryKey],
    options: [.skipsHiddenFiles]
).filter {
    $0.lastPathComponent.hasPrefix("phase-") &&
    (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
}.sorted { $0.lastPathComponent < $1.lastPathComponent }

let pageRect = CGRect(x: 0, y: 0, width: 576, height: 720) // 8 × 10 inches

for phaseFolder in phaseFolders {
    let imageURLs = try fileManager.contentsOfDirectory(
        at: phaseFolder,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
    ).filter { $0.pathExtension.lowercased() == "png" }
     .sorted { $0.lastPathComponent < $1.lastPathComponent }

    guard !imageURLs.isEmpty else { continue }

    let outputURL = outputRoot
        .appendingPathComponent(phaseFolder.lastPathComponent)
        .appendingPathExtension("pdf")

    var mediaBox = pageRect
    guard let consumer = CGDataConsumer(url: outputURL as CFURL),
          let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
        throw NSError(
            domain: "DheerixPDF",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Could not create \(outputURL.path)"]
        )
    }

    for imageURL in imageURLs {
        guard let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw NSError(
                domain: "DheerixPDF",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Could not read \(imageURL.path)"]
            )
        }

        context.beginPDFPage([kCGPDFContextMediaBox as String: pageRect] as CFDictionary)
        context.saveGState()
        context.interpolationQuality = .high
        context.draw(image, in: pageRect)
        context.restoreGState()
        context.endPDFPage()
    }

    context.closePDF()
    print("\(outputURL.lastPathComponent)\t\(imageURLs.count) pages")
}
