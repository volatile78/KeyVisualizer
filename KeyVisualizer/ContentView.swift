import SwiftUI

extension Notification.Name {
    static let contentSizeChanged = Notification.Name("contentSizeChanged")
}

struct ContentView: View {
    @StateObject private var monitor = KeyboardMonitor()
    @ObservedObject var config = KeyConfig.shared

    private var blockW: CGFloat {
        let base = shiftWidth(enabled: config.enabledKeys)
        if config.enabledKeys.contains("Tab") {
            return max(base, keySize)
        }
        return base
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: keySpacing * 2) {
            VStack(alignment: .leading, spacing: keySpacing) {
                row1()
                row2()
                row3()
            }
            mouseColumn()
        }
        .animation(.easeOut(duration: 0.35), value: config.enabledKeys)
        .padding(20)
        .glassEffect(in: .rect(cornerRadius: 24))
        .contentShape(Rectangle())
        .opacity(config.panelOpacity)
        .onAppear { monitor.start() }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { reportSize(proxy.size) }
                    .onChange(of: proxy.size) { _, newSize in
                        reportSize(newSize)
                    }
            }
        }
    }

    private func reportSize(_ size: CGSize) {
        NotificationCenter.default.post(
            name: .contentSizeChanged,
            object: nil,
            userInfo: ["size": size]
        )
    }

    @ViewBuilder
    private func row1() -> some View {
        let hasTab = config.enabledKeys.contains("Tab")
        let hasQ = config.enabledKeys.contains("Q")
        let hasAny = ["Q", "W", "E"].contains { config.enabledKeys.contains($0) } || hasTab

        if hasAny {
            HStack(spacing: keySpacing) {
                if hasTab {
                    let tabW = hasQ ? blockW : (blockW + keySpacing + keySize)
                    KeyView(
                        label: "Tab",
                        width: tabW,
                        isPressed: monitor.pressedKeys.contains("Tab")
                    )
                } else if blockW > 0 {
                    Color.clear.frame(width: blockW, height: keySize)
                }

                if !(hasTab && !hasQ) {
                    keyCell("Q")
                }
                keyCell("W")
                keyCell("E")
            }
        }
    }

    @ViewBuilder
    private func row2() -> some View {
        let hasAny = ["A", "S", "D"].contains { config.enabledKeys.contains($0) }
            || config.enabledKeys.contains("Shift_L")
        if hasAny {
            HStack(spacing: keySpacing) {
                if blockW > 0 {
                    if config.enabledKeys.contains("Shift_L") {
                        KeyView(
                            label: "Shift",
                            width: blockW,
                            isPressed: monitor.pressedKeys.contains("Shift_L")
                        )
                    } else {
                        Color.clear.frame(width: blockW, height: keySize)
                    }
                }
                keyCell("A")
                keyCell("S")
                keyCell("D")
            }
        }
    }

    @ViewBuilder
    private func row3() -> some View {
        let mods = modifierOrder.filter { config.enabledKeys.contains($0) }
        let hasSpace = config.enabledKeys.contains("Space")
        if !mods.isEmpty || hasSpace {
            HStack(spacing: keySpacing) {
                if blockW > 0 {
                    HStack(spacing: keySpacing) {
                        ForEach(mods, id: \.self) { id in
                            KeyView(
                                label: labelFor(id),
                                width: keySize,
                                isPressed: monitor.pressedKeys.contains(id)
                            )
                        }
                    }
                    .frame(width: blockW, alignment: .leading)
                }

                if hasSpace {
                    KeyView(
                        label: "Space",
                        width: spaceWidth,
                        isPressed: monitor.pressedKeys.contains("Space")
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func mouseColumn() -> some View {
        let hasL = config.enabledKeys.contains("Mouse_L")
        let hasR = config.enabledKeys.contains("Mouse_R")
        if hasL || hasR {
            VStack(spacing: keySpacing) {
                if hasL {
                    KeyView(
                        label: "LMB",
                        width: keySize,
                        isPressed: monitor.pressedKeys.contains("Mouse_L")
                    )
                }
                if hasR {
                    KeyView(
                        label: "RMB",
                        width: keySize,
                        isPressed: monitor.pressedKeys.contains("Mouse_R")
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func keyCell(_ id: String) -> some View {
        if config.enabledKeys.contains(id) {
            KeyView(
                label: labelFor(id),
                width: keySize,
                isPressed: monitor.pressedKeys.contains(id)
            )
        } else {
            Color.clear.frame(width: keySize, height: keySize)
        }
    }
}

struct KeyView: View {
    let label: String
    let width: CGFloat
    let isPressed: Bool

    var body: some View {
        Text(label)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.primary)
            .frame(width: width, height: keySize)
            .glassEffect(
                .regular,
                in: .rect(cornerRadius: 8)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor)
                    .opacity(isPressed ? 0.6 : 0)
                    .animation(.easeOut(duration: 0.15), value: isPressed)
            }
            .animation(.easeOut(duration: 0.15), value: isPressed)
    }
}

#Preview {
    ContentView()
}
