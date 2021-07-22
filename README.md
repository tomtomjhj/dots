# TODO
* automate installation
    * <https://github.com/junegunn/dotfiles/>
    *  <https://github.com/jaagr/dots>
    * use make, stow, ...
        * https://github.com/masasam/dotfiles/blob/master/Makefile
        * https://polothy.github.io/post/2018-10-09-makefile-dotfiles/
        * https://github.com/b4b4r07/dotfiles/blob/master/Makefile
    * using bare repo and worktree
    ```sh
    git clone --bare ... $HOME/.dotfiles
    alias cfg="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    cfg checkout
    cfg config --local status.showUntrackedFiles no
    ```
    * `--separate-git-dir`
    * https://konfekt.github.io/blog/2018/11/10/simple-dotfiles-setup
* automate direct binary download https://stackoverflow.com/a/29360657
* https://help.ubuntu.com/community/CheckInstall
* opam
    * Opam configuration should be run in `.bash_profile`, not in `.profile`. Why?
        * https://wiki.archlinux.org/index.php/tmux#Start_a_non-login_shell
        * https://superuser.com/a/789465
    * vscoq + opam local switch
        * .profile issue
        * launch coqtop with `opam config exec --`?
    * https://khady.info/opam-compilation-cache.html
* https://github.com/cheat/cheat
* input method for unicode chars
    * compose key?
    * want both tex notation and digraphs
* https://github.com/bcpierce00/unison
* https://github.com/rclone/rclone/issues/118
* disable primary selection stuff, middle mouse click,... (gnome tweak doesn't work... maybe wayland issue?)

# Things to run (20.04)

## ppas
```sh
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/stable
sudo add-apt-repository ppa:libreoffice/ppa
```

## drivers
```bash
sudo ubuntu-drivers install
```

## 한글 nimf
```bash
sudo rm -f /etc/apt/sources.list.d/hamonikr.list
curl -sL https://pkg.hamonikr.org/add-hamonikr.apt | sudo -E bash -
sudo apt install nimf nimf-libhangul
im-config -n nimf
```
* libhangul → add ESC to "shortcuts from Korean to system keyboard" so that esc in vim resets to en
* set "hooking GDK key events" https://github.com/hamonikr/nimf/issues/14#issuecomment-725849454

## capslock
```bash
./interception/install.sh
```
* https://gitlab.com/interception/linux/plugins/dual-function-keys
* https://gist.github.com/tanyuan/55bca522bf50363ae4573d4bdcf06e2e

## font
```
./fonts
ln -s ~/dots/.config/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf
fc-cache -fv
```
* https://repolinux.wordpress.com/2013/03/10/find-out-fallback-font-used-by-fontconfig-for-a-certain-character/
* http://eosrei.net/articles/2016/02/changing-default-fallback-subsitution-fonts-linux

## gnome
* [make gnome terminal title bar small](https://www.reddit.com/r/gnome/comments/b3l1c9/gnometerminal_title_bar_is_huge_in_332/)
  ```
  gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
  ```
* [gnome terminal theme](https://unix.stackexchange.com/questions/448811/how-to-export-a-gnome-terminal-profile)
    1. make a profile
    2. dump `dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf`
    3. put this
       ```ini
       [:UUID-CREATED-IN-1]
       bold-color='#FFFFFFFFFFFF'
       bold-color-same-as-fg=true
       scrollbar-policy='never'
       use-transparent-background=false
       background-color='rgb(0,0,0)'
       cursor-colors-set=false
       visible-name='my theme'
       default-size-columns=100
       use-theme-colors=false
       font='Source Code Pro 13'
       default-size-rows=30
       use-system-font=false
       cell-width-scale=1.0
       palette=['rgb(31,31,31)', 'rgb(235,96,107)', 'rgb(195,232,141)', 'rgb(247,235,149)', 'rgb(128,203,195)', 'rgb(255,36,144)', 'rgb(174,221,255)', 'rgb(255,255,255)', 'rgb(65,65,65)', 'rgb(235,96,107)', 'rgb(195,232,141)', 'rgb(247,235,149)', 'rgb(125,198,191)', 'rgb(108,113,195)', 'rgb(86,214,255)', 'rgb(255,255,255)']
       background-transparency-percent=11
       foreground-color='rgb(255,255,255)'
       cell-height-scale=1.0
       highlight-colors-set=false
       audible-bell=false
       use-theme-transparency=false
       ```
    4. `dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf`
* disable `ctrl-alt-d` https://askubuntu.com/a/177994 TODO dconf-editor

## firefox: allow plugins to override reserved keymap
https://github.com/glacambre/firefox-patches/issues/1
Run it after closing firefox. Rerun when firefox is updated.
```
sudo perl -i -pne 's/reserved="true"/               /g' /usr/lib/firefox/browser/omni.ja
find $HOME/.cache/mozilla/firefox -type d -name startupCache | xargs rm -rf
```

## tex
* `texlive-fonts-extra` contains wrong version of Source Serif, which messes up docs.rs fonts in Firefox
* **TODO** use docker with latest texlive...

## wayland stuff
* **TODO** screen share https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing

# stuff
* https://github.com/cyrus-and/gdb-dashboard
* https://mug896.github.io/awk-script/index.html https://mug896.github.io/bash-shell/quotes.html

## firefox
* ctrl-f is broken
    * sometimes skips a match
    * sometimes doesn't match at all; refreshing doesn't work
* can't decouple language from date format, spell check, ...
    * setting the lang to en-uk *breaks* english spell check
    * multi-lang spell check is completely broken
* pdf.js
    * copy-pasting removes the spaces in the text
    * pdf print quality bad
    * j/k is not like arrow up/down https://github.com/mozilla/pdf.js/issues/7019
* firefox pdf dark mode https://github.com/darkreader/darkreader/issues/374#issuecomment-640622375

# Tips
* gnome shell `alt-F2`

## Git
* To force stash apply, `git checkout` instead of `git stash apply` <https://stackoverflow.com/a/16625128>
* `git pull --autostash`
* https://github.com/mhagger/git-imerge
* git reflog
* git `--follow`?
    * `-D, --irreversible-delete`
    * `-M[<n>], --find-renames[=<n>]`
* `git apply --reject --whitespace=fix`
