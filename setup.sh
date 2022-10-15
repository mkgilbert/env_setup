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

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
	echo "Cloning Vundle"
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

echo "Checking for zsh"
if [ $(which zsh) ]; then
	if [ -d ~/.oh-my-zsh ]; then
		echo "oh-my-zsh is already installed. Skipping"
	else
		echo "Found zsh. Installing oh-my-zsh"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        curl -fsSL https://raw.githubusercontent.com/mkgilbert/ohmyzsh/master/themes/mkgilbert.zsh-theme > ~/.oh-my-zsh/themes/mkgilbert.zsh-theme
		mkdir ~/.oh-my-zsh/custom/plugins
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	fi
fi

echo "Determining version of tmux"
if [[ (( $(tmux -V | cut -c 6-) < 2.1 )) ]]; then 
	echo "Using old version of tmux"
	tmux="tmux.conf.old"
else
	echo "Using newer tmux version"
	tmux="tmux.conf"
fi

echo "Symlinking dotfiles"
for f in tmux.conf bashrc vimrc zshrc gitignore; do
	dest=${HOME}/.${f}
	if [ -L ${dest} ]; then
		echo "Found exisiting symlinked ${f}. Skipping"
		continue
	fi
	if [ -f ${dest} ]; then
		echo "Moving to ${dest}.original"
		mv $HOME/.${f} $HOME/.${f}.original
	fi
	if [[ "${f}" =~ "tmux.conf" ]]; then
		ln -s $(pwd)/${tmux} ${dest}
	else
		ln -s $(pwd)/${f} $HOME/.${f}
	fi
done

echo "Setting git to use global gitignore file"
git config --global core.excludesfile $HOME/.gitignore

echo "Checking that Vim is version > 7.4"
vim_version=$(vi --version|head -n 1 |awk '{print $5}')
if [ ! bc <<< "$vim_version > 7.4" ]; then 
    echo "Error: Vim needs to be version 7.4 or greater. It is currently $vim_version" && exit 1; 
fi

echo "Done!"
echo "Make sure to run :PluginInstall from inside vim!"
exit 0
