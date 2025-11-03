#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
print_info() {
  echo -e "\033[1;32m$1\033[0m"
}

print_info "🚀 Installing Minikube on macOS (Apple Silicon)..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  print_info "🧰 Homebrew not found. Preparing to install Homebrew..."

  # Security: download installer to a temporary file and verify its SHA256 before executing.
  # To use automated install you MUST set HOMEBREW_INSTALLER_SHA256 to the expected checksum
  # (pinned known-good checksum). If you cannot provide a checksum for unattended installs,
  # set SKIP_HOMEBREW_INSTALL=1 to skip automated install and follow the manual audited install steps.

  HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

  if [ "${SKIP_HOMEBREW_INSTALL:-0}" = "1" ]; then
    echo
    print_info "⚠️  Automated Homebrew install skipped (SKIP_HOMEBREW_INSTALL=1)."
    echo "Please install Homebrew manually by auditing the installer at:"
    echo "  $HOMEBREW_INSTALLER_URL"
    echo "Manual install example (audit before running):"
    echo "  /bin/bash -c \"\$(curl -fsSL $HOMEBREW_INSTALLER_URL)\""
    echo
    exit 1
  fi

  if [ -z "${HOMEBREW_INSTALLER_SHA256:-}" ]; then
    echo
    print_info "❗ HOMEBREW_INSTALLER_SHA256 is not set. Refusing to run automated installer."
    echo "Set the expected SHA256 in the environment (HOMEBREW_INSTALLER_SHA256) to enable automated install," \
         "or set SKIP_HOMEBREW_INSTALL=1 to skip automated install and perform a manual, audited installation."
    echo
    exit 1
  fi

  TMPFILE=$(mktemp -t brew-installer.XXXXXXXX)
  trap 'rm -f "$TMPFILE"' EXIT

  print_info "⬇️ Downloading Homebrew installer to temporary file..."
  if ! curl -fsSL -o "$TMPFILE" "$HOMEBREW_INSTALLER_URL"; then
    echo "Failed to download Homebrew installer from $HOMEBREW_INSTALLER_URL" >&2
    exit 1
  fi

  # Compute SHA256 (works on macOS with shasum, fallback to openssl if needed)
  if command -v shasum &>/dev/null; then
    CALC_SHA256=$(shasum -a 256 "$TMPFILE" | awk '{print $1}')
  else
    CALC_SHA256=$(openssl dgst -sha256 "$TMPFILE" | awk '{print $2}')
  fi

  if [ "$CALC_SHA256" != "$HOMEBREW_INSTALLER_SHA256" ]; then
    echo
    echo "ERROR: Homebrew installer checksum verification failed." >&2
    echo "Expected: $HOMEBREW_INSTALLER_SHA256" >&2
    echo "Actual:   $CALC_SHA256" >&2
    echo "Refusing to run the installer. If you believe this is a false positive, verify the installer manually." >&2
    exit 1
  fi

  print_info "✅ Homebrew installer checksum verified. Running installer..."
  /bin/bash "$TMPFILE"
  print_info "✅ Homebrew installed successfully!"
fi

# Ensure brew is up to date
print_info "🔄 Updating Homebrew..."
brew update

# Install dependencies
print_info "📦 Installing dependencies: curl, kubectl, hyperkit (optional driver)..."

# Install essential packages separately so failures abort the script (set -e will exit on non-zero).
print_info "🔧 Installing curl..."
brew install curl

print_info "🔧 Installing kubectl..."
brew install kubectl

# hyperkit is optional for Minikube; install but do not abort if it fails.
print_info "🔧 Installing hyperkit (optional)..."
if ! brew install hyperkit; then
  print_info "⚠️ hyperkit install failed or is unavailable; continuing without hyperkit."
fi

# Install Minikube
print_info "⬇️ Installing the latest version of Minikube..."
brew install minikube

# Or upgrade if already installed
if brew list minikube &>/dev/null; then
  print_info "⚙️ Updating Minikube to the latest version..."
  brew upgrade minikube
fi

# Verify installation
print_info "✅ Verifying Minikube installation..."
minikube version

# Suggest starting Minikube
print_info "🎉 Installation complete!"
echo "You can start Minikube with:"
echo "  minikube start --driver=hyperkit"

