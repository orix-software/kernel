.export XCLOSE_ROUTINE

.proc XCLOSE_ROUTINE
    ; A & Y contains fd
    sta     RESB
    stx     RESB+1 ; save fp

.ifdef WITH_DEBUG
    jsr     xdebug_install  
    ldx     #XDEBUG_FCLOSE
    jsr     xdebug_print
    ;jsr     xdebug_load

.endif

    ; close FD
    
	;jsr     XFREE_ROUTINE
    
    jmp     _ch376_file_close
.endproc	
