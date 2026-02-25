# Dotfiles

## Installation

1. Install Homebrew: https://brew.sh
2. Install all tools: `brew bundle --file=Brewfile`
3. Apply all configs: `make get-all`

## Yabai

Yabai requires partial SIP disabling and a scripting addition to support space-level operations (e.g., focusing spaces with `alt + number`, or moving apps to spaces).

### Some boot-args thing

Run `sudo nvram boot-args=-arm64e_preview_abi `. Needs rebooting to take effect but you'll reboot
for the next step so no need to do it now.

### Disable SIP partially

1. Shut down your Mac
2. Hold the **power button** until "Loading startup options" appears
3. Click **Options** → Continue
4. Open **Terminal** from the Utilities menu
5. Run:
   ```bash
   csrutil enable --without fs --without debug --without nvram
   ```
6. Reboot

### Configure passwordless sudo for yabai

```bash
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d ' ' -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
```

> **Note:** This must be re-run every time yabai is updated (the hash changes).

### Start yabai and skhd

```bash
yabai --start-service
skhd --start-service
```

### Grant permissions

- Go to *System Settings → Privacy & Security → Accessibility* and enable both **yabai** and **skhd**. You'll be prompted and can just click through
- Restart both services after granting permissions
