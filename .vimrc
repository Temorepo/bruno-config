" Not sure why this was commented out
" Might be required for NERD commenter
filetype plugin on

source ~/.vim/dvorak.vim
"source ~/.vim/ant.vim

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

" Key mappings

map T 10j
map N 10k

map - :cnext<CR>
map _ :cprevious<CR>

set sw=4
set expandtab
syntax on
set background=dark
colorscheme peachpuff
set incsearch
set hls
set autowrite

au BufNewFile,BufRead *.as setf actionscript
au BufNewFile,BufRead *.fx setf javafx
au BufNewFile,BufRead *.hx setf haxe
au BufNewFile,BufRead *.mtt setf xhtml

au FileType ant,xml,html set sw=2

" actionscript language
let tlist_actionscript_settings = 'actionscript;c:class;t:constant;f:method;p:property;v:member'
let tlist_haxe_settings='haxe;f:functions;v:variables;c:classes;i:interfaces;e:enums;t:typedefs'
let Tlist_Auto_Open = 0
let Tlist_Exit_OnlyWindow = 1

" commentify a block, highlight a block and then press ",/"
"map ,/ :s/^/\/\//<CR>
"map ,, :s/^\/\///<CR>
" Use NERD commenter instead
map ,/ ,cl
map ,? ,cu

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

autocmd BufNewFile *.as call TemplateAS3()
function! TemplateAS3()
    let path = expand("%:p")

    let package = substitute(path, "^.*\/as\/", "", "")
    let package = substitute(package, "\/[^\/]*$", "", "")
    let package = substitute(package, "\/", ".", "g")
    let result = append(0, "package " . package . " {")

    let classname = substitute(path, "^.*\/", "", "")
    let classname = substitute(classname, "\\..*", "", "")
    let result = append(line("$"), [ "public class " . classname, "{", "}", "}" ])
endfunction

autocmd BufNewFile *.java call TemplateJava()
function! TemplateJava()
    let path = expand("%:p")

    let package = substitute(path, "^.*\/java\/", "", "")
    let package = substitute(package, "\/[^\/]*$", "", "")
    let package = substitute(package, "\/", ".", "g")
    let result = append(0, "package " . package . ";")

    let classname = substitute(path, "^.*\/", "", "")
    let classname = substitute(classname, "\\..*", "", "")
    let result = append(line("$"), [ "public class " . classname, "{", "}" ])
endfunction
