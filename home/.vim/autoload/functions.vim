scriptencoding utf-8

let s:middot='·'
let s:raquo='»'
let s:small_l='ℓ'

" Override default `foldtext()`, which produces something like:
"
"   +---  2 lines: source $HOME/.vim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim--------------------------------
"
" Instead returning:
"
"   »··[2ℓ]··: source $HOME/.vim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim···································
"
function! functions#foldtext() abort
  let l:lines='[' . (v:foldend - v:foldstart + 1) . s:small_l . ']'
  let l:first=substitute(getline(v:foldstart), '\v *', '', '')
  let l:dashes=substitute(v:folddashes, '-', s:middot, 'g')
  return s:raquo . s:middot . s:middot . l:lines . l:dashes . ': ' . l:first
endfunction

" Switch to plaintext mode with: call functions#plaintext()
function! functions#plaintext() abort
    setlocal spell
    setlocal spell spelllang=en_us
    setlocal complete+=kspell
    setlocal textwidth=0
    setlocal wrap
    setlocal wrapmargin=0

    nnoremap <buffer> j gj
    nnoremap <buffer> k gk
endfunction

function! functions#llvm_code() abort
  setlocal iskeyword+=.
  setlocal iskeyword+=%
endfunction

function! functions#toggle_eventignore() abort
    if has('autocmd')
        if &eventignore == ""
            set eventignore=TextChanged,InsertLeave,FocusLost,CursorHold
        else
            set eventignore=
        endif
        set eventignore?
    else
        echoerr "No 'autocmd' functionality available"
    endif
endfunction

function! functions#get_clang_format_path()
  if filereadable("/usr/share/vim/addons/syntax/clang-format.py")
    return "/usr/share/vim/addons/syntax/clang-format.py"
  elseif filereadable("/usr/share/clang/clang-format.py")
    return "/usr/share/clang/clang-format.py"
  elseif filereadable("/usr/share/clang/clang-format-4.0/clang-format.py")
    return "/usr/share/clang/clang-format-4.0/clang-format.py"
  elseif filereadable("/usr/share/clang/clang-format-7/clang-format.py")
    return "/usr/share/clang/clang-format-7/clang-format.py"
  else
    return ""
  endif
endfunction

function! functions#add_to_filetype_for(ext, ft)
  if &filetype ==# a:ft
    let &filetype = &filetype . a:ext
  endif
endfunction

function! functions#searchCWord()
  let wordStr = expand("<cword>")
  if strlen(wordStr) == 0
    echohl ErrorMsg
    echo 'E348: No string under cursor'
    echohl NONE
    return
  endif

  if wordStr[0] =~ '\<'
    let @/ = '\<' . wordStr . '\>'
  else
    let @/ = wordStr
  endif

  let savedUnnamed = @"
  let savedS = @s
  normal! "syiw
  if wordStr != @s
    normal! w
  endif
  let @s = savedS
  let @" = savedUnnamed
endfunction

" https://github.com/bronson/vim-visual-star-search/
function! functions#searchVWord()
  let savedUnnamed = @"
  let savedS = @s
  normal! gv"sy
  let @/ = '\V' . substitute(escape(@s, '\'), '\n', '\\n', 'g')
  let @s = savedS
  let @" = savedUnnamed
endfunction

function! functions#get_human_readable_file_size()
  return trim(system("numfmt --to=iec-i --suffix=B --format=%.2f " . getfsize(expand(@%))))
endfunction

function! functions#add_filesize_for_debug_dumps()
  call airline#parts#define_function('filesize', 'functions#get_human_readable_file_size')
  call airline#parts#define_condition('filesize', '&filetype =~# "debug-dump"')
  let g:airline_section_warning = airline#section#create_right(['filesize'])
endfunction
