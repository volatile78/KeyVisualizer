import SwiftUI
import AppKit

class ConfigWindowManager {
    static let shared = ConfigWindowManager()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: ConfigView())
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 460, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
            w.title = "按键配置 v\(version)"
            w.contentView = hosting
            w.center()
            w.isReleasedWhenClosed = false
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct ConfigView: View {
    @ObservedObject var config = KeyConfig.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("点击启用按键")
                .font(.headline)

            HStack(spacing: 6) {
                ForEach(["Tab", "Q", "W", "E"], id: \.self) { toggle($0) }
            }
            HStack(spacing: 6) {
                ForEach(["Shift_L", "A", "S", "D"], id: \.self) { toggle($0) }
            }
            HStack(spacing: 6) {
                ForEach(["Ctrl_L", "Option_L", "Cmd_L", "Space"], id: \.self) { toggle($0) }
            }
            HStack(spacing: 6) {
                ForEach(["Mouse_L", "Mouse_R"], id: \.self) { toggle($0) }
            }
            Divider().padding(.vertical, 4)
            Toggle("方向键", isOn: $config.arrowMode)
                .toggleStyle(.switch)
            Toggle("鼠标悬停时变透明", isOn: $config.hoverTransparent)
                .toggleStyle(.switch)
            if config.hoverTransparent {
                HStack {
                    Text("悬停时透明度")
                    Slider(value: $config.hoverOpacity, in: 0.05...0.8)
                        .frame(width: 180)
                    Text("\(Int(config.hoverOpacity * 100))%")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
            HStack {
                Text("面板透明度")
                Slider(value: $config.panelOpacity, in: 0.2...1.0)
                    .frame(width: 180)
                Text("\(Int(config.panelOpacity * 100))%")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func toggle(_ id: String) -> some View {
        Button {
            config.toggle(id)
        } label: {
            Text(labelFor(id))
                .font(.system(size: 12, weight: .medium))
                .frame(minWidth: 42, minHeight: 30)
                .padding(.horizontal, 8)
                .background(
                    config.enabledKeys.contains(id)
                        ? Color.accentColor
                        : Color.gray.opacity(0.2)
                )
                .foregroundColor(
                    config.enabledKeys.contains(id) ? .white : .primary
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
