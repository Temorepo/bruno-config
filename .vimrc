"filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

set nocompatible

" Not sure why this was commented out
" Might be required for NERD commenter
filetype plugin on

" Options and parameters
let mapleader=","

set backspace=2
set mouse=a

set ignorecase
set smartcase

set backup
set backupdir=/tmp

set gdefault

syntax on

"set cindent
set smartindent
set showmode

set nowrap
set scrolloff=2
set sidescrolloff=2

set shiftwidth=4
set softtabstop=4
"set tabstop=4
set expandtab

syntax on
set background=dark
set incsearch
set hls
set autowrite

" Key mappings

map T 10j
map N 10k

map - :cnext<CR>
map _ :cprevious<CR>

noremap s l
map n k
map t j
if version > 500
	ounmap t
endif
noremap l n
noremap L N

" GUI options
set guioptions-=r " Scrollbars
set guioptions-=R
set guioptions-=l
set guioptions-=L
set guioptions-=t
set guioptions-=m " Menubar
set guioptions-=T " Toolbar
set mousefocus
set mousehide
highlight Normal guibg=black guifg=white
colorscheme desert

" Autosave liberally. Use git!
au FocusLost * :wa
set autowrite

" File types
au BufNewFile,BufRead *.as setf actionscript
au BufNewFile,BufRead *.fx setf javafx
au BufNewFile,BufRead *.hx setf haxe
au BufNewFile,BufRead *.mtt setf xhtml

au FileType ant,xml,html set sw=2

" Comment and uncomment a block
map <leader>/ <leader>cl
map <leader>? <leader>cu

" Handy
"noremap - ^
"noremap _ $
noremap H <C-O>
noremap S <C-I>
command EditConfig topleft sp ~/.vimrc

set tags=~/.tags/*/tags,./tags,tags

"highlight AutoSearch cterm=underline
"autocmd CursorMoved * silent! exe printf('match AutoSearch /\<%s\>/', expand('<cword>'))

" Auto importer
function! Import(idx)
    let g:importIdx=a:idx
    pyfile ~/.vim/import.py
endfunction
command! -nargs=* Import call Import(<q-args>)
nmap ;i :pyfile /export/assemblage/aspirin/vim/import.py<CR>

command -nargs=1 -complete=tag Coreen !xdg-open http://localhost:8080/coreen/\#LIBRARY~search~<args>
nmap <leader>c :Coreen <cword><CR>

nmap <leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>/

let g:ackprg="ack-grep\\ -H\\ --nocolor\\ --nogroup\\ --column"
nmap <leader>f :Ack 

nmap <silent> <leader>t :CommandT<CR>

highlight TrailingWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match TrailingWhitespace /\s\+\%#\@<!$/ containedin=ALL

" Persistent undo
if version >= 703
    set undofile
    autocmd BufWritePre /tmp/* setlocal noundofile
    set undodir=/tmp
endif

" Always handle C-style comments nicely
set formatoptions+=croq

autocmd User plugin-template-loaded call s:template_keywords()

function! s:template_keywords()
    " The absolute path of the new file
    let abspath = expand("%:p")

    " Short name of the file
    let file = substitute(abspath, "^.*\/", "", "")

    " Filename extension
    let suffix = substitute(file, "^.*\\.", "", "")

    " Part before the extension
    let class = substitute(file, "\\..*", "", "")
    silent! %s/%CLASS%/\=class/g

    " Try to guess the relative path from the project root
    let relpath = substitute(abspath, "^.*\/\\(" . suffix . "\\|src\\)\/", "", "")
    silent! %s/%PATH%/\=relpath/g

    let relpath_noextension = substitute(relpath, "\\..*", "", "")
    silent! %s/%PATH_NOEXTENSION%/\=relpath_noextension/g

    let package = substitute(relpath, "\/[^\/]*$", "", "")
    let package = substitute(package, "\/", ".", "g")
    silent! %s/%PACKAGE%/\=package/g

    let header_path = substitute(abspath, "\/src/.*", "", "") . "/lib/SOURCE_HEADER"
    if filereadable(header_path)
        let header = join(readfile(header_path), "\n")
        silent! %s/%SOURCE_HEADER%/\=header/g
    elseif search("%SOURCE_HEADER%")
        " Remove the entire line with SOURCE_HEADER if we don't have one
        execute 'normal! "_dd'
    endif

    " Jump to %CURSOR%
    if search("%CURSOR%")
        execute 'normal! "_cf%'
    endif
endfunction

function! WasBuildSuccessful()
    for qf in getqflist()
        if qf.valid
            return 0
    endfor
    return 1
endfunction

function! OnVimBuildComplete(filename)
    let curwin = winnr()
    exec "cgetfile " . a:filename
    botright cwindow

    redraw!
    echo

    " Jump back and prevent the quickfix window from stealing focus
    exec curwin . "wincmd w"

    " TODO: We should look at the exit code to see if the build was successful
    if WasBuildSuccessful()
        silent !notify-send "Build passed" -i ~/.vim/icon-ok.svg
    else
        silent !notify-send "Build FAILED" -i ~/.vim/icon-error.svg
    endif
endfunction

function! VimBuild()
    silent wall
    " TODO: Walk up the path and use the deepest vimbuild script
    " TODO: Some way to intelligently set the errorformat/compiler
    let dir = getcwd()
    echo "Building " . substitute(dir, ".*/", "", "") . "..."
    call AsyncCommand(dir . "/vimbuild " . expand("%:p"), "OnVimBuildComplete")
endfunction
map <silent> <F5> :call VimBuild()<CR>
imap <silent> <F5> <C-O>:call VimBuild()<CR>

let g:compiler_gcc_ignore_unmatched_lines=1
autocmd FileType cpp,c compiler gcc
autocmd FileType haxe compiler haxe
autocmd FileType actionscript compiler mxmlc
autocmd FileType javascript compiler closure
autocmd FileType java compiler ant

" Change the windows these commands create
cnoreabbrev sta vert :sta
cnoreabbrev help to :help

" Previous rebinds may screw up SELECT mode (used by snippets), so remove all
" select mode mappings. Is this safe? Who knows!
smapclear
