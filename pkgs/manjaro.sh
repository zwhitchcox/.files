#!/usr/bin/env zsh

# Update package database
sudo pacman -Syyu

# Install packages
set -e


sudo pacman -S --noconfirm z              # Quick directory jumper
sudo pacman -S --noconfirm postgresql     # Object-relational database system
sudo pacman -S --noconfirm zsh            # Advanced shell replacement
sudo pacman -S --noconfirm git            # Version control system
sudo pacman -S --noconfirm github-cli     # Command line interface to GitHub
sudo pacman -S --noconfirm neovim         # Modern fork of the vim text editor
sudo pacman -S --noconfirm tmux           # Terminal multiplexer
sudo pacman -S --noconfirm stow           # Symlink farm manager
sudo pacman -S --noconfirm yarn           # Package manager for JavaScript
sudo pacman -S --noconfirm fzf            # Command-line fuzzy finder
sudo pacman -S --noconfirm ripgrep        # Search tool that combines the speed of grep with the convenience of ag
sudo pacman -S --noconfirm bat            # Cat command with syntax highlighting
sudo pacman -S --noconfirm make           # Build automation tool
sudo pacman -S --noconfirm binutils       # Collection of binary tools
sudo pacman -S --noconfirm direnv         # Environment switcher
sudo pacman -S --noconfirm jq             # Command-line JSON processor
sudo pacman -S --noconfirm fd             # Simple, fast and user-friendly alternative to find
sudo pacman -S --noconfirm doctl          # DigitalOcean CLI
sudo pacman -S --noconfirm rustup         # Rust toolchain installer
sudo pacman -S --noconfirm unzip          # Extract files from ZIP archives
sudo pacman -S --noconfirm yay            # AUR helper
sudo pacman -S --noconfirm snapd          # Package manager for snap packages
sudo pacman -S --noconfirm tree           # Command-line tool for visualizing directory structures
sudo pacman -S --noconfirm htop           # Interactive process viewer and system monitor
sudo pacman -S --noconfirm fdupes         # Command-line tool for finding and removing duplicate files
sudo pacman -S --noconfirm ncdu           # Command-line tool for analyzing disk usage
sudo pacman -S --noconfirm ranger         # File manager with Vim-like keybindings
sudo pacman -S --noconfirm highlight      # Command-line tool for syntax highlighting source code and other text files
sudo pacman -S --noconfirm cscope         # Command-line tool for browsing and navigating C source code
sudo pacman -S --noconfirm docker         # Containerization platform for building, shipping, and running applications
sudo pacman -S --noconfirm kubernetes-cli # Command-line interface for managing Kubernetes clusters
sudo pacman -S --noconfirm aws-cli        # Command-line interface for interacting with Amazon Web Services
sudo pacman -S --noconfirm gcloud         # Command-line interface for interacting with Google Cloud Platform
sudo pacman -S --noconfirm terraform      # Command-line tool for building and managing infrastructure as code
sudo pacman -S --noconfirm ansible        # Configuration management and automation tool
