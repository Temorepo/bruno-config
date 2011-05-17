if exists("current_compiler")
    finish
endif
let current_compiler = "haxe"

setlocal errorformat=
    \%E%f\:%l\:\ characters\ %c-%*[^\ ]\ :\ %m,
    \%E%f\:%l\:\ character\ %c\ :\ %m,
    \%E%f\:%l\:\ lines\ %*[^\ ]-%*[^\ ]\ :\ %m,
    \%-G%.%#
