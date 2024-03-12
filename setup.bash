#! /usr/bin/bash

# run from home dir

#Set pwd as $HOME
cd $HOME

if [ -f /etc/os-release ]; then
	# freedesktop.org and systemd. /etc/os-release
	OS=$NAME
	VER=$VERSION_ID
fi
# installing all the packages
if [ $NAME="Ubuntu" ]; then
	INSTALLER="apt"
	echo $INSTALLER
	sudo apt update && sudo apt-get upgrade
fi

sudo $INSTALLER install tmux -y
sudo $INSTALLER install git -y
sudo $INSTALLER install fish -y
sudo $INSTALLER install curl -y
sudo $INSTALLER install fuse

# setup neovim with app image
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage &&
	chmod u+x nvim.appimage &&
	sudo mkdir -p /opt/nvim &&
	sudo mv nvim.appimage /opt/nvim/nvim &&
	echo export PATH="$PATH:/opt/nvim/" >>$HOME/.bashrc
# nvim requires FUSE
sudo add-apt-repository universe && sudo apt install libfuse2

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt install ./google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb
sudo snap install --classic obsidian

# cleanup
sudo apt autoremove

# github cli
sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
	sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
	sudo apt install gh -y

# setup git and github auth
git config --global user.name "linem.davton"
git config --global user.email "linemdavton@gmail.com"

# github auth for git
ssh-keygen -t ed25519 -a 100 -f $HOME/.ssh/github
#gh auth login
gh auth setup-git

# setup dotfiles and configuration
echo ".cfg" >.gitignore
git clone --bare https://github.com/linem-davton/.cfg $HOME/.cfg
# backup the dotfiles that already exit
mkdir -p $HOME/.config-backup/.config/fish && \
git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}

git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout

# setup obsidian
git clone https://github.com/linem-davton/obsidianvault.git $HOME

# setup projects dir
mkdir -p $HOME/projects

# auto start fish
#echo fish >$HOME/.bashrc
