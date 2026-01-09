# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# NOTE: Logout/login in ubuntu desktop does not clear the session and the env vars are inheritted to the later sessions.
# https://www.reddit.com/r/debian/comments/z1b0ti/gdm_andor_systemd_persists_the_user_environment/

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

PATH="$HOME/.local/bin:$PATH"

if [ -d "$HOME/.local/lib" ] ; then
    export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH
fi
if [ -d "$HOME/.local/include" ] ; then
    export C_INCLUDE_PATH=$HOME/.local/include:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH=$HOME/.local/include:$CPLUS_INCLUDE_PATH
fi

if [ -x "$(command -v nvim)" ]; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

# https://github.com/ocaml/opam/issues/4201
test -r "$HOME/.opam/opam-init/variables.sh" && . "$HOME/.opam/opam-init/variables.sh" > /dev/null 2> /dev/null || true

export MANOPT='--nh --nj'

export PYTHONSTARTUP="$HOME/.pythonrc"

export PATH="$HOME/.cargo/bin:$PATH"
