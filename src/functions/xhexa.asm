
	pha
	and     #$0F
	jsr     Lce60
	tay
	pla
	lsr
	lsr
	lsr
	lsr
Lce60:
	ora     #$30
	cmp     #$3A
	bcc     @skip
	adc     #$06
@skip:
	rts

