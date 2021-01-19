#!/bin/bash

if [ -e $HOME/.bash_profile ]; then
	echo "case $- in *i*) . ~/.bashrc;; esac" >> $HOME/.bash_profile
fi

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

cat bashrc >> $HOME/.bashrc
cat tmux.conf >> $HOME/.tmux.conf
cat vimrc >> $HOME/.vimrc

vim_version=$(vi --version|head -n 1 |awk '{print $5}')
if [ ! bc <<< "$vim_version > 7.4" ]; then 
    echo "Error: Vim needs to be version 7.4 or greater. It is currently $vim_version" && exit 1; 
fi

echo "Done!"
echo "Make sure to run :PluginInstall from inside vim!"
exit 0
