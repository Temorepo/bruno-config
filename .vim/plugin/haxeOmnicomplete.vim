""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Name:		        haxeOmnicomplete vim plugin v 1.01
"                   Copyright(c)2008 Carlos Fco. Delgado M.
"
" Description:	    Allows to use the haxe compiler for omnicomplete in vim.
"                   Includes some niceties like being able to jump to errors 
"                   using the quickfix commands after compiler errors during
"                   omnicompletion. For use and installation, please check
"                   README.
"
" Author:	        Carlos Fco. Delgado M <carlos.f.delgado at gmail.com>
"
" Last Change:	    09-Dic-2008 Fixed another problem with paths (thanks
"                   again Laurence), added support for completing namespaces
"					and types in function calls.
"                   see CHANGELOG.
"
"  This program is free software; you can redistribute it and/or modify
"  it under the terms of the GNU General Public License as published by
"  the Free Software Foundation; either version 2 of the License, or
"  (at your option) any later version.
"
"  This program is distributed in the hope that it will be useful,
"  but WITHOUT ANY WARRANTY; without even the implied warranty of
"  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"  GNU General Public License for more details.
"
"  You should have received a copy of the GNU General Public License
"  along with this program; if not, write to the Free Software
"  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !exists('g:vim_haxe_no_filetype')
  " Map the keys /p and /l to HaxeAddClasspath() and HaxeAddLib() respectively.
  " Mapping could be different if you changed your <LocalLeader> key.
  " set filetype so that the ftplugin/haxe.vim is loaded
  " Declaring errorformat to parse the errors that we may encounter during autocomplete.
  " Check for the global variables on load or new haxe file
  augroup Haxe
    autocmd BufRead,BufNewFile *.m,*.hx setlocal filetype=haxe
      \| nnoremap <silent> <buffer> <LocalLeader>p :call HaxeAddClasspath()<Cr>
      \| nnoremap <silent> <buffer> <LocalLeader>l :call HaxeAddLib()<Cr>
      \| setlocal errorformat=%f:%l:\ characters\ %\\d%\\+-%c\ %m
      "\| autocmd BufNewFile,BufRead *.hx call HaxeCheckForGlobals()

    autocmd BufRead,BufNewFile *.hxml setlocal filetype=haxe_hxml
  augroup end
endif
