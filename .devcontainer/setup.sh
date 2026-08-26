#!/bin/bash
set -e

echo "================================"
echo "Solana Development Environment Setup"
echo "================================"

# Update system packages
echo "Updating system packages..."
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev curl

# Install Rust (if not already installed)
echo ""
echo "Installing Rust toolchain..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "Rust is already installed"
fi

# Add Rust to PATH for this session
export PATH="$HOME/.cargo/bin:$PATH"

# Install Solana CLI from Anza's installer
echo ""
echo "Installing Solana CLI from Anza..."
if ! command -v solana &> /dev/null; then
    sh -c "$(curl -sSfL https://release.anza.dev/solana-install-init.sh)"
else
    echo "Solana CLI is already installed"
fi

# Add Solana to PATH
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Install Node.js and npm (required for Anchor)
echo ""
echo "Installing Node.js and npm..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed"
fi

# Install Anchor CLI via avm
echo ""
echo "Installing Anchor CLI via avm..."
if ! command -v avm &> /dev/null; then
    cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
fi

# Use latest Anchor version
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
