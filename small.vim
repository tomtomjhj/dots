set nocompatible

" stuff from sensible that are not in my settings {{{
" https://github.com/tpope/vim-sensible/blob/2d9f34c09f548ed4df213389caa2882bfe56db58/plugin/sensible.vim
filetype plugin indent on
if !exists('g:syntax_on')
  syntax enable
endif
set complete-=i
set nrformats-=octal
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif
set display+=lastline
if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/usr/bin/env\ bash
endif
set history=1000
set tabpagemax=50
set sessionoptions-=options
set viewoptions-=options
" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
endif
" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif
" }}}

" settings {{{
set mouse=a
set number ruler
set foldcolumn=1 foldnestmax=5
set scrolloff=2 sidescrolloff=2
set showtabline=1
set laststatus=2

set shiftwidth=4
set expandtab smarttab
set autoindent
set formatoptions+=jn
set formatlistpat=\\C^\\s*[\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|^\\s*[-+o*]\\s\\+
set nojoinspaces
set list listchars=tab:\|\ ,trail:-,nbsp:+,extends:>

set wrap linebreak breakindent showbreak=>\ 
let &backspace = (has('patch-8.2.0590') || has('nvim-0.5')) ? 3 : 2
set whichwrap+=<,>,[,],h,l

let mapleader = ","
noremap <M-;> ,

let $LANG='en'
set langmenu=en
set encoding=utf-8
set spelllang=en,cjk

set wildmenu wildmode=longest:full,full
set wildignore=*.o,*~,*.pyc,*.pdf,*.v.d,*.vo,*.vos,*.vok,*.glob,*.aux
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store,*/__pycache__/

set ignorecase smartcase
set hlsearch incsearch

set noerrorbells novisualbell t_vb=
set shortmess+=Ic
set belloff=all

set viminfo=!,'150,<50,s30,h
set updatetime=1234
set backup undofile noswapfile
if has('nvim')
    let s:backupdir = stdpath('data') . '/backup'
    let s:undodir = stdpath("data") . '/undo'
else
    let s:backupdir = $HOME . '/.vim/backup'
    let s:undodir = $HOME . '/.vim/undo'
endif
if !isdirectory(s:backupdir) || !isdirectory(s:backupdir)
    call mkdir(s:backupdir, "p", 0700)
    call mkdir(s:undodir, "p", 0700)
endif
let &backupdir = s:backupdir . '//'
let &undodir = s:undodir . '//'
unlet s:backupdir s:undodir

set autoread
set splitright splitbelow
set switchbuf=useopen,usetab
set hidden
set lazyredraw

set modeline " debian unsets this
set exrc secure

augroup BasicSetup | au!
    au BufRead * if empty(&buftype) && &filetype !~# '\v%(commit)' && line("'\"") > 1 && line("'\"") <= line("$") | exec "norm! g`\"" | endif
    if exists(':clearjumps')
        au VimEnter * exec 'tabdo windo clearjumps' | tabnext
    endif
    let &pumheight = min([&window/4, 20])
    au VimResized * let &pumheight = min([&window/4, 20])
    if has('nvim')
        au TermOpen * setlocal nonumber norelativenumber foldcolumn=0
    endif
    if has('nvim-0.5')
        au TextYankPost * silent! lua vim.highlight.on_yank()
    endif
augroup END
" }}}

" fix terminal/gui problems {{{
if has('gui_running')
    set guioptions=i
elseif !has('nvim') " terminal vim
    silent! !stty -ixon > /dev/null 2>/dev/null
    set ttymouse=sgr
    " fix <M- mappings {{{
    " NOTE: this should be run after set encoding=utf-8
    for c in ['+', '-', '0', ';', 'P', 'n', 'p', 'q', 'y']
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
        if exists('#CmdlineEnter')
            au CmdlineEnter * set timeoutlen=23
            au CmdlineLeave * set timeoutlen=432
        endif
    augroup END
    " }}}
endif
" }}}

" statusline {{{
let s:mode_map = {'n' : 'N ', 'i' : 'I ', 'R' : 'R ', 'v' : 'V ', 'V' : 'VL', "\<C-v>": 'VB', 'c' : 'C ', 's' : 'S ', 'S' : 'SL', "\<C-s>": 'SB', 't': 'T '}
function! StatuslineMode()
    return s:mode_map[mode()]
endfunction

func! ShortRelPath()
    let name = expand('%')
    if empty(name)
        return empty(&buftype) ? '[No Name]' : ''
    elseif isdirectory(name)
        return pathshorten(fnamemodify(name[:-2], ":~")) . '/'
    endif
    return pathshorten(fnamemodify(name, ":~:."))
endfunc

function! UpdateGitStatus()
  if &modifiable && empty(&buftype)
      let rev_parse = system('git -C '.expand('%:p:h').' rev-parse --abbrev-ref HEAD')
      if !v:shell_error
          let b:git_status =' ['.substitute(l:rev_parse, '\n', '', 'g').']'
      endif
  endif
endfunction

augroup Statusine | au!
    au VimEnter,WinEnter,BufEnter * call UpdateGitStatus()
augroup END

set statusline=
set statusline+=\ %{StatuslineMode()}\ 
set statusline+=%#TabLine#
set statusline+=\ %{ShortRelPath()}\ 
set statusline+=%#TabLineFill#
set statusline+=%{get(b:,'git_status','')}
set statusline+=%m%r%w
set statusline+=%=
set statusline+=%#TabLineFill#
set statusline+=\ %3p%%\ 
set statusline+=%#TabLine#
set statusline+=\ %3l:%-2c
set statusline+=\ 
" }}}

" excerpt from configs.vim with some modifications {{{
nnoremap <silent>* :call Star(0)\|set hlsearch<CR>
nnoremap <silent>g* :call Star(1)\|set hlsearch<CR>
vnoremap <silent>* :<C-u>call VisualStar(0)\|set hlsearch<CR>
vnoremap <silent>g* :<C-u>call VisualStar(1)\|set hlsearch<CR>
func! Star(g)
    let @c = expand('<cword>')
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
    noau exec "norm! gvy"
    let @c = @"
    let l:pattern = escape(@", '\.*$^~[]')
    let @/ = a:g ? '\<' . l:pattern . '\>' : l:pattern " reversed
    let @" = l:reg_save
endfunc
nnoremap / :let g:search_mode='/'<CR>/

" NOTE: --others doesn't enumerate the individual files
let $GIT_FILES_CMD = 'git ls-files --exclude-standard -co'
function! GrepFiles()
    call system('git rev-parse --is-inside-work-tree')
    " NOTE: non-atomic chars like "\<C-Left>" can't be used with <C-r>
    if v:shell_error == 0 && v:count
        return "`$GIT_FILES_CMD`"
    else
        return "**"
    endif
endfunction
" NOTE: :bufdo vimgrepadd
nnoremap <C-g>      :<C-u>copen\|vimgrep //j <C-r>=GrepFiles()<CR><C-Left><C-Left><Right>
nnoremap <leader>g/ :<C-u>copen\|vimgrep /<C-r>//j <C-r>=GrepFiles()<CR>
nnoremap <leader>gw :<C-u>copen\|vimgrep /\<<C-r><C-w>\>/j <C-r>=GrepFiles()<CR>
" TODO: something similar for <C-f> like :browse `$GIT_FILES_CMD`
nnoremap <leader>hh :browse oldfiles<CR>

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

let g:sword = '\v(\k+|([^[:alnum:]_[:blank:](){}[\]<>$])\2*|[(){}[\]<>$]|\s+)'
inoremap <silent><C-j> <C-r>=SwordJumpRight()<CR><Right>
inoremap <silent><C-k> <C-r>=SwordJumpLeft()<CR>
func! SwordJumpRight()
    if col('.') !=  col('$')
        call search(g:sword, 'ceW')
    endif
    return ''
endfunc
func! SwordJumpLeft()
    call search(col('.') != 1 ? g:sword : '\v$', 'bW')
    return ''
endfunc
cnoremap <C-j> <S-Right>
cnoremap <C-k> <S-Left>
noremap! <C-space> <C-k>

inoremap <C-u> <C-g>u<C-u>

nnoremap <silent><leader><CR> :nohlsearch\|diffupdate<CR><C-L>
nnoremap <leader>ss :setlocal spell!\|setlocal spell?<cr>
nnoremap <leader>sp :setlocal paste!\|setlocal paste?<cr>
nnoremap <leader>sw :set wrap!\|set wrap?<CR>
nnoremap <leader>sf :syn sync fromstart<CR>

noremap <leader>dp :diffput<CR>
noremap <leader>do :diffget<CR>

inoremap <C-v> <C-g>u<C-\><C-o>:set paste<CR><C-r>+<C-\><C-o>:set nopaste<CR>
vnoremap <C-c> "+y

noremap <leader>fn 2<C-g>

noremap <F1> <Esc>
inoremap <F1> <Esc>
nmap     <C-q> <Esc>
cnoremap <C-q> <C-c>
inoremap <C-q> <Esc>
vnoremap <C-q> <Esc>
onoremap <C-q> <Esc>
noremap! <C-M-q> <C-q>
if has('nvim')
    tnoremap <M-[> <C-\><C-n>
endif

cnoremap <M-p> <Up>
cnoremap <M-n> <Down>

noremap q: :
noremap q <nop>
noremap <M-q> q
noremap <expr> qq empty(reg_recording()) ? 'qq' : 'q'
noremap Q @q

nnoremap U <nop>
xnoremap u <nop>

noremap x "_x

noremap <M-y> "py
noremap <M-p> "pp
noremap <M-P> "pP

nnoremap Y y$
onoremap <silent> ge :execute "normal! " . v:count1 . "ge<space>"<cr>
nnoremap <silent> & :&&<cr>
xnoremap <silent> & :&&<cr>

noremap  <M-+> <C-a>
vnoremap <M-+> g<C-a>
noremap  <M--> <C-x>
vnoremap <M--> g<C-x>

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
nnoremap <leader>td :tab split<CR>
nnoremap <leader>tt :tabedit<CR>
nnoremap <leader>cd :cd <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>e  :e! <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>fe :e!<CR>

nnoremap <leader>fm :let _p=getpos(".") <Bar> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <Bar> call setpos('.', _p) <Bar> :unlet _p <CR>

nnoremap <silent><leader>x  :pc\|ccl\|lcl<CR>
nnoremap <silent>]q :cnext<CR>
nnoremap <silent>[q :cprevious<CR>
nnoremap <silent>]l :lnext<CR>
nnoremap <silent>[l :lprevious<CR>

func! Execute(cmd, mods) abort
    redir => output
    silent execute a:cmd
    redir END
    execute a:mods 'new'
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
endfunction
command! -nargs=* -complete=command Execute silent call Execute(<q-args>, '<mods>')

function! SubstituteDict(dict) range
    exe a:firstline . ',' . a:lastline . 'substitute'
                \ . '/\C\%(' . join(map(keys(a:dict), 'escape(v:val, ''\.*$^~[]'')'), '\|'). '\)'
                \ . '/\=a:dict[submatch(0)]/ge'
endfunction
command! -range=% -nargs=1 SubstituteDict :<line1>,<line2>call SubstituteDict(<args>)
" }}}

" commentary {{{
" https://github.com/tpope/vim-commentary/blob/349340debb34f6302931f0eb7139b2c11dfdf427/plugin/commentary.vim
function! s:commentary_surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(substitute(
        \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

function! s:commentary_strip_white_space(l,r,line) abort
  let [l, r] = [a:l, a:r]
  if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
    let l = l[:-2]
  endif
  if r[0] ==# ' ' && a:line[-strlen(r):] != r && a:line[1-strlen(r):] == r[1:]
    let r = r[1:]
  endif
  return [l, r]
endfunction

function! s:commentary_go(...) abort
  if !a:0
    let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
    return 'g@'
  elseif a:0 > 1
    let [lnum1, lnum2] = [a:1, a:2]
  else
    let [lnum1, lnum2] = [line("'["), line("']")]
  endif

  let [l, r] = s:commentary_surroundings()
  let uncomment = 2
  for lnum in range(lnum1,lnum2)
    let line = matchstr(getline(lnum),'\S.*\s\@<!')
    let [l, r] = s:commentary_strip_white_space(l,r,line)
    if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let uncomment = 0
    endif
  endfor

  if get(b:, 'commentary_startofline')
    let indent = '^'
  else
    let indent = '^\s*'
  endif

  let lines = []
  for lnum in range(lnum1,lnum2)
    let line = getline(lnum)
    if strlen(r) > 2 && l.r !~# '\\'
      let line = substitute(line,
            \'\M' . substitute(l, '\ze\S\s*$', '\\zs\\d\\*\\ze', '') . '\|' . substitute(r, '\S\zs', '\\zs\\d\\*\\ze', ''),
            \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
    endif
    if uncomment
      let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
    else
      let line = substitute(line,'^\%('.matchstr(getline(lnum1),indent).'\|\s*\)\zs.*\S\@<=','\=l.submatch(0).r','')
    endif
    call add(lines, line)
  endfor
  call setline(lnum1, lines)
  let modelines = &modelines
  try
    set modelines=0
    silent doautocmd User CommentaryPost
  finally
    let &modelines = modelines
  endtry
  return ''
endfunction

function! s:commentary_textobject(inner) abort
  let [l, r] = s:commentary_surroundings()
  let lnums = [line('.')+1, line('.')-2]
  for [index, dir, bound, line] in [[0, -1, 1, ''], [1, 1, line('$'), '']]
    while lnums[index] != bound && line ==# '' || !(stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let lnums[index] += dir
      let line = matchstr(getline(lnums[index]+dir),'\S.*\s\@<!')
      let [l, r] = s:commentary_strip_white_space(l,r,line)
    endwhile
  endfor
  while (a:inner || lnums[1] != line('$')) && empty(getline(lnums[0]))
    let lnums[0] += 1
  endwhile
  while a:inner && empty(getline(lnums[1]))
    let lnums[1] -= 1
  endwhile
  if lnums[0] <= lnums[1]
    execute 'normal! 'lnums[0].'GV'.lnums[1].'G'
  endif
endfunction

command! -range -bar Commentary call s:commentary_go(<line1>,<line2>)
xnoremap <expr>   <Plug>Commentary     <SID>commentary_go()
nnoremap <expr>   <Plug>Commentary     <SID>commentary_go()
nnoremap <expr>   <Plug>CommentaryLine <SID>commentary_go() . '_'
onoremap <silent> <Plug>Commentary        :<C-U>call <SID>commentary_textobject(get(v:, 'operator', '') ==# 'c')<CR>
nnoremap <silent> <Plug>ChangeCommentary c:<C-U>call <SID>commentary_textobject(1)<CR>

xmap gc  <Plug>Commentary
nmap gc  <Plug>Commentary
omap gc  <Plug>Commentary
nmap gcc <Plug>CommentaryLine
nmap cgc <Plug>ChangeCommentary
nmap gcu <Plug>Commentary<Plug>Commentary
" }}}

" netrw & vinegar {{{
let g:netrw_fastbrowse = 0
nnoremap <silent><C-w>es :Hexplore<CR>
nnoremap <silent><C-w>ev :Vexplore!<CR>

" https://github.com/tpope/vim-vinegar/blob/b245f3ab4580eba27616a5ce06a56d5f791e67bd/plugin/vinegar.vim
let s:vinegar_dotfiles = '\(^\|\s\s\)\zs\.\S\+'

let s:vinegar_escape = 'substitute(escape(v:val, ".$~"), "*", ".*", "g")'
let g:netrw_list_hide =
      \ join(map(split(&wildignore, ','), '"^".' . s:vinegar_escape . '. "/\\=$"'), ',') . ',^\.\.\=/\=$' .
      \ (get(g:, 'netrw_list_hide', '')[-strlen(s:vinegar_dotfiles)-1:-1] ==# s:vinegar_dotfiles ? ','.s:vinegar_dotfiles : '')
if !exists("g:netrw_banner")
  let g:netrw_banner = 0
endif
unlet! s:vinegar_netrw_up

nnoremap <silent> <Plug>VinegarUp :call <SID>vinegar_opendir('edit')<CR>
if empty(maparg('-', 'n')) && !hasmapto('<Plug>VinegarUp')
  nmap - <Plug>VinegarUp
endif

nnoremap <silent> <Plug>VinegarTabUp :call <SID>vinegar_opendir('tabedit')<CR>
nnoremap <silent> <Plug>VinegarSplitUp :call <SID>vinegar_opendir('split')<CR>
nnoremap <silent> <Plug>VinegarVerticalSplitUp :call <SID>vinegar_opendir('vsplit')<CR>

function! s:vinegar_sort_sequence(suffixes) abort
  return '[\/]$,*' . (empty(a:suffixes) ? '' : ',\%(' .
        \ join(map(split(a:suffixes, ','), 'escape(v:val, ".*$~")'), '\|') . '\)[*@]\=$')
endfunction
let g:netrw_sort_sequence = s:vinegar_sort_sequence(&suffixes)

function! s:vinegar_opendir(cmd) abort
  let df = ','.s:vinegar_dotfiles
  if expand('%:t')[0] ==# '.' && g:netrw_list_hide[-strlen(df):-1] ==# df
    let g:netrw_list_hide = g:netrw_list_hide[0 : -strlen(df)-1]
  endif
  if &filetype ==# 'netrw' && len(s:vinegar_netrw_up)
    let basename = fnamemodify(b:netrw_curdir, ':t')
    execute s:vinegar_netrw_up
    call s:vinegar_seek(basename)
  elseif expand('%') =~# '^$\|^term:[\/][\/]'
    execute a:cmd '.'
  else
    execute a:cmd '%:h' . s:vinegar_slash()
    call s:vinegar_seek(expand('#:t'))
  endif
endfunction

function! s:vinegar_seek(file) abort
  if get(b:, 'netrw_liststyle') == 2
    let pattern = '\%(^\|\s\+\)\zs'.escape(a:file, '.*[]~\').'[/*|@=]\=\%($\|\s\+\)'
  else
    let pattern = '^\%(| \)*'.escape(a:file, '.*[]~\').'[/*|@=]\=\%($\|\t\)'
  endif
  call search(pattern, 'wc')
  return pattern
endfunction

augroup vinegar
  autocmd!
  autocmd FileType netrw call s:vinegar_setup_vinegar()
  if exists('##OptionSet')
    autocmd OptionSet suffixes
          \ if s:vinegar_sort_sequence(v:option_old) ==# get(g:, 'netrw_sort_sequence') |
          \   let g:netrw_sort_sequence = s:vinegar_sort_sequence(v:option_new) |
          \ endif
  endif
augroup END

function! s:vinegar_slash() abort
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction

function! s:vinegar_absolutes(first, ...) abort
  let files = getline(a:first, a:0 ? a:1 : a:first)
  call filter(files, 'v:val !~# "^\" "')
  call map(files, "substitute(v:val, '^\\(| \\)*', '', '')")
  call map(files, 'b:netrw_curdir . s:vinegar_slash() . substitute(v:val, "[/*|@=]\\=\\%(\\t.*\\)\\=$", "", "")')
  return files
endfunction

function! s:vinegar_relatives(first, ...) abort
  let files = s:vinegar_absolutes(a:first, a:0 ? a:1 : a:first)
  call filter(files, 'v:val !~# "^\" "')
  for i in range(len(files))
    let relative = fnamemodify(files[i], ':.')
    if relative !=# files[i]
      let files[i] = '.' . s:vinegar_slash() . relative
    endif
  endfor
  return files
endfunction

function! s:vinegar_escaped(first, last) abort
  let files = s:vinegar_relatives(a:first, a:last)
  return join(map(files, 'fnameescape(v:val)'), ' ')
endfunction

function! s:vinegar_setup_vinegar() abort
  if !exists('s:vinegar_netrw_up')
    let orig = maparg('-', 'n')
    if orig =~? '^<plug>'
      let s:vinegar_netrw_up = 'execute "normal \'.substitute(orig, ' *$', '', '').'"'
    elseif orig =~# '^:'
      " :exe "norm! 0"|call netrw#LocalBrowseCheck(<SNR>123_NetrwBrowseChgDir(1,'../'))<CR>
      let s:vinegar_netrw_up = substitute(orig, '\c^:\%(<c-u>\)\=\|<cr>$', '', 'g')
    else
      let s:vinegar_netrw_up = ''
    endif
  endif
  nmap <buffer> - <Plug>VinegarUp
  cnoremap <buffer><expr> <Plug><cfile> get(<SID>vinegar_relatives('.'),0,"\022\006")
  if empty(maparg('<C-R><C-F>', 'c'))
    cmap <buffer> <C-R><C-F> <Plug><cfile>
  endif
  nnoremap <buffer> ~ :edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>vinegar_escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>vinegar_escaped(line("'<"), line("'>"))<CR><Home>
  if empty(mapcheck('y.', 'n'))
    nnoremap <silent><buffer> y. :<C-U>call setreg(v:register, join(<SID>vinegar_absolutes(line('.'), line('.') - 1 + v:count1), "\n")."\n")<CR>
  endif
  nmap <buffer> ! .!
  xmap <buffer> ! .!
  exe 'syn match netrwSuffixes =\%(\S\+ \)*\S\+\%('.join(map(split(&suffixes, ','), s:vinegar_escape), '\|') . '\)[*@]\=\S\@!='
  hi def link netrwSuffixes SpecialKey
endfunction
" }}}
"
" color {{{
let g:colors_name = 'zenbruh'

" Palette:
let s:fg        = ['#eeeeee', 255]
let s:fgdarkish = ['#d0d0d0', 252]
let s:fgdark    = ['#bcbcbc', 250]

let s:bglighter = ['#303030', 236]
let s:bglight   = ['#262626', 235]
let s:bg        = ['#1c1c1c', 234]
let s:bgdark    = ['#121212', 233]
let s:bgdarker  = ['#121212', 233]

let s:comment   = ['#afd7af', 151]
let s:selection = ['#626262', 241]
let s:subtle    = ['#444444', 238]
let s:special   = ['#ffd7d7', 224]

let s:white        = ['#ffffff',  15]
let s:black        = ['#000000',   0]
let s:cyan         = ['#87d7d7', 116]
let s:lightcyan    = ['#afd7d7', 152]
let s:green        = ['#afd75f', 149]
let s:deepskyblue  = ['#005f5f',  23]
let s:orange       = ['#ffaf5f', 215]
let s:mediumpurple = ['#5f5f87',  60]
let s:pink         = ['#ffafd7', 218]
let s:purple       = ['#d7afff', 183]
let s:red          = ['#ff5f5f', 203]
let s:redish       = ['#d78787', 174]
let s:yellow       = ['#ffff87', 228]
let s:yellowish    = ['#ffd7af', 223]
let s:none         = ['NONE', 'NONE']

" Script Helpers:
function! s:h(scope, fg, ...) " bg, attr_list, special
  let l:fg = copy(a:fg)
  let l:bg = get(a:, 1, ['NONE', 'NONE'])

  let l:attr_list = filter(get(a:, 2, ['NONE']), 'type(v:val) == 1')
  let l:attrs = len(l:attr_list) > 0 ? join(l:attr_list, ',') : 'NONE'

  " Falls back to coloring foreground group on terminals because
  " nearly all do not support undercurl
  let l:special = get(a:, 3, ['NONE', 'NONE'])
  if l:special[0] !=# 'NONE' && l:fg[0] ==# 'NONE' && !has('gui_running')
    let l:fg[0] = l:special[0]
    let l:fg[1] = l:special[1]
  endif

  let l:hl_string = [
        \ 'highlight', a:scope,
        \ 'guifg=' . l:fg[0], 'ctermfg=' . l:fg[1],
        \ 'guibg=' . l:bg[0], 'ctermbg=' . l:bg[1],
        \ 'gui=' . l:attrs, 'cterm=' . l:attrs,
        \ 'guisp=' . l:special[0],
        \]

  execute join(l:hl_string, ' ')
endfunction

" Zenbruh Highlight Groups:
call s:h('ZenbruhBgLight', s:none, s:bglight)
call s:h('ZenbruhBgLighter', s:none, s:bglighter)
call s:h('ZenbruhBgDark', s:none, s:bgdark)
call s:h('ZenbruhBgDarker', s:none, s:bgdarker)

call s:h('ZenbruhFg', s:fg)
call s:h('ZenbruhFgUnderline', s:fg, s:none, ['underline'])
call s:h('ZenbruhFgBold', s:fg, s:none, ['bold'])
call s:h('ZenbruhFgItalic', s:fg, s:none, ['italic'])
call s:h('ZenbruhFgBoldItalic', s:fg, s:none, ['bold', 'italic'])
call s:h('ZenbruhFgDark', s:fgdark)

call s:h('ZenbruhComment', s:comment)
call s:h('ZenbruhCommentBold', s:comment, s:none, ['bold'])

call s:h('ZenbruhSelection', s:none, s:selection)

call s:h('ZenbruhSubtle', s:subtle)
call s:h('ZenbruhNonText', s:selection)

call s:h('ZenbruhCyan', s:cyan)
call s:h('ZenbruhCyanItalic', s:cyan, s:none, ['italic'])
call s:h('ZenbruhLightCyan', s:lightcyan)

call s:h('ZenbruhGreen', s:green)
call s:h('ZenbruhGreenBold', s:green, s:none, ['bold'])
call s:h('ZenbruhGreenItalic', s:green, s:none, ['italic'])

call s:h('ZenbruhOrange', s:orange)
call s:h('ZenbruhOrangeItalic', s:orange, s:none, ['italic'])
call s:h('ZenbruhOrangeInverse', s:bg, s:orange)

call s:h('ZenbruhPink', s:pink)
call s:h('ZenbruhPinkItalic', s:pink, s:none, ['italic'])

call s:h('ZenbruhPurple', s:purple)
call s:h('ZenbruhPurpleBold', s:purple, s:none, ['bold'])
call s:h('ZenbruhPurpleItalic', s:purple, s:none, ['italic'])

call s:h('ZenbruhRed', s:red)
call s:h('ZenbruhRedInverse', s:fg, s:red)
call s:h('ZenbruhRedish', s:redish)

call s:h('ZenbruhYellow', s:yellow)
call s:h('ZenbruhYellowish', s:yellowish)
call s:h('ZenbruhYellowishBold', s:yellowish, s:none, ['bold'])

call s:h('ZenbruhError', s:red, s:none, [], s:red)

call s:h('ZenbruhErrorLine', s:none, s:none, ['undercurl'], s:red)
call s:h('ZenbruhWarnLine', s:none, s:none, ['undercurl'], s:orange)
call s:h('ZenbruhInfoLine', s:none, s:none, ['undercurl'], s:cyan)

call s:h('ZenbruhTodo', s:pink, s:none, ['bold', 'inverse'])
call s:h('ZenbruhSearch', s:none, s:subtle, ['bold', 'underline'])
call s:h('ZenbruhIncSearch', s:none, s:none, ['bold', 'underline', 'inverse'])
call s:h('ZenbruhBoundary', s:fgdarkish, s:bgdark)
call s:h('ZenbruhLink', s:cyan, s:none, ['underline'])

call s:h('ZenbruhDiffAdd', s:none, s:deepskyblue)
call s:h('ZenbruhDiffChange', s:none, s:none)
call s:h('ZenbruhDiffText', s:none, s:mediumpurple)
call s:h('ZenbruhDiffDelete', s:red, s:bgdark)

call s:h('ZenbruhSpecial', s:special)

" User Interface:
set background=dark

" Required as some plugins will overwrite
call s:h('Normal', s:fg, s:bg)
call s:h('NormalFloat', s:none, s:bglighter)
call s:h('StatusLine', s:none, s:bglighter, ['bold', 'inverse'])
call s:h('StatusLineNC', s:none, s:bglight)
call s:h('StatusLineTerm', s:none, s:bglighter, ['bold'])
call s:h('StatusLineTermNC', s:none, s:bglight)
call s:h('WildMenu', s:bg, s:purple, ['bold'])
call s:h('CursorLine', s:none, s:bglight)

hi! link ColorColumn  ZenbruhBgDark
hi! link CursorColumn CursorLine
hi! link CursorLineNr ZenbruhYellow
hi! link DiffAdd      ZenbruhDiffAdd
hi! link DiffChange   ZenbruhDiffChange
hi! link DiffDelete   ZenbruhDiffDelete
hi! link DiffText     ZenbruhDiffText
hi! link diffFile     ZenbruhGreen
hi! link diffNewFile  ZenbruhRed
hi! link diffAdded    ZenbruhGreen
hi! link diffLine     ZenbruhCyanItalic
hi! link diffRemoved  ZenbruhRed
hi! link Directory    ZenbruhPurpleBold
hi! link ErrorMsg     ZenbruhRedInverse
hi! link FoldColumn   ZenbruhSubtle
hi! link Folded       ZenbruhBoundary
hi! link IncSearch    ZenbruhIncSearch
hi! link LineNr       ZenbruhFgDark
hi! link MoreMsg      ZenbruhFgBold
hi! link NonText      ZenbruhNonText
hi! link Pmenu        ZenbruhBgDark
hi! link PmenuSbar    ZenbruhBgDark
hi! link PmenuSel     ZenbruhSelection
hi! link PmenuThumb   ZenbruhSelection
hi! link Question     ZenbruhFgBold
hi! link Search       ZenbruhSearch
hi! link SignColumn   ZenbruhComment
hi! link TabLine      ZenbruhSelection
hi! link TabLineFill  ZenbruhBgLighter
hi! link TabLineSel   Normal
hi! link Title        ZenbruhGreenBold
hi! link VertSplit    ZenbruhBoundary
hi! link Visual       ZenbruhSelection
hi! link VisualNOS    Visual
hi! link WarningMsg   ZenbruhOrangeInverse

" Syntax:
" Required as some plugins will overwrite
call s:h('MatchParen', s:white, s:black, ['bold', 'underline'])
call s:h('Conceal', s:special, s:none)

" Neovim uses SpecialKey for escape characters only. Vim uses it for that, plus whitespace.
if has('nvim')
  hi! link SpecialKey ZenbruhRed
else
  hi! link SpecialKey ZenbruhSubtle
endif

hi! link Comment ZenbruhComment
hi! link Underlined ZenbruhFgUnderline
hi! link Todo ZenbruhTodo

hi! link Error ZenbruhError
hi! link SpellBad ZenbruhErrorLine
hi! link SpellLocal ZenbruhWarnLine
hi! link SpellCap ZenbruhWarnLine
hi! link SpellRare ZenbruhInfoLine

hi! link Constant ZenbruhLightCyan
hi! link String ZenbruhRedish
hi! link Character ZenbruhRedish
hi! link Number ZenbruhPurple
hi! link Boolean ZenbruhPurple
hi! link Float ZenbruhPurple

hi! link Identifier ZenbruhSpecial
hi! link Function ZenbruhGreen

hi! link Statement ZenbruhYellowishBold
hi! link Conditional ZenbruhYellowishBold
hi! link Repeat ZenbruhYellowishBold
hi! link Label ZenbruhYellowishBold
hi! link Operator ZenbruhYellowish
hi! link Keyword ZenbruhYellowishBold
hi! link Exception ZenbruhYellowishBold

hi! link PreProc ZenbruhYellowishBold
hi! link Include ZenbruhYellowishBold
hi! link Define ZenbruhYellowishBold
hi! link Macro ZenbruhYellowishBold
hi! link PreCondit ZenbruhYellowishBold
hi! link StorageClass ZenbruhYellowishBold
hi! link Structure ZenbruhYellowishBold
hi! link Typedef ZenbruhYellowishBold

hi! link Type ZenbruhCyan

hi! link Delimiter ZenbruhFgDark

hi! link Special ZenbruhSpecial
hi! link SpecialComment ZenbruhCommentBold
hi! link Tag ZenbruhCyan
hi! link helpHyperTextJump ZenbruhLink
hi! link helpCommand ZenbruhPurple
hi! link helpExample ZenbruhGreen
hi! link helpBacktick Special
" }}}

" vim: set fdm=marker et sw=4:
