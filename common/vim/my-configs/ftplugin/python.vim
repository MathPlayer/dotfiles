"
" ~/.vim/ftplugin/python.vim
"
"----- tabs -----"
" spaces a tab counts for
setlocal tabstop=4
" spaces inserted when hitting tab in Insert mode
setlocal expandtab
" spaces inserted with reindent operations
setlocal shiftwidth=4
" spaces vim uses when hitting Tab in insert mode
"   - if not equal to tabstop, vim will use a combination of tabs and spaces to
"       make up the desired spacing
"   - if equal to tabstop, vimm will insert spaces/tabs for it, depending
"       whether expandtab in on or off
setlocal softtabstop=4
