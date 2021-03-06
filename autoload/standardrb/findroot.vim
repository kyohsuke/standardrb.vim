" Copy from : https://github.com/mattn/vim-findroot/blob/d2e28fa2b73a93f5c28a064d0b1672b3683bf47a/plugin/findroot.vim

function! s:goup(path, patterns) abort
  let l:path = a:path
  while 1
    for l:pattern in a:patterns
      let l:current = l:path . '/' . l:pattern
      if stridx(l:pattern, '*') != -1 && !empty(glob(l:current, 1))
        return l:path
      elseif l:pattern =~# '/$'
        if isdirectory(l:current)
          return l:path
        endif
      elseif filereadable(l:current)
        return l:path
      endif
    endfor
    let l:next = fnamemodify(l:path, ':h')
    if l:next == l:path || (has('win32') && l:next =~# '^//[^/]\+$')
      break
    endif
    let l:path = l:next
  endwhile
  return ''
endfunction

function! standardrb#findroot#findroot() abort
  let l:bufname = expand('%:p')
  if &buftype !=# '' || empty(l:bufname) || stridx(l:bufname, '://') !=# -1
    return ''
  endif
  let l:dir = escape(fnamemodify(l:bufname, ':p:h:gs!\!/!:gs!//!/!'), ' ')
  let l:patterns = get(g:, 'standardrb_default_project_root_symbols', [
        \  '.git/',
        \  '.svn/',
        \  '.hg/',
        \  '.bzr/',
        \  '.gitignore',
        \  'Rakefile',
        \  'pom.xml',
        \  'project.clj',
        \  'package.json',
        \  'manifest.json',
        \  '*.csproj',
        \  '*.sln',
        \])
  let l:dir = s:goup(l:dir, l:patterns)
  if empty(l:dir)
    return ''
  endif

  return l:dir
endfunction
