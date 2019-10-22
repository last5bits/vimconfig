" Change your current directory to one you're working in
command! Cd cd %:p:h
command! Lcd lcd %:p:h

" Pretty JSON
command! PrettyJson %!python -m json.tool

" Ignore specific regexps in vimdiff
function! IgnoreDiff(pattern)
    let opt = ""
    if &diffopt =~ "icase"
      let opt = opt . "-i "
    endif
    if &diffopt =~ "iwhite"
      let opt = opt . "-b "
    endif
    let cmd = "!diff -a --binary " . opt .
      \ " <(perl -pe 's/" . a:pattern .  "/\".\" x length($0)/gei' " .
      \ v:fname_in .
      \ ") <(perl -pe 's/" . a:pattern .  "/\".\" x length($0)/gei' " .
      \ v:fname_new .
      \ ") > " . v:fname_out
    echo cmd
    silent execute cmd
    redraw!
    return cmd
endfunction
command! IgnoreHexDiff set diffexpr=IgnoreDiff('0x[0-9a-fA-F]+') | diffupdate
command! IgnoreDecimalDiff set diffexpr=IgnoreDiff('\\.\\d+') | diffupdate
command! NormalDiff set diffexpr= | diffupdate

" Invoke cppman in a new tmux window
command! -nargs=+ Cppman silent! call system("tmux new-window cppman " . expand(<q-args>))

" Use AsyncRun when doing Make
command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

" Just like windo, but restore the current window when done.
" http://vim.wikia.com/wiki/Windo_and_restore_current_window
function! WinDo(command)
  let currwin=winnr()
  execute 'windo ' . a:command
  execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command W call WinDo(<q-args>)

" Jump between interesting locations reported by git.  Note that the git-jump
" script was modified to print the locations, rather than to open Vim
" directly.
function! GitJump(mode)
  execute 'cgetexpr ' . 'system("git jump ' . a:mode . '")'
  execute 'call asyncrun#quickfix_toggle(8)'
endfunction
com! -nargs=+ -complete=command Gjump call GitJump(<q-args>)

function! EnablePager() abort
  setlocal tabstop=8
  setlocal nolist nospell nonumber
  setlocal readonly nomodifiable
  setlocal nomodified
  setlocal buftype=nofile
endfunction
command! -nargs=0 PAGER call EnablePager()

" This command now supports CTRL-T, CTRL-V, and CTRL-X key bindings
" and opens fzf according to g:fzf_layout setting.
command! Buffers call fzf#run(fzf#wrap(
    \ {'source': map(range(1, bufnr('$')), 'bufname(v:val)')}))

" This extends the above example to open fzf in fullscreen
" when the command is run with ! suffix (Buffers!)
command! -bang Buffers call fzf#run(fzf#wrap(
    \ {'source': map(range(1, bufnr('$')), 'bufname(v:val)')}, <bang>0))
