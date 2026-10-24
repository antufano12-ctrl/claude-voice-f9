# Claude Voice (F9)

A PowerShell script for Windows that, when you press **F9**, opens the Claude desktop app on a **new chat** and immediately starts **voice mode**.

It uses Windows UI Automation to find and press the "New chat" and "Voice mode" buttons, with a single cached scan to be as fast as possible. If a button doesn't respond to Invoke, it falls back to a mouse click.

## Requirements

- Windows 10/11
- Claude desktop app (Microsoft Store / MSIX version)
- PowerShell 5.1 (included with Windows)

## Installation

1. Download the project to a folder you won't move.
2. Right-click `create_shortcut.ps1` → **Run with PowerShell**.
   It creates a **"Claude Voice"** desktop shortcut with the **F9** hotkey.

## Usage

Press **F9** from anywhere in Windows: Claude opens on a new chat in voice mode.

## Debugging

Run `open_voice.ps1 -Log` to write the steps and the buttons found to `claude_voice_log.txt` on your Desktop. Useful if the Claude UI renames its buttons: in that case, update the regular expressions `$rxNew` and the voice-mode one (they match both Italian and English labels).

## See also

- [f10-whatsapp-claude](../../../f10-whatsapp-claude): F10 opens WhatsApp Web with Claude in Chrome to dictate messages.

## License

[MIT](LICENSE)
