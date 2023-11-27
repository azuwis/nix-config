" A helper to preserve the cursor location with filters
function! UpdateNixFetchgit_Preserve(command)
  let w = winsaveview()
  execute a:command
  call winrestview(w)
endfunction

map <buffer> <nowait> <leader>cu :call UpdateNixFetchgit_Preserve("%!update-nix-fetchgit --location=" . line(".") . ":" . col("."))<CR>
