import SwiftUI
import AppKit

@main
struct KeyVisualizerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("KeyVisualizer", systemImage: "keyboard.badge.eye") {
            Button("按键配置") {
                ConfigWindowManager.shared.show()
            }
            Divider()
            Button("退出") {
                NSApp.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    private var hoverTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let hosting = NSHostingView(rootView: ContentView())
        hosting.setFrameSize(hosting.fittingSize)

        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: hosting.fittingSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.contentView = hosting
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        if let saved = UserDefaults.standard.string(forKey: "windowFrame") {
            window.setFrame(NSRectFromString(saved), display: true)
        } else {
            window.center()
        }

        window.makeKeyAndOrderFront(nil)
        
        let t = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkHover()
        }
        RunLoop.main.add(t, forMode: .common)
        hoverTimer = t

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            UserDefaults.standard.set(
                NSStringFromRect(self.window.frame),
                forKey: "windowFrame"
            )
        }

        NotificationCenter.default.addObserver(
            forName: .contentSizeChanged,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self,
                  let size = note.userInfo?["size"] as? CGSize else { return }
            self.animateWindow(to: size)
        }
    }
    
    private func checkHover() {
        guard let window else { return }

        let mouse = NSEvent.mouseLocation
        let isInside = window.frame.contains(mouse)

        let targetAlpha: CGFloat
        if KeyConfig.shared.hoverTransparent && isInside {
            targetAlpha = CGFloat(KeyConfig.shared.hoverOpacity)
        } else {
            targetAlpha = CGFloat(KeyConfig.shared.panelOpacity)
        }

        if abs(window.alphaValue - targetAlpha) > 0.01 {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
                window.animator().alphaValue = targetAlpha
            }
        }
    }

    private func animateWindow(to newSize: CGSize) {
        let startFrame = window.frame

        if abs(startFrame.width - newSize.width) < 0.5 &&
           abs(startFrame.height - newSize.height) < 0.5 {
            return
        }

        let isGrowing = newSize.width > startFrame.width
                     || newSize.height > startFrame.height

        let targetOrigin = NSPoint(
            x: startFrame.origin.x,
            y: startFrame.origin.y + startFrame.height - newSize.height
        )
        let targetFrame = NSRect(origin: targetOrigin, size: newSize)

        if !isGrowing {
            window.setFrame(targetFrame, display: true)
            return
        }

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.35
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            ctx.allowsImplicitAnimation = true
            window.animator().setFrame(targetFrame, display: true)
        }
    }
}
