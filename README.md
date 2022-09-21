# TODO
* automate installation
    * <https://github.com/junegunn/dotfiles/>
    *  <https://github.com/jaagr/dots>
    * use make, stow, ...
        * https://dotfiles.github.io/
        * https://github.com/masasam/dotfiles/blob/master/Makefile
        * https://polothy.github.io/post/2018-10-09-makefile-dotfiles/
        * https://github.com/b4b4r07/dotfiles/blob/master/Makefile
        * https://konfekt.github.io/blog/2018/11/10/simple-dotfiles-setup
    * using bare repo and worktree
    ```sh
    git clone --bare ... $HOME/.dotfiles
    alias cfg="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    cfg checkout
    cfg config --local status.showUntrackedFiles no
    ```
    * `--separate-git-dir`
* automate direct binary download https://stackoverflow.com/a/29360657
* https://help.ubuntu.com/community/CheckInstall
* opam
    * Opam configuration should be run in `.bash_profile`
    * vscoq + opam local switch
        * .profile issue
        * launch coqtop with `opam config exec --`?
    * too much duplication
        * https://khady.info/opam-compilation-cache.html
        * opam-bin
        * https://coq.zulipchat.com/#narrow/stream/237655-Miscellaneous/topic/opam.20switch.20tight.20to.20a.20directory.3F
* https://github.com/cheat/cheat
* input method for unicode chars
    * compose key?
    * want both tex notation and digraphs
* https://github.com/bcpierce00/unison
* https://github.com/rclone/rclone/issues/118
* disable primary selection stuff, middle mouse click,... (gnome tweak doesn't work... maybe wayland issue?)
* terminal with better input handling, modifyOtherKeys, ...
    * https://gitlab.gnome.org/GNOME/vte/-/issues/1441
    * https://github.com/alacritty/alacritty/issues/3101
    * https://vimhelp.org/vim_faq.txt.html#faq-20.5 https://vimhelp.org/map.txt.html#modifyOtherKeys
    * https://github.com/neovim/neovim/issues/14350
    * https://github.com/tmux/tmux/issues/2216 https://github.com/tmux/tmux/wiki/Modifier-Keys#extended-keys
* https://github.com/camdencheek/fre

# Ubuntu setup

## ppas
```sh
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo add-apt-repository ppa:alessandro-strada/ppa  # google-drive-ocamlfuse
sudo add-apt-repository ppa:libreoffice/ppa
```

## drivers
```bash
sudo ubuntu-drivers install
```

## 한글

### nimf
```bash
sudo rm -f /etc/apt/sources.list.d/hamonikr.list
curl -sL https://pkg.hamonikr.org/add-hamonikr.apt | sudo -E bash -
sudo apt install nimf nimf-libhangul
im-config -n nimf
```
* libhangul → add ESC to "shortcuts from Korean to system keyboard" so that esc in vim resets to en
* set "hooking GDK key events" https://github.com/hamonikr/nimf/issues/14#issuecomment-725849454

### kime
* Ran `im-config -n kime` on Wayland but doesn't work at all <https://github.com/Riey/kime/issues/559>?

## capslock
```bash
./interception/install.sh
```
* https://gitlab.com/interception/linux/plugins/dual-function-keys
* https://gist.github.com/tanyuan/55bca522bf50363ae4573d4bdcf06e2e
* kmonad?

## font
```
./fonts
ln -s ~/dots/.config/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf
fc-cache -fv
```
* https://repolinux.wordpress.com/2013/03/10/find-out-fallback-font-used-by-fontconfig-for-a-certain-character/
* http://eosrei.net/articles/2016/02/changing-default-fallback-subsitution-fonts-linux
* Making texlive fonts available to fontconfig <https://wiki.archlinux.org/title/TeX_Live#Making_fonts_available_to_Fontconfig>.
    * This may cause some pain; e.g. `texlive-fonts-extra` in old texlive contains weird version of Source Serif, which messes up docs.rs fonts in Firefox.
      Undoing:
      ```bash
      sudo rm /etc/fonts/conf.d/09-texlive-fonts.conf
      sudo fc-cache -fsv
      ```

## gnome
* [make gnome terminal title bar small](https://www.reddit.com/r/gnome/comments/b3l1c9/gnometerminal_title_bar_is_huge_in_332/)
  ```
  gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
  ```
* gnome tab bar height
  ```
  cd ~/.config/gtk-3.0 && ln -s ~/dots/.config/gtk-3.0/gtk.css
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
       palette=['rgb(31,31,31)', 'rgb(235,96,107)', 'rgb(195,232,141)', 'rgb(247,235,149)', 'rgb(128,203,195)', 'rgb(255,36,144)', 'rgb(174,221,255)', 'rgb(221,221,221)', 'rgb(102,102,102)', 'rgb(235,96,107)', 'rgb(195,232,141)', 'rgb(247,235,149)', 'rgb(125,198,191)', 'rgb(108,113,195)', 'rgb(86,214,255)', 'rgb(255,255,255)']
       background-transparency-percent=11
       foreground-color='rgb(255,255,255)'
       cell-height-scale=1.0
       highlight-colors-set=false
       audible-bell=false
       use-theme-transparency=false
       ```
    4. `dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf`
    * gnome-terminal colorscheme installer
        * <https://github.com/Mayccoll/Gogh/blob/master/apply-colors.sh#L655>
            * How are `BACKGROUND_COLOR` and etc different from the 16 colors? Maybe fg/bg applied when no color specified. cursor: only terminal knows this...? Vim's Cursor vs. this cursor?
        * https://github.com/bluz71/vim-nightfly-guicolors/blob/master/terminal_themes/gnome-terminal-nightfly.sh
* disable `ctrl-alt-d` https://askubuntu.com/a/177994 TODO dconf-editor

## firefox

### allow plugins to override reserved keymap
https://github.com/glacambre/firefox-patches/issues/1
Run it after closing firefox. Rerun when firefox is updated.
```
sudo perl -i -pne 's/reserved="true"/               /g' /usr/lib/firefox/browser/omni.ja
find $HOME/.cache/mozilla/firefox -type d -name startupCache | xargs rm -rf
```
* automation?
* Removing all reserved keys is not great since some sites have annoying keymaps.

### etc
* `privacy.resistFingerprinting` breaks some stuff

## tex
* [Dockerfile](./docker/texlive/Dockerfile)
* minimal-ish? installation
  ```bash
  sudo apt install texlive-science texlive-xetex texlive-lang-korean texlive-publishers texlive-fonts-extra
  ```

## pandoc
```bash
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep -o "https.*amd64.deb" | wget -O pandoc.deb -qi - && sudo dpkg -i pandoc.deb && rm pandoc.deb
# or get nightly build from https://github.com/jgm/pandoc/actions?query=workflow%3ANightly

cd $HOME/.local/share
ln -s $HOME/dots/.local/share/pandoc
cd pandoc

curl -LSs https://github.com/pandoc/lua-filters/releases/latest/download/lua-filters.tar.gz | tar -zvxf -
mv lua-filters/filters .
rm -rf lua-filters
```

## wayland stuff
* (fixed in 21.10) screen share https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing

## docker
* https://docs.docker.com/engine/install/ubuntu/
* https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

```
sudo usermod -aG docker $USER
```

## obsidian
<https://forum.obsidian.md/t/meta-post-linux-tips-tricks-solutions-to-common-problems/6291/3>
<https://forum.obsidian.md/t/gnome-desktop-installer/499>

```bash
curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -o "https.*AppImage" | tail -n 1 | wget -O $HOME/.local/bin/obsidian -qi - && chmod +x $HOME/.local/bin/obsidian

tee ~/.local/share/applications/obsidian.desktop << EOF
[Desktop Entry]
Type=Application
Name=Obsidian
Exec=${HOME}/.local/bin/obsidian
Icon=obsidian
StartupWMClass=obsidian
MimeType=x-scheme-handler/obsidian;
EOF
update-desktop-database ~/.local/share/applications
```

## etc
* `aptitude upgrade --full-resolver` good for resolving broken package issues

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install ripgrep fd-find bat zoxide git-delta
# ripgrep_all du-dust tokei cargo-cache

cd ~/.config && ln -s ~/dots/.config/bat
bat cache --build
```

## after `do-release-upgrade`

### 21.04
* fix opam https://github.com/ocaml/opam/issues/3708
  ```
  opam install ocaml.4.11.1 ocaml-system.4.11.1 --yes --unlock-base
  ```
* pip kdewallet https://stackoverflow.com/q/64570510

### 21.10
* remove snap firefox and use deb firefox (slow & firenvim support)

### 22.04
* remove ntfs-3g and use linux native ntfs? (kernel 5.15?)
    * ??? <https://www.reddit.com/r/linux/comments/uca3fu/ntfs3_driver_is_orphan_already_what_we_do/>
* `opam upgrade ocaml-system -y`
* reinstall interception and nimf
* get back ctrl-shift-prtsc <https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/5208>
  ```bash
  sudo apt install gnome-screenshot
  # sh -c 'gnome-screenshot -ac' # broken: https://gitlab.gnome.org/GNOME/gnome-screenshot/-/issues/66
  # add this to custom shortcut ... NOTE: && is meaningless because gnome-screenshot exits with 0 even if screenshot is not taken...
  sh -c 'gnome-screenshot -af /tmp/screenshot.png && xclip /tmp/screenshot.png -selection clipboard -target image/png; rm /tmp/screenshot.png'
  ```

issues
* Click on a top bar component (e.g. power on/off menu) → "click" state is maintained when cursor is moved to other component. Very annoying when using volume slider.

#### firefox
snap firefox literally unusable (literally)
* firenvim
* 한글 input
    * nimf, kime doesn't work with snap
    * ibus: broken as usual
    * see <https://www.facebook.com/groups/ubuntu.ko/posts/4999290446775429/?comment_id=4999304873440653>
* ignores per-monitor scale factor on wayland
* ignores system theme stuff (e.g. gnome accent color)
    * `snap install gtk-commons-themes`?

install deb package
<https://ubuntuhandbook.org/index.php/2022/04/install-firefox-deb-ubuntu-22-04/>
```bash
sudo snap remove --purge firefox
sudo add-apt-repository ppa:mozillateam/ppa
sudo apt install -t 'o=LP-PPA-mozillateam' firefox

sudo tee /etc/apt/preferences.d/firefox << 'EOF'
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOF

sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox << EOF
Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";
EOF
```

#### can't login to Wi-Fi with PEAP, MSCHAPv2
Fixed on 2022-06-21.

<https://bugs.launchpad.net/ubuntu/+source/wpa/+bug/1958267>

Downgrade to the version used in 21.10.
```bash
wget http://kr.archive.ubuntu.com/ubuntu/pool/main/w/wpa/wpasupplicant_2.9.0-21build1_amd64.deb
sudo dpkg -i wpasupplicant_2.9.0-21build1_amd64.deb
sudo tee /etc/apt/preferences.d/wpasupplicant << 'EOF'
Package: wpasupplicant
Pin: version 2:2.9.0-21build1
Pin-Priority: 501
EOF
```
Delete `/etc/apt/preferences.d/wpasupplicant` when fixed.

# note, tips
* https://github.com/cyrus-and/gdb-dashboard
* less
    * run `lesskey lesskey`
    * https://github.com/gwsw/less/issues/188 `<C-w>` doesn't work either.. Use `<C-M-H>`
    * `F` command or `+F` (scroll forward)
    * display the search at the bottom? highlight the current search differently?
* ignore
  ```
  ## .gitignore
  _opam

  ## .ignore
  !_opam

  ## _opam/.ignore
  *
  !*/
  # !lib/coq/theories/**/*.v
  !lib/coq/user-contrib/**/*.v
  lib/coq/user-contrib/Ltac2
  ```
* gnome shell `alt-F2`
* troubleshooting slow boot (after removing swap partition)
    * diagnosis
        * `sudo journalctl -b`
        * `systemd-analyze` (very slow kernel stuff)
        * `dmesg` doesn't show some messages??
        * removed `quiet splash` from grub config to see all the messages from kernel
            * `Gave up waiting for suspend/resume device`
    * remove the removed swap partition from `/etc/fstab` https://askubuntu.com/a/744478
    * remove the resume device stuff `sudo rm /etc/initramfs-tools/conf.d/resume && sudo update-initramfs -u` https://askubuntu.com/a/1126353
* archiving: put the ignore file in the dir for `--exclude-vcs-ignores` and exlucde the ignore file itself; remove ownership
  ```bash
  tar czvf $NAME.tar.gz \
      --exclude-vcs-ignores --exclude=.gitignore \
      --owner=0 --group=0 \
      $NAME
  # BSD tar doesn't support --ower stuff. GNU and BSD both support --numeric-owner.
  ```
* ripgrep
    * `rg --hidden --glob '!**/.git/**'`: do not ignore dot files but respect ignore files
    * `-U` (multiline): `\s` includes `\n`
* TODO: I'm using .bash_history + fzf `<C-R>` as command bookmark. Find a proper way to bookmark (find using fzf) and use history as history. <https://github.com/junegunn/fzf/wiki/examples>.


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
* 98
    * why is this an improvement??? https://www.reddit.com/r/firefox/comments/t9h0og/comment/hzvfyxi/?utm_source=share&utm_medium=web2x&context=3
    * see also: https://www.reddit.com/r/firefox/comments/t9hk42/comment/hzu6uq1/?utm_source=share&utm_medium=web2x&context=3
* `accessibility.typeaheadfind.prefillwithselection = false` to disable "ctrl-f prefill with clipboard"
* `browser.fullscreen.autohide = false` to show tabs in fullscreen mode


## shell, bash, shell script
* resource
    * https://mug896.github.io/bash-shell/quotes.html
    * https://mywiki.wooledge.org/BashPitfalls
    * https://github.com/dylanaraps/pure-sh-bible
    * https://mug896.github.io/awk-script/index.html
* login shell
    * what's the point? https://unix.stackexchange.com/a/324391
    * `~/.bash_profile`, `~/.profile`, `~/.bashrc` https://superuser.com/a/789465
    * tmux
        * why login shell? https://superuser.com/q/968942
        * can make it run non-login shell https://wiki.archlinux.org/title/tmux#Start_a_non-login_shell
    * gnome-shell
        * Can't refresh `~/.profile`. Must re-login https://unix.stackexchange.com/a/2963
        * (21.04) re-login to Xorg doesn't run `~/.profile`??
* `[ -t 0 ]` (used in `~/.opam/opam-init/init.sh`) checks if stdin is open. Note that this is false for gnome-shell.
* logging stderr to file with timestamp, using process substitution
  ```bash
  cmd 2> >(while read line; do echo "$(date -Iseconds) $line"; done > log)
  ```
    * TODO: how does bash interact with the subprocess's stdout/stderr?

## Git
* To force stash apply, `git checkout` instead of `git stash apply` <https://stackoverflow.com/a/16625128>
* `git pull --rebase --autostash`
* https://github.com/mhagger/git-imerge
* git reflog
* getting info from git log/diff
    * `-M[<n>], --find-renames[=<n>]`, `-C[<n>], --find-copies[=<n>]` (+ `-C -C`, `-C -C -C`). Also applicable to git blame.
        * hack to force copy detection <https://stackoverflow.com/a/46484848>
    * `-D, --irreversible-delete`
    * `log --follow a-single-file`: history of a file, detecting rename and copy
    * patch search
        * `-G pat`: grep
        * `-S pat [--pickaxe-regex]`: change in number of occurrences
    * <https://stackoverflow.com/questions/29468273/why-git-blame-does-not-follow-renames>
    * Use `git show` for better merge commit diff <https://stackoverflow.com/questions/45253550>
* `git log -L`
    * `:{range}Gclog`
* `git apply --reject --whitespace=fix`
* git files absolute dir `git -C "$ROOT" ls-files | awk -v R="$ROOT" '{ print R "/" $0 }'`
* `git reset --merge` to abort `stash pop` https://stackoverflow.com/a/60444590
* `git diff --check`
* `man gitrevisions(7)`
    * range `<rev>`: commits reachable from `<rev>` (i.e. ancestors)
    * range `^<rev>`: commits not reachable from `<rev>` (i.e. ancestors)
    * range `^main feature` (= `main..feature`):
* <https://stackoverflow.com/questions/39665570/why-can-two-git-worktrees-not-check-out-the-same-branch>
* `git push -u origin my_ref:remote_branch`
* `git-rebase(1)` REBASING MERGES
* `git-rerere`
    * https://stackoverflow.com/questions/49500943/what-is-git-rerere-and-how-does-it-work#comment86015280_49501436
    * not very accuate??
