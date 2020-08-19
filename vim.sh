#!/bin/bash


# Install vim-plug
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Setting neovim
cp -r ./nvim/config-plugins ~/.config/nvim
cp -r ./nvim/general ~/.config/nvim
cp -r ./nvim/vim-plug ~/.config/nvim
cp ./nvim/init.vim ~/.config/nvim

# Install plugins
nvim +PlugInstall +qall
