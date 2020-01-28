; AY contains the number
; X ...
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
	LDA     TR1
	TAY
	SBC     const_10_decimal_low,X 
	STA     TR1
	LDA     TR2
	PHA
	SBC     const_10_decimal_high,X ; 
	STA     TR2
	PLA
	BCS     @L4
	STY     TR1
	STA     TR2
	LDA     TR0
	BEQ     @L2
	STA     TR3
	BNE     @L3+1
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

