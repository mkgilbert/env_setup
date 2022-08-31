##### added by mkgilbert env_setup repo #####
umask 077

if [ -e "/etc/bashrc" ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
export PATH=$HOME/local/bin:$PATH
export LD_LIBRARY_PATH=$HOME/local/lib:$LD_LIBRARY_PATH

# set the prompt to [date|time]user@host:~$
export PS1="\[\033[33m\][\D{%m/%d|%H:%M}]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
# fix directory colors
export TERM="xterm-256color"

#alias tmux="TERMINFO=/usr/share/terminfo/x/xterm-16color TERM=xterm-16color tmux -2"
alias vi="vim"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

export ANSIBLE_NOCOWS=1
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
export EDITOR=vi

# Rust
. "$HOME/.cargo/env"

# Custom Bashrc based on machine type
# -------------------------------------
# First, figure out the real location of this script (in case it's a symlink)
# credit: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# get the parent directory (this is the repo dir)
REPODIR="$(dirname $SOURCE)"
# determine what type of machine this is
if [ "$(uname)" == "Darwin" ]; then
    machine_type="macos"
else
    machine_type="linux"
fi
# add the specific bashrc settings for the machine type
source ${REPODIR}/${machine_type}/bashrc

# switch to zsh if PIBS is being used to manage all user shells
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    export SHELL="/usr/bin/zsh"
    exec /usr/bin/zsh
fi
