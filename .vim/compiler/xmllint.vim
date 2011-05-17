" Vim compiler file
" Compiler:	xmllint
" Maintainer:	Doug Kearns <djkea2@gus.gscit.monash.edu.au>
" URL:		http://gus.gscit.monash.edu.au/~djkea2/vim/compiler/xmllint.vim
" Last Change:	2004 Nov 27

" Sometime in the last 7 years, the errorformat in the official xmllint.vim
" became out of date. So, here's a patched version. -- Bruno

if exists("current_compiler")
  finish
endif
let current_compiler = "xmllint"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet errorformat=%E%f:%l:\ parser\ error\ :\ %m,
		    \%W%f:%l:\ warning\ :\ %m,
		    \%-Z%p^,
		    \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
