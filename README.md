# TODO
* automate installation
    * <https://github.com/junegunn/dotfiles/>
    *  <https://github.com/jaagr/dots>
    * use make, stow, ...
        * https://dotfiles.github.io/
        * Just use home as git repo https://drewdevault.com/2019/12/30/dotfiles.html
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
    * <https://www.chezmoi.io/>
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

## packages

essentials
```
sudo apt install build-essential git vim tmux python3-pip python-is-python3 curl wget xclip htop unzip
```

dev
```
sudo apt install autoconf automake libtool-bin ccache ninja-build cmake g++ pkg-config llvm clang libfuse2 opam default-jre

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# https://github.com/nodesource/distributions#debian-and-ubuntu-based-distributions
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y
```

utils
```
sudo apt install sshfs aptitude dconf-editor gnome-tweaks rclone openssh-server

cargo install ripgrep fd-find bat zoxide git-delta
# ripgrep_all du-dust tokei cargo-cache cargo-edit flamegraph
```

apps
```
sudo apt install zathura okular inkscape
```

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

kime: install as instructed

todo
* Math mode doesn't start in gnome-terminal.
  Need to check if kime is actually in effect in gnome-terminal.

<details>
<summary>nimf</summary>

```bash
sudo rm -f /etc/apt/sources.list.d/hamonikr.list
curl -sL https://pkg.hamonikr.org/add-hamonikr.apt | sudo -E bash -
sudo apt install nimf nimf-libhangul
im-config -n nimf
```
* libhangul → add ESC to "shortcuts from Korean to system keyboard" so that esc in vim resets to en
* set "hooking GDK key events" https://github.com/hamonikr/nimf/issues/14#issuecomment-725849454
</details>

버그?
* kitty, neovide 등에서 한/영 전환 안됨 → 이것들이 지원 안하는 것임
<!-- * libreoffice writer에서 ctrl-f으로 한글 검색 시 뭔가 이상해짐 -->

## capslock
```bash
./interception/install.sh
```
* https://gitlab.com/interception/linux/plugins/dual-function-keys
    * interception-tools is in ubuntu repository, but dual-function-keys is not.
* https://gist.github.com/tanyuan/55bca522bf50363ae4573d4bdcf06e2e
* kmonad?
* <https://github.com/rvaiya/keyd>?

## font
```sh
sudo apt install fonts-nanum fonts-noto-cjk-extra
./fonts
ln -s ~/dots/.config/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf
fc-cache -fv
```

```sh
sudo apt install ttfautohint
git clone --depth 1 https://github.com/tomtomjhj/Iosevka
cd Iosevka
npm install
# see private-build-plans.toml
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
* Google docs: non-ascii 폰트 주의
    * 한글 지원 안하는 폰트 사용하면 export 시 한글이 다 굴림으로 바뀜. ~~현재 Google docs에서 지원하는 한글 폰트 중 쓸만한 건 나눔 고딕 밖에 없음.~~ Noto Sans KR 추가됨
        * `fonts-nanum` 패키지 설치했더라도 Google docs의 "Nanum Gothic"은 odp로 export 후 LibreOffice Impress에서 열 때 "font is not available and will be substituted"라고 나옴. 그런데 대부분 글자는 잘 표시됨 (`fc-match "Nanum Gothic"` 실행 시 `NanumGothic.ttf` 찾음). 그런데 Impress에서는 한글과 ascii char 간격이 훨씬 커서 여하간 레이아웃이 깨짐.
    * Consolas는 설치하기 귀찮으니 그냥 Source Code Pro 사용할 것
    * 수학: Cambria Math

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
    1.  make a profile
    2.  dump `dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf`
    3.  put this
        ```ini
        [:UUID-CREATED-IN-1]
        audible-bell=false
        background-color='rgb(244,244,244)'
        background-transparency-percent=46
        cursor-blink-mode='off'
        default-size-columns=100
        default-size-rows=30
        exit-action='close'
        font='Iosevka Custom 7.5'
        foreground-color='rgb(18,18,18)'
        palette=['rgb(255,255,255)', 'rgb(165,40,54)', 'rgb(32,116,0)', 'rgb(141,99,0)', 'rgb(31,88,182)', 'rgb(131,55,148)', 'rgb(1,123,128)', 'rgb(58,58,58)', 'rgb(158,158,158)', 'rgb(213,86,93)', 'rgb(77,159,58)', 'rgb(193,138,4)', 'rgb(73,131,229)', 'rgb(175,98,193)', 'rgb(5,173,180)', 'rgb(0,0,0)']
        scrollbar-policy='never'
        use-system-font=false
        use-theme-colors=false
        use-theme-transparency=false
        use-transparent-background=false
        visible-name='quite-light'

        [:UUID-CREATED-IN-1]
        audible-bell=false
        background-color='rgb(8,8,8)'
        background-transparency-percent=10
        cursor-blink-mode='off'
        cursor-shape='block'
        default-size-columns=100
        default-size-rows=30
        font='Iosevka Custom 7.5'
        foreground-color='rgb(238,238,238)'
        palette=['rgb(0,0,0)', 'rgb(255,125,129)', 'rgb(115,198,96)', 'rgb(225,161,3)', 'rgb(109,164,255)', 'rgb(218,138,236)', 'rgb(4,197,206)', 'rgb(208,208,208)', 'rgb(112,112,112)', 'rgb(255,175,174)', 'rgb(143,228,125)', 'rgb(255,190,62)', 'rgb(157,194,255)', 'rgb(240,174,255)', 'rgb(6,230,239)', 'rgb(255,255,255)']
        scrollbar-policy='never'
        use-custom-command=false
        use-system-font=false
        use-theme-colors=false
        use-theme-transparency=false
        use-transparent-background=false
        visible-name='quite-dark'
        ```
    4.  `dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf`
    * Run with profile: `gnome-terminal --profile=quite-light`
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
* <https://connect.mozilla.org/t5/discussions/how-to-remove-the-3-dot-menu-on-firefox-suggest-drop-down-items/td-p/28339>

## tex
* [Dockerfile](./docker/texlive/Dockerfile)
* minimal-ish? installation
  ```bash
  sudo apt install latexmk texlive-science texlive-xetex texlive-lang-korean texlive-fonts-extra
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

note
* pandoc converts fenced code block without language to indented code block, which is ugly for code block under list.
  No option to disable this. What's the difference from --markdown-headings, --reference-links?
  https://github.com/jgm/pandoc/issues/2120
  https://stackoverflow.com/questions/66945893/use-fenced-code-blocks-in-pandoc-markdown-output
  ```lua
  -- pandoc .. -L filter.lua
  function CodeBlock (cb)
    if cb.classes[1] or cb.attributes[1] then return nil end
    return pandoc.RawBlock('markdown', ('```\n%s\n```\n'):format(cb.text))
  end
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

## dell
dell command-configure
* download <https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=fr3fy&oscode=ub16g&productcode=xps-13-9360-laptop>
* documentation <https://www.dell.com/support/manuals/en-us/command-configure/dcc_4.8_ug/introduction-to-dell-command-configure-4.8?guid=guid-e3b5faa3-e499-4c5e-b410-3894503bb88d&lang=en-us> (no CLI documentation)

battery charge
```
sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=Custom:65-80
sudo /opt/dell/dcc/cctk --PrimaryBattChargeCfg=Custom:90-95
```

This package broke Welcome_KAIST.
journalctl:
```
OpenSSL: EVP_DigestInit_ex failed: error:12800067:DSO support routines::could not load the shared library
EAP-MSCHAPV2: Failed to derive response
```
`ldd $(which openssl)` showed that some shared lib missing from openssl stuff included in command-configure package.
Maybe the package is intended for ubuntu 16.04?
<https://unix.stackexchange.com/questions/717390/problems-with-openssl>
<!--
nmcli d wifi connect Welcome_KAIST
-->

## etc
* `aptitude upgrade --full-resolver` good for resolving broken package issues
* purge after only remove `sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')`.
  <https://askubuntu.com/a/687305>

```sh
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

install deb package from mozilla's apt repo
<https://support.mozilla.org/en-US/kb/install-firefox-linux?#w_install-firefox-deb-package-for-debian-based-distributions>

Block snap version
```bash
sudo snap remove --purge firefox

sudo tee /etc/apt/preferences.d/firefox << 'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOF
```

See also <https://ubuntuhandbook.org/index.php/2022/04/install-firefox-deb-ubuntu-22-04/>

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

#### kernel 6.2 breaks nvidia stuff
Around 2023-08-04, kernel was upgraded to 6.2 from 5.19.
This broke display in my office desktop (AMD cpu, MSI B450M, GeForce GT 1030):
"NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver".

Solution: Boot into 5.19. This can be selected in grub menu.

2023-10-01: Old kernel is broken too. /:
Gave up and upgraded to 23.04.

### 23.04
* default fonts changed?? much feature so wow
  <https://ubuntuhandbook.org/index.php/2023/04/restore-old-fonts-ubuntu-2304/>
* nautilus에 nimf로 한글 입력 안됨???
* htop `<F5>` got slower

### 23.10
* feature? bug? gnome desktop now "fixes" the tiling configuration.
  2 vertical split windows; add one more vertical split window on left; alt-tab; click right window → left shows the initial left window.
* window snap 후에 터미널에서 키가 씹힐 때가 잇음?? redraw가 씹히는 듯

### 22.04 reinstall
* firefox에서 nimf가 막힘.
  dmesg:
  ```
  apparmor="DENIED" operation="connect" class="file" profile="firefox" name="/run/user/1000/nimf/socket" pid=2512 comm="firefox" requested_mask="wr" denied_mask="wr" fsuid=1000 ouid=1000
  apparmor="DENIED" operation="exec" class="file" profile="firefox" name="/usr/bin/nimf" pid=8274 comm="firefox" requested_mask="x" denied_mask="x" fsuid=1000 ouid=0
  ```
  <https://bugs.launchpad.net/ubuntu/+source/evince/+bug/1569863>
  firenvim도 apparmor가 막음.
  ```
  sudo systemctl disable apparmor
  sudo aa-teardown
  ```
  apparmor같은 거 update 될때마다 해줘야 함.
  <https://help.ubuntu.com/community/AppArmor>.
  TODO: proper fix
    * web spotify도 안됨.
      <https://askubuntu.com/questions/1418203/netflix-on-firefox-the-widevinecdm-plugin-has-crashed>
* nautilus가 간혹 매우 느리게 뜸. 이 시점에는 여러번 실행해도 여러 창이 뜨지 않음.
  `journalctl -b0 -p3`
  ```
  systemd[1537]: Failed to start Tracker file system data miner.
  systemd[1537]: Failed to start Tracker metadata extractor.
  ```
  <https://www.reddit.com/r/gnome/comments/nu4bvr/comment/h0xsag4/>
  `rm -rf ~/.cache/{tracker3,tracker}`. fixed. ubuntu downgrade문제일듯.

# Windows

## WSL
* sshfs: `sshfs -o allow_other,default_permissions`
 <https://github.com/microsoft/WSL/issues/8498>
* `XDG_RUNTIME_DIR`
  <https://github.com/ibhagwan/fzf-lua/issues/1243#issuecomment-2554289014>

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
* bash `history` (man bash; SHELL BUILTIN COMMANDS)
    * Some apps use it to get the current command e.g. `alert` alias, kitty, ...
      These assume that commands are not ignored from history.
    * Most stuff doesn't need to be persisted in .bash_history.
    * <https://unix.stackexchange.com/questions/18212/bash-history-ignoredups-and-erasedups-setting-conflict-with-common-history>
    * TODO: How to apply ignore rules only when writing to .bash_history?
      Do something at `trap ... EXIT`?
    * <https://superuser.com/questions/135651/how-can-i-add-a-command-to-the-bash-history-without-executing-it>
* webp → mp4, with sane fps <https://stackoverflow.com/questions/18123376>
  ```
  ffmpeg -fflags +genpts -i input.webm -r 24 output.mp4
  ```
* pdf → image
  ```
  magick convert -density 300 -trim in.pdf -quality 100 out.png
  ```
  quality max is 100.
  change density if necessary.
  see also <https://imagemagick.org/script/command-line-options.php>
* how to rotate a page in pdf without losing bookmark, etc?
  pdfarranger loses them. can't fix with pdktk update_info
* sync-ing directories
    * https://stackoverflow.com/questions/3672480/cp-command-should-ignore-some-files
    * https://unix.stackexchange.com/questions/203846/how-to-sync-two-folders-with-command-line-tools (trailing slash)
* tmux "server existed unexpectedly" <https://github.com/tmux/tmux/issues/2376>
  ```
  ssh server "rm /tmp/tmux* -rf"
  ```


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
* firefox pdf dark mode <https://github.com/darkreader/darkreader/issues/374#issuecomment-640622375>
  Make a bookmark with the following url.
  ```
  javascript:void(viewer.style = 'filter: grayscale(0%) invert(100%) hue-rotate(180deg) contrast(100%) brightness(100%)')
  ```
  Added `hue-rorate` to make it work like zathura's `recolor-keephue`.
  <https://developer.mozilla.org/en-US/docs/Web/CSS/filter-function/hue-rotate>.
  See also <https://stackoverflow.com/a/65355529>.
    * Problem: When applied, "zoom in" is broken. If zoomed in sufficiently so that the width of document is larger than the width of firefox, scrolled to somewhere else and hyperlinks don't work.
    * See also <https://github.com/shivaprsd/doqment>
* 98
    * why is this an improvement??? https://www.reddit.com/r/firefox/comments/t9h0og/comment/hzvfyxi/?utm_source=share&utm_medium=web2x&context=3
    * see also: https://www.reddit.com/r/firefox/comments/t9hk42/comment/hzu6uq1/?utm_source=share&utm_medium=web2x&context=3
* `accessibility.typeaheadfind.prefillwithselection = false` to disable "ctrl-f prefill with clipboard"
* `browser.fullscreen.autohide = false` to show tabs in fullscreen mode
* `browser.urlbar.resultMenu.keyboardAccessible = false` to tab through search result without selecting three dot menu


## shell, bash, shell script
* resource
    * https://mug896.github.io/bash-shell/quotes.html
    * https://mywiki.wooledge.org/BashPitfalls
    * https://github.com/dylanaraps/pure-sh-bible
    * https://mug896.github.io/awk-script/index.html
    * http://redsymbol.net/articles/unofficial-bash-strict-mode/
        * NOTE: The argument for `IFS=$'\t\n'` is based on the "wrong" usage of `${arr[@]}` (without double quote)
    * [Minimal safe Bash script template](https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038)
    * <https://explainshell.com/>
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
* `find(1)` man page EXAMPLES section
* array
    * output to array (bash ≥ 4.0)
      ```
      mapfile -t lines < <(command)
      ```
* This can be very confusing.
  > Bash uses a hash table to remember the full pathnames of executable files.
  > A full search of the directories in PATH is performed only if the command is not found in the hash table.

  Use `hash -r` to refresh.
* bash lazy-loading completion
  ```bash
  _load_kubectl_completion() {
      complete -r kubectl
      unset -f _load_kubectl_completion
      source <(kubectl completion bash)
      return 124
  }
  complete -F _load_kubectl_completion kubectl
  ```

## Git
* Merging working tree and stash: `git add`, then stash pop. <https://stackoverflow.com/a/16613814>.
  Alternatively, `git checkout` instead of `git stash apply` <https://stackoverflow.com/a/16625128>.
* `git pull --rebase --autostash`
* https://github.com/mhagger/git-imerge
* git reflog
    * git log -g
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
* `git reset --merge <commit>`: like `--hard`, but doesn't touch files with changes that are not added (diff between index and working tree)
    * Can be used for aborting `stash pop` when there was changes in working tree. <https://stackoverflow.com/a/60444590>
* `git diff --check`
* `man gitrevisions(7)`
    * range `<rev>`: commits reachable from `<rev>` (i.e. ancestors)
    * range `^<rev>`: commits not reachable from `<rev>` (i.e. ancestors)
    * range `^main feature` (= `main..feature`):
    * `...`: symmetric diff
* <https://stackoverflow.com/questions/39665570/why-can-two-git-worktrees-not-check-out-the-same-branch>
* `git push -u origin my_ref:remote_branch`
* `git-rebase(1)` REBASING MERGES
* <https://github.com/arxanas/git-branchless>
* `rebase --update-refs` <https://adamj.eu/tech/2022/10/15/how-to-rebase-stacked-git-branches/> 2.38
* what's the best practice for spliting a commit?
* `git blame --reverse` (`fugitive_<CR>` in blob with count) may not show the commit that deletes the line when the path includes merge commits.
  <https://stackoverflow.com/a/42707940>
* `git range-diff`
* Rebasing merge commit with conflict resolution and other additional changes (that modify the part of code that didn't produce conflict marker, but conceptually is a conflict).
  `git rebase --rebase-merges origin/master` + rerere doesn't seem to carry over the additional changes.
  Had to merge the merge commit.
    * This kind of merge is called "evil merge".
      Potential solution?:
      https://git-blame.blogspot.com/2015/10/fun-with-recreating-evil-merge.html
* shallow
    * shallow clone to branch
      ```
      git clone URL --depth 1 -b BRANCH
      ```
      Note that it works only for branches.
    * shallow fetch tag
      ```
      git fetch --depth 1 origin tag v1.1
      ```
      "tag" here is a keyword to indicate that the following is tag (see `<refspec>`).
    * shallow fetch new branch
      ```
      git remote set-branches --add origin <branch-name>
      git fetch --depth 1 origin <branch-name>
      ```
      all branches
      ```
      git remote set-branches origin '*'
      ```
    * shallow submodule
      ```
      git submodule update --init --recursive --depth=1
      ```
      Not perfect, but good enough.
    * deepening
      ```
      git fetch --deepen=N
      ```
