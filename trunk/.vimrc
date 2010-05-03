"filetype plugin on

source ~/.vim/dvorak.vim
"source ~/.vim/ant.vim

" Options and parameters

set backspace=2
set mouse=a

set ignorecase
set smartcase

set backup
set backupdir=/tmp

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

au BufNewFile,BufRead *.as setf actionscript
au BufNewFile,BufRead *.fx setf javafx
au BufNewFile,BufRead *.hx setf haxe
au BufNewFile,BufRead *.mtt setf xhtml

" actionscript language
let tlist_actionscript_settings = 'actionscript;c:class;t:constant;f:method;p:property;v:member'
let tlist_haxe_settings='haxe;f:functions;v:variables;c:classes;i:interfaces;e:enums;t:typedefs'
let Tlist_Auto_Open = 0
let Tlist_Exit_OnlyWindow = 1

" commentify a block, highlight a block and then press ",/"
map ,/ :s/^/\/\//<CR>
map ,, :s/^\/\///<CR>

command -nargs=* Make make <args> | cwindow 3
map <CR> :wa<CR>:make<CR>

" Handy
"noremap - ^
"noremap _ $
noremap H <C-t>
noremap S :tag!<CR>
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
