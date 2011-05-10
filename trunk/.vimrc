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

" commentify a block, highlight a block and then press ",/"
"map ,/ :s/^/\/\//<CR>
"map ,, :s/^\/\///<CR>
" Use NERD commenter instead
map <leader>/ <leader>cl
map <leader>? <leader>cu

command -nargs=* Make make <args> | cwindow 3
"map <CR> :wa<CR>:make<CR>

" Handy
"noremap - ^
"noremap _ $
noremap H <C-O>
noremap S <C-I>
command EditConfig sp ~/.vimrc

" Eclim
"map <silent> <buffer> ji :JavaImport<cr>
"map <silent> <buffer> jg :JavaSearchContext<cr>
"map <silent> <buffer> jc :JavaCorrect<cr>

"let st = g:snip_start_tag
"let et = g:snip_end_tag
"let cd = g:snip_elem_delim
"let g:SuperTabDefaultCompletionType = 'context'
let g:haxe_build_hxml="build.hxml"
"let g:globalHaxeLibs = ['templo', 'hxJSON']
set tags=~/.tags/*/tags,./tags,tags

highlight AutoSearch cterm=underline
autocmd CursorMoved * silent! exe printf('match AutoSearch /\<%s\>/', expand('<cword>'))

" Auto importer
function! Import(idx)
    let g:importIdx=a:idx
    pyfile ~/.vim/import.py
endfunction
command! -nargs=* Import call Import(<q-args>)
nmap ;i :pyfile ~/.vim/import.py<CR>

command -nargs=1 -complete=tag Coreen !xdg-open http://localhost:8080/coreen/\#LIBRARY~search~<args>
nmap <leader>c :Coreen <cword><CR>

nmap <leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>/

let g:ackprg="ack-grep\\ -H\\ --nocolor\\ --nogroup\\ --column"
nmap <leader>f :Ack 

nmap <leader>t :CommandT

highlight TrailingWhitespace ctermbg=red guibg=red
autocmd Syntax * syn match TrailingWhitespace /\s\+\%#\@<!$/ containedin=ALL

" Persistent undo
set undofile
autocmd BufWritePre /tmp/* setlocal noundofile
set undodir=/tmp

autocmd User plugin-template-loaded call s:template_keywords()

function! s:template_keywords()
    " The absolute path of the new file
    let path = expand("%:p")

    " Short name of the file
    let file = substitute(path, "^.*\/", "", "")

    " Filename extension
    let suffix = substitute(file, "^.*\\.", "", "")

    " Part before the extension
    let class = substitute(file, "\\..*", "", "")
    silent! %s/%CLASS%/\=class/g

    " Try to guess the package name from the path
    let package = substitute(path, "^.*\/\\(" . suffix . "\\|src\\)\/", "", "")
    let package = substitute(package, "\/[^\/]*$", "", "")
    let package = substitute(package, "\/", ".", "g")
    silent! %s/%PACKAGE%/\=package/g

    let header_path = substitute(path, "\/src/.*", "", "") . "/lib/SOURCE_HEADER"
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

function! ReWho()
    wall
    silent !/export/who/bin/asbuild main-client
    silent !kill `cat /tmp/whoserver.pid`
endfunction
map <silent> <F5> :call ReWho()<CR>