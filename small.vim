if &compatible | set nocompatible | endif

if !has('nvim')
    let g:loaded_getscriptPlugin = 1
    let g:loaded_rrhelper = 1
    let g:loaded_logiPat = 1
endif
let g:loaded_spellfile_plugin = 1

" set runtimepath above this line for correct ftdetect
if exists("did_load_filetypes") | filetype off | endif
filetype plugin indent on

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
command! -nargs=1 Noremap exe 'nnoremap' <q-args> | exe 'xnoremap' <q-args> | exe 'onoremap' <q-args> 
command! -nargs=1 Map exe 'nmap' <q-args> | exe 'xmap' <q-args> | exe 'omap' <q-args>

if has('vim_starting')
set encoding=utf-8

set mouse=nvi
set number
set ruler showcmd
set foldcolumn=1 foldnestmax=5
set scrolloff=2 sidescrolloff=2 sidescroll=1 startofline
set showtabline=1
set laststatus=2

set shiftwidth=4
set expandtab smarttab
set autoindent
set formatoptions+=jn formatoptions-=c
set formatlistpat=\\C^\\s*[\\[({]\\\?\\([0-9]\\+\\\|[iIvVxXlLcCdDmM]\\+\\\|[a-zA-Z]\\)[\\]:.)}]\\s\\+\\\|^\\s*[-+o*]\\s\\+
set nojoinspaces
set list listchars=tab:\|\ ,trail:-,nbsp:+,extends:>

set wrap linebreak breakindent showbreak=↪\ 
let &backspace = (has('patch-8.2.0590') || has('nvim-0.5')) ? 3 : 2
set whichwrap+=<,>,[,],h,l
set cpoptions-=_

let $LANG='en'
set langmenu=en
set spelllang=en,cjk

let mapleader = "\<Space>"
Noremap <Space> <Nop>
let maplocalleader = ","
Noremap , <Nop>
Noremap <M-;> ,
" scrolling with only left hand
Noremap <C-Space> <C-u>
Noremap <Space><Space> <C-d>
" digraph
noremap! <C-Space> <C-k>

set wildmenu wildmode=longest:full,full
let s:wildignore_files = ['*~', '%*', '*.o', '*.so', '*.pyc', '*.pdf', '*.v.d', '*.vo*', '*.glob', '*.cm*', '*.aux']
let s:wildignore_dirs = ['.git', '__pycache__', 'target']
set complete-=i complete-=u completeopt=menuone,preview
if exists('+completepopup') " 8.1.1951
    set completeopt+=popup completepopup=highlight:NormalFloat,border:off
endif
set path=.,,

set ignorecase smartcase tagcase=match
set hlsearch incsearch

set noerrorbells novisualbell t_vb=
set shortmess+=Ic shortmess-=S
set belloff=all

set history=1000
set viminfo=!,'150,<50,s30,h,r/tmp,r/run,rterm://,rfugitive://,rfern://,rman://,rtemp://
set updatetime=1234
set backup undofile noswapfile
if has('nvim')
    set backupdir-=.
    let s:backupdir = &backupdir
    let s:undodir = &undodir
else
    let s:dotvim = has('win32') ? 'vimfiles' : '.vim'
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
endif

augroup BasicSetup | au!
    au BufRead * if empty(&buftype) && &filetype !~# '\v%(commit)' && line("'\"") > 1 && line("'\"") <= line("$") | exec "norm! g`\"" | endif
    au VimEnter * exec 'tabdo windo clearjumps' | tabnext
    if has('nvim-0.5')
        au TextYankPost * silent! lua vim.highlight.on_yank()
    endif
augroup END
" }}}

" fix terminal vim problems {{{
if !has('gui_running') && !has('nvim')
    if !has('patch-8.2.0852')
        silent! !stty -ixon > /dev/null 2>/dev/null
    endif

    if $TERM ==# 'xterm-kitty'
        " https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
        set t_ut=
    elseif $TERM =~# '\v(tmux|screen)-256'
        " term=tmux-256color messes up ctrl-arrows
        set term=xterm-256color
        " set to xterm in tmux, which doesn't support window resizing with mouse
        set ttymouse=sgr
    endif

    " Keys: {{{
    " NOTE: <M- keys can be affected by 'encoding'.
    " NOTE: Characters that come after <Esc> in terminal codes: [ ] P \ M O
    " (see term.c and `set termcap`)
    let s:my_meta_keys = ['+', '-', '/', '0', ';', 'c', 'P', 'n', 'p', 'q', 'y'] + [',', '.', '\', ']', '\|']
    " These terminal options conflict with my <M- mappings.
    " Fortunately, they are not important and can be disabled.
    set t_IS= t_RF= t_RB= t_SC= t_ts= " uses <Esc>]
    set t_RS= " uses <Esc>P and <ESC>\
    if $TERM ==# 'xterm-kitty'
        set t_ds= " uses <Esc>]
        " t_ke " uses <Esc>>
        " t_ks " uses <Esc>=
        " Setting <M-P> breaks stuff in kitty, even if there is no remaining termcap option using <Esc>P.
        call remove(s:my_meta_keys, index(s:my_meta_keys, 'P'))
    endif
    for c in s:my_meta_keys
        exe 'set <M-'.c.'>='."\<Esc>".c
        exe 'noremap  <M-'.c.'>' c
        exe 'noremap! <M-'.c.'>' c
    endfor
    unlet! s:my_meta_keys
    " NOTE: "set <C-M-j>=\<Esc>\<NL>" breaks stuff. So use <C-M-n> instead.
    exe "set <C-M-n>=\<Esc>\<C-n>"
    exe "set <C-M-k>=\<Esc>\<C-k>"
    exe "set <C-M-l>=\<Esc>\<C-l>"
    " <M-BS>, <C-space> are not :set-able. So there is no nice way to use them
    " in multi-char mapping that both vim and nvim understand.
    exe "set <F34>=\<Esc>\<C-?>"
    map! <F34> <M-BS>
    map  <Nul> <C-Space>
    map! <Nul> <C-Space>
    " }}}

    " :h undercurl
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"
endif
" }}}

" gui settings {{{
function! s:SetupGUI() abort
    command! -nargs=? Font call s:SetFont(<q-args>)
    function! s:SetFont(font) abort
        if !has('nvim') && has('gui_gtk2')
            let &guifont = substitute(a:font, ':h', ' ', '')
        elseif exists('g:GuiLoaded') " nvim-qt: suppress warnings like "reports bad fixed pitch metrics"
            call GuiFont(a:font, 1)
        else
            let &guifont = a:font
        endif
    endfunction

    nnoremap <C--> <Cmd>FontSize -v:count1<CR>
    if !has('nvim')
        nnoremap <C-_> <Cmd>FontSize -v:count1<CR>
    endif
    nnoremap <C-+> <Cmd>FontSize v:count1<CR>
    nnoremap <C-=> <Cmd>FontSize v:count1<CR>
    command! -nargs=1 FontSize call s:FontSize(<args>)
    function! s:FontSize(delta)
        let new_size = matchstr(&guifont, '\d\+') + a:delta
        let new_size = (new_size < 1) ? 1 : ((new_size > 100) ? 100 : new_size)
        call s:SetFont(substitute(&guifont, '\d\+', '\=new_size', ''))
        let &guifontwide = substitute(&guifontwide, '\d\+', '\=new_size', '')
    endfunction

    Font Iosevka Custom:h10
    if has('win32')
        let &guifontwide = 'Malgun Gothic:h10'
    endif

    if !has('nvim')
        set guioptions=i
        set guicursor+=a:blinkon0
    elseif exists('g:GuiLoaded') " nvim-qt
        GuiTabline 0
        GuiPopupmenu 0
    endif
endfunction

if has('nvim')
    au UIEnter * ++once if has('nvim-0.9') ? has('gui_running') : v:event.chan | call s:SetupGUI() | endif
elseif has('gui_running')
    call s:SetupGUI()
endif
" }}}

" statusline & tabline {{{
let &statusline = join([ '%( %w%q%h%)%( %{STLTitle()}%) %<',
                       \ '%( %m%r%{get(b:,"git_status","")}%)',
                       \ '%=',
                       \ ' %3p%% ',
                       \ ' %3l:%-2c '
                       \], '')
set tabline=%!TALFunc()
let g:qf_disable_statusline = 1

function! TALFunc() abort
    let s = ''
    for i in range(tabpagenr('$'))
        let s .= (i + 1 == tabpagenr()) ? '%#TabLineSel#' : '%#TabLine#'
        let s .= '%' . (i + 1) . 'T ' . (i + 1) . ': %{TALLabel(' . (i + 1) . ')} '
    endfor
    let s .= '%T%#TabLineFill#'
    return s
endfunction

function! TALLabel(t) abort
    return STLTitle(win_getid(tabpagewinnr(a:t), a:t))
endfunction

function! STLTitle(...) abort
    let w = a:0 ? a:1 : win_getid()
    let b = winbufnr(w)
    let bt = getbufvar(b, '&buftype')
    let ft = getbufvar(b, '&filetype')
    let bname = bufname(b)
    " NOTE: bt=quickfix,help decides filetype
    if bt is# 'quickfix'
        " NOTE: getwininfo() to differentiate quickfix window and location window
        return gettabwinvar(win_id2tabwin(w)[0], w, 'quickfix_title', ':')
    elseif bt is# 'help'
        return fnamemodify(bname, ':t')
    elseif bt is# 'terminal'
        return has('nvim') ? '!' . fnamemodify(matchstr(bname, 'term://.\{-}//\d\+:\zs.*'), ':t') : bname
    elseif bname =~# '^fugitive://'
        let [obj, gitdir] = FugitiveParse(bname)
        let matches = matchlist(obj, '\v(:\d?|\x+)(:\f*)?')
        return pathshorten(fnamemodify(gitdir, ":~:h")) . ' ' . matches[1][:9] . matches[2]
    elseif getbufvar(b, 'fugitive_type', '') is# 'temp'
        return pathshorten(fnamemodify(bname, ":~:.")) . ' :Git ' . join(FugitiveResult(bname)['args'], ' ')
    elseif ft is# 'gl'
        return ':GL' . join([''] + getbufvar(b, 'gl_args'), ' ')
    elseif bname =~# '^temp://'
        return matchstr(bname, '^temp://\zs.*')
    elseif empty(bname)
        return empty(bt) ? '[No Name]' : bt is# 'nofile' ? '[Scratch]' : '?'
    elseif isdirectory(bname) " NOTE: https://github.com/vim/vim/issues/9099
        return pathshorten(fnamemodify(simplify(bname), ":~")) . '/'
    else
        return pathshorten(fnamemodify(simplify(bname), ":~:."))
    endif
endfunction

function! UpdateGitStatus(buf) abort
    let bname = fnamemodify(bufname(a:buf), ':p')
    if !empty(getbufvar(a:buf, '&buftype')) || !filereadable(bname) | return | endif
    let status = ''
    let git = 'git -C ' . shellescape(fnamemodify(bname, ':h'))
    let rev_parse = systemlist(git . ' rev-parse --abbrev-ref HEAD')[0]
    if !v:shell_error
        let status = systemlist(git . ' status --porcelain ' . shellescape(bname))
        let status = '[' . rev_parse . (empty(status) ? '' : ':' . status[0][:1]) . ']'
    endif
    call setbufvar(a:buf, 'git_status', status)
endfunction

augroup Statusline | au!
    if has('unix') " too slow on windows
        au BufReadPost,BufWritePost * call UpdateGitStatus(str2nr(expand('<abuf>')))
        au User FugitiveChanged call map(getbufinfo({'bufloaded':1}), 'UpdateGitStatus(v:val.bufnr)')
    endif
augroup END
" }}}

" ColorScheme {{{
command! Bg if &background ==# 'dark' | set background=light | else | set background=dark | endif

if $BACKGROUND =~# 'dark\|light'
    let &background = $BACKGROUND
endif

" quite8 colorscheme
function! C8() abort
    " In nvim, :hi-clear inside a function doesn't fully clear highlights??? Reproduceable in at least 0.6.1. Vim works correctly.
    " Reproduce: :color something, :fu Test() hi clear endfu, call Test()
    let bg = &background
    colorscheme default
    let &background = bg

    if has('nvim')
        hi! link SpecialKey Special
    else
        hi! link SpecialKey NonText
    endif
    hi! link Terminal Normal
    hi! link StatusLineTerm StatusLine
    hi! link StatusLineTermNC StatusLineNC

    hi Normal        guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi NormalFloat   guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Comment       guifg=NONE    guibg=NONE gui=bold                   ctermfg=NONE        ctermbg=NONE        cterm=bold
    hi Constant      guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Identifier    guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Statement     guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi PreProc       guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Type          guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Special       guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Underlined    guifg=NONE    guibg=NONE gui=underline              ctermfg=NONE        ctermbg=NONE        cterm=underline
    hi Ignore        guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Error         guifg=#d7005f guibg=NONE gui=bold,reverse           ctermfg=darkred     ctermbg=NONE        cterm=bold,reverse
    hi Todo          guifg=NONE    guibg=NONE gui=bold,reverse           ctermfg=NONE        ctermbg=NONE        cterm=bold,reverse
    hi ColorColumn   guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi Conceal       guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Cursor        guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi CursorColumn  guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi CursorLine    guifg=NONE    guibg=NONE gui=underline              ctermfg=NONE        ctermbg=NONE        cterm=underline
    hi CursorLineNr  guifg=NONE    guibg=NONE gui=bold                   ctermfg=NONE        ctermbg=NONE        cterm=bold
    hi DiffAdd       guifg=#00cc11 guibg=NONE gui=reverse                ctermfg=darkgreen   ctermbg=NONE        cterm=reverse
    hi DiffChange    guifg=#0087d7 guibg=NONE gui=reverse                ctermfg=darkblue    ctermbg=NONE        cterm=reverse
    hi DiffDelete    guifg=#d7005f guibg=NONE gui=reverse                ctermfg=darkred     ctermbg=NONE        cterm=reverse
    hi DiffText      guifg=#d787d7 guibg=NONE gui=reverse                ctermfg=darkmagenta ctermbg=NONE        cterm=reverse
    hi Directory     guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi ErrorMsg      guifg=NONE    guibg=NONE gui=bold,reverse           ctermfg=NONE        ctermbg=NONE        cterm=bold,reverse
    hi FoldColumn    guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Folded        guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi IncSearch     guifg=#d78700 guibg=NONE gui=bold,reverse,underline ctermfg=darkyellow  ctermbg=NONE        cterm=bold,reverse,underline
    hi LineNr        guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi MatchParen    guifg=NONE    guibg=NONE gui=bold,underline         ctermfg=NONE        ctermbg=NONE        cterm=bold,underline
    hi ModeMsg       guifg=NONE    guibg=NONE gui=bold                   ctermfg=NONE        ctermbg=NONE        cterm=bold
    hi MoreMsg       guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi NonText       guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Pmenu         guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi PmenuExtra    guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi PmenuKind     guifg=NONE    guibg=NONE gui=bold,reverse           ctermfg=NONE        ctermbg=NONE        cterm=bold,reverse
    hi PmenuSbar     guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi PmenuSel      guifg=NONE    guibg=NONE gui=bold,underline         ctermfg=NONE        ctermbg=NONE        cterm=bold,underline
    hi PmenuExtraSel guifg=NONE    guibg=NONE gui=bold                   ctermfg=NONE        ctermbg=NONE        cterm=bold
    hi PmenuKindSel  guifg=NONE    guibg=NONE gui=bold                   ctermfg=NONE        ctermbg=NONE        cterm=bold
    hi PmenuThumb    guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Question      guifg=NONE    guibg=NONE gui=standout               ctermfg=NONE        ctermbg=NONE        cterm=standout
    hi QuickFixLine  guifg=#d787d7 guibg=NONE gui=reverse                ctermfg=darkmagenta ctermbg=NONE        cterm=reverse
    hi Search        guifg=#00cccc guibg=NONE gui=bold,reverse           ctermfg=darkcyan    ctermbg=NONE        cterm=bold,reverse
    hi CurSearch     guifg=#d787d7 guibg=NONE gui=bold,reverse,underline ctermfg=darkmagenta ctermbg=NONE        cterm=bold,reverse,underline
    hi SignColumn    guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi SpellBad      guifg=NONE    guibg=NONE guisp=#d7005f              gui=undercurl       ctermfg=darkred     ctermbg=NONE                 cterm=underline
    hi SpellCap      guifg=NONE    guibg=NONE guisp=#0080dd              gui=undercurl       ctermfg=darkblue    ctermbg=NONE                 cterm=underline
    hi SpellLocal    guifg=NONE    guibg=NONE guisp=#d777d7              gui=undercurl       ctermfg=darkmagenta ctermbg=NONE                 cterm=underline
    hi SpellRare     guifg=NONE    guibg=NONE guisp=#00cccc              gui=undercurl       ctermfg=darkcyan    ctermbg=NONE                 cterm=underline
    hi StatusLine    guifg=NONE    guibg=NONE gui=bold,reverse           ctermfg=NONE        ctermbg=NONE        cterm=bold,reverse
    hi StatusLineNC  guifg=NONE    guibg=NONE gui=bold,underline         ctermfg=NONE        ctermbg=NONE        cterm=bold,underline
    hi TabLine       guifg=NONE    guibg=NONE gui=bold,underline         ctermfg=NONE        ctermbg=NONE        cterm=bold,underline
    hi TabLineFill   guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi TabLineSel    guifg=NONE    guibg=NONE gui=bold,reverse           ctermfg=NONE        ctermbg=NONE        cterm=bold,reverse
    hi Title         guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi VertSplit     guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi Visual        guifg=#d78700 guibg=NONE gui=reverse                ctermfg=darkyellow  ctermbg=NONE        cterm=reverse
    hi VisualNOS     guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi WarningMsg    guifg=NONE    guibg=NONE gui=standout               ctermfg=NONE        ctermbg=NONE        cterm=standout
    hi WildMenu      guifg=NONE    guibg=NONE gui=bold                   ctermfg=NONE        ctermbg=NONE        cterm=bold
    hi CursorIM      guifg=NONE    guibg=NONE gui=NONE                   ctermfg=NONE        ctermbg=NONE        cterm=NONE
    hi ToolbarLine   guifg=NONE    guibg=NONE gui=reverse                ctermfg=NONE        ctermbg=NONE        cterm=reverse
    hi ToolbarButton guifg=NONE    guibg=NONE gui=bold,reverse           ctermfg=NONE        ctermbg=NONE        cterm=bold,reverse
    hi diffAdded     guifg=#00cc11 guibg=NONE gui=NONE                   ctermfg=darkgreen   ctermbg=NONE        cterm=NONE
    hi diffRemoved   guifg=#d7005f guibg=NONE gui=NONE                   ctermfg=darkred     ctermbg=NONE        cterm=NONE

endfunction

call C8()
" }}}

" Languages {{{
augroup Languages | au!
    " NOTE: 'syntax-loading'.
    " NOTE: It would be more correct to use Syntax autocmd for syntax customization.
    au FileType c,cpp call s:c_cpp()
    au FileType cpp call s:cpp()
    au FileType lua setlocal shiftwidth=2
    au FileType markdown call s:markdown()
    au FileType pandoc setlocal filetype=markdown
    au FileType python call s:python()
    au FileType vim setlocal formatoptions-=c
    au FileType xml setlocal formatoptions-=r formatoptions-=o " very broken: <!--<CR> → <!--\n--> █
augroup END

" c, cpp {{{
let c_no_comment_fold = 1
let c_no_bracket_error = 1
let c_no_curly_error = 1
function! s:c_cpp() abort
    " don't highlight the #define content
    syn clear cDefine
    syn region	cDefine		matchgroup=PreProc start="^\s*\zs\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
    hi! def link cDefine NONE

    setlocal shiftwidth=2
    setlocal commentstring=//%s
    silent! setlocal formatoptions+=/ " 8.2.4907
    setlocal path+=include,/usr/include
endfunction
function! s:cpp() abort
    syn keyword cppStatement auto
    syn keyword cppConstant this
endfunction
" }}}

" markdown {{{
let g:markdown_fenced_languages = []
let g:markdown_folding = 1
function! s:markdown() abort
    syn clear
    if exists("b:undo_ftplugin")
      exe b:undo_ftplugin
      unlet! b:undo_ftplugin b:did_ftplugin
    endif
    " tpope-vim-markdown/syntax/markdown.vim {{{
    if !exists('main_syntax')
      let main_syntax = 'markdown'
    endif

    if has('folding')
      let l:foldmethod = &l:foldmethod
      let l:foldtext = &l:foldtext
    endif
    let l:iskeyword = &l:iskeyword

    runtime! syntax/html.vim
    unlet! b:current_syntax

    if !exists('g:markdown_fenced_languages')
      let g:markdown_fenced_languages = []
    endif
    let l:done_include = {}
    for l:ft in map(copy(g:markdown_fenced_languages),'matchstr(v:val,"[^=]*$")')
      if has_key(l:done_include, l:ft)
        continue
      endif
      syn case match
      exe 'syn include @markdownHighlight_'.l:ft.' syntax/'.l:ft.'.vim'
      unlet! b:current_syntax
      let l:done_include[l:ft] = 1
    endfor

    syn spell toplevel
    if exists('l:foldmethod') && l:foldmethod !=# &l:foldmethod
      let &l:foldmethod = l:foldmethod
    endif
    if exists('l:foldtext') && l:foldtext !=# &l:foldtext
      let &l:foldtext = l:foldtext
    endif
    if l:iskeyword !=# &l:iskeyword
      let &l:iskeyword = l:iskeyword
    endif

    if !exists('g:markdown_minlines')
      let g:markdown_minlines = 50
    endif
    execute 'syn sync minlines=' . g:markdown_minlines
    syn sync maxlines=500
    syn sync linebreaks=1
    syn case ignore

    syn match markdownValid '[<>]\c[a-z/$!]\@!' transparent contains=NONE
    syn match markdownValid '&\%(#\=\w*;\)\@!' transparent contains=NONE

    syn match markdownLineStart "^[<@]\@!" nextgroup=@markdownBlock,htmlSpecialChar

    syn cluster markdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownCodeBlock,markdownRule
    syn cluster markdownInline contains=markdownLineBreak,markdownLinkText,markdownItalic,markdownBold,markdownCode,markdownEscape,@htmlTop,markdownValid

    syn match markdownH1 "^.\+\n=\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink
    syn match markdownH2 "^.\+\n-\+$" contained contains=@markdownInline,markdownHeadingRule,markdownAutomaticLink

    syn match markdownHeadingRule "^[=-]\+$" contained

    syn region markdownH1 matchgroup=markdownH1Delimiter start=" \{,3}#\s"      end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
    syn region markdownH2 matchgroup=markdownH2Delimiter start=" \{,3}##\s"     end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
    syn region markdownH3 matchgroup=markdownH3Delimiter start=" \{,3}###\s"    end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
    syn region markdownH4 matchgroup=markdownH4Delimiter start=" \{,3}####\s"   end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
    syn region markdownH5 matchgroup=markdownH5Delimiter start=" \{,3}#####\s"  end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained
    syn region markdownH6 matchgroup=markdownH6Delimiter start=" \{,3}######\s" end="#*\s*$" keepend oneline contains=@markdownInline,markdownAutomaticLink contained

    syn match markdownBlockquote ">\%(\s\|$\)" contained nextgroup=@markdownBlock

    " TODO: real nesting
    syn match markdownListMarker "\s*[-*+]\%(\s\+\S\)\@=" contained
    syn match markdownOrderedListMarker "\s*\<\d\+\.\%(\s\+\S\)\@=" contained

    syn match markdownRule "\* *\* *\*[ *]*$" contained
    syn match markdownRule "- *- *-[ -]*$" contained

    syn match markdownLineBreak " \{2,\}$"

    syn region markdownIdDeclaration matchgroup=markdownLinkDelimiter start="^ \{0,3\}!\=\[" end="\]:" oneline keepend nextgroup=markdownUrl skipwhite
    syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained
    syn region markdownUrl matchgroup=markdownUrlDelimiter start="<" end=">" oneline keepend nextgroup=markdownUrlTitle skipwhite contained
    syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+"+ end=+"+ keepend contained
    syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+'+ end=+'+ keepend contained
    syn region markdownUrlTitle matchgroup=markdownUrlTitleDelimiter start=+(+ end=+)+ keepend contained

    syn region markdownLinkText matchgroup=markdownLinkTextDelimiter start="!\=\[\%(\_[^][]*\%(\[\_[^][]*\]\_[^][]*\)*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" nextgroup=markdownLink,markdownId skipwhite contains=@markdownInline,markdownLineStart
    syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained
    syn region markdownId matchgroup=markdownIdDelimiter start="\[" end="\]" keepend contained
    syn region markdownAutomaticLink matchgroup=markdownUrlDelimiter start="<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=" end=">" keepend oneline

    let l:concealends = ''
    if has('conceal') && get(g:, 'markdown_syntax_conceal', 1) == 1
      let l:concealends = ' concealends'
    endif
    exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="\*\S\@=" end="\S\@<=\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . l:concealends
    exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="\w\@<!_\S\@=" end="\S\@<=_\w\@!\|^$" skip="\\_" contains=markdownLineStart,@Spell' . l:concealends
    exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="\*\*\S\@=" end="\S\@<=\*\*\|^$" skip="\\\*" contains=markdownLineStart,markdownItalic,@Spell' . l:concealends
    exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="\w\@<!__\S\@=" end="\S\@<=__\w\@!\|^$" skip="\\_" contains=markdownLineStart,markdownItalic,@Spell' . l:concealends
    exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\*\*\*\S\@=" end="\S\@<=\*\*\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . l:concealends
    exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\w\@<!___\S\@=" end="\S\@<=___\w\@!\|^$" skip="\\_" contains=markdownLineStart,@Spell' . l:concealends
    exe 'syn region markdownStrike matchgroup=markdownStrikeDelimiter start="\~\~\S\@=" end="\S\@<=\~\~\|^$" contains=markdownLineStart,@Spell' . l:concealends

    syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`\|^$" skip="``"
    syn region markdownCode matchgroup=markdownCodeDelimiter start="``" end="``\|^$" skip="```"
    syn region markdownCode matchgroup=markdownCodeDelimiter start="\$\S\@=" end="\S\@<=\$\|^$" skip="\\\$"
    syn region markdownCode matchgroup=markdownCodeDelimiter start="\$\$" end="\$\$\|^$" skip="\\\$"
    syn region markdownCodeBlock matchgroup=markdownCodeDelimiter start="\z(`\{3,\}\).*$" end="\z1\ze\s*$"
    syn region markdownCodeBlock matchgroup=markdownCodeDelimiter start="\z(\~\{3,\}\).*$" end="\z1\ze\s*$"

    syn match markdownFootnote "\[^[^\]]\+\]"
    syn match markdownFootnoteDefinition "^\[^[^\]]\+\]:"

    let l:done_include = {}
    for l:type in g:markdown_fenced_languages
      if has_key(l:done_include, l:type)
        continue
      endif
      let l:name = matchstr(l:type,'[^=]*')
      let l:ft = matchstr(l:type,'[^=]*$')
      exe 'syn region markdownHighlight_'.l:ft.' matchgroup=markdownCodeDelimiter start="^\s*\z(`\{3,\}\)\s*\%({.\{-}\.\)\='.l:name.'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight_'.l:ft . l:concealends
      exe 'syn region markdownHighlight_'.l:ft.' matchgroup=markdownCodeDelimiter start="^\s*\z(\~\{3,\}\)\s*\%({.\{-}\.\)\='.l:name.'}\=\S\@!.*$" end="^\s*\z1\ze\s*$" keepend contains=@markdownHighlight_'.l:ft . l:concealends
      let l:done_include[l:type] = 1
    endfor

    if get(b:, 'markdown_yaml_head', get(g:, 'markdown_yaml_head', main_syntax ==# 'markdown'))
      syn include @markdownYamlTop syntax/yaml.vim
      unlet! b:current_syntax
      syn region markdownYamlHead start="\%^---$" end="^\%(---\|\.\.\.\)\s*$" keepend contains=@markdownYamlTop,@Spell
    endif

    syn match markdownEscape "\\[][\\`$*_{}()<>#+.!-]"

    hi def link markdownH1                    htmlH1
    hi def link markdownH2                    htmlH2
    hi def link markdownH3                    htmlH3
    hi def link markdownH4                    htmlH4
    hi def link markdownH5                    htmlH5
    hi def link markdownH6                    htmlH6
    hi def link markdownHeadingRule           markdownRule
    hi def link markdownH1Delimiter           markdownHeadingDelimiter
    hi def link markdownH2Delimiter           markdownHeadingDelimiter
    hi def link markdownH3Delimiter           markdownHeadingDelimiter
    hi def link markdownH4Delimiter           markdownHeadingDelimiter
    hi def link markdownH5Delimiter           markdownHeadingDelimiter
    hi def link markdownH6Delimiter           markdownHeadingDelimiter
    hi def link markdownHeadingDelimiter      Delimiter
    hi def link markdownOrderedListMarker     markdownListMarker
    hi def link markdownListMarker            htmlTagName
    hi def link markdownBlockquote            Comment
    hi def link markdownRule                  PreProc

    hi def link markdownFootnote              Typedef
    hi def link markdownFootnoteDefinition    Typedef

    hi def link markdownLinkText              htmlLink
    hi def link markdownIdDeclaration         Typedef
    hi def link markdownId                    Type
    hi def link markdownAutomaticLink         markdownUrl
    hi def link markdownUrl                   Float
    hi def link markdownUrlTitle              String
    hi def link markdownIdDelimiter           markdownLinkDelimiter
    hi def link markdownUrlDelimiter          htmlTag
    hi def link markdownUrlTitleDelimiter     Delimiter

    hi def link markdownItalic                htmlItalic
    hi def link markdownItalicDelimiter       markdownItalic
    hi def link markdownBold                  htmlBold
    hi def link markdownBoldDelimiter         markdownBold
    hi def link markdownBoldItalic            htmlBoldItalic
    hi def link markdownBoldItalicDelimiter   markdownBoldItalic
    hi def link markdownStrike                htmlStrike
    hi def link markdownStrikeDelimiter       markdownStrike

    hi def link markdownCodeDelimiter         Delimiter

    hi def link markdownEscape                Special

    let b:current_syntax = "markdown"
    if main_syntax ==# 'markdown'
      unlet main_syntax
    endif
    " }}}
    " after/syntax/markdown.vim {{{
    syn keyword mkdTodo TODO containedin=ALL
    hi def link mkdTodo Todo
    " }}}
    " tpope-vim-markdown/ftplugin/markdown.vim {{{
    runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

    setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=<!--%s-->
    setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
    setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:\\&^.\\{4\\}

    if exists('b:undo_ftplugin')
      let b:undo_ftplugin .= "|setl cms< com< fo< flp< et< ts< sts< sw<"
    else
      let b:undo_ftplugin = "setl cms< com< fo< flp< et< ts< sts< sw<"
    endif

    if get(g:, 'markdown_recommended_style', 1)
      setlocal expandtab tabstop=4 softtabstop=4 shiftwidth=4
    endif

    if !exists("g:no_plugin_maps") && !exists("g:no_markdown_maps")
      nnoremap <silent><buffer> [[ :<C-U>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "bsW")<CR>
      nnoremap <silent><buffer> ]] :<C-U>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "sW")<CR>
      xnoremap <silent><buffer> [[ :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "bsW")<CR>
      xnoremap <silent><buffer> ]] :<C-U>exe "normal! gv"<Bar>call search('\%(^#\{1,5\}\(\s\\|$\)\\|^\S.*\n^[=-]\+$\)', "sW")<CR>
      let b:undo_ftplugin .= '|sil! nunmap <buffer> [[|sil! nunmap <buffer> ]]|sil! xunmap <buffer> [[|sil! xunmap <buffer> ]]'
    endif

    function! s:IsCodeBlock(lnum) abort
      let synstack = synstack(a:lnum, 1)
      for i in synstack
        if synIDattr(i, 'name') =~# '^\%(markdown\%(Code\|Highlight\|Yaml\)\|htmlComment\)'
          return 1
        endif
      endfor
      return 0
    endfunction

    function! MarkdownFold() abort
      let line = getline(v:lnum)
      let hashes = matchstr(line, '^#\+\(\s\|$\)\@=')
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

    function! s:HashIndent(lnum) abort
      let hash_header = matchstr(getline(a:lnum), '^#\{1,6}')
      if len(hash_header)
        return hash_header
      else
        let nextline = getline(a:lnum + 1)
        if nextline =~# '^=\+\s*$'
          return '#'
        elseif nextline =~# '^-\+\s*$'
          return '##'
        endif
      endif
    endfunction

    function! MarkdownFoldText() abort
      let hash_indent = s:HashIndent(v:foldstart)
      let title = substitute(getline(v:foldstart), '^#\+\s*', '', '')
      let foldsize = (v:foldend - v:foldstart + 1)
      let linecount = '['.foldsize.' lines]'
      return hash_indent.' '.title.' '.linecount
    endfunction

    if has("folding") && get(g:, "markdown_folding", 0)
      setlocal foldexpr=MarkdownFold()
      setlocal foldmethod=expr
      setlocal foldtext=MarkdownFoldText()
      let b:undo_ftplugin .= "|setl foldexpr< foldmethod< foldtext<"
    endif
    " }}}
    " s:markdown() {{{
    setlocal foldlevel=6

    " <> pair is too intrusive
    setlocal matchpairs-=<:>
    " Set from $VIMRUNTIME/ftplugin/html.vim
    let b:match_words = substitute(b:match_words, '<:>,', '', '')
    " }}}
endfunction
" }}}

" Python {{{
let g:pyindent_continue = '&shiftwidth'
let g:pyindent_open_paren = '&shiftwidth'
function! s:python() abort
    setlocal foldmethod=indent foldnestmax=2 foldignore=
    setlocal formatoptions+=ro
endfunction
" }}}

let g:lisp_rainbow = 1
let g:tex_flavor = 'latex'
let g:tex_no_error = 1
" }}}

" search & files {{{
" search_mode: which command last set @/?
" `*`, `v_*` without moving the cursor. Reserve @c for the raw original text
" NOTE: Can't repeat properly if ins-special-special is used. Use q-recording.
nnoremap <silent>* :<C-u>call Star(0)\|set hlsearch<CR>
nnoremap <silent>g* :<C-u>call Star(1)\|set hlsearch<CR>
xnoremap <silent>* :<C-u>call VisualStar(0)\|set hlsearch<CR>
xnoremap <silent>g* :<C-u>call VisualStar(1)\|set hlsearch<CR>
" set hlsearch inside the function doesn't work? Maybe :h function-search-undo?
" NOTE: word boundary is syntax property -> may not match in other ft buffers
let g:search_mode = get(g:, 'search_mode', '/')
func! Star(g)
    let @c = expand('<cword>')
    " <cword> can be non-keyword
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
nnoremap <C-g>      :<C-u>Grep<space>
nnoremap <leader>g/ :<C-u>Grep! <C-r>=shellescape(GrepInput(@/), 1)<CR>
nnoremap <leader>gw :<C-u>Grep! <C-R>=shellescape('\b'.expand('<cword>').'\b')<CR>
nnoremap <C-f>      :<C-u>Files<space>
nnoremap <leader>hh :<C-u>History<space>

" NOTE: When using :Grep!, must do shellescape(_, 1) in cmdline yourself.
command! -nargs=? -bang Grep call Grep(<q-args>, <bang>0)
command! -nargs=? History call History(<q-args>)
command! -nargs=? Files call Files(<q-args>)

if executable('rg')
    " --vimgrep is like vimgrep /pat/g
    let &grepprg = "rg -. -g '!**/.git/**' --no-heading -H -n --column -S"
    set grepformat^=%f:%l:%c:%m
elseif has('linux') || !has('patch-8.1.0846') " has GNU grep, probably
    let &grepprg = 'grep -EHnrI'
    " NOTE: The default POSIX-compliant grepprg adds /dev/null to [FILE...] to simulate GNU grep's -H,
    " which disables GNU grep's feature that defaults empty [FILE...] to cwd when -r is provided.
endif
function! Grep(query, advanced) abort
    let opts = string(v:count)
    let options = (&grepprg =~# '^grep') ? Wildignore2exclude() : ''
    " NOTE: shellescape('!', 1) == '\!', but :grep doesn't handle this, because "!" is not handled by find_cmdline_var.
    let query = a:advanced ? a:query : shellescape(a:query, 1)
    if opts =~ '3'
        let query .= ' ' . shellescape(s:git_root(empty(bufname('%')) ? getcwd() : bufname('%')), 1)
    endif
    " NOTE: cmdline-special is expanded here.
    exe 'grep!' options query
    belowright cwindow
    redraw
endfunction
func! GrepInput(raw)
    if g:search_mode ==# 'n'
        return substitute(a:raw, '\v\\[<>]','','g')
    elseif g:search_mode ==# 'v'
        return escape(a:raw, '+|?-(){}') " not escaped by VisualStar
    elseif a:raw[0:1] !=# '\v' " can convert most of strict very magic to riggrep regex, otherwise, DIY
        return substitute(a:raw, '\v(\\V|\\[<>])','','g')
    else
        return substitute(a:raw[2:], '\v\\([~/])', '\1', 'g')
    endif
endfunc
function! History(...) abort
    silent doautocmd QuickFixCmdPre History
    let files = copy(v:oldfiles)
    call map(files, 'expand(v:val)')
    call filter(files, 'filereadable(v:val)' . (a:0 ? ' && match(v:val, a:1) >= 0' : ''))
    call setqflist([], ' ', {'lines': files, 'title': ':History', 'efm': '%f'})
    silent doautocmd QuickFixCmdPost History
    belowright cwindow
endfunction
function! Files(...) abort
    silent doautocmd QuickFixCmdPre Files
    let opts = string(v:count)
    if opts =~ '3'
        let root = s:git_root(empty(bufname('%')) ? getcwd() : bufname('%'))
        " NOTE: add -co to include untracked files (n.b. may not enumerate each file)
        let files = systemlist('git -C ' . shellescape(root) . ' ls-files --exclude-standard')
        call map(files, "'".root."/'.v:val")
    else
        let cmd = (&grepprg =~# '^rg') ? "rg --hidden --glob '!**/.git/**' --files" : 'find . -type f'
        let files = systemlist(cmd)
    endif
    if a:0
        call filter(files, 'match(v:val, a:1) >= 0')
    endif
    call setqflist([], ' ', {'lines': files, 'title': 'Files', 'efm': '%f'})
    silent doautocmd QuickFixCmdPost Files
    belowright cwindow
endfunction
" }}}

" Motion, insert mode, ... {{{
" just set nowrap instead of explicit linewise ops
nnoremap <expr> j                     v:count ? 'j' : 'gj'
nnoremap <expr> k                     v:count ? 'k' : 'gk'
nnoremap <expr> J                     v:count ? 'j' : 'gj'
nnoremap <expr> K                     v:count ? 'k' : 'gk'
xnoremap <expr> j mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
xnoremap <expr> k mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
onoremap <expr> j mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
onoremap <expr> k mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
xnoremap <expr> J mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
xnoremap <expr> K mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
onoremap <expr> J mode() !=# 'v' \|\| v:count ? 'j' : 'gj'
onoremap <expr> K mode() !=# 'v' \|\| v:count ? 'k' : 'gk'
Noremap <leader>J J
Noremap <expr> H v:count ? 'H' : 'h'
Noremap <expr> L v:count ? 'L' : 'l'

Noremap <M-0> ^w

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

" TODO: (special char -> non-blank, non-keyword), user-defined (paren -> pair?)
" s-word: (a keyword | repetition of non-paren special char | a paren | whitespace)
let g:sword = '\v(\k+|([^[:alnum:]_[:blank:](){}[\]<>''"`$])\2*|[(){}[\]<>''"`$]|\s+)'
"                     %(\k|[()[\]{}<>[:blank:]$])@!(.)\1*
" NOTE: \v(<|>) works well for word chars, but not for non-word chars 𝓥s
" '\v(<|>|[^[:alnum:]_[:blank:]])', '\k\+\|[[:punct:]]\|\s\+'

" Jump past a sword. Assumes `set whichwrap+=]` for i_<Right>
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
" <C-b> <C-e>
cnoremap <C-j> <S-Right>
cnoremap <C-k> <S-Left>

inoremap <expr> <C-u> match(getline('.'), '\S') >= 0 ? '<C-g>u<C-u>' : '<C-u>'
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
        let l:vsts = exists('+varsofttabstop') ? &varsofttabstop : '' " 8.1.0114
        silent! setlocal softtabstop=0 varsofttabstop=
        return repeat("\<BS>", l:idx)
                    \ . "\<C-R>=execute('".printf('setl sts=%d %s', l:sts, exists('+varsofttabstop') ? printf('vsts=%d', l:vsts) : '')."')\<CR>"
                    \ . (a:finer ? "" : "\<C-R>=MuPairsBS()\<CR>")
    elseif l:chars[-1] !~ '\k'
        return MuPairsBS()
    else
        return "\<C-w>"
    endif
endfunc
" }}}

" etc mappings {{{
nnoremap <silent><leader><CR> :let v:searchforward=1\|nohlsearch<CR>
nnoremap <silent><leader><C-L> :diffupdate<CR><C-L>
nnoremap <silent><leader>sfs :syntax sync fromstart<CR><C-L>
nnoremap <leader>ss :setlocal spell! spell?<CR>
nnoremap <leader>sc :if empty(&spc) \| setl spc< spc? \| else \| setl spc= spc? \| endif<CR>
nnoremap <leader>sp :set paste! paste?<CR>
nnoremap <leader>sw :setlocal wrap! wrap?<CR>
nnoremap <leader>ic :set ignorecase! smartcase! ignorecase?<CR>

Noremap <leader>dp :diffput<CR>
Noremap <leader>do :diffget<CR>

" clipboard.
inoremap <C-v> <C-g>u<C-r><C-o>+
Noremap <M-c> "+y
nnoremap <silent> yY :let _view = winsaveview() \| exe 'keepjumps keepmarks norm ggVG"+y' \| call winrestview(_view) \| unlet _view<cr>

" buf/filename
nnoremap <leader>fn 2<C-g>

noremap <F1> <Esc>
inoremap <F1> <Esc>
nmap     <C-q> <Esc>
cnoremap <C-q> <C-c>
inoremap <C-q> <Esc>
xnoremap <C-q> <Esc>
snoremap <C-q> <Esc>
onoremap <C-q> <Esc>
noremap! <C-M-q> <C-q>

cnoremap <M-p> <Up>
cnoremap <M-n> <Down>

" disable annoying q and Q (use c_CTRL-F and gQ) and streamline record/execute
" TODO: q quits hit-enter and *starts recording* unlike q of more-prompt → open a vim issue
Noremap q: :
Noremap q <nop>
Noremap <M-q> q
if exists('*reg_recording') " 8.1.0020
    Noremap <expr> qq empty(reg_recording()) ? 'qq' : 'q'
endif
Noremap Q @q

" v_u mistake is  hard to notice. Use gu instead (works for visual mode too).
nnoremap U <nop>
xnoremap u <nop>

" delete without clearing regs
Noremap x "_x

nnoremap gV `[v`]

" repetitive pastes using designated register @p
Noremap <M-y> "py
Noremap <M-p> "pp
Noremap <M-P> "pP

nnoremap Y y$
onoremap <silent> ge :execute "normal! " . v:count1 . "ge<space>"<cr>
nnoremap <silent> & :&&<cr>
xnoremap <silent> & :&&<cr>

" set nrformats+=alpha
Noremap  <M-+> <C-a>
xnoremap <M-+> g<C-a>
Noremap  <M--> <C-x>
xnoremap <M--> g<C-x>

nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

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
nnoremap <leader>fe :e!<CR>

inoreabbrev <expr> date strftime('%F')
" }}}

" pairs {{{
let g:surround_indent = 0
let g:surround_{char2nr('c')} = "/* \r */"
let g:surround_{char2nr('m')} = "(* \r *)"

inoremap <expr> ( MuPairsOpen('(', ')')
inoremap <expr> ) MuPairsClose('(', ')')
inoremap <expr> [ MuPairsOpen('[', ']')
inoremap <expr> ] MuPairsClose('[', ']')
inoremap <expr> { MuPairsOpen('{', '}')
inoremap <expr> } MuPairsClose('{', '}')
inoremap <expr> <CR> (match(getline('.'), '\k') >= 0 ? "\<C-G>u" : "") . MuPairsCR()
inoremap <expr> <BS> MuPairsBS()
inoremap <expr> " MuPairsDumb('"')
inoremap <expr> ' MuPairsDumb("'")
inoremap <expr> ` MuPairsDumb('`')

" NOTE: If the cursor is on the start of the line which is also start of a
" syntax region R (comment or string), the region type is detected as R, while
" the actual region type of the to-be-inserted opener might not be R. So the
" opener may match a closer in a different region, which prevents inserting a
" closer. This is not really an issue because the closer can't be inserted
" anyway since the start of R is usually delimited by non-keyword char, which
" prevents inserting the closer.
function! MuPairsOpen(open, close) abort
    if MuPairsBalance(a:open, a:close, MuPairsRegionType(line('.'), s:esccol())) > 0
        return a:open
    elseif s:curchar() =~# '\k'
        return a:open
    endif
    return a:open . a:close . "\<C-g>U\<Left>"
endfunction
function! MuPairsClose(open, close) abort
    if s:curchar() !=# a:close
        return a:close
    elseif MuPairsBalance(a:open, a:close, MuPairsRegionType(line('.'), s:esccol())) >= 0
        return "\<C-g>U\<Right>"
    endif
    return a:close
endfunction
function! MuPairsBS() abort
    let cur = s:curchar()
    if empty(cur) | return "\<BS>" | endif
    let prev = s:prevchar()
    if empty(prev) | return "\<BS>" | endif
    if prev . cur =~# '\%(""\|''''\|``\)'
        return "\<Del>\<BS>"
    elseif prev . cur !~# '\V\%(()\|[]\|{}\)'
        return "\<BS>"
    elseif MuPairsBalance(prev, cur, MuPairsRegionType(line('.'), s:esccol())) < 0
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
function! MuPairsBalance(open, close, rtype) abort
    let openpat = '\V' . a:open
    let closepat = '\V' . a:close
    let skip = 'MuPairsRegionType(line("."), col(".")) !=# ' . '"'.a:rtype.'"'
    return searchpair(openpat, '', closepat, 'cnrm', skip, 0, 16)
       \ - searchpair(openpat, '', closepat, 'bnrm', skip, 0, 16)
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
" The coloumn at which the cursor will be placed when exiting insert mode
" using <Esc> or <C-o>. Wrong for multibyte, but ok because synID works
" correctly for any byte index.
function! s:esccol() abort
    return max([col('.') - 1, 1])
endfunction
" Can be fooled by groups contained in comment/string like vimTodo, escape,
" ..., but synstack is too slow.
function! MuPairsRegionType(l, c) abort
    let name = synIDattr(synID(a:l, a:c, 0), 'name')
    if name =~? 'comment' | return 'c' | endif
    if name =~? 'string' | return 's' | endif
    return 'n'
endfunction
if exists('*charcol') " 8.2.2324
    function! s:prevchar() abort
        let c = charcol('.')
        if c == 1 | return '' | endif
        let l = getline('.')
        return matchstr(l, '.', byteidx(l, c - 1 - 1))
    endfunction
else
    " NOTE: Returns empty string if prev char is multibyte. This actually
    " isn't that problematic for mupairs since parens are usually 1 byte.
    function! s:prevchar() abort
        return matchstr(getline('.'), '\%' . (col('.') - 1) . 'c.')
    endfunction
endif
function! s:curchar() abort
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction
" }}}

" shell, terminal {{{
if has('win32')
    " :h shell-powershell
    let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
    let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
endif

if has('nvim')
    tnoremap <M-[> <C-\><C-n>
    tnoremap <expr> <M-r> '<C-\><C-N>"'.nr2char(getchar()).'pi'
    command! -nargs=? -complete=shellcmd T <mods> split | exe "terminal" <q-args> | if empty(<q-args>) | startinsert | endif
else
    " NOTE: If 'hidden' is set and arg is provided, job finished + window closed doesn't wipe the buffer, in contrary to the doc:
    " > When the job has finished and no changes were made to the buffer: closing the
    " > window will wipe out the buffer.
    command! -nargs=? -complete=shellcmd T exe <q-mods> "terminal" <q-args>
endif

augroup terminal-custom | au!
    if has('nvim')
        au TermOpen,WinEnter *           if &buftype is# 'terminal' | setlocal nonumber norelativenumber foldcolumn=0 signcolumn=no | endif
    elseif exists('##TerminalWinOpen') " 8.1.2219
        au TerminalWinOpen,BufWinEnter * if &buftype is# 'terminal' | setlocal nonumber norelativenumber foldcolumn=0 signcolumn=no | endif
    endif
augroup END
" }}}

" window layout {{{
command! -count Wfh setlocal winfixheight | if <count> | exe 'resize' <count> | endif
nnoremap <silent> <C-w>g= :<C-u>call <SID>adjust_winfix_wins()<CR>

function! s:adjust_winfix_wins() abort
    for w in range(1, winnr('$'))
        if getwinvar(w, '&winfixheight')
            exe w 'resize' &previewheight
        endif
    endfor
endfunction

function! s:heights() abort
    let &pumheight = min([&window/4, 20])
    let &previewheight = max([&window/4, 12])
endfunction
call s:heights()

augroup layout-custom | au!
    au VimResized * call s:heights()
augroup END
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

" like cwindow, but don't jump to the window
command! -bar -nargs=? CW call s:cwindow(0, <q-mods>, <q-args>)
command! -bar -nargs=? LW call s:cwindow(1, <q-mods>, <q-args>)
function! s:cwindow(loclist, mods, args) abort
    let curwin = win_getid()
    let view = winsaveview()
    exe a:mods . (a:loclist ? ' lwindow' : ' cwindow') a:args
    " jumped to qf/loc window. return.
    if curwin != win_getid() && &buftype ==# 'quickfix'
        wincmd p
        call winrestview(view)
    endif
endfunction

function s:qf() abort
    setlocal nowrap
    setlocal norelativenumber number
    setlocal nobuflisted
    " Like CTRL-W_<CR>, but with preview window and without messing up buffer list
    nnoremap <buffer><silent> p :<C-u>call <SID>PreviewQf(line('.'))<CR>
    nnoremap <buffer><silent> <CR> :<C-u>pclose<CR><CR>
endfunction

augroup qf-custom | au!
    au FileType qf call s:qf()
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
    if s:PreviewBufnr() != l:entry.bufnr
        execute 'keepjumps pedit' bufname(l:entry.bufnr)
    endif
    noautocmd wincmd P
    if l:entry.lnum > 0
        execute l:entry.lnum
    else
        call search(l:entry.pattern, 'w')
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
" https://github.com/felipec/vim-sanegx/blob/e97c10401d781199ba1aecd07790d0771314f3f5/plugin/gx.vim
function! GXBrowse(url)
    if exists('g:netrw_browsex_viewer')
        let viewer = g:netrw_browsex_viewer
    elseif has('unix') && executable('xdg-open')
        let viewer = 'xdg-open'
    elseif has('macunix') && executable('open')
        let viewer = 'open'
    elseif has('win32')
        let viewer = 'start'
    else
        return
    endif
    execute 'silent! !' . viewer . ' ' . shellescape(a:url, 1)
    redraw!
endfunction
" based on https://gist.github.com/gruber/249502
let s:url_regex = '\c\<\%([a-z][0-9A-Za-z_-]\+:\%(\/\{1,3}\|[a-z0-9%]\)\|www\d\{0,3}[.]\|[a-z0-9.\-]\+[.][a-z]\{2,4}\/\)\%([^ \t()<>]\+\|(\([^ \t()<>]\+\|\(([^ \t()<>]\+)\)\)*)\)\+\%((\([^ \t()<>]\+\|\(([^ \t()<>]\+)\)\)*)\|[^ \t`!()[\]{};:'."'".'".,<>?«»“”‘’]\)'
function! CursorURL() abort
    return matchstr(expand('<cWORD>'), s:url_regex)
endfunction
nnoremap <silent> gx :call GXBrowse(CursorURL())<cr>

let g:netrw_home = simplify(&undodir . '..')
let g:netrw_fastbrowse = 0
let g:netrw_clipboard = 0
let g:netrw_dirhistmax = 0
nnoremap <silent><leader>- :<C-u>call <SID>explore_bufdir('Explore')<CR>
nnoremap <silent><C-w>es   :<C-u>call <SID>explore_bufdir('Hexplore')<CR>
nnoremap <silent><C-w>ev   :<C-u>call <SID>explore_bufdir('Vexplore!')<CR>
nnoremap <silent><C-w>et   :<C-u>call <SID>explore_bufdir('Texplore')<CR>
nnoremap <leader>cd :cd <Plug>BufDir/
nnoremap <leader>e  :e! <Plug>BufDir/
nnoremap <leader>te :tabedit <Plug>BufDir/
function! s:netrw() abort
    silent! nunmap <buffer> <C-L>
    nmap <buffer> <leader><C-L> <Plug>NetrwRefresh
endfunction
function! s:explore_bufdir(cmd) abort
    let name = expand('%:t')
    " <q-args>, -bar, -complete=dir
    exe a:cmd escape(BufDir(), '|#%')
    call s:vinegar_seek(name)
endfunction

augroup netrw-custom | au!
    au FileType netrw call s:netrw()
augroup END

noremap! <Plug>BufDir <C-r><C-r>=fnameescape(BufDir())<CR>
function! BufDir(...) abort
    let b = a:0 ? a:1 : bufnr('')
    let bname = bufname(b)
    let ft = getbufvar(b, '&filetype')
    if ft is# 'fugitive'
        return fnamemodify(FugitiveGitDir(b), ':h')
    elseif bname =~# '^fugitive://'
        return fnamemodify(FugitiveReal(bname), ':h')
    else
        " NOTE: If `isdirectory(bname)`, `:p` appends a path separator. This is removed by `:h`.
        return fnamemodify(bname, ':p:h')
    endif
endfunction
" }}}

" Git. See also plugin/git.vim {{{
augroup git-custom | au!
    au FileType diff
        \ nnoremap <silent><buffer>zM :setlocal foldmethod=expr foldexpr=GitDiffFoldExpr(v:lnum)\|unmap <lt>buffer>zM<CR>zM
    au FileType git,fugitive,gitcommit
        \ nnoremap <silent><buffer>zM :setlocal foldmethod=expr foldexpr=GitDiffFoldExpr(v:lnum)\|unmap <lt>buffer>zM<CR>zM
        \|silent! unmap <buffer> *
        \|Map <buffer> <localleader>* <Plug>fugitive:*
    au User FugitiveObject,FugitiveIndex
        \ silent! unmap <buffer> *
        \|Map <buffer> <localleader>* <Plug>fugitive:*
    " TODO: diff mapping for gitcommit
augroup END

" See also:
" - https://github.com/sgeb/vim-diff-fold/blob/master/ftplugin/diff.vim
" - https://vim.fandom.com/wiki/Folding_for_diff_files
function! GitDiffFoldExpr(lnum)
    let line = getline(a:lnum)
    if line =~# '^diff'
        return '>1'
    elseif line =~# '^@@'
        return '>2'
    else
        return '='
    endif
endfunction
" }}}

" etc util {{{
" helpers {{{
function! s:git_root(file_or_dir) abort
    let file_or_dir = fnamemodify(expand(a:file_or_dir), ':p')
    let dir = isdirectory(file_or_dir) ? file_or_dir : fnamemodify(file_or_dir, ':h')
    let output = systemlist('git -C ' . shellescape(dir) . ' rev-parse --show-toplevel')[0]
    if v:shell_error | throw output | endif
    return output
endfunction
" Expands cmdline-special in text that that doesn't contain \r.
function! s:expand_cmdline_special(line) abort
    return substitute(substitute(substitute(
                \ a:line, '\\\\', '\r', 'g' ),
                \ '\v\\@<!(\%|#%(\<?\d+|#)?)', '\=expand(submatch(1))', 'g' ),
                \ '\r', '\\\\', 'g' )
endfunction
function! s:cabbrev(lhs, rhs) abort
    return (getcmdtype() == ':' && getcmdline() ==# a:lhs) ? a:rhs : a:lhs
endfunction
" }}}

if has('nvim-0.9')
    nnoremap <leader>st <Cmd>Inspect<CR>
else
    nnoremap <silent><leader>st :<C-u>echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")') '->' synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')<CR>
endif
function! Text2Magic(text)
    return escape(a:text, '\.*$^~[]')
endfunction
function! Text2VeryMagic(str) abort
    return escape(a:str, '!#$%&()*+,-./:;<=>?@[\]^{|}~')
endfunction
function! Wildignore2exclude() abort
    let exclude = copy(g:wildignore_files)
    let exclude_dir = copy(g:wildignore_dirs)
    call map(exclude, 'shellescape(v:val, 1)')
    call map(exclude_dir, 'shellescape(v:val, 1)')
    return '--exclude={'.join(exclude, ',').'} --exclude-dir={'.join(exclude_dir, ',').'}'
endfunction

function! TempBuf(mods, title, ...) abort
    exe a:mods 'new'
    if !empty(a:title)
        exe 'file' printf('temp://%d/%s', bufnr(''), a:title)
    endif
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile nomodeline
    if a:0
        call setline(1, a:1)
    endif
endfunction
function! Execute(cmd, mods) abort
    call TempBuf(a:mods, ':' . a:cmd, split(execute(a:cmd), "\n"))
endfunction
function! WriteC(cmd, mods) range abort
    call TempBuf(a:mods, ':w !' . a:cmd, systemlist(s:expand_cmdline_special(a:cmd), getline(a:firstline, a:lastline)))
endfunction
function! Bang(cmd, mods) abort
    call TempBuf(a:mods, ':!' . a:cmd, systemlist(s:expand_cmdline_special(a:cmd)))
endfunction
command! -nargs=* -complete=command Execute call Execute(<q-args>, '<mods>')
command! -nargs=* -range=% -complete=shellcmd WC <line1>,<line2>call WriteC(<q-args>, '<mods>')
command! -nargs=* -complete=shellcmd Bang call Bang(<q-args>, '<mods>')

command! -range=% TrimWhitespace
            \ let _view = winsaveview()
            \|keeppatterns keepjumps <line1>,<line2>substitute/\s\+$//e
            \|call winrestview(_view)
            \|unlet _view

command! -range=% CollapseBlank
            \ let _view = winsaveview()
            \|exe 'keeppatterns keepjumps <line1>,<line2>global/^\_$\_s\+\_^$/d _'
            \|call winrestview(_view)
            \|unlet _view

command! -range=% Unpdf
            \ let _view = winsaveview()
            \|keeppatterns keepjumps <line1>,<line2>substitute/[“”łž]/"/ge
            \|keeppatterns keepjumps <line1>,<line2>substitute/[‘’]/'/ge
            \|keeppatterns keepjumps <line1>,<line2>substitute/\w\zs-\n//ge
            \|call winrestview(_view)
            \|unlet _view

" :substitute using a dict, where key == submatch (like VisualStar)
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

" Doesn't work with hard wrapped list.
" Alternative: %!pandoc --from=commonmark_x --to=commonmark_x --wrap=none
command! -range=% ZulipMarkdown
            \ keeppatterns keepjumps <line1>,<line2>substitute/^    \ze[-+*]\s/  /e
            \|keeppatterns keepjumps <line1>,<line2>substitute/^        \ze[-+*]\s/    /e
            \|keeppatterns keepjumps <line1>,<line2>substitute/^            \ze[-+*]\s/      /e

if !has('nvim')
    command! -nargs=+ -complete=shellcmd Man delcommand Man | runtime ftplugin/man.vim | if winwidth(0) > 170 | exe 'vert Man' <q-args> | else | exe 'Man' <q-args> | endif
    command! SW w !sudo tee % > /dev/null
endif
" }}}

" comments {{{
" https://github.com/tomtomjhj/vim-commentary/blob/05b5bbad0d9c14c308f5cb3bc26975f41df7fcaa/plugin/commentary.vim
function! s:commentary_surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(substitute(
        \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

function! s:commentary_strip_white_space(l,r,line) abort
  let [l, r] = [a:l, a:r]
  if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
    let l = l[:-2]
  endif
  if r[0] ==# ' ' && (' ' . a:line)[-strlen(r)-1:] != r && a:line[-strlen(r):] == r[1:]
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
    if strlen(r) > 2 && l.r !~# '\\' && r !~# '\V*)\|-}\||#'
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

function! s:commentary_insert()
  let [l, r] = s:commentary_surroundings()
  return l . r . repeat("\<C-G>U\<Left>", strchars(r))
endfunction

command! -range -bar -bang Commentary call s:commentary_go(<line1>,<line2>,<bang>0)
xnoremap <expr>   <Plug>Commentary     <SID>commentary_go()
nnoremap <expr>   <Plug>Commentary     <SID>commentary_go()
nnoremap <expr>   <Plug>CommentaryLine <SID>commentary_go() . '_'
onoremap <silent> <Plug>Commentary        :<C-U>call <SID>commentary_textobject(get(v:, 'operator', '') ==# 'c')<CR>
nnoremap <silent> <Plug>ChangeCommentary c:<C-U>call <SID>commentary_textobject(1)<CR>
inoremap <expr>   <Plug>CommentaryInsert <SID>commentary_insert()

xmap gc  <Plug>Commentary
nmap gc  <Plug>Commentary
omap gc  <Plug>Commentary
nmap gcc <Plug>CommentaryLine
nmap gcu <Plug>Commentary<Plug>Commentary

imap <M-/> <C-G>u<Plug>CommentaryInsert
" }}}

" vinegar {{{
" https://github.com/tpope/vim-vinegar/blob/bb1bcddf43cfebe05eb565a84ab069b357d0b3d6/plugin/vinegar.vim
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
    if orig =~? '^<plug>' && orig !=# '<Plug>VinegarUp'
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
" https://github.com/tomtomjhj/vim-surround/blob/320d3203a3f49ef2fe263874153de766b09cdd84/plugin/surround.vim
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

" Wrapping/unwrapping functions {{{2

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

if exists('*trim')
  function! s:surround_trim(txt) abort
    return trim(a:txt)
  endfunction
else
  function! s:surround_trim(txt) abort
    return substitute(a:txt, '\%(^\s\+\|\s\+$\)', '', 'g')
  endfunction
endif

function! s:surround_customsurroundings(char, b, trim) abort
  let all    = s:surround_process(get(a:b ? b: : g:, 'surround_'.char2nr(a:char)))
  let before = s:surround_extractbefore(all)
  let after  = s:surround_extractafter(all)
  return a:trim ? [s:surround_trim(before), s:surround_trim(after)] : [before, after]
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
    let [before, after] = s:surround_customsurroundings(newchar, 1, 0)
  elseif exists("g:surround_".char2nr(newchar))
    let [before, after] = s:surround_customsurroundings(newchar, 0, 0)
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

function! s:surround_escape(str) abort
  return escape(a:str, '!#$%&()*+,-./:;<=>?@[\]^{|}~')
endfunction

function! s:surround_deletecustom(char, b, count) abort
  let [before, after] = s:surround_customsurroundings(a:char, a:b, 1)
  let [before_pat, after_pat] = ['\v\C'.s:surround_escape(before), '\v\C'.s:surround_escape(after)]
  " searchpair()'s 'c' flag matches both start and end.
  " Append '\zs' to the closer pattern so that it doesn't match the closer on the cursor.
  let found = searchpair(before_pat, '', after_pat.'\zs', 'bcW')
  if found <= 0
    return ['','']
  endif
  " Handle count/nesting only for asymmetric surroundings
  if before !=# after
    for _ in range(a:count - 1)
      let found = searchpair(before_pat, '', after_pat, 'bW')
      if found <= 0
        return ['','']
      endif
    endfor
  endif
  norm! v
  if before ==# after
    call search(before_pat, 'ceW')
    let found = search(after_pat, 'eW')
  else
    let found = searchpair(before_pat, '', after_pat, 'W')
    call search(after_pat, 'ceW')
  endif
  if found <= 0
    exe "norm! \<Esc>"
    return ['','']
  endif
  norm! d
  return [before, after]
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
  call setreg('"',"\032",'v')
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
  call search("\032",'bW')
  let @@ = reg_save
  let &clipboard = cb_save
  return "\<Del>"
endfunction " }}}2

function! s:surround_reindent() abort " {{{2
  if get(b:, 'surround_indent', get(g:, 'surround_indent', 1)) && (!empty(&equalprg) || !empty(&indentexpr) || &cindent || &smartindent || &lisp)
    silent norm! '[=']
  endif
endfunction " }}}2

function! s:surround_dosurround(...) " {{{2
  let sol_save = &startofline
  set startofline
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
  if !exists("b:surround_".char2nr(char)) && !exists("g:surround_".char2nr(char))
    if char == 'a'
      let char = '>'
    elseif char == 'r'
      let char = ']'
    endif
  endif
  let newchar = ""
  if a:0 > 1
    let newchar = a:2
    if newchar == "\<Esc>" || newchar == "\<C-C>" || newchar == ""
      if !sol_save
        set nostartofline
      endif
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
  elseif exists("b:surround_".char2nr(char))
    let [before, after] = s:surround_deletecustom(char, 1, scount)
  elseif exists("g:surround_".char2nr(char))
    let [before, after] = s:surround_deletecustom(char, 0, scount)
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
    if !sol_save
      set nostartofline
    endif
    return ""
  endif
  let oldline = getline('.')
  let oldlnum = line('.')
  if exists("b:surround_".char2nr(char)) || exists("g:surround_".char2nr(char))
    call setreg('"', before.after, "c")
    let keeper = substitute(substitute(keeper,'\v\C^'.s:surround_escape(before).'\s=','',''), '\v\C\s='.s:surround_escape(after).'$', '','')
  elseif char ==# "p"
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
  if !sol_save
    set nostartofline
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

" vim: set fdm=marker et sw=4:
