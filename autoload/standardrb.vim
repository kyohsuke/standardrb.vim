" vim:set foldmethod=marker
scriptencoding utf-8

let g:standardrb_default_project_root_symbols = [
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
      \ ]

function! standardrb#command() abort
  let l:rootdir = standardrb#findroot#findroot()
  let l:cmd = 'standardrb'

  if len(rootdir)
    let l:gemfile = l:rootdir . '/Gemfile'

    if filereadable(l:gemfile)
      let l:body = join(readfile(l:gemfile), "\n")

      if 0 < len(matchstr(l:body, "standard"))
        let l:cmd = 'bundle exec standardrb'
      endif
    endif
  endif

  return l:cmd
endfunction

function! standardrb#run() abort
  let l:bufnr = bufnr('%')
  let l:curpos = getcurpos()
  let l:view = winsaveview()

  let l:lines = standardrb#execute()
  echo l:lines

  let l:num = 1
  call deletebufline(l:bufnr, 1)
  for line in l:lines
    call setbufline(l:bufnr, l:num, line)
    let l:num += 1
  endfor
  
  call winrestview(l:view)
  call setpos('.', l:curpos)
endfunction


function! standardrb#execute() abort
  let l:cmd = standardrb#command() . ' --fix --force-exclusion --stdin %s'
  let l:buffer = join(getbufline(bufnr("%"), 1, '$'), "\n")
  let l:result = system(l:cmd, l:buffer)

  let l:lines = []
  let l:started = 0
  for line in split(l:result, "\n")
    if l:started == 1
      call add(l:lines, line)
      continue
    endif

    if match(line, "=====") !=# -1 
      let l:started = 1
    endif
  endfor

  return l:lines
endfunction
