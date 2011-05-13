if exists("current_compiler")
    finish
endif
let current_compiler = "mxmlc"

setlocal errorformat=
    \%E%f(%l):\ col:\ %c\ Error:\ %m,
    \%W%f(%l):\ col:\ %c\ Warning:\ %m,
    \%-G%.%#
