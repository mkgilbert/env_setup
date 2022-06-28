#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Must specify type of system (macos|linux). Exiting"
	exit 1
fi

sys=$1

if [[ ! "$sys" =~ "macos" ]] && [[ ! "$sys" =~ "linux" ]]; then
	echo "Must specify either 'macos' or 'linux'"
	exit 1
fi
	
if [ -e $HOME/.bash_profile ]; then
	echo "case $- in *i*) . ~/.bashrc;; esac" >> $HOME/.bash_profile
fi

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

for f in bashrc tmux.conf vimrc zshrc; do
	if [ -f $HOME/.${f} ]; then
		mv $HOME/.${f} $HOME/.${f}.original
	fi
	ln -s $(pwd)/${f} $HOME/.${f}
done

#cat ${sys}/bashrc >> $HOME/.bashrc

vim_version=$(vi --version|head -n 1 |awk '{print $5}')
if [ ! bc <<< "$vim_version > 7.4" ]; then 
    echo "Error: Vim needs to be version 7.4 or greater. It is currently $vim_version" && exit 1; 
fi

echo "Done!"
echo "Make sure to run :PluginInstall from inside vim!"
exit 0
