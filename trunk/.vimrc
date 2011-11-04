"filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

set nocompatible

" To allow reloading, clear out vimrc autocmds
" Also since I like to spread autocmds throughout this entire file and augroup
" only works on unbroken sequences of :autocmd, set up Vautocmd to use the
" vimrc group.
augroup vimrc | autocmd!
command! -nargs=* Vautocmd autocmd vimrc <args>

" Reload vimrc on write
Vautocmd BufWritePost $MYVIMRC source %

" Not sure why this was commented out
" Might be required for NERD commenter
filetype plugin on

" General options
let mapleader=","

set backspace=indent,eol,start
set mouse=a

set ignorecase
set smartcase

set backup
set backupdir=/tmp

set gdefault

set confirm

set showmode
set showcmd

set nowrap
set scrolloff=2
set sidescrolloff=2

set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set autoindent
set smartindent

syntax on
set background=dark
set incsearch
set hls

set wildignore+=*/dist,*/build
set wildignore+=.svn,.hg,.git
set wildignore+=*.png,*.swf,*.fla,*.pyc,*.o,*.cmo,*.cmi,*.cmx,*.annot,*.class,*.jar,*.swc

" Key mappings

map T 10j
map N 10k

" Cycle through build errors (and ack results)
map <silent> - :cc<CR>:cnext<CR>
map <silent> _ :cc<CR>:cprevious<CR>
map <silent> <leader>- :ccl<CR>

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
set guioptions+=c " Console dialogs
set mousefocus
set mousehide
highlight Normal guibg=black guifg=white
colorscheme desert

" Autosave liberally. Use version control!
Vautocmd FocusLost * if !&readonly | wall | endif
set autowrite

" File types
Vautocmd BufNewFile,BufRead *.as setf actionscript
Vautocmd BufNewFile,BufRead *.fx setf javafx
Vautocmd BufNewFile,BufRead *.hx setf haxe
Vautocmd BufNewFile,BufRead *.mtt setf xhtml

Vautocmd FileType ant,xml,html setlocal sw=2

" Comment and uncomment a block
let NERDSpaceDelims=1
map <leader>/ <leader>cl
map <leader>? <leader>cu

" Handy
"noremap - ^
"noremap _ $
noremap H <C-O>
noremap S <C-I>
command! EditConfig sp $MYVIMRC

" Dvorak HTNS switches windows
noremap <C-H> <C-W>h
noremap <C-T> <C-W>j
noremap <C-N> <C-W>k
noremap <C-S> <C-W>l
noremap <Space> <C-W>w
noremap <S-Space> <C-W>W

" inoremap { {<CR>}<ESC>O

set tags=~/.tags/*/tags,./tags,tags

"highlight AutoSearch term=italic cterm=italic gui=italic
"Vautocmd CursorMoved * silent! exe printf('match AutoSearch /\<%s\>/', expand('<cword>'))

" Open the symbol under the cursor in Coreen
command! -nargs=1 -complete=tag Coreen !xdg-open http://localhost:8192/coreen/\#LIBRARY~search~<args>
nmap <leader>c :Coreen <cword><CR>

" Quickly search and replace the word under the cursor
nmap <leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>/
" TODO(bruno): Search and replace across multiple files

let g:ackprg="ack-grep -H --nocolor --nogroup --column --ignore-dir=dist --ignore-dir=build"
let g:ackhighlight=1
nmap <leader>f :Ack<space>
nmap <leader>F :Ack <c-r>=expand("<cword>")<cr><space>
" TODO(bruno): Ack using current visual selection

let g:CommandTMaxDepth=30
let g:CommandTMaxHeight=20
let g:CommandTMatchWindowAtTop=1

nmap <leader>g :tag<space>
nmap <leader>G :stag<space>

nmap <silent> <leader>t :CommandT<CR>

" Highlight trailing whitespace
highlight TrailingWhitespace ctermbg=red guibg=red
Vautocmd InsertLeave,Syntax * match TrailingWhitespace /\s\+$/
Vautocmd InsertEnter * match TrailingWhitespace /\s\+\%#\@<!$/

" Highlight characters past 100 columns
highlight LongLine ctermbg=DarkRed guibg=DarkRed
Vautocmd BufNewFile,BufRead * if &modifiable | syntax match LongLine '\%>100v.\+' | endif
set textwidth=100
set winwidth=100

" Persistent undo
if version >= 703
    set undofile
    Vautocmd BufWritePre /tmp/* setlocal noundofile
    set undodir=/tmp
endif

" Always handle C-style comments nicely
set formatoptions+=croq

Vautocmd User plugin-template-loaded call s:template_keywords()
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

    let project_root = substitute(abspath, "\/src/.*", "", "")
    let header_path = project_root . "/etc/SOURCE_HEADER"
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

function! ShowErrors(filename)
    let curwin = winnr()
    exec "cgetfile " . a:filename
    cwindow

    redraw!
    echo

    " Jump back and prevent the quickfix window from stealing focus
    exec curwin . "wincmd w"
endfunction

function! OnVimBuildComplete(filename)
    call ShowErrors(a:filename)

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
    echo "Building " . substitute(dir, ".*/", "", "") . " ..."
    call AsyncCommand(dir . "/vimbuild " . expand("%:p"), "OnVimBuildComplete")
endfunction
map <silent> <F5> :call VimBuild()<CR>
imap <silent> <F5> <C-O>:call VimBuild()<CR>

" Compilers
let g:compiler_gcc_ignore_unmatched_lines=1
Vautocmd FileType cpp,c compiler gcc
Vautocmd FileType haxe compiler haxe
Vautocmd FileType actionscript compiler mxmlc
Vautocmd FileType javascript compiler closure
Vautocmd FileType java compiler ant
Vautocmd FileType xml compiler xmllint

" Window management
"set splitright

" (Experimental)
" Layout windows by their type. Help windows will always be openned at the
" very top, file edit windows will always be vertically split below that, and
" everything else along the very bottom.
function! IsMiddleWindow(buftype)
    return a:buftype == ""
endfunction

"Vautocmd BufNewFile,BufRead * if &buftype == "quickfix" | cc | endif

let RecentWindows = []
function! OnWindowEnter()
    if expand("%") == "GoToFile"
        return " Don't react to Command-T
    endif
    if !IsMiddleWindow(&buftype)
        return
    endif
    let buf = bufnr("%")
    let idx = index(g:RecentWindows, buf)
    if idx >= 0
        let _ = remove(g:RecentWindows, idx)
    endif
    let g:RecentWindows = insert(g:RecentWindows, buf)[:1]
endfunction
"Vautocmd BufRead,WinEnter * call OnWindowEnter()

function! ArrangeWindows()
    if expand("%") == "GoToFile"
        return " Don't react to Command-T
    endif

    let bookmark = bufnr("%")
    let top = []
    let middle = []
    let bottom = []

    let wincount = winnr("$")
    for ii in range(1, wincount)
        let buf = winbufnr(ii)
        let buftype = getbufvar(buf, "&buftype")
        if IsMiddleWindow(buftype)
            let middle = add(middle, buf)
        elseif buftype == "help"
            let top = add(top, buf)
        else
            let bottom = add(bottom, buf)
        endif
    endfor

    "call OnWindowEnter()
    for buf in middle
        exec bufwinnr(buf) . "wincmd w"
        if len(g:RecentWindows) < 2 || index(g:RecentWindows, buf) >= 0
            wincmd L
        else
            close
        endif
    endfor
    for buf in top
        exec bufwinnr(buf) . "wincmd w"
        wincmd K
        "resize 20
    endfor
    for buf in bottom
        exec bufwinnr(buf) . "wincmd w"
        wincmd J
        resize 10
    endfor

    " Jump back to the original window
    exec bufwinnr(bookmark) . "wincmd w"
endfunction
"Vautocmd BufWinEnter * call ArrangeWindows()
Vautocmd BufNewFile,BufRead * call ArrangeWindows()

function! ToggleWindow()
    if len(g:RecentWindows) < 2
        return
    endif
    let buf = bufnr("%")
    let dest = g:RecentWindows[0]
    if buf == dest
        let dest = g:RecentWindows[1]
    endif
    exec bufwinnr(dest) . "wincmd w"
endfunction
"noremap <silent> <Space> :call ToggleWindow()<CR>

" Validate XML syntax on write (skips schema validation)
Vautocmd BufWritePost *.xml call AsyncCommand("xmllint --postvalid " . expand("%:p"), "ShowErrors")

" Opens the edit command on the current directory
"cnoremap ced e <c-r>=expand("%:h")<cr>/

let g:as_log = $HOME . "/.macromedia/Flash_Player/Logs/flashlog.txt"
let g:as_locations = [
\ "/export/assemblage/aspirin/src/main/as",
\ "/export/assemblage/flashbang/src/main/as",
\ "/export/assemblage/narya/src/main/as",
\ "/export/assemblage/nenya/src/main/as",
\ "/export/assemblage/vilya/src/main/as",
\ "/export/assemblage/orth/src/main/as",
\ "/export/AsWing/src",
\ "/export/flex/flex_sdk_4.1.0.16076/frameworks/libs/player/10.1/playerglobal.swc",
\ "/export/who/src/main/as",
\ "/export/msoy/src/as"
\ ]
nmap <leader>i :call AspirinImport()<CR>
nmap <leader>e :call AspirinLastEx() \| cwindow<CR>

" Previous rebinds may screw up SELECT mode (used by snippets), so remove all
" select mode mappings. Is this safe? Who knows!
smapclear
