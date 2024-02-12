.proc XDECIM_ROUTINE
   .out     .sprintf("|CALL:XDECIM:XBINDX")
   .out     .sprintf("|CALL:XDECIM:XWR0")
   .out     .sprintf("|MODIFY:TR4:XDECIM")
   .out     .sprintf("|MODIFY:TR5:XDECIM")
   .out     .sprintf("|MODIFY:TR6:XDECIM")
	pha
	lda     #$00 ; 65c02
	sta     TR5
	lda     #$01
	sta     TR6
	pla
	jsr     XBINDX_ROUTINE
	ldy     #$00
@loop:
	lda     FUFTRV,y
	jsr     XWR0_ROUTINE
	iny
	cpy     TR4
	bne     @loop
	rts
.endproc
