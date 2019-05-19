" Use the terminal cursor.
set guicursor=
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0
" Workaround for some broken plugins which set guicursor indiscriminately.
autocmd OptionSet guicursor noautocmd set guicursor=

" Use the system clipboard.
set clipboard+=unnamedplus

" Use the vim configuration.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
