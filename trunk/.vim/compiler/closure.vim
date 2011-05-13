if exists("current_compiler")
    finish
endif
let current_compiler = "closure"

setlocal errorformat=
    \%E%f\:%l\:\ ERROR\ -\ %m,
    \%-Z%p^,
    \%W%f\:%l\:\ WARNING\ -\ %m,
    \%-Z%p^,
    \%-G%.%#
