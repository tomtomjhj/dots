" vim: set foldmethod=marker foldlevel=0:
" https://github.com/junegunn/vim-plug#vim
" Plugins {{{
let mapleader = ","
call plug#begin('~/.vim/plugged')

" Theme {{{
Plug 'itchyny/lightline.vim'
Plug 'tomtomjhj/zenbruh.vim'
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['git', 'readonly', 'shortrelpath', 'modified'] ],
      \   'right': [ ['lineinfo'], ['percent'], ['asyncrun'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'shortrelpath': '%{pathshorten(fnamemodify(expand("%"), ":~:."))}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'git': '%{GitStatusline()}',
      \   'asyncrun': '%{g:asyncrun_status}',
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }
" }}}

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'

Plug 'justinmk/vim-sneak'
let g:sneak#s_next = 1
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" comment {{{
Plug 'preservim/nerdcommenter', { 'on': ['<plug>NERDCommenterComment', '<plug>NERDCommenterToggle', '<plug>NERDCommenterInsert', '<plug>NERDCommenterSexy'] }
let g:NERDCreateDefaultMappings = 0
imap <M-/> <Plug>NERDCommenterInsert
map <M-/> <Plug>NERDCommenterComment
xmap ,c<Space> <Plug>NERDCommenterToggle
nmap ,c<Space> <Plug>NERDCommenterToggle
xmap ,cs <Plug>NERDCommenterSexy
nmap ,cs <Plug>NERDCommenterSexy
let g:NERDSpaceDelims = 1
let g:NERDCustomDelimiters = {
            \ 'python' : { 'left': '#', 'leftAlt': '#' },
            \ 'c': { 'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' },
            \}
let g:NERDDefaultAlign = 'both'
" }}}

Plug 'skywind3000/asyncrun.vim'
map <leader>R :AsyncRun<space>
map <leader>S :AsyncStop<CR>
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
map <leader>M :Make<space>

Plug 'Konfekt/FastFold'

" quickfix, loclist, ... {{{
Plug 'romainl/vim-qf'
let g:qf_window_bottom = 0
let g:qf_loclist_window_bottom = 0
let g:qf_auto_open_quickfix = 0
let g:qf_auto_open_loclist = 0
let g:qf_auto_resize = 0
let g:qf_max_height = 12
let g:qf_auto_quit = 0

command! CW 
            \ if IsWinWide() |
            \   exec 'vert copen' min([&columns-112,&columns/2]) | setlocal nowrap | winc p |
            \ else |
            \   belowright copen 12 | winc p |
            \ endif
command! LW
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

Plug 'lifepillar/vim-mucomplete'
set completeopt+=menuone,noselect
set belloff+=ctrlg
let g:mucomplete#always_use_completeopt = 1

Plug 'tomtomjhj/auto-pairs'
let g:AutoPairsMapSpace = 0
let g:AutoPairsCenterLine = 0
let g:AutoPairsMapCh = 0
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutJump = ''
augroup SetAutoPairs
    au FileType lisp if !exists('b:AutoPairs') | let b:AutoPairs = AutoPairsDefine({}, ["'"]) | endif
    au FileType pandoc if !exists('b:AutoPairs') | let b:AutoPairs = AutoPairsDefine({'$':'$', '$$':'$$'}) | endif
    au FileType ocaml if !exists('b:AutoPairs') | let b:AutoPairs = AutoPairsDefine({}, ["'"]) | endif
    au FileType rust if !exists('b:AutoPairs') | let b:AutoPairs = AutoPairsDefine({'|': '|'}, ["'"]) | endif
augroup END

Plug 'ctrlpvim/ctrlp.vim'
noremap  <leader>b  :<C-u>CtrlPBuffer<CR>
noremap  <C-f>      :<C-u>CtrlP<CR>
noremap  <leader>hh :<C-u>CtrlPMRU<CR>

Plug 'tomtomjhj/vim-markdown'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_frontmatter = 1
let g:pandoc#filetypes#pandoc_markdown = 0
Plug 'vim-pandoc/vim-pandoc' |  Plug 'tomtomjhj/vim-pandoc-syntax'
let g:tex_flavor = "latex"
let g:tex_noindent_env = '\v\w+.?'
let g:pandoc#syntax#codeblocks#embeds#langs = ["python", "cpp", "rust"]
let g:pandoc#modules#enabled = ["formatting", "hypertext"]
let g:pandoc#folding#level = 99
let g:pandoc#hypertext#use_default_mappings = 0
let g:pandoc#syntax#use_definition_lists = 0
let g:pandoc#syntax#protect#codeblocks = 0

" Plug 'rust-lang/rust.vim' | Plug 'tomtomjhj/vim-rust-syntax-ext'
" Plug 'tomtomjhj/vim-ocaml'
call plug#end()
" }}}

" settings {{{
if !exists('g:colors_name') " run only once at the start up
    colorscheme zenbruh
    if has("gui_running")
        set guioptions=i
        if has("gui_win32")
            set guifont=Consolas:h10:cANSI
        elseif has("gui_gtk2")
        elseif has("x11")
        endif
    else
        " TODO: no sane solution for <M- maps?
    endif
endif
hi! Sneak guifg=black guibg=#afff00 gui=bold ctermfg=black ctermbg=154 cterm=bold

set mouse=a
set number ruler cursorline
set foldcolumn=1 foldnestmax=5
set scrolloff=2
set showtabline=1
set laststatus=2

set tabstop=4 shiftwidth=4
set expandtab smarttab
set autoindent smartindent

" indent the wrapped line, w/ `> ` at the start
set wrap linebreak breakindent showbreak=>\ 
set backspace=eol,start,indent
set whichwrap+=<,>,[,],h,l

set timeoutlen=432
set updatetime=1234

let $LANG='en'
set langmenu=en
set encoding=utf8

set wildmenu wildmode=longest:full,full
set wildignore=*.o,*~,*.pyc,*.pdf,*.v.d,*.vo,*.glob
set wildignore+=*/target/*,*/build/*,*/node_modules/*,*/dist/*
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

set magic
set ignorecase smartcase
set hlsearch incsearch

set noerrorbells novisualbell t_vb=
set shortmess+=c

set nobackup nowritebackup noswapfile
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", "", 0700)
endi
set undofile undodir=~/.vim/undodir
set history=500

set autoread
set splitright splitbelow
set switchbuf=useopen,usetab
set hidden
set lazyredraw

set modeline
set exrc secure

let &pumheight = min([&window/4, 20])
augroup BasicSetup | au!
    " Return to last edit position when opening files
    au BufWinEnter * if line("'\"") > 1 && line("'\"") <= line("$") | exec "norm! g'\"" | endif
    au BufWritePost ~/.vimrc source ~/.vimrc
    au FileType help nnoremap <silent><buffer> <M-.> :h <C-r><C-w><CR>
    au VimResized * let &pumheight = min([&window/4, 20])
augroup END
" }}}

" Search {{{
nnoremap <silent>* :call Star(0)\|set hlsearch<CR>
nnoremap <silent>g* :call Star(1)\|set hlsearch<CR>
vnoremap <silent>* :<C-u>call VisualStar(0)\|set hlsearch<CR>
vnoremap <silent>g* :<C-u>call VisualStar(1)\|set hlsearch<CR>
func! Star(g)
    let g:search_mode = 'n'
    let @c = expand('<cword>')
    let @/ = a:g ? @c : '\<' . @c . '\>'
endfunc
func! VisualStar(g)
    let g:search_mode = 'v'
    let l:reg_save = @"
    exec "norm! gvy"
    let @c = @"
    let l:pattern = escape(@", '\.*$^~[]')
    let @/ = a:g ? '\<' . l:pattern . '\>' : l:pattern " reversed
    let @" = l:reg_save
endfunc
nnoremap / :let g:search_mode='/'<CR>/

nnoremap <C-g>      :vimgrep //j **<left><left><left><left><left>
nnoremap <leader>g/ :vimgrep /<C-r>//j **<CR>
nnoremap <leader>gw :vimgrep /\<<C-r><C-w>\>/j **
" }}}

" insert mode hack {{{
let g:sword = '\v(\k+|([^[:alnum:]_[:blank:](){}[\]<>$])\2*|[(){}[\]<>$]|\s+)'
inoremap <silent><C-j> <C-\><C-O>:call SwordJumpRight()<CR><Right><C-\><C-o><ESC>
inoremap <silent><C-k> <C-\><C-O>:call SwordJumpLeft()<CR>
func! SwordJumpRight()
    if col('.') !=  col('$')
        call search(g:sword, 'ceW')
    endif
endfunc
func! SwordJumpLeft()
    call search(col('.') != 1 ? g:sword : '\v$', 'bW')
endfunc

inoremap <CR> <C-G>u<CR>
inoremap <C-u> <C-\><C-o><ESC><C-g>u<C-u>
inoremap <silent><expr><C-w> FineGrainedICtrlW()
func! FineGrainedICtrlW()
    let l:col = col('.')
    if l:col == 1 | return "\<BS>" | endif
    let l:before = strpart(getline('.'), 0, l:col - 1)
    let l:chars = split(l:before, '.\zs')
    if l:chars[-1] =~ '\s'
        let l:len = len(l:chars)
        let l:idx = 1
        while l:idx < l:len && l:chars[-(l:idx + 1)] =~ '\s'
            let l:idx += 1
        endwhile
        if l:idx == l:len || l:chars[-(l:idx + 1)] =~ '\k'
            return "\<C-\>\<C-o>\<ESC>\<C-w>"
        endif
        let l:sts = &softtabstop
        setlocal softtabstop=0
        return repeat("\<BS>", l:idx) . "\<C-R>=execute('setl sts=".l:sts."')\<CR>\<BS>"
    elseif l:chars[-1] !~ '\k'
        return "\<BS>"
    else
        return "\<C-\>\<C-o>\<ESC>\<C-w>"
    endif
endfunc
" }}}

" fix bad defaults {{{
noremap j gj
noremap k gk
noremap <S-j> gj
noremap <S-k> gk
noremap <S-h> h
noremap <S-l> l
noremap <leader>J J
" c_CTRL-F: editable cmd/search history, gQ: enter ex mode, Q instead of q for macros
noremap q: :
noremap q <nop>
noremap Q q
noremap x "_x
nnoremap Y y$
onoremap <silent> ge :execute "normal! " . v:count1 . "ge<space>"<cr>
nnoremap <silent> & :&&<cr>
xnoremap <silent> & :&&<cr>
noremap <F1> <Esc>
inoremap <F1> <Esc>
" }}}

" alias {{{
noremap  <M-.> K
noremap  <M-]> <C-]>
nnoremap <M-o> <C-o>
nnoremap <M-i> <C-i>
nnoremap <space> <C-d>
nnoremap <c-space> <C-u>
noremap! <C-q> <C-c>
vnoremap <C-q> <Esc>
cnoremap <M-p> <Up>
cnoremap <M-n> <Down>
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <leader>q :<C-u>q<CR>
nnoremap q, :<C-u>q<CR>
nnoremap <leader>w :<C-u>w!<cr>
command! -bang W   exec 'w<bang>'
command! -bang Q   exec 'q<bang>'
command! -bang Wq  exec 'wq<bang>'
command! -bang Wqa exec 'wqa<bang>'
command! -bang Qa  exec 'qa<bang>'
" }}}

" shortcuts {{{
nnoremap <silent><leader><CR> :noh<CR>
nnoremap <leader>ss :setlocal spell!\|setlocal spell?<cr>
nnoremap <leader>sc :if &spc == "" \| setl spc< \| else \| setl spc= \| endif \| setl spc?<CR>
nnoremap <leader>pp :setlocal paste!\|setlocal paste?<cr>
nnoremap <leader>sw :set wrap!\|set wrap?<CR>
nnoremap <leader>ic :set ignorecase! smartcase!\|set ignorecase?<CR>
nnoremap <leader>sf :syn sync fromstart<CR>
nnoremap <leader>cx :tabclose<cr>
nnoremap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>td :tab split<CR>
nnoremap <leader>tt :tabedit<CR>
nnoremap <leader>cd :cd %:p:h<cr>:pwd<cr>
nnoremap <leader>e :e! <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>fe :e!<CR>
nnoremap <leader>fm :let _p=getpos(".") <Bar> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <Bar> call setpos('.', _p) <Bar> :unlet _p <CR>
noremap  <leader>dp :diffput<CR>
noremap  <leader>do :diffget<CR>
noremap  <leader>fn 2<C-g>
inoremap <C-v> <C-\><C-o>:setl paste<CR><C-r>+<C-\><C-o>:setl nopaste<CR>
vnoremap <C-c> "+y
noremap <M-y> "py
noremap <M-p> "pp
" }}}

" etc {{{
func! IsWinWide()
    return winwidth(0) > 170
endfunc
" garbage buf {{{
let g:lasthidden = 0
augroup GarbageBuf | au!
    au BufHidden * let g:lasthidden = expand("<abuf>")
    au BufEnter * call CheckAndBW(g:lasthidden)
augroup END
func! CheckAndBW(buf)
    if IsCleanEmptyBuf(a:buf)
        exec "bw" a:buf
    endif
endfunc
func! IsCleanEmptyBuf(buf)
    return a:buf > 0 && buflisted(+a:buf) && empty(bufname(+a:buf)) && !getbufvar(+a:buf, "&mod")
endfunc
" }}}

" Bclose {{{
" Delete buffer while keeping window layout (don't close buffer's windows).
" Version 2008-11-18 from http://vim.wikia.com/wiki/VimTip165
if !exists('bclose_multiple')
  let bclose_multiple = 1
endif
" Display an error message.
function! s:Warn(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
endfunction

" Command ':Bclose' executes ':bd' to delete buffer in current window.
" The window will show the alternate buffer (Ctrl-^) if it exists,
" or the previous buffer (:bp), or a blank buffer if no previous.
" Command ':Bclose!' is the same, but executes ':bd!' (discard changes).
" An optional argument can specify which buffer to close (name or number).
function! s:Bclose(bang, buffer)
  if empty(a:buffer)
    let btarget = bufnr('%')
  elseif a:buffer =~ '^\d\+$'
    let btarget = bufnr(str2nr(a:buffer))
  else
    let btarget = bufnr(a:buffer)
  endif
  if btarget < 0
    call s:Warn('No matching buffer for '.a:buffer)
    return
  endif
  if empty(a:bang) && getbufvar(btarget, '&modified')
    call s:Warn('No write since last change for buffer '.btarget.' (use :Bclose!)')
    return
  endif
  " Numbers of windows that view target buffer which we will delete.
  let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
  if !g:bclose_multiple && len(wnums) > 1
    call s:Warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
    return
  endif
  let wcurrent = winnr()
  for w in wnums
    execute w.'wincmd w'
    let prevbuf = bufnr('#')
    if prevbuf > 0 && buflisted(prevbuf) && prevbuf != btarget
      buffer #
    else
      bprevious
    endif
    if btarget == bufnr('%')
      " Numbers of listed buffers which are not the target to be deleted.
      let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
      " Listed, not target, and not displayed.
      let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
      " Take the first buffer, if any (could be more intelligent).
      let bjump = (bhidden + blisted + [-1])[0]
      if bjump > 0
        execute 'buffer '.bjump
      else
        execute 'enew'.a:bang
      endif
    endif
  endfor
  execute 'bdelete'.a:bang.' '.btarget
  execute wcurrent.'wincmd w'
endfunction
command! -bang -complete=buffer -nargs=? Bclose call <SID>Bclose(<q-bang>, <q-args>)
nnoremap <silent> <Leader>cb :Bclose<CR>
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
" }}}
