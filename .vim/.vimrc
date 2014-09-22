" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" cronntab hates backups on OSX
au FileType crontab set nobackup nowritebackup

" Backup files suck
set nobackup

" Swap files suck
set noswapfile

" Turn off softwarp
set nowrap

" Make :wq case insensitive
:command WQ wq
:command Wq wq
:command W w
:command Q q

" Command completion for Vim's commands
set wildmenu
set wildmode=list:longest,full

set guifont=Inconsolata:h15
set background=light
colorscheme mayansmoke
filetype plugin indent on

" Remap default leader to comma
let mapleader=","

" Delete word under cursor in insert mode: http://stackoverflow.com/questions/833838/delete-word-after-or-around-cursor-in-vim
:imap <C-d> <C-[>diwi

" Toggle mode with jj as well as escape
inoremap jj <ESC>

" Leader commands.
" Open a new vertical split and jump to it -- stevelosh.com
noremap <leader>w <C-w>v<C-w>l
" Move around splits with the ctrl keey -- stevelosh.com
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Bring up NERDTree with Ctrl-E
map <C-E> :NERDTreeToggle<CR>

" Close vim if only NERDTree is open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Auto change the directory to the current file I'm working on
autocmd BufEnter * lcd %:p:h

" Highlight current line - this is apparently beyond Emacs' abilities
set cursorline

" Move backwards and forwards through buffers similar to moving through text
map <C-J> <ESC>:bn<CR>
map <C-K> <ESC>:bp<CR>

abbreviate teh the
abbreviate sout System.out.println
abbreviate serr System.err.println
abbreviate ztailrec import scala.annotation.tailrec
abbreviate zbash #!/usr/bin/env bash<CR>set -e # Bail early<CR>#set -x # Very verbose<CR>

map ,,, :r ~/.vim/asfheader<CR>

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set number              " turn on line numbers
set expandtab
set tabstop=2
set sts=2
set shiftwidth=2
set softtabstop=2

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

set autoindent                " always set autoindenting on

endif " has("autocmd")

" Change the color of the status line based on insert mode
" first, enable status line always
set laststatus=2

" now set it up to change the status line based on mode
if version >= 700
  au InsertEnter * hi StatusLine term=reverse ctermbg=12 gui=undercurl guisp=DeepSkyBlue
  au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=4 gui=bold,reverse
endif

" Auto run python
autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd BufRead *.py nmap <F5> :!python %<CR>

" CtrlP configuration
:nmap ; :CtrlPBuffer<CR>
:let g:ctrlp_map = '<Leader>t'
:let g:ctrlp_match_window_bottom = 0
:let g:ctrlp_match_window_reversed = 0
:let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|class|jar)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py|build|target'
:let g:ctrlp_working_path_mode = 'r' 
:let g:ctrlp_dotfiles = 0
:let g:ctrlp_switch_buffer = 0

" Code folding
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=10         "this is just what i use 

" Move swp file to /tmp so that Dropbox doesn't keep synching them.
set directory=~/tmp//,.,/var/tmp//,/tmp//

" Vim 7.3 introduced relative numbers.  If available, use them
if v:version >= 703
  set nuw=5
  autocmd FocusLost * :set number
  autocmd InsertEnter * :set number
  autocmd InsertLeave * :set relativenumber
  autocmd CursorMoved * :set relativenumber
endif

" Turn on rainbow parens
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" BufExplorer is more useful as leader e, like intellij
nnoremap <leader>e :BufExplorer<CR>

" The Silver Searcher
" Taken from http://robots.thoughtbot.com/faster-grepping-in-vim
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR><CR>

" The following is taken from Damian Conway's talk on Most Instantly Better
" Vim: http://programming.oreilly.com/2013/10/more-instantly-better-vim.

" Highlight  just the 81st column of wide lines...
highlight ColorColumn ctermbg=blue
call matchadd('ColorColumn', '\%81v', 100)

"====[ Make tabs, trailing whitespace, and non-breaking spaces visible ]======
exec "set listchars=tab:\uBB\uBB,trail:\uB7,nbsp:~"
set list

"Remap ; to : to save on typing
nnoremap  ;  :

"Toggle paste with F2
set pastetoggle=<F2>

" Map building the current file to F5 and always write it
:inoremap <f5> <c-o>:make<cR>
:map <f5> :make<cR>
set autowrite

" Makeprgs for some filetypes
autocmd BufRead *.io set makeprg=clear;io\ %

