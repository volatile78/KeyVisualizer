import SwiftUI
import Combine
import AppKit

class KeyboardMonitor: ObservableObject {
    @Published var pressedKeys: Set<String> = []

    private var keyMap: [UInt16: String] {
        var map: [UInt16: String] = [
            48: "Tab",
            56: "Shift_L",
            59: "Ctrl_L", 58: "Option_L", 55: "Cmd_L",
            49: "Space",
        ]
        if KeyConfig.shared.arrowMode {
            map[126] = "W"   // ↑
            map[123] = "A"   // ←
            map[125] = "S"   // ↓
            map[124] = "D"   // →
        } else {
            map[12] = "Q"
            map[13] = "W"
            map[14] = "E"
            map[0]  = "A"
            map[1]  = "S"
            map[2]  = "D"
        }
        return map
    }

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var mouseTimer: Timer?

    func start() {
        let mask: NSEvent.EventTypeMask = [.keyDown, .keyUp, .flagsChanged]

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }

        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.pollMouse()
        }
        RunLoop.main.add(timer, forMode: .common)
        mouseTimer = timer
    }

    private func handle(_ event: NSEvent) {
        switch event.type {
        case .flagsChanged:
            handleModifier(event)
        case .keyDown:
            guard let key = keyMap[event.keyCode] else { return }
            set(key, pressed: true)
        case .keyUp:
            guard let key = keyMap[event.keyCode] else { return }
            set(key, pressed: false)
        default:
            break
        }
    }

    private func pollMouse() {
        let buttons = NSEvent.pressedMouseButtons
        update("Mouse_L", pressed: (buttons & 0x1) != 0)
        update("Mouse_R", pressed: (buttons & 0x2) != 0)
    }

    private func set(_ key: String, pressed: Bool) {
        DispatchQueue.main.async {
            self.update(key, pressed: pressed)
        }
    }

    private func update(_ key: String, pressed: Bool) {
        let was = pressedKeys.contains(key)
        if was == pressed { return }
        if pressed {
            pressedKeys.insert(key)
        } else {
            pressedKeys.remove(key)
        }
    }

    private func handleModifier(_ event: NSEvent) {
        guard let key = keyMap[event.keyCode] else { return }

        let pressed: Bool
        switch event.keyCode {
        case 56, 60:   pressed = event.modifierFlags.contains(.shift)
        case 59, 62:   pressed = event.modifierFlags.contains(.control)
        case 58, 61:   pressed = event.modifierFlags.contains(.option)
        case 55, 54:   pressed = event.modifierFlags.contains(.command)
        default:       return
        }

        set(key, pressed: pressed)
    }

    func stop() {
        if let m = globalMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        mouseTimer?.invalidate()
        mouseTimer = nil
    }
}
