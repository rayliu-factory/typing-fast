import SwiftUI
import UIKit

/// Receives external-keyboard input while the game uses its own touch keyboard.
struct HardwareKeyboard: UIViewRepresentable {
    var active: Bool
    var onKey: (String) -> Void
    func makeUIView(context: Context) -> KeyReceiver {
        let view = KeyReceiver()
        view.onKey = onKey
        return view
    }
    func updateUIView(_ view: KeyReceiver, context: Context) {
        view.onKey = onKey
        if active && !view.isFirstResponder { view.becomeFirstResponder() }
        if !active && view.isFirstResponder { view.resignFirstResponder() }
    }
}

final class KeyReceiver: UIView, UIKeyInput {
    var onKey: (String) -> Void = { _ in }
    override var canBecomeFirstResponder: Bool { true }
    override var inputView: UIView? { UIView(frame: .zero) }
    var hasText: Bool { true }
    var autocorrectionType: UITextAutocorrectionType = .no
    var autocapitalizationType: UITextAutocapitalizationType = .none
    func insertText(_ text: String) {
        for char in text {
            onKey(char == "\n" || char == "\r" ? "ENTER" : String(char))
        }
    }
    func deleteBackward() { onKey("⌫") }
    override var keyCommands: [UIKeyCommand]? {
        [UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escape)),
         UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(nextTarget))]
    }
    @objc private func escape() { onKey("ESC") }
    @objc private func nextTarget() { onKey("LOCK NEXT") }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
    }
}
