# TODO

* sync ssh xclip and client xclip
* automate installation
    * <https://github.com/junegunn/dotfiles/>
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
* automate [efficient git submoduling](https://jokester.io/post/2017-04/update-git-submodule-minimal-traffic/)

# stuff
* https://github.com/skywind3000/z.lua
    ```sh
    # .bashrc
    eval "$(lua ~/dots/ext/z.lua/z.lua --init bash enhanced once fzf)"
    ```

# Note
* `.profile` vs `.bash_profile`
