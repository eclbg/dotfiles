#!/usr/bin/env bash
set -euo pipefail

# Install Xcode Command Line Tools (needed for git, compilers, etc.)
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Press enter once the installation finishes."
  read -r
else
  echo "Xcode Command Line Tools already installed."
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for the rest of this script
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Persist Homebrew in PATH for future shell sessions
  ZPROFILE="$HOME/.zprofile"
  BREW_INIT='eval "$(/opt/homebrew/bin/brew shellenv)"'
  if ! grep -qF "$BREW_INIT" "$ZPROFILE" 2>/dev/null; then
    echo "$BREW_INIT" >> "$ZPROFILE"
    echo "Added Homebrew to $ZPROFILE."
  fi
else
  echo "Homebrew already installed."
fi

echo "Done! Homebrew is ready. Run 'brew bundle --file=Brewfile' to install packages."
