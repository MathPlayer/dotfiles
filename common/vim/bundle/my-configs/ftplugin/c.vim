"
" ~/.vim/ftplugin/c.vim
"


"----- indent ------"
" copy indent from current line when starting a new line
setlocal autoindent
" smart indent when starting a new line
setlocal nosmartindent
" c-like indent, more strict than smartindent; do not use them simultanously
setlocal cindent

"----- tabs -----"
" spaces a tab counts for
setlocal tabstop=8
" spaces inserted when hitting tab in Insert mode
setlocal noexpandtab
" spaces inserted with reindent operations
setlocal shiftwidth=8
" spaces vim uses when hitting Tab in insert mode
"   - if not equal to tabstop, vim will use a combination of tabs and spaces to
"       make up the desired spacing
"   - if equal to tabstop, vimm will insert spaces/tabs for it, depending
"       whether expandtab in on or off
setlocal softtabstop=8
