" platform/terminal/gui stuff {{{
if has('nvim') || has('win32')
    set runtimepath^=~/.vim
    set runtimepath+=~/.vim/after
    let &packpath = &runtimepath
endif
if !has('nvim') && !has('gui_running')
    silent !stty -ixon > /dev/null 2>/dev/null
    set ttymouse=sgr
    " fix <M- mappings {{{
    " NOTE: :h 'termcap' (e.g. arrows). Map only necessary stuff.
    for c in [',', '.', '/', '0', '\', ']', 'i', 'j', 'k', 'l', 'n', 'o', 'p', 'y', '\|']
        exec 'map  <ESC>'.c '<M-'.c.'>'
        exec 'map! <ESC>'.c '<M-'.c.'>'
    endfor
    cnoremap <ESC><ESC> <C-c>
    map  <Nul> <C-space>
    map! <Nul> <C-space>

    " A hack to bypass <ESC> prefix map timeout stuff.
    function! s:ESCHack(mode)
        exec a:mode . 'unmap <buffer><ESC>'
        let extra = ''
        while 1
            let c = getchar(0)
            if c == 0
                break
            endif
            let extra .= nr2char(c)
        endwhile
        if a:mode != 'i'
            let prefix = v:count ? v:count : ''
            let prefix .= '"'.v:register . (a:mode == 'v' ? 'gv' : '')
            if mode(1) == 'no'
                if v:operator == 'c'
                    let prefix = "\<esc>" . prefix
                endif
                let prefix .= v:operator
            endif
            call feedkeys(prefix, 'n')
        endif
        call feedkeys("\<ESC>" . extra . "\<Plug>" . a:mode . "mapESC")
    endfunction

    imap <silent><Plug>imapESC <C-o>:<C-u>call ESCimap()<CR>
    map  <silent><Plug>imapESC      :<C-u>call ESCimap()<CR>
    imap <silent><Plug>nmapESC <C-o>:<C-u>call ESCnmap()<CR>
    map  <silent><Plug>nmapESC      :<C-u>call ESCnmap()<CR>
    imap <silent><Plug>vmapESC <C-o>:<C-u>call ESCvmap()<CR>
    map  <silent><Plug>vmapESC      :<C-u>call ESCvmap()<CR>
    imap <silent><Plug>omapESC <C-o>:<C-u>call ESComap()<CR>
    map  <silent><Plug>omapESC      :<C-u>call ESComap()<CR>

    function! ESCimap()
        imap <silent><buffer><nowait><ESC> <C-o>:<C-u>call <SID>ESCHack('i')<CR>
    endfunction
    function! ESCnmap()
        nmap <silent><buffer><nowait><ESC> :<C-u>call <SID>ESCHack('n')<CR>
    endfunction
    function! ESCvmap()
        vmap <silent><buffer><nowait><ESC> :<C-u>call <SID>ESCHack('v')<CR>
    endfunction
    function! ESComap()
        omap <silent><buffer><nowait><ESC> :<C-u>call <SID>ESCHack('o')<CR>
    endfunction
    augroup TerminalVimSetup | au!
        au BufEnter * call ESCimap() | call ESCnmap() | call ESCvmap() | call ESComap()
        au CmdlineEnter * set timeoutlen=23
        au CmdlineLeave * set timeoutlen=432
    augroup END
    " }}}
else
    set guioptions=i
    if has("gui_win32")
        set guifont=Consolas:h10:cANSI
    endif
endif
" }}}

" Plug {{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif

" appearance
Plug 'itchyny/lightline.vim'
Plug 'tomtomjhj/zenbruh.vim'
" editing
Plug 'lifepillar/vim-mucomplete'
Plug 'tomtomjhj/vim-sneak'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tomtomjhj/pear-tree'
Plug 'andymass/vim-matchup' " i%, a%, ]%, z%, g%
Plug 'wellle/targets.vim' " multi (e.g. ib, iq), separator, argument
Plug 'kana/vim-textobj-user' | Plug 'glts/vim-textobj-comment' | Plug 'michaeljsmith/vim-indent-object'
Plug 'preservim/nerdcommenter', { 'on': '<Plug>NERDCommenter' }
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
Plug 'AndrewRadev/splitjoin.vim'
" etc
Plug 'tpope/vim-fugitive'
Plug 'rhysd/git-messenger.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': has('unix') ? './install --all' : { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'fszymanski/fzf-quickfix', { 'on': 'Quickfix' }
Plug 'Konfekt/FastFold' " only useful for non-manual folds
Plug 'romainl/vim-qf'
Plug 'markonm/traces.vim'
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'wellle/visual-split.vim' " <C-w>g gr/gss/gsa/gsb
Plug 'andymass/vim-tradewinds' " <C-w>g h/j/k/l
Plug 'justinmk/vim-dirvish'
Plug 'preservim/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] } " use menu!
" lanauges
Plug 'dense-analysis/ale', { 'on': ['<Plug>(ale_', 'ALEEnable'] } ")
Plug 'plasticboy/vim-markdown'
Plug 'tomtomjhj/vim-rust-syntax-ext'| Plug 'rust-lang/rust.vim'
call plug#end()
" }}}

" Basic {{{
set mouse=a
set number ruler " cursorline
set foldcolumn=1 foldnestmax=5
set scrolloff=2 " sidescrolloff
set showtabline=1
set laststatus=2

set tabstop=4 shiftwidth=4
set expandtab smarttab
set autoindent " smartindent is unnecessary
" set indentkeys+=!<M-i> " doesn't work, maybe i_META? just use i_CTRL-F
set formatoptions+=n " this may interfere with 'comment'?
set formatlistpat=\\C^\\s*[\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|^\\s*[-+o*]\\s\\+
set nojoinspaces

" indent the wrapped line, w/ `> ` at the start
set wrap linebreak breakindent showbreak=>\ 
set backspace=eol,start,indent
set whichwrap+=<,>,[,],h,l

let mapleader = ","
set timeoutlen=987
set updatetime=1234

let $LANG='en'
set langmenu=en
set encoding=utf8
" set spellfile=~/.vim/spell/en.utf-8.add
set spelllang=en,cjk

set wildmenu wildmode=longest:full,full
set wildignore=*.o,*~,*.pyc,*.pdf,*.v.d,*.vo,*.vos,*.vok,*.glob
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

set magic
set ignorecase smartcase
set hlsearch incsearch

set noerrorbells novisualbell t_vb=
set shortmess+=c
set belloff=all

set noswapfile " set directory=~/.vim/swap//
if !isdirectory($HOME."/.vim/backup")
    call mkdir($HOME."/.vim/backup", "", 0700)
endif
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "", 0700)
endif
set backup backupdir=~/.vim/backup//
set undofile undodir=~/.vim/undo//
set history=500
if has('nvim') | set shada=!,'150,<50,s30,h | endif

set autoread
set splitright splitbelow
set switchbuf=useopen,usetab
set hidden
set lazyredraw

set modeline
set exrc secure

let &pumheight = min([&window/4, 20])
augroup BasicSetup | au!
    au BufWinEnter * if empty(&buftype) && line("'\"") > 1 && line("'\"") <= line("$") | exec "norm! g`\"" | endif
    au VimEnter * exec 'tabdo windo clearjumps' | tabnext
    au FileType help nnoremap <silent><buffer> <M-.> :h <C-r><C-w><CR>
    au VimResized * let &pumheight = min([&window/4, 20])
augroup END

if has('unix')
    let g:python_host_prog  = '/usr/bin/python2'
    let g:python3_host_prog = '/usr/bin/python3'
endif
" }}}

" Themes {{{
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['readonly', 'speicialbuf', 'shortrelpath', 'modified'],
      \             ['git'] ],
      \   'right': [ ['lineinfo'], ['percent'],
      \              ['asyncrun'] ]
      \ },
      \ 'inactive': {
      \   'left': [ ['speicialbuf', 'shortrelpath'] ],
      \   'right': [ ['lineinfo'],
      \              ['percent'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&readonly && &filetype !=# "help" ? "🔒" : ""}',
      \   'speicialbuf': '%q%w',
      \   'modified': '%{&filetype==#"help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'asyncrun': '%{g:asyncrun_status[:3]}',
      \ },
      \ 'component_function': {
      \   'git': 'GitStatusline',
      \   'shortrelpath': 'ShortRelPath',
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!=#"help"&& &readonly)',
      \   'modified': '(&filetype!=#"help"&&(&modified||!&modifiable))',
      \   'speicialbuf': '&pvw||&buftype==#"quickfix"',
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': '|', 'right': '|' },
      \ 'mode_map': {
      \     'n' : 'N ',
      \     'i' : 'I ',
      \     'R' : 'R ',
      \     'v' : 'V ',
      \     'V' : 'VL',
      \     "\<C-v>": 'VB',
      \     'c' : 'C ',
      \     's' : 'S ',
      \     'S' : 'SL',
      \     "\<C-s>": 'SB',
      \     't': 'T ',
      \ }
      \ }
func! ShortRelPath()
    let name = expand('%')
    if empty(name)
        return empty(&buftype) ? '[No Name]' : ''
    elseif isdirectory(name)
        return pathshorten(fnamemodify(name[:-2], ":~")) . '/'
    endif
    return pathshorten(fnamemodify(name, ":~:."))
endfunc
" `vil() { nvim "$@" --cmd 'set background=light'; }` for light theme
if !exists('g:colors_name') " loading the color again breaks lightline
    colorscheme zenbruh
endif
" }}}

" Completion {{{
" This breaks <C-q> for vim (i_CTRL-X_CTRL-V). Much wow.
" > Note: The keys that are valid in CTRL-X mode are not mapped.  This allows for
" > ":map ^F ^X^F" to work (where ^F is CTRL-F and ^X is CTRL-X).
set completeopt=menuone,noinsert,noselect
set complete-=b,u
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#chains = {
    \ 'default': ['path', 'omni', 'c-p'],
    \ 'vim': ['path', 'cmd', 'c-p'],
    \ }

call mucomplete#map('imap', '<c-l>', '<plug>(MUcompleteCycFwd)')
noremap! <C-j> <S-Right>
noremap! <C-k> <S-Left>
noremap! <C-space> <C-k>
augroup Completions | au!
    " au Filetype * if empty(&omnifunc) | setl omnifunc=syntaxcomplete#Complete | endif
    " au FileType rust setl omnifunc=ale#completion#OmniFunc
augroup END
" }}}

" ALE, LSP, ... global settings {{{
let g:ale_linters = {}
let g:ale_fixers = {
            \ 'c': ['clang-format'],
            \ 'cpp': ['clang-format'],
            \ 'python': ['yapf'],
            \ 'ocaml': ['ocamlformat'],
            \ 'go': ['gofmt'],
            \ '*': ['trim_whitespace']
            \ }
let g:ale_set_highlights = 1
let g:ale_linters_explicit = 1

nmap <leader>fm <Plug>(ale_fix)
nmap <M-,> <Plug>(ale_detail)<C-W>p
nmap ]a <Plug>(ale_next_wrap)
nmap [a <Plug>(ale_previous_wrap)
noremap  <M-.> K
noremap  <M-]> <C-]>
nnoremap <M-o> <C-o>
nnoremap <M-i> <C-i>
" }}}

" Languages {{{
" Rust {{{
" let g:termdebugger = 'rust-gdb'
let g:cargo_shell_command_runner = 'AsyncRun -post=CW'
command! -nargs=* Cclippy call cargo#cmd("+nightly clippy -Zunstable-options " . <q-args>)
command! -range=% PrettifyRustSymbol <line1>,<line2>SubstituteDict { '$SP$': '@', '$BP$': '*', '$RF$': '&', '$LT$': '<', '$GT$': '>', '$LP$': '(', '$RP$': ')', '$C$' : ',',  '$u20$': ' ', '$u7b$': '{', '$u7d$': '}', }
" }}}

" Markdown, Pandoc, Tex {{{
let g:tex_flavor = "latex"
let g:tex_noindent_env = '\v\w+.?'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_folding_level = 6
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_frontmatter = 1

function! s:NotCodeBlock(lnum) abort
    return !InSynStack('^mkd\%(Code\|Snippet\)', synstack(a:lnum, 1))
endfunction

function! MyMarkdownFoldExpr() abort
    let line = getline(v:lnum)
    let hashes = matchstr(line, '^\s\{,3}\zs#\+')
    if !empty(hashes) && s:NotCodeBlock(v:lnum)
        return ">" . len(hashes)
    endif
    let nextline = getline(v:lnum + 1)
    if (line =~ '^.\+$') && (nextline =~ '^=\+$') && s:NotCodeBlock(v:lnum + 1)
        return ">1"
    endif
    if (line =~ '^.\+$') && (nextline =~ '^-\+$') && s:NotCodeBlock(v:lnum + 1)
        return ">2"
    endif
    return "="
endfunction

function! MyMarkdownFoldText()
    let line = getline(v:foldstart)
    let has_numbers = &number || &relativenumber
    let nucolwidth = &fdc + has_numbers * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 6
    let foldedlinecount = v:foldend - v:foldstart
    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let line = substitute(line, '\%("""\|''''''\)', '', '')
    let fillcharcount = windowwidth - strdisplaywidth(line) - len(foldedlinecount) + 1
    return line . ' ' . repeat("-", fillcharcount) . ' ' . foldedlinecount
endfunction
augroup MarkdownFold | au!
    au FileType markdown 
                \ setlocal foldexpr=MyMarkdownFoldExpr() |
                \ setlocal foldmethod=expr |
                \ setlocal foldtext=MyMarkdownFoldText()
" }}}
" }}}

" search & fzf {{{
nnoremap <silent>* :call Star(0)\|set hlsearch<CR>
nnoremap <silent>g* :call Star(1)\|set hlsearch<CR>
vnoremap <silent>* :<C-u>call VisualStar(0)\|set hlsearch<CR>
vnoremap <silent>g* :<C-u>call VisualStar(1)\|set hlsearch<CR>
func! Star(g)
    let @c = expand('<cword>')
    " <cword> can be non-keyword
    if match(@c, '\k') == -1
        let g:search_mode = 'v'
        let @/ = escape(@c, '\.*$^~[]')
    else
        let g:search_mode = 'n'
        let @/ = a:g ? @c : '\<' . @c . '\>'
    endif
endfunc
func! VisualStar(g)
    let g:search_mode = 'v'
    let l:reg_save = @"
    " don't trigger TextYankPost
    noau exec "norm! gvy"
    let @c = @"
    let l:pattern = escape(@", '\.*$^~[]')
    let @/ = a:g ? '\<' . l:pattern . '\>' : l:pattern " reversed
    let @" = l:reg_save
endfunc
nnoremap / :let g:search_mode='/'<CR>/

nnoremap <C-g>      :<C-u>Grep<space>
nnoremap <leader>g/ :<C-u>Grep <C-r>=RgInput(@/)<CR>
nnoremap <leader>gw :<C-u>Grep \b<C-R>=expand('<cword>')<CR>\b
nnoremap <leader>b  :<C-u>Buffers<CR>
nnoremap <C-f>      :<C-u>Files<CR>
nnoremap <leader>hh :<C-u>History<CR>
nnoremap <leader><C-t> :Tags ^<C-r><C-w>\  <CR>

augroup fzf | au!
    if has('nvim')
        " `au TermOpen tnoremap` and `au FileType fzf tunmap` breaks coc-fzf
        tnoremap <expr> <Esc> (&filetype == 'fzf') ? '<Esc>' : '<c-\><c-n>'
        tnoremap <expr> <C-q> (&filetype == 'fzf') ? '<C-q>' : '<c-\><c-n>'
    else
        tnoremap <C-q> <Esc>
    endif
augroup END

command! -nargs=* -bang Grep call Grep(<q-args>)
command! -bang -nargs=? -complete=dir Files call Files(<q-args>)
" allow search on the full tag info, excluding the appended tagfile name
command! -bang -nargs=* Tags call fzf#vim#tags(<q-args>, { 'options': ['-d', '\t', '--nth', '..-2'] })

func! FzfOpts(arg, spec)
    let l:opts = string(a:arg)
    if l:opts =~ '2'
        let l:preview_window = 'up'
    else
        let l:preview_window = IsVimWide() ? 'right' : 'up'
    endif
    if l:opts =~ '3'
        let a:spec['dir'] = asyncrun#get_root("%")
    endif
    return fzf#vim#with_preview(a:spec, l:preview_window)
endfunc
func! RgInput(raw)
    if g:search_mode == 'n'
        return substitute(a:raw, '\v\\[<>]','','g')
    elseif g:search_mode == 'v'
        return escape(a:raw, '+|?-(){}') " not escaped by VisualStar
    else " can convert most of strict very magic to riggrep regex, otherwise, DIY
        if a:raw[0:1] != '\v'
            return substitute(a:raw, '\v\\[<>]','','g')
        endif
        return substitute(a:raw[2:], '\v\\([~/])', '\1', 'g')
    endif
endfunc
func! Grep(query)
    " let cmd = 'git grep --color --line-number -- ' . shellescape(a:query)
    let cmd = 'egrep --color=always --exclude-dir=.git -nrI ' . shellescape(a:query)
    let spec = FzfOpts(v:count, {'options': ['--info=inline']})
    call fzf#vim#grep(cmd, 0, spec)
endfunc
func! Files(query)
    let spec = FzfOpts(v:count, {})
    if empty(a:query) && !empty(get(spec, 'dir', ''))
        let l:query = spec['dir']
        unlet spec['dir']
        let spec['options'] = ['--prompt', fnamemodify(l:query, ':~:.') . '/']
    else
        let l:query = a:query
    endif
    call fzf#vim#files(l:query, fzf#vim#with_preview(spec, 'right'))
endfunc

" }}}

" Motion, insert mode, ... {{{
nnoremap <expr> j                     v:count ? 'j' : 'gj'
nnoremap <expr> k                     v:count ? 'k' : 'gk'
nnoremap <expr> J                     v:count ? 'j' : 'gj'
nnoremap <expr> K                     v:count ? 'k' : 'gk'
vnoremap <expr> j mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
vnoremap <expr> k mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
onoremap <expr> j mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
onoremap <expr> k mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
vnoremap <expr> J mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
vnoremap <expr> K mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
onoremap <expr> J mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
onoremap <expr> K mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
noremap <leader>J J
noremap <expr> H v:count ? 'H' : 'h'
noremap <expr> L v:count ? 'L' : 'l'

nnoremap <space> <C-d>
nnoremap <c-space> <C-u>

noremap <M-0> ^w

let g:sneak#s_next = 1
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
hi! Sneak guifg=black guibg=#afff00 gui=bold ctermfg=black ctermbg=154 cterm=bold

inoremap <C-w> <C-\><C-o><ESC><C-w>
inoremap <C-u> <C-\><C-o><ESC><C-g>u<C-u>
" }}}

" etc mappings {{{
map <silent><leader><CR> :noh<CR>
map <leader>ss :setlocal spell!\|setlocal spell?<cr>
map <leader>sc :if &spc == "" \| setl spc< \| else \| setl spc= \| endif \| setl spc?<CR>
map <leader>sp :setlocal paste!\|setlocal paste?<cr>
map <leader>sw :set wrap!\|set wrap?<CR>
map <leader>ic :set ignorecase! smartcase!\|set ignorecase?<CR>
map <leader>sf :syn sync fromstart<CR>

map <leader>dp :diffput<CR>
map <leader>do :diffget<CR>

" clipboard.
inoremap <C-v> <C-g>u<C-\><C-o>:set paste<CR><C-r>+<C-\><C-o>:set nopaste<CR>
vnoremap <C-c> "+y

" buf/filename
noremap <leader>fn 2<C-g>

noremap <F1> <Esc>
inoremap <F1> <Esc>
nmap     <C-q> <Esc>
cnoremap <C-q> <C-c>
inoremap <C-q> <Esc>
vnoremap <C-q> <Esc>
onoremap <C-q> <Esc>
noremap! <C-M-q> <C-q>

cnoremap <M-p> <Up>
cnoremap <M-n> <Down>

" c_CTRL-F: editable cmd/search history, gQ: enter ex mode, Q instead of q for macros
noremap q: :
noremap q <nop>
noremap Q q

" delete without clearing regs
noremap x "_x

" repetitive pastes using designated register @p
noremap <M-y> "py
noremap <M-p> "pp
noremap <M-P> "pP

nnoremap Y y$
onoremap <silent> ge :execute "normal! " . v:count1 . "ge<space>"<cr>
nnoremap <silent> & :&&<cr>
xnoremap <silent> & :&&<cr>

noremap + <C-a>
vnoremap + g<C-a>
noremap - <C-x>
vnoremap - g<C-x>

" <C-b> <C-e>
cnoremap <C-j> <S-Right>
cnoremap <C-k> <S-Left>

nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

noremap <leader>q :<C-u>q<CR>
noremap q, :<C-u>q<CR>
nnoremap <leader>w :<C-u>up<CR>
noremap ZAQ :<C-u>qa!<CR>
command! -bang W   w<bang>
command! -bang Q   q<bang>

nmap <leader>cx :tabclose<cr>
nmap <leader>td :tab split<CR>
nmap <leader>tt :tabedit<CR>
nmap <leader>cd :cd <c-r>=expand("%:p:h")<cr>/
nmap <leader>e  :e! <c-r>=expand("%:p:h")<cr>/
nmap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
nmap <leader>fe :e!<CR>
" }}}

" etc plugin settings {{{
" pairs {{{
let g:pear_tree_map_special_keys = 0
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_backspace = 1
let g:pear_tree_timeout = 23
let g:pear_tree_repeatable_expand = 0
" assumes nosmartindent
imap <expr> <CR> match(getline('.'), '\w') >= 0 ? "\<C-G>u\<Plug>(PearTreeExpand)" : "\<Plug>(PearTreeExpand)"
imap <BS> <Plug>(PearTreeBackspace)

" 'a'ny block from matchup
xmap aa a%
omap aa a%
xmap ia i%
omap ia i%

augroup MyTargets | au!
    " - a'r'guments, any 'q'uote, any 'b'lock, separators + 'n'ext,'l'ast
    " - Leave a for matchup any-block.
    autocmd User targets#mappings#user call targets#mappings#extend({
    \ '(': {},
    \ ')': {},
    \ '{': {},
    \ '}': {},
    \ 'B': {},
    \ '[': {},
    \ ']': {},
    \ '<': {},
    \ '>': {},
    \ '"': {},
    \ "'": {},
    \ '`': {},
    \ 't': {},
    \ 'a': {},
    \ 'r': {'argument': [{'o': '[([]', 'c': '[])]', 's': ','}]},
    \ })
augroup END
" }}}

" asyncrun
map <leader>R :AsyncRun<space>
map <leader>S :AsyncStop<CR>
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
map <leader>M :Make<space>

" quickfix, loclist, ... {{{
let g:qf_window_bottom = 0
let g:qf_loclist_window_bottom = 0
let g:qf_auto_open_quickfix = 0
let g:qf_auto_open_loclist = 0
let g:qf_auto_resize = 0
let g:qf_max_height = 12
let g:qf_auto_quit = 0

command! -bar CW
            \ if IsWinWide() |
            \   exec 'vert copen' min([&columns-112,&columns/2]) | setlocal nowrap | winc p |
            \ else |
            \   belowright copen 12 | winc p |
            \ endif
command! -bar LW
            \ if IsWinWide() |
            \   exec 'vert lopen' min([&columns-112,&columns/2]) | setlocal nowrap | winc p |
            \ else |
            \   belowright lopen 12 | winc p |
            \ endif
nmap <silent><leader>cw :CW<CR>
nmap <silent><leader>lw :LW<CR>
nmap <silent><leader>x  :pc\|ccl\|lcl<CR>
nmap <silent>]q <Plug>(qf_qf_next)
nmap <silent>[q <Plug>(qf_qf_previous)
nmap <silent>]l <Plug>(qf_loc_next)
nmap <silent>[l <Plug>(qf_loc_previous)
" }}}

" Explorers {{{
let g:loaded_netrwPlugin = 1
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(expand((exists("g:netrw_gx")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())<cr>
vnoremap <silent> <Plug>NetrwBrowseXVis :<c-u>call netrw#BrowseXVis()<cr>
nmap gx <Plug>NetrwBrowseX
vmap gx <Plug>NetrwBrowseXVis

let NERDTreeHijackNetrw = 0
let g:NERDTreeIgnore=['\~$', '\.glob$', '\v\.vo[sk]?$', '\.v\.d$', '\.o$']
let g:NERDTreeStatusline = -1
nmap <silent><leader>nn :NERDTreeToggle<cr>
nmap <silent><leader>nf :NERDTreeFind<cr>

command! -nargs=? -complete=dir Sexplore split | silent Dirvish <args>
command! -nargs=? -complete=dir Vexplore vsplit | silent Dirvish <args>
nmap <silent><C-w>es :Sexplore %<CR>
nmap <silent><C-w>ev :Vexplore %<CR>
nmap <leader>D <Plug>(dirvish_up)
hi! link DirvishSuffix Special
" }}}

let g:EditorConfig_exclude_patterns = ['.*[.]git/.*', 'fugitive://.*', 'scp://.*']

" textobj
let s:url_regex = '\c\<\(\%([a-z][0-9A-Za-z_-]\+:\%(\/\{1,3}\|[a-z0-9%]\)\|www\d\{0,3}[.]\|[a-z0-9.\-]\+[.][a-z]\{2,4}\/\)\%([^ \t()<>]\+\|(\([^ \t()<>]\+\|\(([^ \t()<>]\+)\)\)*)\)\+\%((\([^ \t()<>]\+\|\(([^ \t()<>]\+)\)\)*)\|[^ \t`!()[\]{};:'."'".'".,<>?«»“”‘’]\)\)'
call textobj#user#plugin('url', { 'url': { 'pattern': s:url_regex, 'select': ['au', 'iu'] } })
call textobj#user#plugin('path', { 'path': { 'pattern': '\f\+', 'select': ['aP', 'iP'] } })

" comments
let g:NERDCreateDefaultMappings = 0
imap <M-/> <Plug>NERDCommenterInsert
imap <M-/> <C-G>u<Plug>NERDCommenterInsert
map <M-/> <Plug>NERDCommenterComment
xmap <leader>c<Space> <Plug>NERDCommenterToggle
nmap <leader>c<Space> <Plug>NERDCommenterToggle
xmap <leader>cs <Plug>NERDCommenterSexy
nmap <leader>cs <Plug>NERDCommenterSexy
xmap <leader>cm <Plug>NERDCommenterMinimal
nmap <leader>cm <Plug>NERDCommenterMinimal
let g:NERDSpaceDelims = 1
let g:NERDCustomDelimiters = {
            \ 'python' : { 'left': '#', 'leftAlt': '#' },
            \ 'c': { 'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' },
            \ 'coq': { 'left': '(*', 'right': '*)', 'nested': 1 },
            \}
let g:NERDDefaultAlign = 'left'

" undotree
let g:undotree_WindowLayout = 4
nnoremap U :UndotreeToggle<CR>
" }}}

" etc util {{{
func! InSynStack(pat, ...)
    let synstack = a:0 ? a:1 : synstack(line('.'), col('.'))
    for i in synstack
        if synIDattr(i, 'name') =~# a:pat
            return 1
        endif
    endfor
    return 0
endfunc
func! IsWinWide()
    return winwidth(0) > 170
endfunc
func! IsVimWide()
    return &columns > 170
endfunc

func! Execute(cmd) abort
    let output = execute(a:cmd)
    tabnew
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
endfunc
command! -nargs=* -complete=command Execute silent call Execute(<q-args>)

" :substitute using a dict, where key == submatch (like VisualStar)
function! SubstituteDict(dict) range
    exe a:firstline . ',' . a:lastline . 'substitute'
                \ . '/\C\%(' . join(map(keys(a:dict), 'escape(v:val, ''\.*$^~[]'')'), '\|'). '\)'
                \ . '/\=' . string(a:dict) . '[submatch(0)]/ge'
endfunction
command! -range=% -nargs=1 SubstituteDict :<line1>,<line2>call SubstituteDict(<args>)
" }}}

" git status line {{{
function! s:Slash(path) abort
  if exists('+shellslash')
    return tr(a:path, '\', '/')
  else
    return a:path
  endif
endfunction

function! s:DirCommitFile(path) abort
  let vals = matchlist(s:Slash(a:path), '\c^fugitive:\%(//\)\=\(.\{-\}\)\%(//\|::\)\(\x\{40,\}\|[0-3]\)\(/.*\)\=$')
  if empty(vals)
    return ['', '', '']
  endif
  return vals[1:3]
endfunction

function! GitStatusline() abort
  let dir = FugitiveGitDir(bufnr(''))
  if empty(dir)
    return ''
  endif
  let status = ''
  let commit = s:DirCommitFile(@%)[1]
  let status .= FugitiveHead(7, dir)
  if len(commit)
    let status .= ':' . commit[0:6]
  endif
  return '['.status.']'
endfunction
" }}}

" vim: set foldmethod=marker foldlevel=0 nomodeline:
