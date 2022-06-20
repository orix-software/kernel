	sta     TR0
	sty     TR1
	ldx     #$00
	stx     RESB
	stx     RESB+1
	ldx     #$10
@loop:
	asl     RES
	rol     RES+1
	rol     RESB
	rol     RESB+1
	sec
	lda     RESB
	sbc     TR0
	tay

	lda     RESB+1
	sbc     TR1
	bcc     @skip
	sty     RESB
	sta     RESB+1
	inc     RES
@skip:
	dex
	bne     @loop
	rts
