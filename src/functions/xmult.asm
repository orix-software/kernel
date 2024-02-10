	sta     TR4
	sty     TR4+1
	ldx     #$00
	stx     TR0
	stx     TR1
	stx     $0E
	stx     $0F
	stx     RESB
	stx     RESB+1
	ldx     #$10

LCEAB:
	lsr     TR4+1
	ror     TR4
	bcc     LCECA
	clc

	lda     RES
	adc     TR0
	sta     TR0

	lda     RES+1
	adc     TR1
	sta     TR1

	lda     RESB
	adc     $0F
	sta     $0F

	lda     RESB+1
	adc     $0F
	sta     $0F
LCECA:
	asl     RES
	rol     RES+1
	rol     RESB
	rol     RESB+1

	lda     TR4
	ora     $11
	beq     Lcedb
	dex
	bne     LCEAB

Lcedb:
	rts
