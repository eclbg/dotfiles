# Dotfiles

## Installation

```bash
./bootstrap.sh
```

This installs Xcode Command Line Tools and Homebrew. Then:

```bash
brew bundle --file=Brewfile
make get-all
```

## Yabai

Yabai requires partial SIP disabling and a scripting addition to support space-level operations (e.g., focusing spaces with `alt + number`, or moving apps to spaces).

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

### Some boot-args thing

Run `sudo nvram boot-args=-arm64e_preview_abi `. 
Reboot

### Configure passwordless sudo for yabai

```bash
echo "$(whoami) ALL=(root) NOPASSWD: SETENV: sha256:$(shasum -a 256 $(which yabai) | cut -d ' ' -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
```

> **Note:** This must be re-run every time yabai is updated (the hash changes).

### Gotchas

- **`sudo: sorry, you are not allowed to set the following environment variables: TERMINFO`** — This happens when your terminal (e.g., Kitty) sets the `TERMINFO` env var. The fix is to add `SETENV:` to the sudoers entry (already included in the command above).

- **`could not spawn remote thread: (os/kern) protection failure`** — Known bug in yabai v7.1.16+ on Sequoia, caused by a PAC ABI mismatch. Either downgrade to v7.1.15 or apply the [patch script from issue #2686](https://github.com/asmvik/yabai/issues/2686#issuecomment-2884938498). To downgrade:
  ```bash
  brew uninstall yabai
  curl -L -o ~/yabai-old.rb https://raw.githubusercontent.com/koekeishiya/homebrew-formulae/f5711b9c70e104bffc79e3525e2ed0dc335bdbba/yabai.rb
  brew tap-new local/yabai
  mv ~/yabai-old.rb $(brew --repo local/yabai)/Formula/yabai.rb
  brew install local/yabai/yabai
  brew pin local/yabai/yabai
  ```
  Then re-run the sudoers command above.

### Start yabai and skhd

```bash
yabai --start-service
skhd --start-service
```

### Grant permissions

- Go to *System Settings → Privacy & Security → Accessibility* and enable both **yabai** and **skhd**. You'll be prompted and can just click through
- Restart both services after granting permissions
