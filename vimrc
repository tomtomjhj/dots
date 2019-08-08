set runtimepath+=~/.vim_runtime
if has('nvim')
  set runtimepath+=~/.vim
  set runtimepath+=~/.vim/after
  set mouse=a
endif

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim
source ~/.vim_runtime/vimrcs/extended.vim

try
source ~/.vim_runtime/configs.vim
catch
endtry


set exrc
set secure
