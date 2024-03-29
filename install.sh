# install python
echo "=======================================>Install Python..."
sudo apt install python3 python-is-python3 -y

# install prerequisites: wget git
echo "=======================================>Install wget git..."
sudo apt install wget git -y

# install git-lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt install git-lfs

# install zsh
echo "=======================================>Install zsh..."
sudo apt install zsh -y 
chsh -s /usr/bin/zsh

echo $SHELL #check if chsh works

# install oh-my-zsh
echo "=======================================>Install oh-my-zsh..."
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

echo "=======================================>Check env vars"
echo "SHELL:" $SHELL
echo "ZSH_CUSTOM:" $ZSH_CUSTOM

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
chmod 777 ./install.py
python3 ./install.py
cd ..

zsh

# overwrite default .zshrc
cp ./zsh/zshrc ~/.zshrc

# enable all the settings
echo "=======================================>Enable all the settings..."
source ~/.zshrc

sudo apt upgrade -y
sudo apt update
sudo apt install git-lfs -y

# install tmux
sudo apt install tmux -y
mkdir ~/.tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp ./tmux/tmux.conf ~/.tmux.conf
tmux source ~/.tmux.conf
