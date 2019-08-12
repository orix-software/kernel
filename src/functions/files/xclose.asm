.export XCLOSE_ROUTINE

.proc XCLOSE_ROUTINE
    ; A & Y contains fd
	jsr     XFREE_ROUTINE
    jmp     _ch376_file_close
.endproc	

