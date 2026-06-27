import AppKit

// Renders a 1024x1024 macOS-style app icon: a rounded-rect (squircle) with
// padding on a transparent canvas, the focus gradient, and a white timer glyph.
let canvas = 1024
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: canvas, pixelsHigh: canvas,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext

// macOS icon grid: ~824pt content inside 1024 with ~100 padding, continuous corners.
let pad: CGFloat = 100
let side = CGFloat(canvas) - pad * 2
let rect = CGRect(x: pad, y: pad, width: side, height: side)
let radius = side * 0.2237
let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

// Soft drop shadow under the icon.
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30,
              color: NSColor.black.withAlphaComponent(0.25).cgColor)
ctx.addPath(path)
ctx.setFillColor(NSColor.white.cgColor)
ctx.fillPath()
ctx.restoreGState()

// Gradient fill clipped to the squircle.
ctx.saveGState()
ctx.addPath(path)
ctx.clip()
let colors = [
    NSColor(srgbRed: 0.98, green: 0.36, blue: 0.42, alpha: 1).cgColor,
    NSColor(srgbRed: 0.96, green: 0.55, blue: 0.30, alpha: 1).cgColor
] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: pad, y: CGFloat(canvas) - pad),
                       end: CGPoint(x: CGFloat(canvas) - pad, y: pad), options: [])
ctx.restoreGState()

// Centered white timer glyph.
let config = NSImage.SymbolConfiguration(pointSize: 430, weight: .semibold)
    .applying(.init(paletteColors: [.white]))
if let symbol = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) {
    let s = symbol.size
    let origin = CGPoint(x: (CGFloat(canvas) - s.width) / 2, y: (CGFloat(canvas) - s.height) / 2)
    symbol.draw(in: CGRect(origin: origin, size: s))
}

NSGraphicsContext.restoreGraphicsState()

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-macos-1024.png"
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
