" Vim compiler file
" Compiler:     haxe
" Maintainer:   Bruno Garcia

if exists("current_compiler")
  finish
endif
let current_compiler = "haxe"

"if exists(":CompilerSet") != 2		" older Vim always used :setlocal
"  command -nargs=* CompilerSet setlocal <args>
"endif

CompilerSet makeprg=haxe\ build.hxml
set errorformat=%f\:%l\:\ characters\ %c-%*[^\ ]\ :\ %m
"CompilerSet errorformat=%f:%l:\ characters\ %c-%*\\d\ :\ %m
"CompilerSet errorformat=%f:%l:\ characters\ %c\-%n\ :\ %m
