#!/bin/bash
set -e

echo "================================"
echo "Solana Development Environment Setup"
echo "================================"

# Update system packages
echo "Updating system packages..."
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev

# Install Rust (if not already installed)
echo ""
echo "Installing Rust toolchain..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "Rust is already installed"
fi

# Install Solana CLI from Anza's installer
echo ""
echo "Installing Solana CLI from Anza..."
sh -c "$(curl -sSfL https://release.anza.dev/solana-install-init.sh)"
export PATH="/home/vscode/.local/share/solana/install/active_release/bin:$PATH"

# Install Node.js and npm (required for Anchor)
echo ""
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Anchor CLI via avm
echo ""
echo "Installing Anchor CLI via avm..."
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force

# Initialize avm and install latest Anchor
avm install latest
avm use latest

echo ""
echo "================================"
echo "Version Verification"
echo "================================"

# Verify installations
echo ""
echo "Rust version:"
rustc --version

echo ""
echo "Solana CLI version:"
solana --version

echo ""
echo "Anchor version:"
anchor --version

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo "All toolchains installed successfully."
