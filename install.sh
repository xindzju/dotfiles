# install python
sudo apt install python3 -y

# install prerequisites: wget git
sudo apt install wget git -y

# install zsh
sudo apt install zsh -y 
chsh -s /usr/bin/zsh

echo $SHELL #check if chsh works

# install oh-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# enable the zsh env variables
cp ./zsh/zshrc ~/.zshrc
source ~/.zshrc

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

# install auto jump
git clone https://github.com/wting/autojump.git
cd autojump
chmod 777 ./install.py
./install.py

# enable all the settings
source ~/.zshrc