.proc XREADDIR_ROUTINE
	;jsr		XOPEN_ROUTINE

    lda     #<4000
    ldy     #>4000

    jsr     XMALLOC_ROUTINE
    ; A & Y contains a pt

	rts
.endproc
