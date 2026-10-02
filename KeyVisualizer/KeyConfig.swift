import SwiftUI
import Combine

class KeyConfig: ObservableObject {
    static let shared = KeyConfig()

    @Published var enabledKeys: Set<String> = [] {
        didSet { save() }
    }

    @Published var arrowMode: Bool = false {
        didSet { UserDefaults.standard.set(arrowMode, forKey: "arrowMode") }
    }

    @Published var panelOpacity: Double = 1.0 {
        didSet { UserDefaults.standard.set(panelOpacity, forKey: "panelOpacity") }
    }
    
    @Published var hoverTransparent: Bool = false {
        didSet { UserDefaults.standard.set(hoverTransparent, forKey: "hoverTransparent") }
    }

    @Published var hoverOpacity: Double = 0.3 {
        didSet { UserDefaults.standard.set(hoverOpacity, forKey: "hoverOpacity") }
    }

    private let allKeys: Set<String> = [
        "Tab","Q","W","E","A","S","D",
        "Shift_L","Ctrl_L","Option_L","Cmd_L","Space",
        "Mouse_L","Mouse_R",
    ]

    private init() {
        if let saved = UserDefaults.standard.stringArray(forKey: "enabledKeys") {
            enabledKeys = Set(saved)
        } else {
            enabledKeys = allKeys
        }
        arrowMode = UserDefaults.standard.bool(forKey: "arrowMode")

        let saved = UserDefaults.standard.double(forKey: "panelOpacity")
        panelOpacity = saved == 0 ? 1.0 : saved
        
        hoverTransparent = UserDefaults.standard.bool(forKey: "hoverTransparent")

        let savedHover = UserDefaults.standard.double(forKey: "hoverOpacity")
        hoverOpacity = savedHover == 0 ? 0.3 : savedHover
    }

    func toggle(_ key: String) {
        if enabledKeys.contains(key) {
            enabledKeys.remove(key)
        } else {
            enabledKeys.insert(key)
        }
    }

    private func save() {
        UserDefaults.standard.set(Array(enabledKeys), forKey: "enabledKeys")
    }
}
