if &compatible | set nocompatible | endif

" set runtimepath above this line for correct ftdetect
if exists("did_load_filetypes") | filetype off | endif
filetype plugin indent on

" OS stuff {{{
let g:os = (has('win64') || has('win32') || has('win16')) ? 'Windows' : substitute(system('uname'), '\n', '', '')

if g:os ==# 'Windows'
    " :h shell-powershell
    set shell=powershell
    let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
endif
" }}}

" stuff from sensible that are not in my settings {{{
" https://github.com/tpope/vim-sensible/blob/2d9f34c09f548ed4df213389caa2882bfe56db58/plugin/sensible.vim
syntax enable
set nrformats-=octal
set ttimeout ttimeoutlen=50
set display+=lastline
set tags-=./tags tags-=./tags; tags^=./tags;
if &shell =~# 'fish$' && (v:version < 704 || v:version == 704 && !has('patch276'))
  set shell=/usr/bin/env\ bash
endif
set tabpagemax=50
set sessionoptions-=options
if &t_Co == 8 && $TERM !~# '^Eterm'
  set t_Co=16
endif
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif
" }}}

" Basic {{{
set mouse=a
set number ruler showcmd
set foldcolumn=1 foldnestmax=5
set scrolloff=2 sidescrolloff=2 sidescroll=1 nostartofline
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
set cpoptions-=_

let $LANG='en'
set langmenu=en
set encoding=utf-8
set spelllang=en,cjk

let mapleader = ","
noremap <M-;> ,

set wildmenu wildmode=longest:full,full
let s:wildignore_files = ['*~', '%*', '*.o', '*.so', '*.pyc', '*.pdf', '*.v.d', '*.vo*', '*.glob', '*.cm*', '*.aux']
let s:wildignore_dirs = ['.git', '__pycache__', 'target']
set complete-=i complete-=u completeopt=menuone,preview
if exists('+completepopup')
    set completeopt+=popup completepopup=highlight:NormalFloat,border:off
endif
set path=.,,

set ignorecase smartcase
set hlsearch incsearch

set noerrorbells novisualbell t_vb=
set shortmess+=Ic shortmess-=S
set belloff=all

set history=1000
set viminfo=!,'150,<50,s30,h,r/tmp,rfugitive://
set updatetime=1234
set backup undofile noswapfile
if has('nvim')
    set backupdir-=.
    let s:backupdir = &backupdir
    let s:undodir = &undodir
else
    let s:dotvim = g:os ==# 'Windows' ? 'vimfiles' : '.vim'
    let s:backupdir = $HOME . '/' . s:dotvim . '/backup'
    let s:undodir = $HOME . '/' . s:dotvim . '/undo'
    unlet s:dotvim
endif
if !isdirectory(s:backupdir) | call mkdir(s:backupdir, "p", 0700) | endif
if !isdirectory(s:undodir) | call mkdir(s:undodir, "p", 0700) | endif
let &backupdir = s:backupdir . '//'
let &undodir = s:undodir . '//'
unlet s:backupdir s:undodir

set autoread
set splitright splitbelow
if (has('patch-8.1.2315') || has('nvim-0.5')) | set switchbuf+=uselast | endif
set hidden
set lazyredraw

set modeline " debian unsets this
set exrc secure
if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt+=algorithm:histogram,indent-heuristic
endif

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

" fix terminal vim problems {{{
if !has('gui_running') && !has('nvim')
    silent! !stty -ixon > /dev/null 2>/dev/null
    if $TERM =~ '\(tmux\|screen\)-256' | set term=xterm-256color | endif
    set ttymouse=sgr
    " NOTE: <M- keys can be affected by 'encoding'.
    " NOTE: Characters that come after <Esc> in terminal codes: [ ] P \ M O
    " (see term.c and `set termcap`)
    " These terminal options (gnome-terminal) conflict with my <M- mappings.
    " Fortunately, they are not important and can be disabled.
    set t_IS= t_RF= t_RB= t_SC= t_ts= t_Cs= " uses <Esc>]
    set t_RS= " uses <Esc>P and <ESC>\
    for c in ['+', '-', '/', '0', ';', 'P', 'n', 'p', 'q', 'y'] + [',', '.', '\', ']', '\|']
        exe 'set <M-'.c.'>='."\<Esc>".c
        exe 'noremap  <M-'.c.'>' c
        exe 'noremap! <M-'.c.'>' c
    endfor
    " <M-BS>, <C-space> are not :set-able
    exe "set <F34>=\<Esc>\<C-?>"
    map! <F34> <M-BS>
    map  <Nul> <C-space>
    map! <Nul> <C-space>
    " :h undercurl
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"
endif
" }}}

" gui settings {{{
if has('nvim')
    augroup NvimUI | au!
        au UIEnter * if exists('g:GuiLoaded') | call SetupNvimQt() | endif
    augroup END
    function! SetupNvimQt() abort
        GuiTabline 0
        GuiPopupmenu 0
        GuiFont Source Code Pro:h13
        func! FontSize(delta)
            let [name, size] = matchlist(g:GuiFont, '\v(.*:h)(\d+)')[1:2]
            let new_size = str2nr(size) + a:delta
            exe 'GuiFont ' . name . new_size
        endfunc
        map <silent><C--> :<C-u>call FontSize(-v:count1)<CR>
        map <silent><C-+> :<C-u>call FontSize(v:count1)<CR>
        map <silent><C-=> :<C-u>call FontSize(v:count1)<CR>
    endfunction
elseif has('gui_running')
    set guioptions=i
    set guicursor+=a:blinkon0
    if g:os ==# 'Windows'
        set guifont=Source_Code_Pro:h12:cANSI:qDRAFT
    elseif g:os ==# 'Linux'
        set guifont=Source\ Code\ Pro\ 12
    endif
    command! -nargs=1 FontSize let &guifont = substitute(&guifont, '\d\+', '\=eval(submatch(0)+<args>)', 'g')
endif
" }}}

" Statusline {{{
let s:has_stl_expand_expr = has('patch-8.2.2854') || has('nvim-0.5')
if s:has_stl_expand_expr
    let s:statusline = [
                \ '%{%StatuslineHighlight1()%}', '%( %{StatuslineMode()} %)',
                \ '%{%StatuslineHighlight2()%}', '%( %{ShortRelPath()} %)',
                \ '%{%StatuslineHighlight3()%}', '%m%r%w', '%{get(b:,"git_status","")}',
                \ '%=',
                \ '%{%StatuslineHighlight3()%}', ' %3p%% ',
                \ '%{%StatuslineHighlight2()%}', ' %3l:%-2c ']
else
    let s:statusline = [
                \ '%( %{StatuslineMode()} %)',
                \ '%#STLModeNormal2#', '%( %{ShortRelPath()} %)',
                \ '%#STLModeNormal3#', '%m%r%w', '%{get(b:,"git_status","")}',
                \ '%=',
                \ '%#STLModeNormal3#', ' %3p%% ',
                \ '%#STLModeNormal2#', ' %3l:%-2c ']
endif
let &statusline = join(s:statusline, '')
unlet s:statusline

if s:has_stl_expand_expr
    let s:stl_mode_hl = {
                \ 'n' :     '%#STLModeNormal1#',
                \ 'i' :     '%#STLModeInsert1#',
                \ 'R' :     '%#STLModeReplace#',
                \ 'v' :     '%#STLModeVisual#',
                \ 'V' :     '%#STLModeVisual#',
                \ "\<C-v>": '%#STLModeVisual#',
                \ 'c' :     '%#STLModeCmdline1#',
                \ 's' :     '%#STLModeVisual#',
                \ 'S' :     '%#STLModeVisual#',
                \ "\<C-s>": '%#STLModeVisual#',
                \ 't':      '%#STLModeInsert1#',}

    function! StatuslineHighlight1()
        return get(s:stl_mode_hl, mode(), '')
    endfunction
    function! StatuslineHighlight2()
        if g:actual_curwin != win_getid() | return '%#STLModeNormal2#' | endif
        return mode() =~# '^[it]' ? '%#STLModeInsert2#' : mode() =~# '^c' ? '%#STLModeCmdline2#' : '%#STLModeNormal2#'
    endfunction
    function! StatuslineHighlight3()
        if g:actual_curwin != win_getid() | return '%#STLModeNormal3#' | endif
        return mode() =~# '^[it]' ? '%#STLModeInsert3#' : mode() =~# '^c' ? '%#STLModeCmdline3#' : '%#STLModeNormal3#'
    endfunction
endif

function! StatuslineHighlightInit()
    if s:has_stl_expand_expr
        hi! StatusLine guibg=#303030 ctermbg=236 gui=bold cterm=bold
    else
        hi! StatusLine guibg=#303030 ctermbg=236 gui=bold,inverse cterm=bold,inverse
    endif
    hi! StatusLineNC     guibg=#262626 ctermbg=235 gui=none cterm=none
    hi! StatusLineTerm   guibg=#303030 ctermbg=236 gui=bold cterm=bold
    hi! StatusLineTermNC guibg=#262626 ctermbg=235 gui=none cterm=none

    hi! STLModeNormal1  guifg=#005f00 ctermfg=22  guibg=#afdf00 ctermbg=148 gui=bold cterm=bold
    hi! STLModeNormal2                            guibg=#626262 ctermbg=241
    hi! STLModeNormal3                            guibg=#303030 ctermbg=236
    hi! STLModeVisual   guifg=#870000 ctermfg=88  guibg=#ff8700 ctermbg=208 gui=bold cterm=bold
    hi! STLModeReplace  guifg=#ffffff ctermfg=231 guibg=#df0000 ctermbg=160 gui=bold cterm=bold
    hi! STLModeInsert1  guifg=#005f5f ctermfg=23  guibg=#ffffff ctermbg=231 gui=bold cterm=bold
    hi! STLModeInsert2  guifg=#ffffff ctermfg=231 guibg=#0087af ctermbg=31
    hi! STLModeInsert3  guifg=#ffffff ctermfg=231 guibg=#005f87 ctermbg=24
    hi! STLModeCmdline1 guifg=#262626 ctermfg=235 guibg=#ffffff ctermbg=231 gui=bold cterm=bold
    hi! STLModeCmdline2 guifg=#303030 ctermfg=236 guibg=#d0d0d0 ctermbg=252
    hi! STLModeCmdline3 guifg=#303030 ctermfg=236 guibg=#8a8a8a ctermbg=245

    hi! TabLine      cterm=NONE ctermfg=NONE ctermbg=241 gui=NONE guibg=#626262
    hi! TabLineFill  cterm=NONE ctermbg=238 gui=NONE guibg=#444444
    " TabLineSel
endfunction
call StatuslineHighlightInit()

let s:stl_mode_map = {'n' : 'N ', 'i' : 'I ', 'R' : 'R ', 'v' : 'V ', 'V' : 'VL', "\<C-v>": 'VB', 'c' : 'C ', 's' : 'S ', 'S' : 'SL', "\<C-s>": 'SB', 't': 'T '}
if has('patch-8.1.1372') || has('nvim-0.5')
    function! StatuslineMode()
        if g:actual_curwin != win_getid() | return '' | endif
        return get(s:stl_mode_map, mode(), '')
    endfunction
else
    function! StatuslineMode()
        return get(s:stl_mode_map, mode(), '')
    endfunction
endif

func! ShortRelPath()
    let name = expand('%')
    if empty(name)
        return empty(&buftype) ? '[No Name]' : &buftype ==# 'nofile' ? '[Scratch]' : ''
    elseif isdirectory(name)
        return pathshorten(fnamemodify(name[:-2], ":~")) . '/'
    endif
    return pathshorten(fnamemodify(name, ":~:."))
endfunc

function! UpdateGitStatus(buf)
    let bufname = fnamemodify(bufname(a:buf), ':p')
    let status = ''
    if !empty(bufname) && getbufvar(a:buf, '&modifiable') && empty(getbufvar(a:buf, '&buftype'))
        let git = 'git -C '.fnamemodify(bufname, ':h')
        let rev_parse = s:system(git . ' rev-parse --abbrev-ref HEAD')[0]
        if !v:shell_error
            let status = s:system(git . ' status --porcelain ' . shellescape(bufname))
            let status = empty(status) ? '' : status[0][:1]
            let status = ' [' . rev_parse . (empty(status) ? '' : ':' . status) . ']'
        endif
    endif
    call setbufvar(a:buf, 'git_status', status)
endfunction

augroup Statusline | au!
    if g:os !=# 'Windows' " too slow on windows
        au BufReadPost,BufWritePost * call UpdateGitStatus(str2nr(expand('<abuf>')))
        if exists('*getbufinfo')
            au User FugitiveChanged call map(getbufinfo({'bufloaded':1}), 'UpdateGitStatus(v:val.bufnr)')
        endif
    endif
    au ColorScheme * call StatuslineHighlightInit()
augroup END
" }}}

" Languages {{{
augroup Languages | au!
    " NOTE: 'syntax-loading'
    au FileType c,cpp call s:c_cpp()
    au FileType markdown call s:markdown()
    au FileType pandoc setlocal filetype=markdown
    au FileType python call s:python()
    au FileType xml setlocal formatoptions-=r " very broken: <!--<CR> → <!--\n--> █
augroup END

" c, cpp {{{
function! s:c_cpp() abort
    " don't highlight the #define content
    syn clear cDefine
    syn region	cDefine		matchgroup=PreProc start="^\s*\zs\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
    hi! link cDefine NONE
endfunction
" }}}

" markdown {{{
let g:markdown_folding = 1
function! s:markdown() abort
    setlocal formatoptions< formatlistpat<
    setlocal commentstring=<!--%s-->
    setlocal comments=s:<!--,m:\ \ \ \ ,e:-->,:\|,n:>
    setlocal foldexpr=MyMarkdownFoldExpr()
    setlocal foldlevel=6
    setlocal matchpairs-=<:>
    if b:match_words[:3] ==# '<:>,'
        let b:match_words = b:match_words[4:]
    endif

    syn sync minlines=123
    syn sync linebreaks=1
    if hlID('markdownError')
        syn clear markdownError markdownItalic markdownBold markdownBoldItalic
        syn clear markdownListMarker markdownOrderedListMarker
        syn clear markdownCode markdownCodeBlock
    endif
    let concealends = ''
    if has('conceal') && get(g:, 'markdown_syntax_conceal', 1) == 1
        let concealends = ' concealends'
    endif
    " no emphasis using underscore
    exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="\*\S\@=" end="\S\@<=\*" skip="\\\*" contains=markdownLineStart,@Spell' . concealends
    exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="\*\*\S\@=" end="\S\@<=\*\*" skip="\\\*" contains=markdownLineStart,markdownItalic,@Spell' . concealends
    exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\*\*\*\S\@=" end="\S\@<=\*\*\*" skip="\\\*" contains=markdownLineStart,@Spell' . concealends
    " arbitrarily nested items
    syn match markdownListMarker "^\s*[-*+]\%(\s\+\S\)\@=" contained
    syn match markdownOrderedListMarker "\s*\<\d\+\.\%(\s\+\S\)\@=" contained
    " no indented code block
    syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`" keepend contains=markdownLineStart
    syn region markdownCode matchgroup=markdownCodeDelimiter start="`` \=" end=" \=``" keepend contains=markdownLineStart
    syn region markdownCodeBlock matchgroup=markdownCodeDelimiter start="^\s*\z(`\{3,\}\).*$" end="^\s*\z1\ze\s*$" keepend
    syn region markdownCodeBlock matchgroup=markdownCodeDelimiter start="^\s*\z(\~\{3,\}\).*$" end="^\s*\z1\ze\s*$" keepend
    " redefine fenced code block with language to fix the priority
    let done_include = {}
    for type in g:markdown_fenced_languages
        if has_key(done_include, matchstr(type,'[^.]*'))
            continue
        endif
        exe 'syn region markdownHighlight'.substitute(matchstr(type,'[^=]*$'),'\..*','','').' matchgroup=markdownCodeDelimiter start="^\s*\z(`\{3,\}\)\s*\%({.\{-}\.\)\='.matchstr(type,'[^=]*').'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight'.substitute(matchstr(type,'[^=]*$'),'\.','','g') . concealends
        exe 'syn region markdownHighlight'.substitute(matchstr(type,'[^=]*$'),'\..*','','').' matchgroup=markdownCodeDelimiter start="^\s*\z(\~\{3,\}\)\s*\%({.\{-}\.\)\='.matchstr(type,'[^=]*').'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight'.substitute(matchstr(type,'[^=]*$'),'\.','','g') . concealends
        let done_include[matchstr(type,'[^.]*')] = 1
    endfor
endfunction

function! s:IsCodeBlock(lnum) abort
    let synstack = synstack(a:lnum, 1)
    for i in synstack
        if synIDattr(i, 'name') =~# '^markdown\%(Code\|Highlight\)'
            return 1
        endif
    endfor
    return 0
endfunction

function! MyMarkdownFoldExpr() abort
    let line = getline(v:lnum)
    let hashes = matchstr(line, '^#\+')
    let is_code = -1
    if !empty(hashes)
        let is_code = s:IsCodeBlock(v:lnum)
        if !is_code
            return ">" . len(hashes)
        endif
    endif
    if !empty(line)
        let nextline = getline(v:lnum + 1)
        if nextline =~ '^=\+$'
            if is_code == -1
                let is_code = s:IsCodeBlock(v:lnum)
            endif
            if !is_code
                return ">1"
            endif
        endif
        if nextline =~ '^-\+$'
            if is_code == -1
                let is_code = s:IsCodeBlock(v:lnum)
            endif
            if !is_code
                return ">2"
            endif
        endif
    endif
    return "="
endfunction
" }}}

" Python {{{
let g:pyindent_continue = '&shiftwidth'
let g:pyindent_open_paren = '&shiftwidth'
function s:python() abort
    setlocal foldmethod=indent foldnestmax=2 foldignore=
    setlocal formatoptions+=ro
endfunction
" }}}

let g:lisp_rainbow = 1
let g:vimsyn_embed = 'l' " NOTE: only loads $VIMRUNTIME/syntax/lua.vim
let g:tex_no_error = 1
" }}}

" search & files {{{
nnoremap <silent>* :call Star(0)\|set hlsearch<CR>
nnoremap <silent>g* :call Star(1)\|set hlsearch<CR>
vnoremap <silent>* :<C-u>call VisualStar(0)\|set hlsearch<CR>
vnoremap <silent>g* :<C-u>call VisualStar(1)\|set hlsearch<CR>
let g:search_mode = get(g:, 'search_mode', '/')
func! Star(g)
    let @c = expand('<cword>')
    if match(@c, '\k') == -1
        let g:search_mode = 'v'
        let @/ = Text2Magic(@c)
    else
        let g:search_mode = 'n'
        let @/ = a:g ? @c : '\<' . @c . '\>'
    endif
    call histadd('/', @/)
endfunc
func! VisualStar(g)
    let g:search_mode = 'v'
    let l:reg_save = @"
    " don't trigger TextYankPost
    noau silent! normal! gvy
    let @c = @"
    let l:pattern = Text2Magic(@")
    let @/ = a:g ? '\<' . l:pattern . '\>' : l:pattern " reversed
    call histadd('/', @/)
    let @" = l:reg_save
endfunc
nnoremap / :let g:search_mode='/'<CR>/
nnoremap ? :let g:search_mode='/'<CR>?

" NOTE: :cex [] | bufdo vimgrepadd /pat/j %
" NOTE: :Grep pat `git\ ls-files\ dir`
nnoremap <C-g>      :<C-u>Grep<space>
nnoremap <leader>g/ :<C-u>Grep <C-r>=GrepInput(@/,0)<CR>
nnoremap <leader>gw :<C-u>Grep <C-R>=GrepInput(expand('<cword>'),1)<CR>
nnoremap <C-f>      :<C-u>Files<space>
nnoremap <leader>hh :<C-u>History<space>

command! -nargs=* -complete=dir Grep call Grep(<f-args>)
command! -nargs=? History call History(<f-args>)
command! -nargs=? Files call Files(<f-args>)

if executable('rg')
    " --vimgrep is like vimgrep /pat/g
    let &grepprg = 'rg --column --line-number --no-heading --smart-case'
    set grepformat^=%f:%l:%c:%m
elseif executable('egrep')
    let &grepprg = 'egrep -nrI $* /dev/null'
else
    set grepprg=internal
endif
function! Grep(query, ...) abort
    " NOTE: escape the space ('\ ') to include space in query
    let opts = string(v:count)
    let options = (&grepprg =~# '^egrep') ? Wildignore2exclude() : ''
    let query = (&grepprg ==# 'internal') ? ('/'.a:query.'/j') : s:cmdshellescape(a:query)
    let dir = '.'
    if a:0
        let dir = a:1
    elseif opts =~ '3'
        let dir = s:git_root(empty(bufname()) ? getcwd() : bufname())
    elseif &grepprg ==# 'internal'
        let dir = '**'
    endif
    exe 'grep!' options query dir
    belowright cwindow
    redraw
endfunction
func! GrepInput(raw, word)
    let query = a:raw
    if &grepprg ==# 'internal' " assumes magic
        let query = escape(query, '/ \')
        return a:word ? '\<'.query.'\>' : query
    endif
    if a:word
        let query = '\b'.query.'\b'
    elseif g:search_mode ==# 'n'
        let query = substitute(query, '\v\\[<>]','','g')
    elseif g:search_mode ==# 'v'
        let query = escape(query, '+|?-(){}')
    elseif query[0:1] !=# '\v'
        let query = substitute(query, '\v(\\V|\\[<>])','','g')
    else
        let query = substitute(query[2:], '\v\\([~/])', '\1', 'g')
    endif
    return escape(query, ' \#%') " for <f-args> and cmdline-special
endfunc
function! History(...) abort
    silent doautocmd QuickFixCmdPre History
    let files = copy(v:oldfiles)
    call map(files, 'expand(v:val)')
    call filter(files, 'filereadable(v:val)' . (a:0 ? ' && match(v:val, a:1) >= 0' : ''))
    call s:setqflist_files(files, ':History')
    silent doautocmd QuickFixCmdPost History
    belowright cwindow
endfunction
function! Files(...) abort
    silent doautocmd QuickFixCmdPre Files
    let opts = string(v:count)
    if opts =~ '3'
        let root = s:git_root(empty(bufname()) ? getcwd() : bufname())
        " NOTE: add -co to include untracked files (n.b. may not enumerate each file)
        let files = s:system('git -C '.root.' ls-files --exclude-standard')
        call map(files, "'".root."/'.v:val")
    else
        let cmd = (&grepprg =~# '^rg') ? 'rg --files' : 'find . -type f'
        let files = s:system(cmd)
    endif
    if a:0
        call filter(files, 'match(v:val, a:1) >= 0')
    endif
    call s:setqflist_files(files, ':Files')
    silent doautocmd QuickFixCmdPost Files
    belowright cwindow
endfunction
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

" sneak {{{
" TODO: support visual mode
nnoremap <silent> s :<C-u>call MuSneak(0)<CR>
nnoremap <silent> S :<C-u>call MuSneak(1)<CR>
nnoremap <silent> ;     :<C-u>call MuSneakRepeat(0)<CR>
nnoremap <silent> <M-;> :<C-u>call MuSneakRepeat(1)<CR>

let g:musneak_repeat_sneak = 0
function! MuSneak(up) abort
    echo '>'
    let ch1 = getchar()
    let ch1 = type(ch1) == type(0) ? nr2char(ch1) : ch1
    if ch1 !~# '\p' | return | endif
    redraw | echo '>'.ch1
    let ch2 = getchar()
    let ch2 = type(ch2) == type(0) ? nr2char(ch2) : ch2
    if ch2 !~# '\p' | return | endif
    redraw | echo '>'.ch1.ch2
    let g:musneak_up = a:up
    let g:musneak_pat = '\v' . escape(ch1, '!#$%&()*+,-./:;<=>?@[\]^{|}~') . escape(ch2, '!#$%&()*+,-./:;<=>?@[\]^{|}~')
    call MuSneakSearch(g:musneak_up, 1)
    call MuSneakHijackFTft()
endfunction
function! MuSneakRepeat(rev) abort
    if g:musneak_repeat_sneak
        let i = v:count1
        while i > 0 && MuSneakSearch(xor(g:musneak_up, a:rev), 0)
            let i -= 1
        endwhile
    else
        execute 'normal!' v:count1 . (a:rev ? ',' : ';')
    endif
endfunction
function! MuSneakSearch(up, mark) abort
    let flags = 'W' . (a:up ? 'b' : '') . (a:mark ? 's' : '')
    let stopline = a:up ? line('w0') : line('w$')
    " TODO: skip folded region with foldclosed()?
    return searchpos(g:musneak_pat, flags, stopline)[0]
endfunction
function! MuSneakHijackFTft() abort
    let g:musneak_repeat_sneak = 1
    nnoremap <silent> f :<C-u>call MuSneakReset()<CR>f
    nnoremap <silent> t :<C-u>call MuSneakReset()<CR>t
    nnoremap <silent> F :<C-u>call MuSneakReset()<CR>F
    nnoremap <silent> T :<C-u>call MuSneakReset()<CR>T
endfunction
function! MuSneakReset() abort
    let g:musneak_repeat_sneak = 0
    unmap f
    unmap t
    unmap F
    unmap T
endfunction
" }}}

let g:sword = '\v(\k+|([^[:alnum:]_[:blank:](){}[\]<>''"`$])\2*|[(){}[\]<>''"`$]|\s+)'
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

inoremap <expr> <C-u> match(getline('.'), '\S') >= 0 ? "\<C-g>u<C-u>" : "<C-u>"
" Delete a single character of other non-blank chars
inoremap <silent><expr><C-w>  FineGrainedICtrlW(0)
" Like above, but first consume whitespace
inoremap <silent><expr><M-BS> FineGrainedICtrlW(1)
func! FineGrainedICtrlW(finer)
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
        if l:idx == l:len || (!a:finer && l:chars[-(l:idx + 1)] =~ '\k')
            return "\<C-w>"
        endif
        let l:sts = &softtabstop
        setlocal softtabstop=0
        return repeat("\<BS>", l:idx)
                    \ . "\<C-R>=FineGrainedICtrlWReset(".l:sts.")\<CR>"
                    \ . (a:finer ? "" : "\<C-R>=MuPairsBS(7)\<CR>")
    elseif l:chars[-1] !~ '\k'
        return MuPairsBS(7)
    else
        return "\<C-w>"
    endif
endfunc
function! FineGrainedICtrlWReset(sts) abort
    let &l:softtabstop = a:sts
    return ''
endfunc
" }}}

" etc mappings {{{
nnoremap <silent><leader><CR> :let v:searchforward=1\|nohlsearch<CR>
nnoremap <silent><leader><C-L> :diffupdate\|syntax sync fromstart<CR><C-L>
nnoremap <leader>ss :setlocal spell! spell?<CR>
nnoremap <leader>sc :if empty(&spc) \| setl spc< spc? \| else \| setl spc= spc? \| endif<CR>
nnoremap <leader>sp :setlocal paste! paste?<CR>
nnoremap <leader>sw :set wrap! wrap?<CR>
nnoremap <leader>ic :set ignorecase! smartcase! ignorecase?<CR>

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
if exists('*reg_recording')
    noremap <expr> qq empty(reg_recording()) ? 'qq' : 'q'
endif
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

" set nrformats+=alpha
noremap  <M-+> <C-a>
vnoremap <M-+> g<C-a>
noremap  <M--> <C-x>
vnoremap <M--> g<C-x>

nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

command! -count Wfh set winfixheight | if <count> | exe "normal! z".<count>."\<CR>" | endif

noremap <leader>q :<C-u>q<CR>
noremap q, :<C-u>q<CR>
nnoremap <leader>w :<C-u>up<CR>
nnoremap ZAQ :<C-u>qa!<CR>
cnoreabbrev <expr> W <SID>cabbrev('W', 'w')
cnoreabbrev <expr> Q <SID>cabbrev('Q', 'q')

cnoreabbrev <expr> ff  <SID>cabbrev('ff',  "find**/<Left><Left><Left>")
cnoreabbrev <expr> sff <SID>cabbrev('sff', "sf**/<Left><Left><Left>")
cnoreabbrev <expr> vsb <SID>cabbrev('vsb', 'vert sb')
cnoreabbrev <expr> vsf <SID>cabbrev('vsf', "vert sf**/<Left><Left><Left>")
cnoreabbrev <expr> tsb <SID>cabbrev('tsb', 'tab sb')
cnoreabbrev <expr> tsf <SID>cabbrev('tsf', "tab sf**/<Left><Left><Left>")

nnoremap <leader>cx :tabclose<CR>
nnoremap <leader>td :tab split<CR>
nnoremap <leader>tt :tabedit<CR>
nnoremap <leader>cd :cd <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>e  :e! <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
nnoremap <leader>fe :e!<CR>

inoreabbrev <expr> \date\ strftime('%F')
" }}}

" pairs {{{
xmap aa a%

inoremap <expr> ( MuPairsOpen('(', ')', 15)
inoremap <expr> ) MuPairsClose('(', ')', 15)
inoremap <expr> [ MuPairsOpen('[', ']', 15)
inoremap <expr> ] MuPairsClose('[', ']', 15)
inoremap <expr> { MuPairsOpen('{', '}', 127)
inoremap <expr> } MuPairsClose('{', '}', 127)
inoremap <expr> <CR> (match(getline('.'), '\w') >= 0 ? "\<C-G>u" : "") . MuPairsCR()
inoremap <expr> <BS> MuPairsBS(15)
inoremap <expr> " MuPairsDumb('"')
inoremap <expr> ' MuPairsDumb("'")
inoremap <expr> ` MuPairsDumb('`')

function! MuPairsOpen(open, close, distance) abort
    if MuPairsBalance(a:open, a:close, a:distance) > 0
        return a:open
    elseif s:curchar() =~# '\k'
        return a:open
    endif
    return a:open . a:close . "\<C-g>U\<Left>"
endfunction
function! MuPairsClose(open, close, distance) abort
    if s:curchar() !=# a:close
        return a:close
    elseif MuPairsBalance(a:open, a:close, a:distance) >= 0
        return "\<C-g>U\<Right>"
    endif
    return a:close
endfunction
function! MuPairsBS(distance) abort
    let cur = s:curchar()
    if empty(cur) | return "\<BS>" | endif
    let prev = s:prevchar()
    if empty(prev) | return "\<BS>" | endif
    if prev . cur =~# '\%(""\|''''\|``\)'
        return "\<Del>\<BS>"
    elseif prev . cur !~# '\V\%(()\|[]\|{}\)'
        return "\<BS>"
    elseif MuPairsBalance(prev, cur, a:distance) < 0
        return "\<BS>"
    endif
    return "\<Del>\<BS>"
endfunction
function! MuPairsCR() abort
    let cur = s:curchar()
    if empty(cur) | return "\<CR>" | endif
    let prev = s:prevchar()
    if empty(prev) | return "\<CR>" | endif
    if prev . cur !~# '\V\%(()\|[]\|{}\)'
        return "\<CR>"
    endif
    return "\<CR>\<C-c>O"
endfunction
function! MuPairsBalance(open, close, distance) abort
    let openpat = '\V' . a:open
    let closepat = '\V' . a:close
    let lnum = line('.')
    return searchpair(openpat, '', closepat, 'cnrm', '', lnum + a:distance)
         \ - searchpair(openpat, '', closepat, 'bnrm', '', max([lnum - a:distance, 1]))
endfunction
function! MuPairsDumb(char) abort
    let cur = s:curchar()
    if cur ==# a:char
        return "\<C-g>U\<Right>"
    elseif cur =~# '\k' || s:prevchar() =~# '\%(\k\|'.a:char.'\)'
        return a:char
    endif
    return a:char . a:char . "\<C-g>U\<Left>"
endfunction
function! s:prevchar() abort
    return matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
endfunction
function! s:curchar() abort
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction
" }}}

" quickfix, loclist, ... {{{
if has('patch-8.1.0311') || has('nvim-0.3.2')
    packadd cfilter
endif
nnoremap <silent><leader>x  :pc\|ccl\|lcl<CR>
nnoremap <silent>]q :cnext<CR>
nnoremap <silent>[q :cprevious<CR>
nnoremap <silent>]l :lnext<CR>
nnoremap <silent>[l :lprevious<CR>

" Like CTRL-W_<CR>, but with preview window and without messing up buffer list
" NOTE: :chistory
augroup Qf | au! * <buffer>
    au Filetype qf nnoremap <buffer><silent> p :<C-u>call <SID>PreviewQf(line('.'))<CR>
    au Filetype qf nnoremap <buffer><silent> <CR> :<C-u>pclose<CR><CR>
augroup END

function! s:GetQfEntry(linenr) abort
    if &filetype !=# 'qf' | return {} | endif
    let l:qflist = getloclist(0)
    if empty(l:qflist)
        let l:qflist = getqflist()
    endif
    if !l:qflist[a:linenr-1].valid | return {} | endif
    if !filereadable(bufname(l:qflist[a:linenr-1].bufnr)) | return {} | endif
    return l:qflist[a:linenr-1]
endfunction
function! s:PreviewQf(linenr) abort
    let l:entry = s:GetQfEntry(a:linenr)
    if empty(l:entry) | return | endif
    let l:listed = buflisted(l:entry.bufnr)
    if s:PreviewBufnr() == l:entry.bufnr
        noautocmd wincmd P
        execute l:entry.lnum
    else
        execute 'keepjumps pedit +'.l:entry.lnum bufname(l:entry.bufnr)
        noautocmd wincmd P
    endif
    normal! zz
    setlocal cursorline nofoldenable
    if !l:listed
        setlocal nobuflisted bufhidden=delete noswapfile
    endif
    noautocmd wincmd p
endfunction
function! s:PreviewBufnr()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, '&previewwindow') == 1
            return winbufnr(nr)
        endif
    endfor
    return 0
endfunction
" }}}

" Explorers {{{
let g:netrw_home = &undodir . '..'
let g:netrw_fastbrowse = 0
let g:netrw_clipboard = 0
nnoremap <silent><C-w>es :Hexplore<CR>
nnoremap <silent><C-w>ev :Vexplore!<CR>

" https://github.com/felipec/vim-sanegx/blob/e97c10401d781199ba1aecd07790d0771314f3f5/plugin/gx.vim
function! GXBrowse(url)
    let redir = '>&/dev/null'
    if exists('g:netrw_browsex_viewer')
        let viewer = g:netrw_browsex_viewer
    elseif has('unix') && executable('xdg-open')
        let viewer = 'xdg-open'
    elseif has('macunix') && executable('open')
        let viewer = 'open'
    elseif has('win64') || has('win32')
        let viewer = 'start'
        redir = '>null'
    else
        return
    endif
    execute 'silent! !' . viewer . ' ' . shellescape(a:url, 1) . redir
    redraw!
endfunction
let s:url_regex = '\c\<\%([a-z][0-9A-Za-z_-]\+:\%(\/\{1,3}\|[a-z0-9%]\)\|www\d\{0,3}[.]\|[a-z0-9.\-]\+[.][a-z]\{2,4}\/\)\%([^ \t()<>]\+\|(\([^ \t()<>]\+\|\(([^ \t()<>]\+)\)\)*)\)\+\%((\([^ \t()<>]\+\|\(([^ \t()<>]\+)\)\)*)\|[^ \t`!()[\]{};:'."'".'".,<>?«»“”‘’]\)'
function! CursorURL() abort
    return matchstr(expand('<cWORD>'), s:url_regex)
endfunction
nnoremap <silent> gx :call GXBrowse(CursorURL())<cr>
" }}}

" git {{{
let g:flog_default_arguments = { 'max_count': 512, 'all': 1, }
let g:flog_permanent_default_arguments = { 'date': 'short', }

augroup git-custom | au!
    " TODO: Very slow and doesn't fold each hunk.
    au FileType git,fugitive,gitcommit nnoremap <buffer>zM :setlocal foldmethod=syntax\|unmap <lt>buffer>zM<CR>zM
    au User FugitiveObject,FugitiveIndex silent! unmap <buffer> *
    au FileType floggraph silent! nunmap <buffer> <Tab>
augroup END
" }}}

" etc util {{{
" helpers {{{
if exists('*execute')
    function! s:execute(cmd) abort
        return execute(a:cmd)
    endfunction
else
    function! s:execute(cmd) abort
        redir => output
        execute a:cmd
        redir END
        return output
    endfunction
endif
function! s:git_root(file_or_dir) abort
    let file_or_dir = fnamemodify(expand(a:file_or_dir), ':p')
    let dir = isdirectory(file_or_dir) ? file_or_dir : fnamemodify(file_or_dir, ':h')
    let output = s:system('git -C '.dir.' rev-parse --show-toplevel')[0]
    if v:shell_error | throw output | endif
    return output
endfunction
if has('patch-8.0.1040') || has('nvim-0.3.2')
    function! s:setqflist_files(files, title) abort
        return setqflist([], ' ', {'lines': a:files, 'title': a:title, 'efm': '%f'})
    endfunction
else
    function! s:setqflist_files(files, title) abort
        return setqflist(map(a:files, '{"filename": v:val, "lnum": 1}')) " can't go to last cursor pos in these versions
    endfunction
endif
function! s:system(cmd) abort
    return split(system(a:cmd), '\n', 0)
endfunction
" escape cmdline-special and shell stuff for commands that run shell command
function! s:cmdshellescape(text) abort
    return escape(shellescape(a:text), '#%')
endfunction
function s:cabbrev(lhs, rhs) abort
    return (getcmdtype() == ':' && getcmdline() ==# a:lhs) ? a:rhs : a:lhs
endfunction
" }}}

nmap <silent><leader>st :<C-u>echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")') '->' synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')<CR>
function! Text2Magic(text)
    return escape(a:text, '\.*$^~[]')
endfunction
function! Wildignore2exclude() abort
    let exclude = copy(g:wildignore_files)
    let exclude_dir = copy(g:wildignore_dirs)
    call map(exclude, 's:cmdshellescape(v:val)')
    call map(exclude_dir, 's:cmdshellescape(v:val)')
    return '--exclude={'.join(exclude, ',').'} --exclude-dir={'.join(exclude_dir, ',').'}'
endfunction

function! Execute(cmd) abort
    let output = s:execute(a:cmd)
    new
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
endfunction
command! -nargs=* -complete=command Execute silent call Execute(<q-args>)

command! -range=% TrimWhitespace
            \ let _view = winsaveview() |
            \ keeppatterns keepjumps <line1>,<line2>substitute/\s\+$//e |
            \ call winrestview(_view) |
            \ unlet _view
noremap <leader>fm :TrimWhitespace<CR>
command! -range=% Unpdf
            \ keeppatterns keepjumps <line1>,<line2>substitute/[“”łž]/"/ge |
            \ keeppatterns keepjumps <line1>,<line2>substitute/[‘’]/'/ge |
            \ keeppatterns keepjumps <line1>,<line2>substitute/\w\zs-\n//ge

function! SubstituteDict(dict) range
    exe a:firstline . ',' . a:lastline . 'substitute'
                \ . '/\C\%(' . join(map(keys(a:dict), 'Text2Magic(v:val)'), '\|'). '\)'
                \ . '/\=a:dict[submatch(0)]/ge'
endfunction
command! -range=% -nargs=1 SubstituteDict :<line1>,<line2>call SubstituteDict(<args>)

command! -nargs=+ -bang AddWildignore call AddWildignore([<f-args>], <bang>0)
function! AddWildignore(wigs, is_dir) abort
    if a:is_dir
        let g:wildignore_dirs += a:wigs
        let globs = map(a:wigs, 'v:val.",".v:val."/,**/".v:val."/*"')
    else
        let g:wildignore_files += a:wigs
        let globs = a:wigs
    endif
    exe 'set wildignore+='.join(globs, ',')
endfunction
if !exists('g:wildignore_files')
    let [g:wildignore_files, g:wildignore_dirs] = [[], []]
    call AddWildignore(s:wildignore_files, 0)
    call AddWildignore(s:wildignore_dirs, 1)
endif

if !has('nvim')
    command! -nargs=+ -complete=shellcmd Man delcommand Man | runtime ftplugin/man.vim | if winwidth(0) > 170 | exe 'vert Man' <q-args> | else | exe 'Man' <q-args> | endif
    command! SW w !sudo tee % > /dev/null
endif
" }}}

" comments {{{
" Commentary: {{{2
" https://github.com/tpope/vim-commentary/blob/627308e30639be3e2d5402808ce18690557e8292/plugin/commentary.vim
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
  let force_uncomment = a:0 > 2 && a:3
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
    if force_uncomment
      if line =~ '^\s*' . l
        let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
      endif
    elseif uncomment
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

command! -range -bar -bang Commentary call s:commentary_go(<line1>,<line2>,<bang>0)
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
" }}}2
" Etc: {{{2
function! s:commentary_insert()
  let [l, r] = s:commentary_surroundings()
  return l . r . repeat("\<C-G>U\<Left>", strchars(r))
endfunction
inoremap <expr> <M-/> "\<C-G>u" . <SID>commentary_insert()
" }}} }}}

" vinegar {{{
" https://github.com/tpope/vim-vinegar/blob/43576e84d3034bccb1216f39f51ed36d945d7b96/plugin/vinegar.vim
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
nmap <leader>- <Plug>VinegarUp

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
    execute a:cmd '%:h' . (expand('%:p') =~# '^\a\a\+:' ? s:vinegar_slash() : '')
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

" surround {{{
" https://github.com/tpope/vim-surround/blob/f51a26d3710629d031806305b6c8727189cd1935/plugin/surround.vim
" Input functions {{{2

function! s:surround_getchar()
  let c = getchar()
  if c =~ '^\d\+$'
    let c = nr2char(c)
  endif
  return c
endfunction

function! s:surround_inputtarget()
  let c = s:surround_getchar()
  while c =~ '^\d\+$'
    let c .= s:surround_getchar()
  endwhile
  if c == " "
    let c .= s:surround_getchar()
  endif
  if c =~ "\<Esc>\|\<C-C>\|\0"
    return ""
  else
    return c
  endif
endfunction

function! s:surround_inputreplacement()
  let c = s:surround_getchar()
  if c == " "
    let c .= s:surround_getchar()
  endif
  if c =~ "\<Esc>" || c =~ "\<C-C>"
    return ""
  else
    return c
  endif
endfunction

function! s:surround_beep()
  exe "norm! \<Esc>"
  return ""
endfunction

function! s:surround_redraw()
  redraw
  return ""
endfunction

" }}}2

" Wrapping functions {{{2

function! s:surround_extractbefore(str)
  if a:str =~ '\r'
    return matchstr(a:str,'.*\ze\r')
  else
    return matchstr(a:str,'.*\ze\n')
  endif
endfunction

function! s:surround_extractafter(str)
  if a:str =~ '\r'
    return matchstr(a:str,'\r\zs.*')
  else
    return matchstr(a:str,'\n\zs.*')
  endif
endfunction

function! s:surround_fixindent(str,spc)
  let str = substitute(a:str,'\t',repeat(' ',&sw),'g')
  let spc = substitute(a:spc,'\t',repeat(' ',&sw),'g')
  let str = substitute(str,'\(\n\|\%^\).\@=','\1'.spc,'g')
  if ! &et
    let str = substitute(str,'\s\{'.&ts.'\}',"\t",'g')
  endif
  return str
endfunction

function! s:surround_process(string)
  let i = 0
  for i in range(7)
    let repl_{i} = ''
    let m = matchstr(a:string,nr2char(i).'.\{-\}\ze'.nr2char(i))
    if m != ''
      let m = substitute(strpart(m,1),'\r.*','','')
      let repl_{i} = input(match(m,'\w\+$') >= 0 ? m.': ' : m)
    endif
  endfor
  let s = ""
  let i = 0
  while i < strlen(a:string)
    let char = strpart(a:string,i,1)
    if char2nr(char) < 8
      let next = stridx(a:string,char,i+1)
      if next == -1
        let s .= char
      else
        let insertion = repl_{char2nr(char)}
        let subs = strpart(a:string,i+1,next-i-1)
        let subs = matchstr(subs,'\r.*')
        while subs =~ '^\r.*\r'
          let sub = matchstr(subs,"^\r\\zs[^\r]*\r[^\r]*")
          let subs = strpart(subs,strlen(sub)+1)
          let r = stridx(sub,"\r")
          let insertion = substitute(insertion,strpart(sub,0,r),strpart(sub,r+1),'')
        endwhile
        let s .= insertion
        let i = next
      endif
    else
      let s .= char
    endif
    let i += 1
  endwhile
  return s
endfunction

function! s:surround_wrap(string,char,type,removed,special)
  let keeper = a:string
  let newchar = a:char
  let s:surround_input = ""
  let type = a:type
  let linemode = type ==# 'V' ? 1 : 0
  let before = ""
  let after  = ""
  if type ==# "V"
    let initspaces = matchstr(keeper,'\%^\s*')
  else
    let initspaces = matchstr(getline('.'),'\%^\s*')
  endif
  let pairs = "b()B{}r[]a<>"
  let extraspace = ""
  if newchar =~ '^ '
    let newchar = strpart(newchar,1)
    let extraspace = ' '
  endif
  let idx = stridx(pairs,newchar)
  if newchar == ' '
    let before = ''
    let after  = ''
  elseif exists("b:surround_".char2nr(newchar))
    let all    = s:surround_process(b:surround_{char2nr(newchar)})
    let before = s:surround_extractbefore(all)
    let after  =  s:surround_extractafter(all)
  elseif exists("g:surround_".char2nr(newchar))
    let all    = s:surround_process(g:surround_{char2nr(newchar)})
    let before = s:surround_extractbefore(all)
    let after  =  s:surround_extractafter(all)
  elseif newchar ==# "p"
    let before = "\n"
    let after  = "\n\n"
  elseif newchar ==# 's'
    let before = ' '
    let after  = ''
  elseif newchar ==# ':'
    let before = ':'
    let after = ''
  elseif newchar =~# "[tT\<C-T><]"
    let dounmapp = 0
    let dounmapb = 0
    if !maparg(">","c")
      let dounmapb = 1
      " Hide from AsNeeded
      exe "cn"."oremap > ><CR>"
    endif
    let default = ""
    if newchar ==# "T"
      if !exists("s:surround_lastdel")
        let s:surround_lastdel = ""
      endif
      let default = matchstr(s:surround_lastdel,'<\zs.\{-\}\ze>')
    endif
    let tag = input("<",default)
    if dounmapb
      silent! cunmap >
    endif
    let s:surround_input = tag
    if tag != ""
      let keepAttributes = ( match(tag, ">$") == -1 )
      let tag = substitute(tag,'>*$','','')
      let attributes = ""
      if keepAttributes
        let attributes = matchstr(a:removed, '<[^ \t\n]\+\zs\_.\{-\}\ze>')
      endif
      let s:surround_input = tag . '>'
      if tag =~ '/$'
        let tag = substitute(tag, '/$', '', '')
        let before = '<'.tag.attributes.' />'
        let after = ''
      else
        let before = '<'.tag.attributes.'>'
        let after  = '</'.substitute(tag,' .*','','').'>'
      endif
      if newchar == "\<C-T>"
        if type ==# "v" || type ==# "V"
          let before .= "\n\t"
        endif
        if type ==# "v"
          let after  = "\n". after
        endif
      endif
    endif
  elseif newchar ==# 'l' || newchar == '\'
    " LaTeX
    let env = input('\begin{')
    if env != ""
      let s:surround_input = env."\<CR>"
      let env = '{' . env
      let env .= s:surround_closematch(env)
      echo '\begin'.env
      let before = '\begin'.env
      let after  = '\end'.matchstr(env,'[^}]*').'}'
    endif
  elseif newchar ==# 'f' || newchar ==# 'F'
    let fnc = input('function: ')
    if fnc != ""
      let s:surround_input = fnc."\<CR>"
      let before = substitute(fnc,'($','','').'('
      let after  = ')'
      if newchar ==# 'F'
        let before .= ' '
        let after = ' ' . after
      endif
    endif
  elseif newchar ==# "\<C-F>"
    let fnc = input('function: ')
    let s:surround_input = fnc."\<CR>"
    let before = '('.fnc.' '
    let after = ')'
  elseif idx >= 0
    let spc = (idx % 3) == 1 ? " " : ""
    let idx = idx / 3 * 3
    let before = strpart(pairs,idx+1,1) . spc
    let after  = spc . strpart(pairs,idx+2,1)
  elseif newchar == "\<C-[>" || newchar == "\<C-]>"
    let before = "{\n\t"
    let after  = "\n}"
  elseif newchar !~ '\a'
    let before = newchar
    let after  = newchar
  else
    let before = ''
    let after  = ''
  endif
  let after  = substitute(after ,'\n','\n'.initspaces,'g')
  if type ==# 'V' || (a:special && type ==# "v")
    let before = substitute(before,' \+$','','')
    let after  = substitute(after ,'^ \+','','')
    if after !~ '^\n'
      let after  = initspaces.after
    endif
    if keeper !~ '\n$' && after !~ '^\n'
      let keeper .= "\n"
    elseif keeper =~ '\n$' && after =~ '^\n'
      let after = strpart(after,1)
    endif
    if keeper !~ '^\n' && before !~ '\n\s*$'
      let before .= "\n"
      if a:special
        let before .= "\t"
      endif
    elseif keeper =~ '^\n' && before =~ '\n\s*$'
      let keeper = strcharpart(keeper,1)
    endif
    if type ==# 'V' && keeper =~ '\n\s*\n$'
      let keeper = strcharpart(keeper,0,strchars(keeper) - 1)
    endif
  endif
  if type ==# 'V'
    let before = initspaces.before
  endif
  if before =~ '\n\s*\%$'
    if type ==# 'v'
      let keeper = initspaces.keeper
    endif
    let padding = matchstr(before,'\n\zs\s\+\%$')
    let before  = substitute(before,'\n\s\+\%$','\n','')
    let keeper = s:surround_fixindent(keeper,padding)
  endif
  if type ==# 'V'
    let keeper = before.keeper.after
  elseif type =~ "^\<C-V>"
    " Really we should be iterating over the buffer
    let repl = substitute(before,'[\\~]','\\&','g').'\1'.substitute(after,'[\\~]','\\&','g')
    let repl = substitute(repl,'\n',' ','g')
    let keeper = substitute(keeper."\n",'\(.\{-\}\)\(\n\)',repl.'\n','g')
    let keeper = substitute(keeper,'\n\%$','','')
  else
    let keeper = before.extraspace.keeper.extraspace.after
  endif
  return keeper
endfunction

function! s:surround_wrapreg(reg,char,removed,special)
  let orig = getreg(a:reg)
  let type = substitute(getregtype(a:reg),'\d\+$','','')
  let new = s:surround_wrap(orig,a:char,type,a:removed,a:special)
  call setreg(a:reg,new,type)
endfunction
" }}}2

function! s:surround_insert(...) " {{{2
  " Optional argument causes the result to appear on 3 lines, not 1
  let linemode = a:0 ? a:1 : 0
  let char = s:surround_inputreplacement()
  while char == "\<CR>" || char == "\<C-S>"
    let linemode += 1
    let char = s:surround_inputreplacement()
  endwhile
  if char == ""
    return ""
  endif
  let cb_save = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let reg_save = @@
  call setreg('"',"\r",'v')
  call s:surround_wrapreg('"',char,"",linemode)
  " If line mode is used and the surrounding consists solely of a suffix,
  " remove the initial newline.  This fits a use case of mine but is a
  " little inconsistent.  Is there anyone that would prefer the simpler
  " behavior of just inserting the newline?
  if linemode && match(getreg('"'),'^\n\s*\zs.*') == 0
    call setreg('"',matchstr(getreg('"'),'^\n\s*\zs.*'),getregtype('"'))
  endif
  " This can be used to append a placeholder to the end
  if exists("g:surround_insert_tail")
    call setreg('"',g:surround_insert_tail,"a".getregtype('"'))
  endif
  if &ve != 'all' && col('.') >= col('$')
    if &ve == 'insert'
      let extra_cols = virtcol('.') - virtcol('$')
      if extra_cols > 0
        let [regval,regtype] = [getreg('"',1,1),getregtype('"')]
        call setreg('"',join(map(range(extra_cols),'" "'),''),'v')
        norm! ""p
        call setreg('"',regval,regtype)
      endif
    endif
    norm! ""p
  else
    norm! ""P
  endif
  if linemode
    call s:surround_reindent()
  endif
  norm! `]
  call search('\r','bW')
  let @@ = reg_save
  let &clipboard = cb_save
  return "\<Del>"
endfunction " }}}2

function! s:surround_reindent() " {{{2
  if exists("b:surround_indent") ? b:surround_indent : (!exists("g:surround_indent") || g:surround_indent)
    silent norm! '[=']
  endif
endfunction " }}}2

function! s:surround_dosurround(...) " {{{2
  let scount = v:count1
  let char = (a:0 ? a:1 : s:surround_inputtarget())
  let spc = ""
  if char =~ '^\d\+'
    let scount = scount * matchstr(char,'^\d\+')
    let char = substitute(char,'^\d\+','','')
  endif
  if char =~ '^ '
    let char = strpart(char,1)
    let spc = 1
  endif
  if char == 'a'
    let char = '>'
  endif
  if char == 'r'
    let char = ']'
  endif
  let newchar = ""
  if a:0 > 1
    let newchar = a:2
    if newchar == "\<Esc>" || newchar == "\<C-C>" || newchar == ""
      return s:surround_beep()
    endif
  endif
  let cb_save = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let append = ""
  let original = getreg('"')
  let otype = getregtype('"')
  call setreg('"',"")
  let strcount = (scount == 1 ? "" : scount)
  if char == '/'
    exe 'norm! '.strcount.'[/d'.strcount.']/'
  elseif char =~# '[[:punct:][:space:]]' && char !~# '[][(){}<>"''`]'
    exe 'norm! T'.char
    if getline('.')[col('.')-1] == char
      exe 'norm! l'
    endif
    exe 'norm! dt'.char
  else
    exe 'norm! d'.strcount.'i'.char
  endif
  let keeper = getreg('"')
  let okeeper = keeper " for reindent below
  if keeper == ""
    call setreg('"',original,otype)
    let &clipboard = cb_save
    return ""
  endif
  let oldline = getline('.')
  let oldlnum = line('.')
  if char ==# "p"
    call setreg('"','','V')
  elseif char ==# "s" || char ==# "w" || char ==# "W"
    " Do nothing
    call setreg('"','')
  elseif char =~ "[\"'`]"
    exe "norm! i \<Esc>d2i".char
    call setreg('"',substitute(getreg('"'),' ','',''))
  elseif char == '/'
    norm! "_x
    call setreg('"','/**/',"c")
    let keeper = substitute(substitute(keeper,'^/\*\s\=','',''),'\s\=\*$','','')
  elseif char =~# '[[:punct:][:space:]]' && char !~# '[][(){}<>]'
    exe 'norm! F'.char
    exe 'norm! df'.char
  else
    " One character backwards
    call search('\m.', 'bW')
    exe "norm! da".char
  endif
  let removed = getreg('"')
  let rem2 = substitute(removed,'\n.*','','')
  let oldhead = strpart(oldline,0,strlen(oldline)-strlen(rem2))
  let oldtail = strpart(oldline,  strlen(oldline)-strlen(rem2))
  let regtype = getregtype('"')
  if char =~# '[\[({<T]' || spc
    let keeper = substitute(keeper,'^\s\+','','')
    let keeper = substitute(keeper,'\s\+$','','')
  endif
  if col("']") == col("$") && virtcol('.') + 1 == virtcol('$')
    if oldhead =~# '^\s*$' && a:0 < 2
      let keeper = substitute(keeper,'\%^\n'.oldhead.'\(\s*.\{-\}\)\n\s*\%$','\1','')
    endif
    let pcmd = "p"
  else
    let pcmd = "P"
  endif
  if line('.') + 1 < oldlnum && regtype ==# "V"
    let pcmd = "p"
  endif
  call setreg('"',keeper,regtype)
  if newchar != ""
    let special = a:0 > 2 ? a:3 : 0
    call s:surround_wrapreg('"',newchar,removed,special)
  endif
  silent exe 'norm! ""'.pcmd.'`['
  if removed =~ '\n' || okeeper =~ '\n' || getreg('"') =~ '\n'
    call s:surround_reindent()
  endif
  if getline('.') =~ '^\s\+$' && keeper =~ '^\s*\n'
    silent norm! cc
  endif
  call setreg('"',original,otype)
  let s:surround_lastdel = removed
  let &clipboard = cb_save
  if newchar == ""
    silent! call s:repeat_set("\<Plug>Dsurround".char,scount)
  else
    silent! call s:repeat_set("\<Plug>C".(a:0 > 2 && a:3 ? "S" : "s")."urround".char.newchar.s:surround_input,scount)
  endif
endfunction " }}}2

function! s:surround_changesurround(...) " {{{2
  let a = s:surround_inputtarget()
  if a == ""
    return s:surround_beep()
  endif
  let b = s:surround_inputreplacement()
  if b == ""
    return s:surround_beep()
  endif
  call s:surround_dosurround(a,b,a:0 && a:1)
endfunction " }}}2

function! s:surround_opfunc(type, ...) abort " {{{2
  if a:type ==# 'setup'
    let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
    return 'g@'
  endif
  let char = s:surround_inputreplacement()
  if char == ""
    return s:surround_beep()
  endif
  let reg = '"'
  let sel_save = &selection
  let &selection = "inclusive"
  let cb_save  = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let reg_save = getreg(reg)
  let reg_type = getregtype(reg)
  let type = a:type
  if a:type == "char"
    silent exe 'norm! v`[o`]"'.reg.'y'
    let type = 'v'
  elseif a:type == "line"
    silent exe 'norm! `[V`]"'.reg.'y'
    let type = 'V'
  elseif a:type ==# "v" || a:type ==# "V" || a:type ==# "\<C-V>"
    let &selection = sel_save
    let ve = &virtualedit
    if !(a:0 && a:1)
      set virtualedit=
    endif
    silent exe 'norm! gv"'.reg.'y'
    let &virtualedit = ve
  elseif a:type =~ '^\d\+$'
    let type = 'v'
    silent exe 'norm! ^v'.a:type.'$h"'.reg.'y'
    if mode() ==# 'v'
      norm! v
      return s:surround_beep()
    endif
  else
    let &selection = sel_save
    let &clipboard = cb_save
    return s:surround_beep()
  endif
  let keeper = getreg(reg)
  if type ==# "v" && a:type !=# "v"
    let append = matchstr(keeper,'\_s\@<!\s*$')
    let keeper = substitute(keeper,'\_s\@<!\s*$','','')
  endif
  call setreg(reg,keeper,type)
  call s:surround_wrapreg(reg,char,"",a:0 && a:1)
  if type ==# "v" && a:type !=# "v" && append != ""
    call setreg(reg,append,"ac")
  endif
  silent exe 'norm! gv'.(reg == '"' ? '' : '"' . reg).'p`['
  if type ==# 'V' || (getreg(reg) =~ '\n' && type ==# 'v')
    call s:surround_reindent()
  endif
  call setreg(reg,reg_save,reg_type)
  let &selection = sel_save
  let &clipboard = cb_save
  if a:type =~ '^\d\+$'
    silent! call s:repeat_set("\<Plug>Y".(a:0 && a:1 ? "S" : "s")."surround".char.s:surround_input,a:type)
  else
    silent! call s:repeat_set("\<Plug>SurroundRepeat".char.s:surround_input)
  endif
endfunction

function! s:surround_opfunc2(...) abort
  if !a:0 || a:1 ==# 'setup'
    let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
    return 'g@'
  endif
  call s:surround_opfunc(a:1, 1)
endfunction " }}}2

function! s:surround_closematch(str) " {{{2
  " Close an open (, {, [, or < on the command line.
  let tail = matchstr(a:str,'.[^\[\](){}<>]*$')
  if tail =~ '^\[.\+'
    return "]"
  elseif tail =~ '^(.\+'
    return ")"
  elseif tail =~ '^{.\+'
    return "}"
  elseif tail =~ '^<.+'
    return ">"
  else
    return ""
  endif
endfunction " }}}2

nnoremap <silent> <Plug>SurroundRepeat .
nnoremap <silent> <Plug>Dsurround  :<C-U>call <SID>surround_dosurround(<SID>surround_inputtarget())<CR>
nnoremap <silent> <Plug>Csurround  :<C-U>call <SID>surround_changesurround()<CR>
nnoremap <silent> <Plug>CSurround  :<C-U>call <SID>surround_changesurround(1)<CR>
nnoremap <expr>   <Plug>Yssurround '^'.v:count1.<SID>surround_opfunc('setup').'g_'
nnoremap <expr>   <Plug>YSsurround <SID>surround_opfunc2('setup').'_'
nnoremap <expr>   <Plug>Ysurround  <SID>surround_opfunc('setup')
nnoremap <expr>   <Plug>YSurround  <SID>surround_opfunc2('setup')
vnoremap <silent> <Plug>VSurround  :<C-U>call <SID>surround_opfunc(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
vnoremap <silent> <Plug>VgSurround :<C-U>call <SID>surround_opfunc(visualmode(),visualmode() ==# 'V' ? 0 : 1)<CR>
inoremap <silent> <Plug>Isurround  <C-R>=<SID>surround_insert()<CR>
inoremap <silent> <Plug>ISurround  <C-R>=<SID>surround_insert(1)<CR>

if !exists("g:surround_no_mappings") || ! g:surround_no_mappings
  nmap ds  <Plug>Dsurround
  nmap cs  <Plug>Csurround
  nmap cS  <Plug>CSurround
  nmap ys  <Plug>Ysurround
  nmap yS  <Plug>YSurround
  nmap yss <Plug>Yssurround
  nmap ySs <Plug>YSsurround
  nmap ySS <Plug>YSsurround
  xmap S   <Plug>VSurround
  xmap gS  <Plug>VgSurround
  if !exists("g:surround_no_insert_mappings") || ! g:surround_no_insert_mappings
    if !hasmapto("<Plug>Isurround","i") && "" == mapcheck("<C-S>","i")
      imap    <C-S> <Plug>Isurround
    endif
    imap      <C-G>s <Plug>Isurround
    imap      <C-G>S <Plug>ISurround
  endif
endif
" }}}

" repeat {{{
" https://github.com/tpope/vim-repeat/blob/24afe922e6a05891756ecf331f39a1f6743d3d5a/autoload/repeat.vim
let g:repeat_tick = -1
let g:repeat_reg = ['', '']

" Special function to avoid spurious repeats in a related, naturally repeating
" mapping when your repeatable mapping doesn't increase b:changedtick.
function! s:repeat_invalidate()
    autocmd! repeat_custom_motion
    let g:repeat_tick = -1
endfunction

function! s:repeat_set(sequence,...)
    let g:repeat_sequence = a:sequence
    let g:repeat_count = a:0 ? a:1 : v:count
    let g:repeat_tick = b:changedtick
    augroup repeat_custom_motion
        autocmd!
        autocmd CursorMoved <buffer> let g:repeat_tick = b:changedtick | autocmd! repeat_custom_motion
    augroup END
endfunction

function! s:repeat_setreg(sequence,register)
    let g:repeat_reg = [a:sequence, a:register]
endfunction


function! s:default_register()
    let values = split(&clipboard, ',')
    if index(values, 'unnamedplus') != -1
        return '+'
    elseif index(values, 'unnamed') != -1
        return '*'
    else
        return '"'
    endif
endfunction

function! s:repeat_run(count)
    let s:repeat_errmsg_ = ''
    try
        if g:repeat_tick == b:changedtick
            let r = ''
            if g:repeat_reg[0] ==# g:repeat_sequence && !empty(g:repeat_reg[1])
                " Take the original register, unless another (non-default, we
                " unfortunately cannot detect no vs. a given default register)
                " register has been supplied to the repeat command (as an
                " explicit override).
                let regname = v:register ==# s:default_register() ? g:repeat_reg[1] : v:register
                if regname ==# '='
                    " This causes a re-evaluation of the expression on repeat, which
                    " is what we want.
                    let r = '"=' . getreg('=', 1) . "\<CR>"
                else
                    let r = '"' . regname
                endif
            endif

            let c = g:repeat_count
            let s = g:repeat_sequence
            let cnt = c == -1 ? "" : (a:count ? a:count : (c ? c : ''))
            if ((v:version == 703 && has('patch100')) || (v:version == 704 && !has('patch601')))
                exe 'norm ' . r . cnt . s
            elseif v:version <= 703
                call feedkeys(r . cnt, 'n')
                call feedkeys(s, '')
            else
                call feedkeys(s, 'i')
                call feedkeys(r . cnt, 'ni')
            endif
        else
            if ((v:version == 703 && has('patch100')) || (v:version == 704 && !has('patch601')))
                exe 'norm! '.(a:count ? a:count : '') . '.'
            else
                call feedkeys((a:count ? a:count : '') . '.', 'ni')
            endif
        endif
    catch /^Vim(normal):/
        let s:repeat_errmsg_ = v:errmsg
        return 0
    endtry
    return 1
endfunction
function! s:repeat_errmsg()
    return s:repeat_errmsg_
endfunction

function! s:repeat_wrap(command,count)
    let preserve = (g:repeat_tick == b:changedtick)
    call feedkeys((a:count ? a:count : '').a:command, 'n')
    exe (&foldopen =~# 'undo\|all' ? 'norm! zv' : '')
    if preserve
        let g:repeat_tick = b:changedtick
    endif
endfunction

nnoremap <silent> <Plug>(RepeatDot)      :<C-U>if !<SID>repeat_run(v:count)<Bar>echoerr <SID>repeat_errmsg()<Bar>endif<CR>
nnoremap <silent> <Plug>(RepeatUndo)     :<C-U>call <SID>repeat_wrap('u',v:count)<CR>
nnoremap <silent> <Plug>(RepeatUndoLine) :<C-U>call <SID>repeat_wrap('U',v:count)<CR>
nnoremap <silent> <Plug>(RepeatRedo)     :<C-U>call <SID>repeat_wrap("\<Lt>C-R>",v:count)<CR>

if !hasmapto('<Plug>(RepeatDot)', 'n')
    nmap . <Plug>(RepeatDot)
endif
if !hasmapto('<Plug>(RepeatUndo)', 'n')
    nmap u <Plug>(RepeatUndo)
endif
if maparg('U','n') ==# '' && !hasmapto('<Plug>(RepeatUndoLine)', 'n')
    nmap U <Plug>(RepeatUndoLine)
endif
if !hasmapto('<Plug>(RepeatRedo)', 'n')
    nmap <C-R> <Plug>(RepeatRedo)
endif

augroup repeatPlugin
    autocmd!
    autocmd BufLeave,BufWritePre,BufReadPre * let g:repeat_tick = (g:repeat_tick == b:changedtick || g:repeat_tick == 0) ? 0 : -1
    autocmd BufEnter,BufWritePost * if g:repeat_tick == 0|let g:repeat_tick = b:changedtick|endif
augroup END
" }}}

" colorscheme {{{
set background=dark

" :h group-name
hi! Comment      term=NONE ctermfg=108 guifg=#87af87
hi! Constant     term=underline ctermfg=152 guifg=#afd7d7
hi! Identifier   term=NONE cterm=NONE ctermfg=NONE guifg=NONE
hi! Statement    term=bold cterm=bold ctermfg=NONE gui=bold guifg=NONE
hi! PreProc      term=bold cterm=bold ctermfg=NONE gui=bold guifg=NONE
hi! Type         term=NONE ctermfg=NONE gui=NONE guifg=NONE
hi! StorageClass term=italic cterm=italic gui=italic
hi! link Structure Keyword
hi! link Typedef Keyword
hi! Special      term=underline ctermfg=224 guifg=#ffd7d7
hi! Delimiter    ctermfg=252 guifg=#bcbcbc
hi! Underlined   ctermfg=143 guifg=#afaf5f
hi! Todo         cterm=bold,reverse ctermfg=218 ctermbg=NONE gui=bold,reverse guifg=#ffafd7 guibg=NONE

" :h highlight-groups
hi! link Conceal Special
hi! DiffAdd      ctermbg=22 guibg=#284028
hi! DiffChange   ctermbg=234 guibg=#1c1c1c
hi! DiffDelete   ctermfg=203 ctermbg=16 guifg=#ff5f5f guibg=#000000
hi! DiffText     cterm=NONE ctermbg=60 gui=NONE guibg=#484060
hi! VertSplit    cterm=NONE ctermbg=16 ctermfg=252 gui=NONE guibg=#000000 guifg=#d0d0d0
hi! Folded       ctermfg=252 ctermbg=16 guifg=#d0d0d0 guibg=#000000
hi! FoldColumn   ctermbg=NONE ctermfg=238 guibg=NONE guifg=#444444
hi! IncSearch    cterm=bold,underline,reverse gui=bold,underline,reverse
hi! LineNr       ctermfg=250 guifg=#bcbcbc
hi! MatchParen   cterm=bold,underline ctermfg=231 ctermbg=67 gui=bold,underline guifg=#ffffff guibg=#5f87af
hi! NonText      ctermfg=242 gui=NONE guifg=#6c6c6c
hi! Normal       ctermbg=233 guibg=#121212 ctermfg=255 guifg=#eeeeee
hi! NormalFloat  ctermbg=235 guibg=#262626
hi! Pmenu        ctermbg=16 ctermfg=252 guibg=#000000 guifg=#d0d0d0
hi! PmenuSel     ctermbg=241 ctermfg=231 guibg=#626262 guifg=#ffffff
hi! Search       cterm=bold,underline ctermfg=180 ctermbg=238 gui=bold,underline guifg=#d7af87 guibg=#444444
hi! SpecialKey   ctermfg=242 guifg=#6c6c6c
exe 'hi! SpellBad cterm=undercurl ctermbg=NONE guisp=#ff5f5f' . (has('patch-8.2.0863') ? ' ctermul=203' : '')
exe 'hi! SpellCap cterm=undercurl ctermbg=NONE guisp=#ffaf5f' . (has('patch-8.2.0863') ? ' ctermul=215' : '')
hi! Title        term=bold cterm=bold ctermfg=150 gui=bold guifg=#afd787
hi! Visual       ctermbg=241 guibg=#626262

" Filetypes:
hi! diffAdded    ctermfg=150 guifg=#afd787
hi! diffRemoved  ctermfg=203 guifg=#ff5f5f

hi! link helpHyperTextJump Underlined
hi! link helpOption Underlined

hi! link markdownCode String
hi! link markdownCodeDelimiter String

hi! link rustCommentLineDoc Comment
hi! link rustLabel Special
hi! link rustModPath NONE

hi! link shCommandSub NONE
hi! link shArithmetic NONE
hi! link shShellVariables Identifier
hi! link shSpecial Constant
hi! link shSpecialDQ shSpecial
hi! link shSpecialSQ shSpecial

hi! link vimCommentTitle Title
" }}}
" vim: set fdm=marker et sw=4:
