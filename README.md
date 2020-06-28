# dotfiles
Personal dotfiles for Linux.

# Installation
```
curl https://github.com/xindzju/dotfiles/install.sh | bash
```

## Install & Config Oh-my-zsh framework
On Ubuntu:
```
#Install zsh
sudo apt install zsh -y 
chsh -s /usr/bin/zsh
echo $SHELL #check if chsh works
#Install Oh-my-zsh
sudo apt install wget git -y
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
#Install plugins
* zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
* zsh-autosuggestions
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
#Install autojump
git clone git://github.com/wting/autojump.git
cd autojump
./install.py or ./uninstall.py
#Enable
cp */dotfiles/zsh/zshrc ~/.zshrc
source ~/.zshrc
```



