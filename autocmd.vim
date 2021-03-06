" ----------------------------------------
" Auto Commands
" ----------------------------------------

if has("autocmd")
  " No formatting on o key newlines
  autocmd BufNewFile,BufEnter * set formatoptions-=o

  " No more complaining about untitled documents
  autocmd FocusLost silent! :wa

  " When editing a file, always jump to the last cursor position.
  " This must be after the uncompress commands.
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line ("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

  " Fix trailing whitespace in my most used programming langauges
  autocmd BufWritePre *.py,*.coffee,*.rb silent! :StripTrailingWhiteSpace

  "recalculate the trailing whitespace warning when idle, and after saving
  autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

  "return '[\s]' if trailing white space is detected
  "return '' otherwise
  function! StatuslineTrailingSpaceWarning()
      if !exists("b:statusline_trailing_space_warning")

          if !&modifiable
              let b:statusline_trailing_space_warning = ''
              return b:statusline_trailing_space_warning
          endif

          if search('\s\+$', 'nw') != 0
              let b:statusline_trailing_space_warning = '[\s]'
          else
              let b:statusline_trailing_space_warning = ''
          endif
      endif
      return b:statusline_trailing_space_warning
  endfunction

  "recalculate the tab warning flag when idle and after writing
  autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

  "return '[&et]' if &et is set wrong
  "return '[mixed-indenting]' if spaces and tabs are used to indent
  "return an empty string if everything is fine
  function! StatuslineTabWarning()
      if !exists("b:statusline_tab_warning")
          let b:statusline_tab_warning = ''

          if !&modifiable
              return b:statusline_tab_warning
          endif

          let tabs = search('^\t', 'nw') != 0

          "find spaces that arent used as alignment in the first indent column
          let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw') != 0

          if tabs && spaces
              let b:statusline_tab_warning =  '[mixed-indenting]'
          elseif (spaces && !&et) || (tabs && &et)
              let b:statusline_tab_warning = '[&et]'
          endif
      endif
      return b:statusline_tab_warning
  endfunction

  "recalculate the long line warning when idle and after saving
  autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

  "return a warning for "long lines" where "long" is either &textwidth or 80 (if
  "no &textwidth is set)
  "
  "return '' if no long lines
  "return '[#x,my,$z] if long lines are found, were x is the number of long
  "lines, y is the median length of the long lines and z is the length of the
  "longest line
  function! StatuslineLongLineWarning()
      if !exists("b:statusline_long_line_warning")

          if !&modifiable
              let b:statusline_long_line_warning = ''
              return b:statusline_long_line_warning
          endif

          let long_line_lens = s:LongLines()

          if len(long_line_lens) > 0
              let b:statusline_long_line_warning = "[" .
                          \ '#' . len(long_line_lens) . "," .
                          \ 'm' . s:Median(long_line_lens) . "," .
                          \ '$' . max(long_line_lens) . "]"
          else
              let b:statusline_long_line_warning = ""
          endif
      endif
      return b:statusline_long_line_warning
  endfunction

  "return a list containing the lengths of the long lines in this buffer
  function! s:LongLines()
      let threshold = (&tw ? &tw : 80)
      let spaces = repeat(" ", &ts)
      let line_lens = map(getline(1,'$'), 'len(substitute(v:val, "\\t", spaces, "g"))')
      return filter(line_lens, 'v:val > threshold')
  endfunction

  "jump to last cursor position when opening a file
  "dont do it when writing a commit log entry
  autocmd BufReadPost * call SetCursorPosition()
  function! SetCursorPosition()
      if &filetype !~ 'svn\|commit\c'
          if line("'\"") > 0 && line("'\"") <= line("$")
              exe "normal! g`\""
              normal! zz
          endif
      end
  endfunction

  "spell check when writing commit logs
  autocmd filetype svn,*commit* setlocal spell

  "http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
  "hacks from above (the url, not jesus) to delete fugitive buffers when we
  "leave them - otherwise the buffer list gets poluted
  "
  "add a mapping on .. to view parent tree
  autocmd BufReadPost fugitive://* set bufhidden=delete
  autocmd BufReadPost fugitive://*
    \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
    \   nnoremap <buffer> .. :edit %:h<CR> |
    \ endif

  "find the median of the given array of numbers
  function! s:Median(nums)
      let nums = sort(a:nums)
      let l = len(nums)

      if l % 2 == 1
          let i = (l-1) / 2
          return nums[i]
      else
          return (nums[l/2] + nums[(l/2)-1]) / 2
      endif
  endfunction

 " au BufNewFile,BufRead *.twig set filetype=html
  au BufNewFile,BufRead *.twig set filetype=jinja

endif


" Function to remove trailing whitespaces on save
function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

" Autoremove trailing whitespaces on save
autocmd BufWritePre *.html,*.php,*.js :call <SID>StripTrailingWhitespaces()


autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

autocmd FileType html setlocal shiftwidth=2 tabstop=2


autocmd BufWritePre *.js :%s/\s\+$//e
