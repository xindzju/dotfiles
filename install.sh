#!/bin/bash

# Detect if running as root
if [ "$EUID" -eq 0 ]; then
    SUDO=""
    echo "Running as root user"
else
    SUDO="sudo"
    echo "Running as non-root user"
fi

# Function to run command with or without sudo
run_cmd() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# install python
echo "=======================================>Install Python..."
run_cmd apt install python3 python-is-python3 -y

# install prerequisites: wget git
echo "=======================================>Install wget git..."
run_cmd apt install wget git -y

# install git-lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | $SUDO bash
run_cmd apt install git-lfs

# install zsh
echo "=======================================>Install zsh..."
run_cmd apt install zsh -y 

# Change shell - handle both root and non-root cases
if [ "$EUID" -eq 0 ]; then
    chsh -s /usr/bin/zsh
else
    sudo chsh -s /usr/bin/zsh $USER
fi

echo $SHELL #check if chsh works

# install oh-my-zsh
echo "=======================================>Install oh-my-zsh..."
# Download and run oh-my-zsh installer, but don't let it change shell automatically
export RUNZSH=no
export KEEP_ZSHRC=yes
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

echo "=======================================>Check env vars"
echo "SHELL:" $SHELL
echo "ZSH_CUSTOM:" $ZSH_CUSTOM
echo "HOME:" $HOME

# Ensure proper ownership of oh-my-zsh directory
if [ "$EUID" -ne 0 ]; then
    # For non-root users, ensure proper ownership
    if [ -d "$HOME/.oh-my-zsh" ]; then
        sudo chown -R $USER:$USER $HOME/.oh-my-zsh 2>/dev/null || true
    fi
fi

# zsh-syntax-highlighting
echo "=======================================>Download zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-autosuggestions
echo "=======================================>Download zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install auto jump
echo "=======================================>Install auto jump..."
git clone https://github.com/wting/autojump.git
cd autojump
chmod +x ./install.py
python3 ./install.py
cd ..
rm -rf autojump

# overwrite default .zshrc
echo "=======================================>Copy zshrc configuration..."
cp ./zsh/zshrc ~/.zshrc

# Ensure proper file ownership for non-root users
if [ "$EUID" -ne 0 ]; then
    # Fix ownership of user files
    sudo chown $USER:$USER ~/.zshrc 2>/dev/null || true
    if [ -d "$HOME/.oh-my-zsh" ]; then
        sudo chown -R $USER:$USER $HOME/.oh-my-zsh 2>/dev/null || true
    fi
    if [ -d "$HOME/.autojump" ]; then
        sudo chown -R $USER:$USER $HOME/.autojump 2>/dev/null || true
    fi
fi

# Update package lists and upgrade
echo "=======================================>Update and upgrade packages..."
run_cmd apt update
run_cmd apt upgrade -y

# install tmux
echo "=======================================>Install tmux..."
run_cmd apt install tmux -y
mkdir -p ~/.tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp ./tmux/tmux.conf ~/.tmux.conf

# Fix tmux file ownership for non-root users
if [ "$EUID" -ne 0 ]; then
    sudo chown -R $USER:$USER ~/.tmux 2>/dev/null || true
    sudo chown $USER:$USER ~/.tmux.conf 2>/dev/null || true
fi

# Source tmux config (only if tmux is not running)
if ! tmux list-sessions >/dev/null 2>&1; then
    echo "Tmux configuration will be loaded on first tmux session"
else
    tmux source ~/.tmux.conf 2>/dev/null || echo "Could not reload tmux config - please restart tmux"
fi

echo "=======================================>Installation complete!"
echo "Switching to zsh shell..."
echo "Note: Some changes may require a full logout/login to take effect"

# Switch to zsh shell to make changes take effect immediately
exec zsh
