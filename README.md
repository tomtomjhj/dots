# TODO

* sync ssh xclip and client xclip
* automate installation
    * <https://github.com/junegunn/dotfiles/>
    * use make, stow, ...
    * using bare repo and worktree
    ```sh
    git clone --bare ... $HOME/.dotfiles
    alias cfg="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    cfg checkout
    cfg config --local status.showUntrackedFiles no
    ```
    * `--separate-git-dir`
* automate [efficient git submoduling](https://jokester.io/post/2017-04/update-git-submodule-minimal-traffic/)

# Note
* `.profile` vs `.bash_profile`
