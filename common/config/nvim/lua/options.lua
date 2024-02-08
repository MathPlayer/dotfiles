local HOME = require('utils').HOME

---- General settings
-- Disable the GUI cursor / use the terminal one.
vim.opt.guicursor = ''
-- Workaround for some broken plugins which set guicursor indiscriminately.
vim.cmd('autocmd OptionSet guicursor noautocmd set guicursor=')
-- Use the system clipboard.
vim.opt.clipboard = 'unnamedplus'

---- Tool config
vim.g.neovim_python_env = HOME .. "/.config/nvim/.venv"
vim.g.python3_host_prog = vim.g.neovim_python_env .. "/bin/python3"
vim.g.node_host_prog = HOME .. "/.config/nvim/node_modules/.bin/neovim-node-host"

---- appearance
-- use 24-bit colors
vim.opt.termguicolors = true
--  Improve visual performance by not redrawing the screen when executing some commands
vim.opt.lazyredraw = true
-- show line numbers...
vim.opt.number = true
-- ... except when on quickfix
vim.cmd('autocmd FileType qf setlocal nonumber')

---- spelling
vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.spelloptions = 'camel'
vim.cmd[[highlight SpellBad gui=undercurl guisp=LightGreen]]


---- search
-- highlight the search phrase
vim.opt.hlsearch = true
-- highlight while typing the search phrase
vim.opt.incsearch = true
-- do case insensitive matching
vim.opt.ignorecase = true
-- override ignorecase if pattern contains upper case characters
vim.opt.smartcase = true

-- highlight the cursor line
-- XXX: using this + vertical splits is sometimes slow in (n)vim
vim.opt.cursorline = true
-- show the 'line,columns' on the bar
vim.opt.ruler = true
-- show matching brackets
vim.opt.showmatch = true

-- Always show the signcolumn, except for plugins configured below
vim.cmd('autocmd BufRead,BufNewFile * setlocal signcolumn=yes')

---- indent
-- copy indent from current line when starting a new line
vim.opt.autoindent = true
-- smart indent when starting a new line
vim.opt.smartindent = true
-- c-like indent, more strict than smartindent; do not use them simultanously
-- vim.opt.cindent = true

---- tabs
-- spaces a tab counts for
vim.opt.tabstop = 2
-- spaces inserted when hitting tab in Insert mode
vim.opt.expandtab = true
-- spaces inserted with reindent operations
vim.opt.shiftwidth = 2
-- spaces vim uses when hitting Tab in insert mode:
-- - if not equal to tabstop, vim will use a combination of tabs and spaces to make up the desired spacing
-- - if equal to tabstop, vimm will insert spaces/tabs for it, depending whether expandtab in on or off
vim.opt.softtabstop = 2

-- TODO: convert to lua equivalent
vim.cmd([[
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set text maximum width to 99 (100 including newline) - except when on quickfix
set textwidth=99
if exists('+colorcolumn')
  set colorcolumn=100
  autocmd FileType qf setlocal colorcolumn=
else
  autocmd BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>99v.\+', -1)
  " TODO remove matchadd on quickfix window for older versions of vim
endif

"----- whitespace -----"
" display whitespace characters
set list
" characters to show for tab, trailing whitespace and normal space
try
  set listchars=tab:→\ ,trail:~,nbsp:·
catch
  set listchars=tab:>\ ,trail:_,nbsp:~
endtry
set showbreak=\\   " the spaces are needed

"----- highlight colors -----"
" change search highlight color
highlight Search cterm=NONE ctermfg=black ctermbg=darkyellow gui=NONE guifg=black guibg=darkyellow
" highlight trailing whitespace as errors
" highlight default link ExtraWhitespace Error
" highlight ExtraWhitespace ctermbg=darkred guibg=darkred
" match ExtraWhitespace /\s\+$/
" augroup HighlightWhitespace
" autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" autocmd BufWinLeave * call clearmatches()
" augroup END

"----- menu and status -----"
" always show the status line
set laststatus=2
" turn on command line completion wild style
set wildmenu
" turn on wild mode huge list
set wildmode=list:longest
" show partial commands in last line of screen
set showcmd


"----- miscellaneous -----"
" use smart backspaces over enumerated elements
set backspace=eol,start,indent
" don't wrap lines
set nowrap
" do not save backup files
set nobackup
" do not save swap files
set noswapfile
" remember 1000 commands and history
set history=1000
" set levels of undo
set undolevels=2000
" splitting a window will put the new one below the current one
set splitbelow
" splitting a window will put the new one right to the current one
set splitright
" use mouse with the new sgr protocol (i.e. useful to scroll on big terminals)
if has('mouse_sgr')
  set ttymouse=sgr
endif
" use mouse (=a -> anywhere possible)
set mouse=a
" set timeout between consecutive characters type when entering a command
" sequence
set timeoutlen=500


"----- key mappings -----"
" easy search highlighted text (visual highlight and press //)
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'
" Have <esc> leave cmdline-window (I do not use it)
autocmd CmdwinEnter * nnoremap <buffer> <esc> :q\|echo ""<cr>
"fast buffer switch
nnoremap <A-j> :bprev<CR>
nnoremap <A-k> :bnext<CR>
" switch buffers without save
set hidden
" Change work directory to parent of current file.
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" set key for paste toogle (when active, the pasted text formatting is not
" modified by any indent feature)
set pastetoggle=<F2>

" Format json files.
map <leader>jf :%!python -m json.tool<cr>

"----- misc -----"

fun! StripTrailingWhitespace()
  " function to remove trailing whitespaces
  let L = line(".")
  let C = col(".")
  %s/\s\+$//e
  call cursor(L, C)
endfun
"---- call above function on each write;
" Internet says it's unsafe if you edit binary files
" XXX: call it on exit for file, not on each write
" FIXME: strip trailing whitespace only on edited lines
" autocmd BufWrite  * :call <SID>StripTrailingWhitespaces()
command StripTrailingWhitespace call StripTrailingWhitespace()

" Set specific syntax
" objective-c vs octave problem
augroup filetypedetect
  " au! BufRead, BufNewFile *.m,*.oct set filetype=octave
  au! BufRead,BufNewFile,BufRead *.m set filetype=objc
  au! BufRead,BufNewFile,BufRead *.mm set filetype=objcpp
augroup END
augroup filetypedetect
  au! BufRead, BufNewFile *.xcconfig set filetype=xcconfig
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
]])

-- vim: ts=2 sts=2 sw=2 et
