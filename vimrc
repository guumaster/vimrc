"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.

" Auto commands.
source ~/.vim/vundle.vim

" Basic Vim configuration
source ~/.vim/config.vim

"activate pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim

" statusline configuration
source ~/.vim/statusline.vim

" Auto commands.
source ~/.vim/autocmd.vim


"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default



"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 45
" ack bundle
let g:ackprg="ack-grep -H --nocolor --nogroup --column"
" snipmate bundle
let g:snips_author = 'Gustavo Marin'
"let g:snippets_dir="~/.vim/bundle/snipmate-snippets/snippets/"

" ---------------
" Bindings
" ---------------

"explorer mappings
nnoremap <f1> :BufExplorer<cr>
nnoremap <f2> :NERDTreeToggle<cr>
nnoremap <f3> :TagbarToggle<cr>

"dont load csapprox if we no gui support - silences an annoying warning
"if !has("gui")
"    let g:CSApprox_loaded = 1
"endif




" Fixes common typos
command! W w
command! Q q
map <F1> <Esc>
imap <F1> <Esc>

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"make Y consistent with C and D
nnoremap Y y$

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

