#!/usr/bin/bash

set -e

# run from home dir
#Set pwd as $HOME
cd $HOME

if [[ -f /etc/os-release ]]; then
  OS=$NAME
fi
# installing all the packages
if [ $NAME="Ubuntu" ]; then
  INSTALLER="apt"
  sudo apt update && sudo apt-get upgrade
fi
#---------------------- PACKAGES ----------------------
sudo $INSTALLER install tmux -y
sudo $INSTALLER install fish -y
sudo $INSTALLER install curl -y
sudo $INSTALLER install wget -y
sudo $INSTALLER install unzip -y
sudo $INSTALLER install tar -y
sudo $INSTALLER install gzip -y

sudo $INSTALLER install git -y
sudo $INSTALLER install googler -y
sudo $INSTALLER install build-essential -y
sudo $INSTALLER install gdb -y
sudo $INSTALLER install clang -y
sudo $INSTALLER install npm -y
sudo $INSTALLER install ripgrep -y
sudo $INSTALLER install direnv -y
sudo $INSTALLER install bat -y
sudo $INSTALLER install tig -y
sudo $INSTALLER install python3-venv -y
# UV for Python 
curl -LsSf https://astral.sh/uv/install.sh | sh

#---------------------- CMAKE ----------------------
wget https://github.com/Kitware/CMake/releases/download/v3.30.2/cmake-3.30.2-linux-x86_64.sh
sudo sh cmake-3.30.2-linux-x86_64.sh --prefix=/usr/local --skip-license
rm cmake-3.30.2-linux-x86_64.sh

#---------------------- Neovim ----------------------
# Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage &&
  chmod u+x nvim.appimage &&
  sudo mkdir -p /opt/nvim &&
  sudo mv nvim.appimage /opt/nvim/nvim &&
  # nvim requires FUSE
  sudo add-apt-repository universe && sudo apt install libfuse2 -y

# cleanup
sudo apt autoremove

#------------------GIT AND GITHUB---------------------

# github cli gh
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# github auth for git
if [[ ! -f $HOME/.ssh/github ]]; then
  ssh-keygen -t ed25519 -a 100 -f $HOME/.ssh/github
  echo "====Need to setup gh login only once!====="
  gh auth login
  gh auth setup-git
fi

#---------------------- DOT FILES ----------------------
echo ".cfg" >.gitignore
if [[ -d $HOME/.cfg ]]; then
  rm -rf $HOME/.cfg
fi
git clone --bare https://github.com/linem-davton/.cfg $HOME/.cfg

# backup the dotfiles that already exit
mkdir -p $HOME/.config-backup/.config/fish/functions $HOME/.config-backup/.config/clangd $HOME/.config-backup/.config/nvim/lua/plugins/dap $HOME/.config-backup/.config/nvim/lua/plugins/lsp \
  $HOME/.config-backup/.config/nvim/lua/linemdavton $HOME/.config-backup/.config/nvim/lua/lazy

git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}

# checkout the dotfiles
git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout
git --git-dir=$HOME/.cfg/ --work-tree=$HOME config --local status.showUntrackedFiles no

#--------- NEOVIM Python Env -------
cd $HOME/.config/nvim && python3 -m venv venv


#------ nerd-fonts -------
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/0xProto.zip &&
  unzip 0xProto.zip -d $HOME/.fonts &&
  fc-cache -fv

#---------------------- OBSIDIAN----------------------
# setup obsidian
if [[ ! -d $HOME/obsidian ]]; then
  sudo snap install --classic obsidian
  git clone git@github.com:linem-davton/obsidianvault.git $HOME/obsidian
  sudo apt-get install "fonts-cmu"
fi

#---------------------- FZF ----------------------
if [[ ! -d $HOME/.fzf ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi

#---------------------- zoxide  ----------------------
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

#---------------------- lazydocker----------------------
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

#---------------------- lazygit----------------------
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit &&
  sudo install lazygit /usr/local/bin &&
  rm lazygit.tar.gz lazygit

#-----------deltagit-------------------
wget https://github.com/dandavison/delta/releases/download/0.18.1/git-delta_0.18.1_amd64.deb &&
  sudo dpkg -i git-delta_0.18.1_amd64.deb &&
  rm -rf git-delta_0.18.1_amd64.deb


#---------------------- RUST ----------------------
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup update

#---------------------- YAZI (Terminal File Manager) ----------------------
rustup update
cargo install --locked yazi-fm yazi-cli

#---------------------- Dua-cli (Disk Usage) ----------------------
cargo install dua-cli # Usage dua i  
