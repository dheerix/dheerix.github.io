import AppKit
import Foundation
import PDFKit

let fileManager = FileManager.default
let workspace = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let pdfRoot = workspace.appendingPathComponent("output/pdf", isDirectory: true)
let renderRoot = workspace.appendingPathComponent("tmp/pdfs", isDirectory: true)
try fileManager.createDirectory(at: renderRoot, withIntermediateDirectories: true)

let pdfURLs = try fileManager.contentsOfDirectory(
    at: pdfRoot,
    includingPropertiesForKeys: nil,
    options: [.skipsHiddenFiles]
).filter { $0.pathExtension.lowercased() == "pdf" }
 .sorted { $0.lastPathComponent < $1.lastPathComponent }

guard pdfURLs.count == 20 else {
    throw NSError(
        domain: "DheerixPDF",
        code: 10,
        userInfo: [NSLocalizedDescriptionKey: "Expected 20 PDFs, found \(pdfURLs.count)"]
    )
}

for (index, pdfURL) in pdfURLs.enumerated() {
    guard let document = PDFDocument(url: pdfURL),
          document.pageCount > 0,
          let firstPage = document.page(at: 0) else {
        throw NSError(
            domain: "DheerixPDF",
            code: 11,
            userInfo: [NSLocalizedDescriptionKey: "Could not open \(pdfURL.path)"]
        )
    }

    let bounds = firstPage.bounds(for: .mediaBox)
    guard abs(bounds.width - 576) < 0.1, abs(bounds.height - 720) < 0.1 else {
        throw NSError(
            domain: "DheerixPDF",
            code: 12,
            userInfo: [NSLocalizedDescriptionKey: "Unexpected page size in \(pdfURL.path): \(bounds)"]
        )
    }

    print("\(pdfURL.lastPathComponent)\t\(document.pageCount)\t\(Int(bounds.width))x\(Int(bounds.height)) pt")

    if index == 0 || index == 9 || index == 19 {
        let thumbnail = firstPage.thumbnail(of: NSSize(width: 864, height: 1080), for: .mediaBox)
        guard let tiff = thumbnail.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(
                domain: "DheerixPDF",
                code: 13,
                userInfo: [NSLocalizedDescriptionKey: "Could not render \(pdfURL.path)"]
            )
        }
        let outputURL = renderRoot.appendingPathComponent(
            pdfURL.deletingPathExtension().lastPathComponent + "-page-001.png"
        )
        try png.write(to: outputURL)
    }
}
