set runtimepath+=~/.vim_runtime
set mouse=a
" TODO: correctly handle /after
if has('nvim')
  set runtimepath+=~/.vim
  set runtimepath+=~/.vim/after
endif

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim

try
source ~/.vim_runtime/configs.vim
catch
endtry

" TODO how to do this correctly
set exrc
set secure
