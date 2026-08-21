#!/bin/bash

case "$(uname -s)" in
	Darwin) detected_sys="macos" ;;
	Linux)  detected_sys="linux" ;;
	*)      detected_sys="" ;;
esac

if [ "$#" -gt 1 ]; then
	echo "Usage: $0 [macos|linux]. Exiting"
	exit 1
fi

if [ "$#" -eq 1 ]; then
	sys=$1
	case "$sys" in
		macos|linux) ;;
		*)
			echo "Must specify either 'macos' or 'linux'"
			exit 1
			;;
	esac
	if [ -n "$detected_sys" ] && [ "$sys" != "$detected_sys" ]; then
		echo "Warning: you specified '${sys}' but this machine looks like '${detected_sys}' (uname -s: $(uname -s)). Continuing with '${sys}'."
	fi
else
	if [ -z "$detected_sys" ]; then
		echo "Could not auto-detect OS from 'uname -s' ($(uname -s)). Must specify either 'macos' or 'linux'. Exiting"
		exit 1
	fi
	sys=$detected_sys
	echo "Auto-detected system type: ${sys}"
fi

# Linux distro id, used for distro-specific install steps below. Populated from
# /etc/os-release; ID_LIKE is the fallback for derivatives that don't set ID
# to something we recognize (e.g. some Debian derivatives).
distro_id=""
distro_id_like=""
if [ "$sys" = "linux" ] && [ -f /etc/os-release ]; then
	. /etc/os-release
	distro_id="${ID:-}"
	distro_id_like="${ID_LIKE:-}"
fi

if [ -e $HOME/.bash_profile ] && ! grep -qF 'esac # env_setup: source .bashrc for interactive shells' $HOME/.bash_profile; then
	echo 'case $- in *i*) . ~/.bashrc;; esac # env_setup: source .bashrc for interactive shells' >> $HOME/.bash_profile
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
tmux_version=$(tmux -V | cut -c 6-)
if [ "$(printf '%s\n' "$tmux_version" "2.1" | sort -V | head -n 1)" != "2.1" ]; then
	echo "Using old version of tmux ($tmux_version)"
	tmux="tmux.conf.old"
else
	echo "Using newer tmux version ($tmux_version)"
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

if [[ "$sys" =~ "macos" ]]; then
    echo "Symlinking hammerspoon config"
    for f in $(ls $(pwd)/macos/hammerspoon/); do
        dest=${HOME}/.hammerspoon/${f}
        if [ -L ${dest} ]; then
            echo "Found existing symlinked ${f}. Skipping"
            continue
        fi
        if [ -f ${dest} ]; then
            echo "Moving to ${dest}.original"
            mv $HOME/.hammerspoon/${f} $HOME/.hammerspoon/${f}.original
        fi
        ln -s $(pwd)/macos/hammerspoon/${f} $HOME/.hammerspoon/${f}
    done
fi

echo "Setting git to use global gitignore file"
git config --global core.excludesfile $HOME/.gitignore

echo "Checking that Vim is version > 7.4"
vim_version=$(vi --version|head -n 1 |awk '{print $5}')
if [ "$(printf '%s\n' "$vim_version" "7.4" | sort -V | head -n 1)" = "$vim_version" ] && [ "$vim_version" != "7.4" ]; then
    echo "Error: Vim needs to be version 7.4 or greater. It is currently $vim_version" && exit 1
fi

echo "Installing Eternal Terminal (et)"
if [[ "$sys" =~ "macos" ]]; then
	if command -v brew >/dev/null 2>&1; then
		brew install et
	else
		echo "Homebrew not found. Install it, or install et manually: https://github.com/MisterTea/EternalTerminal#installing"
	fi
elif [[ "$sys" =~ "linux" ]]; then
	case "$distro_id" in
		ubuntu)
			echo "Detected Ubuntu. Installing et via PPA"
			sudo apt install -y software-properties-common
			sudo add-apt-repository -y ppa:jgmath2000/et
			sudo apt update && sudo apt install -y et
			;;
		debian)
			echo "Detected Debian. Installing et via debian-et repo"
			sudo mkdir -p /etc/apt/keyrings
			echo "deb [signed-by=/etc/apt/keyrings/et.gpg] https://mistertea.github.io/debian-et/debian-source/ ${VERSION_CODENAME} main" | sudo tee -a /etc/apt/sources.list.d/et.list
			curl -sSL https://github.com/MisterTea/debian-et/raw/master/et.gpg | sudo tee /etc/apt/keyrings/et.gpg >/dev/null
			sudo apt update
			sudo apt install -y et
			;;
		*)
			echo "Unrecognized Linux distro ('${distro_id:-unknown}', like '${distro_id_like:-unknown}')."
			echo "Please install Eternal Terminal manually using the instructions at:"
			echo "https://github.com/MisterTea/EternalTerminal#installing"
			;;
	esac
fi

echo "Done!"
echo "Make sure to run :PluginInstall from inside vim!"
exit 0
