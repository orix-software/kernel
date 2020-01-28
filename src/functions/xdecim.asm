.proc XDECIM_ROUTINE
	pha
	lda     #$00 ; 65c02
	sta     TR5
	lda     #$01
	sta     TR6
	pla
	jsr     XBINDX_ROUTINE
	ldy     #$00
@loop:
	lda     FUFTRV,Y
	jsr     XWR0_ROUTINE
	iny
	cpy     TR4
	bne     @loop
	rts
.endproc
