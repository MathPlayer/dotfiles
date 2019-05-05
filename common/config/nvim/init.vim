" Instruct vim to use terminal cursor
set guicursor=
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0
" Workaround for some broken plugins which set guicursor indiscriminately.
autocmd OptionSet guicursor noautocmd set guicursor=

" Use system clipboard
set clipboard+=unnamedplus

" Use vim configuration
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
