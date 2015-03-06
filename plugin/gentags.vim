scriptencoding utf-8

if exists('g:loaded_gentags')
  finish
endif


let s:save_cpo = &cpo
set cpo&vim

"-nargs=*    Any number of arguments are allowed (0, 1, or many),
command! -nargs=* -complete=dir
\ GenTags call gentags#ctags(<f-args>)

augroup augrp__gentags
  autocmd!
  autocmd BufWritePost * :call gentags#auto_ctags()
  autocmd BufReadPost  * :call gentags#auto_settags()
augroup END

let g:loaded_gentags = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
