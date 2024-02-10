; AY contains the number
; X ...
.out     .sprintf("|MODIFY:TR0:XBINDX")
.out     .sprintf("|MODIFY:TR1:XBINDX")
.out     .sprintf("|MODIFY:TR2:XBINDX")
.out     .sprintf("|MODIFY:TR3:XBINDX")
.out     .sprintf("|MODIFY:TR4:XBINDX")
.out     .sprintf("|MODIFY:TR5:XBINDX")

	sta     TR1
	sty     TR2

	lda     #$00 ; 65c02
	sta     TR3
	sta     TR4
@L5:
	lda     #$FF
	sta     TR0

@L4:
	inc     TR0
	sec
	lda     TR1
	tay
	sbc     const_10_decimal_low,x
	sta     TR1
	lda     TR2
	pha
	sbc     const_10_decimal_high,x
	sta     TR2
	pla
	bcs     @L4
	sty     TR1
	sta     TR2
	lda     TR0
	beq     @L2
	sta     TR3
	bne     @L3+1

@L2:
	ldy     TR3
	bne     @L3+1
	lda     DEFAFF
@L3:
	.byt    $2C
	ora     #$30

	jsr     @L1
	dex
	bpl     @L5
	lda     TR1
	ora     #$30

@L1:
	ldy     TR4

	sta     (TR5),Y
	inc     TR4
	rts
