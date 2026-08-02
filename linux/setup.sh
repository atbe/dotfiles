#!/bin/bash

###############################################################################
# \author Ibrahim Ahmed                                                       #
# \github atbe                                                                #
# \copyright MIT                                                              #
###############################################################################

# ignore errors and just do what is told
set +e

# update
printf "\n*****\nrunning a quick apt update\n*****\n"
sudo apt update > /dev/null
sudo apt -y upgrade > /dev/null

# install neccessary packages
printf "\n*****\napt installing a bunch of stuffs\n*****\n"
sudo apt install -y git zsh tmux irssi autojump tree curl > /dev/null

# clone dotfiles
printf "\n*****\nCloning dotfiles\n*****\n"
cd "$HOME"
git clone https://github.com/atbe/dotfiles.git
cd dotfiles
./makesymlinks.sh
mkdir -p "$HOME/.config/nvim/"
ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim" # link neovim

# get oh-my-zsh and other zsh plugins installed
printf "\n*****\nSetting up zsh\n*****\n"
mkdir -p "$HOME/bin/antigen"
curl -L git.io/antigen > "$HOME/bin/antigen/antigen.zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/"
git clone https://github.com/wting/autojump.git "$HOME/.oh-my-zsh/custom/plugins/"

# neovim
printf "\n*****\nSetting up neovim\n*****\n"
sudo apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get update > /dev/null
sudo apt-get install -y neovim > /dev/null
sudo apt-get install -y python-dev python-pip python3-dev python3-pip > /dev/null

# update all the default editors to use neovim
printf "\n*****\nChoosing defaults\n*****\n"
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

# plug for neovim
printf "\n*****\nInstalling plug for neovim\n*****\n"
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# base16 shell
printf "\n*****\nShell base16 installing\n*****\n"
git clone https://github.com/chriskempson/base16-shell.git "$HOME/.config/base16-shell"
