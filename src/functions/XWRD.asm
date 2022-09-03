XRDW0_ROUTINE:
	lda     #$00

	sta     $1B
@loop:
	lda     $1B
	jsr     Lc7da
	bcs     @loop
ROUTINE_I_O_NOTHING:
	sec
	rts
