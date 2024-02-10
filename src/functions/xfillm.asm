.proc XFILLM_ROUTINE
   .out     .sprintf("|MODIFY:RES:XFILLM")
   .out     .sprintf("|MODIFY:RESB:XFILLM")
	pha
	sec
	tya
	sbc     RES
	tay
	txa
	sbc     RES+1
	tax
	sty     RESB
	pla
	ldy     #$00

loop:
	cpy     RESB
	bcs     @skip2
	sta     (RES),y
	iny
	bne     loop

@skip2:
	pha
	tya

	ldy     #$00
	jsr     XADRES_ROUTINE
	pla
	cpx     #$00
	beq     @skip
	ldy     #$00

@L1:
	sta     (RES),y
	iny
	bne     @L1
	inc     RES+1
	dex
	bne     @L1

@skip:
	rts
.endproc
