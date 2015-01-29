scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:defval = {} " {{{
let s:defval.tags = 'tags'
let s:defval.ctags = 'ctags'
let s:defval.dirs = ['.git']
let s:defval.cmdopt = '-R --sort=yes --tag-relative'
let s:defval.filetype = 0
" }}}

function! s:get(name) abort " {{{
  return get(g:, 'gentags#' . a:name, s:defval[a:name])
endfunction " }}}

function! s:get_path() abort " {{{
  " search `tags` file or '.git' dir upwards.
  let dd = ''
  let fdir = expand('%:p:h')
  for dir in s:get('dirs')
    let dd = finddir(dir, fdir . ';')
    if dd !=# ''
      let dd = fnamemodify(dd, ':p:h')
      break
    endif
  endfor

  let df = findfile(s:get('tags'), fdir . ';')
  if df !=# ''
    let df = fnamemodify(df, ':p:h')
  endif

  if dd ==# '' && df ==# ''
    return fdir
  elseif dd ==# ''
    return df
  elseif df ==# ''
    return dd
  elseif len(df) < len(dd)
    " なるべく深いところ.
    return dd
  else
    return df
  endif
endfunction " }}}

function! s:cmdopt(dir) abort " {{{
  let opt = ' '
  let opt .= s:get('cmdopt')
  if s:get('filetype') && &filetype !=# ''
    let opt .= printf(' --languages=%s', &filetype)
    let opt .= printf(' -f %s/%s.%s', a:dir, &filetype, s:get('tags'))
  else
    let opt .= printf(' -f %s/%s', a:dir, s:get('tags'))
  endif
  return opt
endfunction " }}}

function! s:has_vimproc() abort " {{{
  if !exists('s:exists_vimproc')
    try
      call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction " }}}

function! s:system(cmd, opt) abort " {{{
  let system = s:has_vimproc() ? 'vimproc#system_bg' : 'system'
  let args = [a:cmd . a:opt]
  return call(system, args)
endfunction " }}}

function! s:throwmsg(msg) abort " {{{
  return printf('gentags: %s', a:msg)
endfunction " }}}

function! gentags#ctags(...) abort " {{{
  let dir = a:0 == 0 ? s:get_path() : a:1
  if dir == ''
    echoerr s:throwmsg('tags path not found' . a:0)
    return
  endif
  let cmd = s:get('ctags')

  let save_dir = getcwd()
  try
    execute printf('lcd %s', dir)
    echo s:throwmsg(printf('do `%s` at `%s`', cmd, dir))
    call s:system(cmd, s:cmdopt(dir))
  finally
    execute printf('lcd %s', save_dir)
  endtry
endfunction " }}}

function! gentags#test() abort " {{{
  return s:get_path()
endfunction " }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
