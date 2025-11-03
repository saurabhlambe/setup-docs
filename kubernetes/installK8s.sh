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
  print_info "🧰 Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_info "✅ Homebrew installed successfully!"
fi

# Ensure brew is up to date
print_info "🔄 Updating Homebrew..."
brew update

# Install dependencies
print_info "📦 Installing dependencies: curl, kubectl, hyperkit (optional driver)..."
brew install curl kubectl hyperkit || true

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

