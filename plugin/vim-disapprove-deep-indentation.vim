" Vim plugin to disapprove deeply indented lines.
" Maintainer:           David Csakvari
" URL:                  https://github.com/dodie/vim-disapprove-deep-indentation
" License:              MIT
" ----------------------------------------------------------------------------
function! g:DisapproveDeepIndent()
    if &modifiable
        " Backward compatible fix for a typo in the API.
        if !exists("g:LookOfDisapprovalSpaceThreshold") && exists("g:LookOfDisapprovalSpaceTreshold")
            let g:LookOfDisapprovalSpaceThreshold=g:LookOfDisapprovalSpaceTreshold
        endif
        if !exists("g:LookOfDisapprovalTabThreshold") && exists("g:LookOfDisapprovalTabTreshold")
            let g:LookOfDisapprovalTabThreshold=g:LookOfDisapprovalTabTreshold
        endif

        " Setting the defaults.
        if !exists("g:LookOfDisapprovalSpaceThreshold") || (g:LookOfDisapprovalSpaceThreshold > 0 && g:LookOfDisapprovalSpaceThreshold < 5)
            let g:LookOfDisapprovalSpaceThreshold=(&tabstop*5)
        endif
        if !exists("g:LookOfDisapprovalTabThreshold") || (g:LookOfDisapprovalTabThreshold > 0 && g:LookOfDisapprovalTabThreshold < 5)
            let g:LookOfDisapprovalTabThreshold=5
        endif

        " If the plugin is not disabled, then place the look of disapproval for deeply indented lines.
        if g:LookOfDisapprovalTabThreshold > 0 || g:LookOfDisapprovalSpaceThreshold > 0
            syn match LookOfDisapprovalLeftEye contained '\%1c\s' conceal cchar=ಠ
            syn match LookOfDisapprovalMouth contained '\%2c\s' conceal cchar=_
            syn match LookOfDisapprovalRightEye contained '\%3c\s' conceal cchar=ಠ
            syn match LookOfDisapprovalPadding contained '\%4c\s' conceal cchar= 

            if g:LookOfDisapprovalSpaceThreshold > 0
                execute 'syn match LookOfDisapproval /^\s\s\s\s\{'.(g:LookOfDisapprovalSpaceThreshold-3).'\}/ contains=LookOfDisapprovalLeftEye,LookOfDisapprovalMouth,LookOfDisapprovalRightEye,LookOfDisapprovalPadding'
            endif

            if g:LookOfDisapprovalTabThreshold > 0
                execute 'syn match LookOfDisapproval /^\t\t\t\{'.(g:LookOfDisapprovalTabThreshold-2).'\}/ contains=LookOfDisapprovalLeftEye,LookOfDisapprovalMouth,LookOfDisapprovalRightEye,LookOfDisapprovalPadding'
            endif

            set conceallevel=1 concealcursor=nvic
            hi conceal ctermfg=red ctermbg=NONE guifg=red guibg=NONE


	    "
	    " There can be problems if the existing syntax rules use
	    " contains=ALL or contains=ALLBUT.
	    " The ಠ_ಠ shouldn't be applied, except for deeply indented lines,
	    " but these rules sabotage this goal because they make the
	    " plugins contained rules match.
	    "
	    " Because it affects many common syntax highlight setups
	    " I decided to put a quick and dirty fix here,
	    " where we check the current syntax and the presence of a known
	    " rule that breaks the plugin.
	    "
	    " More info:
	    " https://github.com/dodie/vim-disapprove-deep-indentation/issues/2
	    "

            " fix for the default SQL syntax
            if hlexists("sqlFold") && &syntax == "sql"
                syn region sqlFold start='^\s*\zs\c\(Create\|Update\|Alter\|Select\|Insert\)' end=';$\|^$' transparent fold contains=ALLBUT,LookOfDisapprovalLeftEye,LookOfDisapprovalRightEye,LookOfDisapprovalMouth,LookOfDisapprovalPadding
            endif

	    " fix for the default Ruby syntax
            if hlexists("rubyLocalVariableOrMethod") && &syntax == "ruby"
		syn cluster rubyNotTop add=LookOfDisapprovalLeftEye,LookOfDisapprovalRightEye,LookOfDisapprovalMouth,LookOfDisapprovalPadding
            endif

	    " fix for the default Python syntax
	    if hlexists("pythonDoctest") && &syntax == "python"
		syn region pythonDoctest
		  \ start="^\s*>>>\s" end="^\s*$"
		  \ contained contains=ALLBUT,pythonDoctest,@Spell,LookOfDisapprovalLeftEye,LookOfDisapprovalRightEye,LookOfDisapprovalMouth,LookOfDisapprovalPadding
	    endif
        endif
    endif
endfunction

autocmd BufEnter,BufNewFile,BufReadPost * call g:DisapproveDeepIndent()
