.export XCLOSE_ROUTINE

.proc XCLOSE_ROUTINE
    ; A & Y contains fd
    sta     RESB
    sty     RESB+1 ; save fp
    
	jsr     XFREE_ROUTINE
    
    jmp     _ch376_file_close
.endproc	
