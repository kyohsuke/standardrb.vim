if exists('g:loaded_standardrb')
  finish
endif
let g:loaded_standardrb = 1

command! StandardRb call standardrb#run()
