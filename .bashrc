#
# Adapted from Manjaro /etc/skel/.bashrc
#

[[ $- != *i* ]] && return

# Taken from https://gist.github.com/vivkin/567896630dbc588ad470b8196c601ad1
# See also https://askubuntu.com/a/279014
colors() {
    T='text'
    echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m";
    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m'; do
        FG=${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
            echo -en "$EINS \033[$FG\033[$BG  $T \033[0m\033[$BG \033[0m";
        done
        echo;
    done
    echo
}

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*|tmux*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac


alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more=less

# can be slow  over ssh -X
xhost +local:root > /dev/null 2>&1

# https://stackoverflow.com/a/53655744
# complete -cf sudo

shopt -s expand_aliases

# export QT_SELECT=4

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


#
# Adapted from Ubuntu /etc/skel/.bashrc --------------------------------
#

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# TODO: clean up PS1 stuff
# set variable identifying the chroot you work in (used in the prompt below)
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
# fi

# set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
#     xterm-color|*-256color) color_prompt=yes;;
# esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# my stuff -------------------------------------------

HISTTIMEFORMAT="%F %T "
HISTIGNORE="?:??:???:git ??"

export PS1="\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export PROMPT_DIRTRIM=3

export LC_ALL=C.UTF-8

export LESS='Ri'

alias mk="make -j -k"
alias nv=nvim
cn() { nvim --cmd 'let g:ide_client = "coc"' "$@"; }
vil() { nvim --cmd 'set background=light' "$@"; }
alias vimdiff="nvim -d"
alias e="emacs -nw"
alias g=git
alias gti=git
alias py=python3
# TODO: use `shopt -s autocd`?
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ssh='TERM=xterm-256color ssh'
alias tmux='tmux -2u'
alias ta='tmux attach'
man () { /usr/bin/man "$@" | nvim +Man!; }
alias stage="$HOME/stage-git/stage"

# History stuff
shopt -s histappend
# NOTE: erasedups doesn't guarantee nodup??
HISTCONTROL=ignorespace:ignoredups:erasedups
HISTIGNORE="?:??:???"
HISTSIZE=2000
HISTFILESIZE=4000
# Delete last command from history (assuming that this command itself is ignored from history); `history -d -2--1`
alias hd='history -d -1'
# M-C-h: Pop last command from history
hpop() {
    READLINE_LINE="$(HISTTIMEFORMAT= history 1 | sed 's/^[ ]*[0-9]*[ ]*//')"
    history -d -1
    READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\e\C-h" : hpop'
alias hfence='history -a; history -n'
alias hnoise='unset HISTFILE'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
if [ -x "$(command -v fd)" ]; then
  # NOTE: `--type d` also lists directories that only contain excluded files
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
export FZF_DEFAULT_OPTS="--bind alt-a:select-all,alt-d:deselect-all,alt-t:toggle-all"

[ -x "$(command -v zoxide)" ] && eval "$(zoxide init bash)"

stty -ixon

# https://github.com/ocaml/opam/issues/4201
test -r "${HOME}/.opam/opam-init/complete.sh" && . "${HOME}/.opam/opam-init/complete.sh" > /dev/null 2> /dev/null || true
test -r "${HOME}/.opam/opam-init/env_hook.sh" && . "${HOME}/.opam/opam-init/env_hook.sh" > /dev/null 2> /dev/null || true

# [ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit;}
if [ -z "$TMUX"  ] && [ -z "$VIM" ]; then
  detached=$(tmux ls 2> /dev/null | grep "window" | grep -v "attached" | wc -l)
  if [ $detached == 0 ]; then
    tmux new-session
  else
    tmux attach
  fi
  detached=$(tmux ls 2> /dev/null | grep "window" | grep -v "attached" | wc -l)
  [ $detached == 0 ] && exit
fi
