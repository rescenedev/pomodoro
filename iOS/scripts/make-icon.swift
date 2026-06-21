import AppKit

// Renders a 1024x1024 iOS app icon: the app's focus red→orange gradient with a
// centered white timer glyph. No transparency (iOS applies the rounded mask).
let size = 1024
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4,
    hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0
)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
let rect = CGRect(x: 0, y: 0, width: size, height: size)

// Diagonal gradient (matches SessionType.focus: top-leading → bottom-trailing)
let colors = [
    NSColor(srgbRed: 0.98, green: 0.36, blue: 0.42, alpha: 1).cgColor,
    NSColor(srgbRed: 0.96, green: 0.55, blue: 0.30, alpha: 1).cgColor
] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
// CG origin is bottom-left, so start at top-left, end at bottom-right.
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

// Centered white timer glyph.
let config = NSImage.SymbolConfiguration(pointSize: 560, weight: .semibold)
    .applying(.init(paletteColors: [.white]))
if let symbol = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) {
    let s = symbol.size
    let origin = CGPoint(x: (CGFloat(size) - s.width) / 2, y: (CGFloat(size) - s.height) / 2)
    symbol.draw(in: CGRect(origin: origin, size: s))
}

NSGraphicsContext.restoreGraphicsState()

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
