if exists("current_compiler")
    finish
endif
let current_compiler = "haxe"

setlocal errorformat=
    \%E%f(%l):\ col:\ %c\ Error:\ %m,
    \%W%f(%l):\ col:\ %c\ Warning:\ %m,
    \%-G%.%#
setlocal errorformat=
    \%f\:%l\:\ characters\ %c-%*[^\ ]\ :\ %m,
    \%-G%.%#
