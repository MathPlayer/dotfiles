"
" ~/.vimrc
"

" pathogen load
execute pathogen#infect()

" explicitly get out of vi-compatible mode
set nocompatible
" fast terminal buffering
set ttyfast


"----- appearance -----"
" use default syntax highlighting
syntax on
" enable filetype detection
filetype on
" enable filetype-specific indenting
filetype indent on
" enable filetype-specific plugins
filetype plugin on
" show line numbers
set number
" show the 'line,columns' on the bar
set ruler
" show matching brackets.
set showmatch
" show tabline if there are at least two tab pages
set showtabline=2
" set text maximum width to 80
set textwidth=80
if exists('+colorcolumn')
	set colorcolumn=81
else
	au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif


"----- indent ------"
" copy indent from current line when starting a new line
set autoindent
" smart indent when starting a new line
set smartindent
" c-like indent, more strict than smartindent; do not use them simultanously
" set cindent


"----- tabs -----"
" spaces a tab counts for
set tabstop=8
" spaces inserted when hitting tab in Insert mode
set noexpandtab
" spaces inserted with reindent operations
set shiftwidth=8
" spaces vim uses when hitting Tab in insert mode
"   - if not equal to tabstop, vim will use a combination of tabs and spaces to
"       make up the desired spacing
"   - if equal to tabstop, vimm will insert spaces/tabs for it, depending
"       whether expandtab in on or off
set softtabstop=8


"----- whitespace -----"
" display whitespace characters
set list
" characters to show for tab, trailing whitespace and normal space
" set listchars=tab:→\ ,trail:~,nbsp:·
set listchars=tab:>\ ,trail:~,nbsp:·


"----- search -----"
" highlight the search phrase
set hlsearch
" highlight while typing the search phrase
set incsearch
" do case insensitive matching
set ignorecase
" override ignorecase if pattern contains upper case characters
set smartcase
" change search highlight color
highlight Search cterm=NONE ctermfg=grey ctermbg=blue
" change TODO highlight color
highlight TODO cterm=NONE ctermfg=black ctermbg=darkgreen
" change bracket match highlight color
highlight MatchParen ctermfg=red ctermbg=black


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
set backspace=indent,eol,start
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
" use mouse (=a -> anywhere possible)
set mouse=a
" set timeout between consecutive characters type when entering a command
" sequence
set timeoutlen=500
" set key for paste toogle (when active, the pasted text formatting is not
" modified by any indent feature)
set pastetoggle=<F2>


"----- key mappings -----"
" more efficient command mapping of :
nnoremap ; :
" more efficient mapping of <ESC> from insert mode
inoremap jj <ESC>
" remap arrow keys to nothing --- still learning to use vi :)
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
" map sudo save command
cmap w!! w !sudo tee % >/dev/null
" Outline overview of file toogle key
" nnoremap <silent> <F8> :TlistToggle<CR>
nnoremap <silent> <F8> :TagbarToggle<CR>
" Clear search results by pressing Enter
nnoremap <CR> :noh<CR><CR>
" Have <esc> leave cmdline-window (I do not use it)
autocmd CmdwinEnter * nnoremap <buffer> <esc> :q\|echo ""<cr>
" set key for paste toogle (when active, the pasted text formatting is not
" modified by any indent feature)
set pastetoggle=<F2>
" keys for NERDTree and Tagbar
nnoremap <silent> <F3> :TagbarToggle<CR>
nnoremap <silent> <F9> :NERDTreeToggle<CR>
nnoremap <silent> <F10> :NERDTreeFind<CR>

"----- function to remove trailing whitespace -----"
fun! <SID>StripTrailingWhitespaces()
	let L = line(".")
	let C = col(".")
	%s/\s\+$//e
	call cursor(L, C)
endfun
"---- call above function on each write;
" Internet says it's unsafe if you edit binary files
" FIXME: call it on exit for file, not on each write
" FIXME: strip trailing whitespace only on edited lines
autocmd BufWrite  * :call <SID>StripTrailingWhitespaces()


"----- plugin settings -----"
" FIXME: the pathogen plugins are loaded __after__ vimrc loading, so any
" 'exists' conditional will fail.
" Settings should be moved into each plugin own config file.

" cscope
set nocscopeverbose " suppress 'duplicate connection' error
function! LoadCscope()
	let db = findfile("cscope.out", ".;")
	if (!empty(db))
		let path = strpart(db, 0, match(db, "/cscope.out$"))
		set nocscopeverbose " suppress 'duplicate connection' error
		exe "cs add " . db . " " . path
		set cscopeverbose
	endif
endfunction
autocmd BufEnter /* call LoadCscope()

" Tlist
" Automatically open the taglist window
let Tlist_Auto_Open = 1
" DO not use any extra empty lines
let Tlist_Compact_Format = 1
let Tlist_Display_Prototype = 1
" open the tag window on the right
let Tlist_Use_Right_Window = 1
" fold tags for inactive files
let Tlist_File_Fold_Auto_Close = 1
" show tags only for the current file
let Tlist_Show_One_File = 1
" set width of taglist window
let Tlist_WinWidth = 40
" set maximum length for a tag name
let Tlist_Max_Tag_Length = 40
" close tlist if it is the last tab opened
let Tlist_Exit_OnlyWindow = 1

" nerdtree-tabs
" open NERDTreeTabs automatically
let g:nerdtree_tabs_open_on_console_startup = 1

" tagbar
" Do not show any element unfolded
let g:tagbar_foldlevel = 0
" Do not use any extra empty lines
let g:tagbar_compact = 1
" set indentation for folds
let g:tagbar_indent = 1

" automatically open and close the popup menu / preview window
" au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" set completeopt=menuone,menu,longest,preview
