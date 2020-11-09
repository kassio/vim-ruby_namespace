let s:ruby_namespace = expand('<sfile>:r') . '.rb'

function! ruby_namespace#namespace(line)
  let l:output = system(printf(
        \   '%s %s %d',
        \   shellescape(s:ruby_namespace),
        \   shellescape(expand('%')),
        \   a:line
        \ ))

  if v:shell_error != 0
    echohl ErrorMsg
    echomsg 'ruby-namespace.rb failed: ' + l:output
    echohl None
    return ''
  else
    return substitute(l:output, '\n$', '', '')
  end
endfunction
