# TODO

* automate installation
    * <https://github.com/junegunn/dotfiles/>
* automate [efficient git submoduling](https://jokester.io/post/2017-04/update-git-submodule-minimal-traffic/)


## vim
* init.vim repo -> the `~/.vim`. remove it from this repo. ignore plugged.
* let init.vim source `~/.vim/configs.vim`, `set rtp+=~/.vim{/after}`, ...
* in `configs.vim`, just do the `Plug` things for simple stuff
* use submodule to manage forked plugins, load with `Plug`
* remove pathogen
