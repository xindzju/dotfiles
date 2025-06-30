#!/bin/bash

#===============================================================================
# DOTFILES INSTALLATION SCRIPT
#===============================================================================
# This script sets up a complete development environment with:
# - Zsh shell with oh-my-zsh framework
# - Enhanced zsh plugins (syntax highlighting, autosuggestions)
# - Tmux terminal multiplexer with plugin manager
# - Autojump for quick directory navigation
# - Custom configurations from this dotfiles repository
#===============================================================================

set -e  # Exit on any error

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}======================================>${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}======================================>${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

# Detect if running as root and set up sudo handling
setup_sudo() {
    if [ "$EUID" -eq 0 ]; then
        SUDO=""
        print_status "Running as root user"
    else
        SUDO="sudo"
        print_status "Running as non-root user"
    fi
}

# Function to run command with or without sudo based on user context
run_cmd() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Fix file ownership for non-root users
fix_ownership() {
    local file_path="$1"
    if [ "$EUID" -ne 0 ] && [ -e "$file_path" ]; then
        sudo chown -R $USER:$USER "$file_path" 2>/dev/null || true
    fi
}

#===============================================================================
# MAIN INSTALLATION FUNCTIONS
#===============================================================================

install_system_packages() {
    print_status "Installing system packages"
    
    # Update package lists first
    run_cmd apt update
    
    # Install Python
    echo "Installing Python 3..."
    run_cmd apt install python3 python-is-python3 -y
    
    # Install basic prerequisites
    echo "Installing basic tools (wget, git)..."
    run_cmd apt install wget git -y
    
    # Install git-lfs from official repository
    echo "Installing Git LFS..."
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | $SUDO bash
    run_cmd apt install git-lfs -y
}

install_zsh() {
    print_status "Setting up Zsh shell"
    
    # Install zsh
    echo "Installing zsh..."
    run_cmd apt install zsh -y
    
    # Change default shell to zsh
    echo "Changing default shell to zsh..."
    if [ "$EUID" -eq 0 ]; then
        chsh -s /usr/bin/zsh
    else
        sudo chsh -s /usr/bin/zsh $USER
    fi
    
    echo "Current shell: $SHELL"
}

install_oh_my_zsh() {
    print_status "Installing Oh My Zsh framework"
    
    # Remove existing oh-my-zsh installation if it exists
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_warning "Existing oh-my-zsh installation found at $HOME/.oh-my-zsh"
        echo "Removing existing installation to prevent conflicts..."
        rm -rf "$HOME/.oh-my-zsh"
        echo "Existing oh-my-zsh installation removed successfully"
    fi
    
    # Set environment variables to control oh-my-zsh installation
    export RUNZSH=no        # Don't switch to zsh immediately
    export KEEP_ZSHRC=yes   # Keep existing .zshrc file
    
    # Download and install oh-my-zsh
    echo "Downloading and installing oh-my-zsh..."
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
    
    # Display environment information
    echo "Environment check:"
    echo "SHELL: $SHELL"
    echo "ZSH_CUSTOM: $ZSH_CUSTOM"
    echo "HOME: $HOME"
    
    # Fix ownership for non-root users
    fix_ownership "$HOME/.oh-my-zsh"
}

install_zsh_plugins() {
    print_status "Installing Zsh plugins"
    
    local plugin_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"
    
    # Remove existing plugins if they exist to prevent conflicts
    if [[ -d "$plugin_dir/zsh-syntax-highlighting" ]]; then
        echo "Removing existing zsh-syntax-highlighting plugin..."
        rm -rf "$plugin_dir/zsh-syntax-highlighting"
    fi
    
    if [[ -d "$plugin_dir/zsh-autosuggestions" ]]; then
        echo "Removing existing zsh-autosuggestions plugin..."
        rm -rf "$plugin_dir/zsh-autosuggestions"
    fi
    
    # Install zsh-syntax-highlighting
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # Install zsh-autosuggestions
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

install_autojump() {
    print_status "Installing Autojump"
    
    # Remove existing autojump installation if it exists
    if [[ -d "$HOME/.autojump" ]]; then
        print_warning "Existing autojump installation found"
        echo "Removing existing autojump installation..."
        rm -rf "$HOME/.autojump"
    fi
    
    # Remove any temporary autojump directory from previous runs
    if [[ -d "./autojump" ]]; then
        echo "Cleaning up previous autojump download..."
        rm -rf autojump
    fi
    
    # Clone, install, and cleanup autojump
    echo "Downloading autojump..."
    git clone https://github.com/wting/autojump.git
    
    echo "Installing autojump..."
    cd autojump
    chmod +x ./install.py
    python3 ./install.py
    cd ..
    
    echo "Cleaning up autojump installation files..."
    rm -rf autojump
    
    # Fix ownership
    fix_ownership "$HOME/.autojump"
}

apply_zsh_configuration() {
    print_status "Applying Zsh configuration"
    
    # Copy custom zsh configuration
    echo "Copying custom .zshrc..."
    cp ./zsh/zshrc ~/.zshrc
    
    # Fix ownership
    fix_ownership ~/.zshrc
    
    echo "Zsh configuration applied successfully"
}

install_tmux() {
    print_status "Setting up Tmux"
    
    # Install tmux
    echo "Installing tmux..."
    run_cmd apt install tmux -y
    
    # Remove existing TPM installation if it exists
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "Removing existing Tmux Plugin Manager..."
        rm -rf "$HOME/.tmux/plugins/tpm"
    fi
    
    # Create tmux directory and install TPM (Tmux Plugin Manager)
    echo "Installing Tmux Plugin Manager..."
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    
    # Copy tmux configuration
    echo "Copying tmux configuration..."
    cp ./tmux/tmux.conf ~/.tmux.conf
    
    # Fix ownership
    fix_ownership ~/.tmux
    fix_ownership ~/.tmux.conf
    
    # Handle tmux configuration loading
    if ! tmux list-sessions >/dev/null 2>&1; then
        echo "Tmux configuration will be loaded on first tmux session"
    else
        tmux source ~/.tmux.conf 2>/dev/null || echo "Could not reload tmux config - please restart tmux"
    fi
}

perform_system_upgrade() {
    print_status "Updating system packages"
    
    echo "Updating package lists..."
    run_cmd apt update
    
    echo "Upgrading installed packages..."
    run_cmd apt upgrade -y
}

#===============================================================================
# MAIN INSTALLATION PROCESS
#===============================================================================

main() {
    echo "Starting dotfiles installation..."
    echo "This script will set up a complete development environment."
    echo ""
    
    # Setup sudo handling
    setup_sudo
    
    # Run installation steps
    install_system_packages
    install_zsh
    install_oh_my_zsh
    install_zsh_plugins
    install_autojump
    apply_zsh_configuration
    perform_system_upgrade
    install_tmux
    
    # Installation complete
    print_status "Installation completed successfully!"
    echo ""
    echo "🎉 Your development environment is now ready!"
    echo ""
    echo "What was installed:"
    echo "  ✓ Zsh shell with oh-my-zsh framework"
    echo "  ✓ Zsh plugins (syntax highlighting, autosuggestions)"
    echo "  ✓ Autojump for quick directory navigation"
    echo "  ✓ Tmux with plugin manager"
    echo "  ✓ Your custom configurations"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run 'source ~/.zshrc'"
    echo "  2. In tmux, press Ctrl+b then I to install tmux plugins"
    echo "  3. Some changes may require a full logout/login to take effect"
    echo ""
    
    # Switch to zsh shell
    print_status "Switching to Zsh shell"
    exec zsh
}

# Run the main installation process
main "$@"
