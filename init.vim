" Neovim (~/.config/nvim/autoload)
" curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" TODO: remove init.vim repo and use dots repo
" vim-plug for the most of the stuff.
" main setup + portable setup

call plug#begin('~/.vim/plugged')

" theme
Plug 'tomtomjhj/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'rakr/vim-one'

" general
Plug 'tomtom/tlib_vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter', { 'on': 'GitGutterToggle' }
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'scrooloose/nerdcommenter'
Plug 'skywind3000/asyncrun.vim', { 'on': 'AsyncRun' }
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'tomtomjhj/auto-pairs'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Shougo/vimproc.vim', { 'do' : 'make' }

" completion
Plug 'ervandew/supertab'
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif
" only for markdown/tex?
Plug 'SirVer/ultisnips', { 'for': 'pandoc' }
" Plug 'honza/vim-snippets'
" https://github.com/junegunn/vim-plug/wiki/tips#loading-plugins-manually
" https://github.com/junegunn/vim-plug/wiki/faq

" lanauges
Plug 'tomtomjhj/ale'
Plug 'autozimu/LanguageClient-neovim', {
            \ 'branch': 'next',
            \ 'do': 'bash install.sh',
            \ 'for': ['rust', 'haskell'],
            \ }

Plug 'tomtomjhj/vim-pandoc-syntax' | Plug 'vim-pandoc/vim-pandoc'
Plug 'tomtomjhj/rust.vim', { 'for': ['rust', 'pandoc'] }
Plug 'deoplete-plugins/deoplete-jedi'

" TODO: pandoc syntax: use g:pandoc#syntax#codeblocks#embeds#langs
" on-demand load of embedded lang syntax?
" Plug 'tomtomjhj/haskell-vim', { 'for': 'haskell' }
" Plug 'parsonsmatt/intero-neovim', { 'for': 'haskell' }
" Plug 'tomlion/vim-solidity', { 'for': 'solidity' }
" Plug 'tomtomjhj/vim-ocaml', { 'for': 'ocaml' }
"
" on-demand load

" Plugin options
" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }


" Unmanaged plugin (manually installed and updated)
" Plug '~/my-prototype-plugin'

" Initialize plugin system, :PlugInstall
call plug#end()
