# TODO
* sync ssh xclip and client xclip
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
* git `--follow`?
* Opam configuration should be run in `.bash_profile`, not in `.profile`. Why?
    * https://wiki.archlinux.org/index.php/tmux#Start_a_non-login_shell
    * https://superuser.com/a/789465
* automate direct binary download https://stackoverflow.com/a/29360657
* https://help.ubuntu.com/community/CheckInstall
* vscoq + opam local switch
    * .profile issue
    * launch coqtop with `opam config exec --`?

# Things to run (20.04)
* `ubuntu-drivers install`
* nimf
    * libhangul → shortcuts from Korean to system keyboard (for vim)
    * https://github.com/hamonikr/nimf/issues/14#issuecomment-725849454

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

# stuff
* https://github.com/skywind3000/z.lua
    ```sh
    # .bashrc
    eval "$(lua ~/dots/ext/z.lua/z.lua --init bash enhanced once fzf)"
    ```
* `git apply --reject --whitespace=fix`
* failed to suppress chrome white screen stun grenade
    * `chrome://version` → profile path → `path/User SytleSheets/Custom.css`
    * https://superuser.com/questions/580228/prevent-white-screen-before-loading-page-in-chromium
    * https://stackoverflow.com/questions/21207474/custom-css-has-stopped-working-in-32-0-1700-76-m-google-chrome-update
    * https://github.com/hbtlabs/chromium-white-flash-fix

## firefox
* plugins can't override reserved keymap
    * https://github.com/glacambre/firefox-patches/issues/1
* ctrl-f is broken
    * sometimes skips a match
    * sometimes doesn't match at all; refreshing doesn't work
* can't decouple language from date format, spell check, ...
    * setting the lang to en-uk *breaks* english spell check
    * multi-lang spell check is completely broken
* pdf.js
    * copy-pasting removes the spaces in the text
* firefox pdf dark mode https://github.com/darkreader/darkreader/issues/374#issuecomment-640622375
