if exists("current_compiler")
    finish
endif
let current_compiler = "mxmlc"

" One for ant...
setlocal errorformat=
    \%E\ %#[%.%#]\ %f(%l):\ col:\ %c\ Error:\ %m,
    \%W\ %#[%.%#]\ %f(%l):\ col:\ %c\ Warning:\ %m,
    \%E\ %#[%.%#]\ %f:\ Error:\ %m,
    \%W\ %#[%.%#]\ %f:\ Warning:\ %m,
    \%-G%.%#

" One for standalone
setlocal errorformat+=
    \%E%f(%l):\ col:\ %c\ Error:\ %m,
    \%W%f(%l):\ col:\ %c\ Warning:\ %m,
    \%E%f:\ Error:\ %m,
    \%W%f:\ Warning:\ %m,
    \%-G%.%#
