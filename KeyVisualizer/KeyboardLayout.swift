import Foundation

let keySize: CGFloat = 50
let keySpacing: CGFloat = 6

let modifierOrder = ["Ctrl_L", "Option_L", "Cmd_L"]
let spaceWidth: CGFloat = 3 * keySize + 2 * keySpacing

func modifierWidth(enabled: Set<String>) -> CGFloat {
    let mods = modifierOrder.filter { enabled.contains($0) }
    if mods.isEmpty { return 0 }
    return CGFloat(mods.count) * keySize + CGFloat(mods.count - 1) * keySpacing
}

func shiftWidth(enabled: Set<String>) -> CGFloat {
    let hasShift = enabled.contains("Shift_L")
    let modW = modifierWidth(enabled: enabled)
    if hasShift {
        return max(keySize, modW)
    }
    return modW
}

func labelFor(_ id: String) -> String {
    let arrow = KeyConfig.shared.arrowMode
    switch id {
    case "Ctrl_L":   return "⌃"
    case "Option_L": return "⌥"
    case "Cmd_L":    return "⌘"
    case "Shift_L":  return "Shift"
    case "Space":    return "Space"
    case "Tab":      return "Tab"
    case "Q":        return "Q"
    case "E":        return "E"
    case "W":        return arrow ? "↑" : "W"
    case "A":        return arrow ? "←" : "A"
    case "S":        return arrow ? "↓" : "S"
    case "D":        return arrow ? "→" : "D"
    case "Mouse_L":  return "LMB"
    case "Mouse_R":  return "RMB"
    default:         return id
    }
}
