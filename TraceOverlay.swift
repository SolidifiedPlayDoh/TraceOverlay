/*
  Full-screen tracing overlay: transparent image you can move, resize, and rotate.
  Lock = click-through so you can trace in the app behind. Control via menu bar icon.
  Build with build.sh (no Xcode).
*/
import AppKit
import Foundation
import UniformTypeIdentifiers

// MARK: - Full-screen overlay content (image with position, scale, rotation)

final class TraceOverlayView: NSView {
    var image: NSImage? { didSet { needsDisplay = true } }
    var imageOpacity: CGFloat = 0.5 { didSet { needsDisplay = true } }
    var isLocked: Bool = false

    var imageCenter: NSPoint = .zero { didSet { needsDisplay = true } }
    var imageScale: CGFloat = 0.5 { didSet { needsDisplay = true } }
    var imageRotation: CGFloat = 0 { didSet { needsDisplay = true } }

    private var dragStart: NSPoint = .zero
    private var centerStart: NSPoint = .zero
    private var scaleStart: CGFloat = 0.5
    private var rotationStart: CGFloat = 0
    private var rotateStartPoint: NSPoint = .zero
    private var rotateStartAngle: CGFloat = 0

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        guard let img = image else {
            let msg = "Open an image from the menu bar (▼) to start"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 18),
                .foregroundColor: NSColor.tertiaryLabelColor
            ]
            let size = (msg as NSString).size(withAttributes: attrs)
            (msg as NSString).draw(at: NSPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2), withAttributes: attrs)
            return
        }

        let imgSize = img.size
        guard imgSize.width > 0, imgSize.height > 0 else { return }

        let center = NSPoint(x: bounds.midX + imageCenter.x, y: bounds.midY + imageCenter.y)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        ctx.saveGState()
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: imageRotation)
        ctx.scaleBy(x: imageScale, y: imageScale)
        ctx.translateBy(x: -imgSize.width / 2, y: -imgSize.height / 2)
        let rect = CGRect(origin: .zero, size: imgSize)
        img.draw(in: rect, from: rect, operation: .sourceOver, fraction: imageOpacity)
        ctx.restoreGState()
    }

    override func mouseDown(with event: NSEvent) {
        guard !isLocked, image != nil else { return }
        let p = convert(event.locationInWindow, from: nil)
        dragStart = p
        centerStart = imageCenter
        scaleStart = imageScale
        rotationStart = imageRotation
        rotateStartPoint = p
        let center = NSPoint(x: bounds.midX + imageCenter.x, y: bounds.midY + imageCenter.y)
        rotateStartAngle = atan2(p.y - center.y, p.x - center.x) - imageRotation
    }

    override func mouseDragged(with event: NSEvent) {
        guard !isLocked, image != nil else { return }
        let p = convert(event.locationInWindow, from: nil)
        if event.modifierFlags.contains(.option) {
            let center = NSPoint(x: bounds.midX + imageCenter.x, y: bounds.midY + imageCenter.y)
            let angle = atan2(p.y - center.y, p.x - center.x)
            imageRotation = angle - rotateStartAngle
        } else {
            imageCenter = NSPoint(
                x: centerStart.x + (p.x - dragStart.x),
                y: centerStart.y + (p.y - dragStart.y)
            )
        }
    }

    override func scrollWheel(with event: NSEvent) {
        guard !isLocked, image != nil else { return }
        let delta: CGFloat = event.scrollingDeltaY > 0 ? 0.1 : -0.1
        imageScale = max(0.05, min(3, imageScale + delta))
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard !isLocked, sender.draggingPasteboard.types?.contains(.fileURL) == true else { return [] }
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL],
              let url = urls.first else { return false }
        let ext = (url.pathExtension as NSString).lowercased
        guard ["png", "jpg", "jpeg", "gif", "tiff", "bmp"].contains(ext) else { return false }
        guard let img = NSImage(contentsOf: url) else { return false }
        image = img
        imageCenter = .zero
        imageScale = 0.5
        imageRotation = 0
        return true
    }
}

// MARK: - Full-screen overlay window

final class TraceOverlayWindow: NSWindow {
    let overlayView = TraceOverlayView()

    init(screen: NSScreen = NSScreen.main!) {
        let frame = screen.frame
        super.init(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        self.setFrame(frame, display: true)
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        contentView = overlayView
        overlayView.frame = NSRect(origin: .zero, size: frame.size)
        collectionBehavior = [.canJoinAllSpaces, .stationary]
    }

    var isLocked: Bool {
        get { overlayView.isLocked }
        set { overlayView.isLocked = newValue }
    }

    func applyLock(_ locked: Bool) {
        ignoresMouseEvents = locked
        overlayView.isLocked = locked
    }
}

// MARK: - App delegate + status bar menu

final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: TraceOverlayWindow!
    var statusItem: NSStatusItem?
    var lockMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = TraceOverlayWindow()
        window.orderFrontRegardless()
        setupStatusBar()
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "square.dashed", accessibilityDescription: "Trace Overlay")
        statusItem?.button?.image?.isTemplate = true
        let menu = NSMenu()
        let open = NSMenuItem(title: "Open Image…", action: #selector(openImage), keyEquivalent: "o")
        open.target = self
        menu.addItem(open)
        menu.addItem(NSMenuItem.separator())
        lockMenuItem = NSMenuItem(title: "Lock (click-through)", action: #selector(toggleLock), keyEquivalent: "l")
        lockMenuItem?.target = self
        menu.addItem(lockMenuItem!)
        let opacityItem = NSMenuItem(title: "Opacity", action: nil, keyEquivalent: "")
        let opacityMenu = NSMenu()
        for (title, value) in [("30%", 0.3), ("50%", 0.5), ("70%", 0.7), ("100%", 1.0)] {
            let m = NSMenuItem(title: title, action: #selector(setOpacity(_:)), keyEquivalent: "")
            m.target = self
            m.representedObject = value as NSNumber
            opacityMenu.addItem(m)
        }
        opacityItem.submenu = opacityMenu
        menu.addItem(opacityItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Trace Overlay", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func openImage() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [.png, .jpeg, .gif, .tiff]
        } else {
            panel.allowedFileTypes = ["png", "jpg", "jpeg", "gif", "tiff", "bmp"]
        }
        let response = panel.runModal()
        if response == .OK, let url = panel.url {
            loadImage(from: url)
        }
    }

    func loadImage(from url: URL) {
        guard let img = NSImage(contentsOf: url) else { return }
        window.overlayView.image = img
        window.overlayView.imageCenter = .zero
        window.overlayView.imageScale = 0.5
        window.overlayView.imageRotation = 0
    }

    @objc func toggleLock() {
        let locked = !window.isLocked
        window.applyLock(locked)
        lockMenuItem?.title = locked ? "Unlock (click-through off)" : "Lock (click-through)"
    }

    @objc func setOpacity(_ sender: NSMenuItem) {
        guard let num = sender.representedObject as? NSNumber else { return }
        window.overlayView.imageOpacity = CGFloat(truncating: num)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        loadImage(from: url)
    }
}

// MARK: - Entry

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
