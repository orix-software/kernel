XRDW0_ROUTINE:
	lda     #$00
	.byt    $2C
XRDW1_ROUTINE:
	lda     #$04
	.byt    $2C
XRDW2_ROUTINE:
	lda     #$08
	.byt    $2C
XRDW3_ROUTINE:
	lda     #$0C
	sta     $1B
@loop:
	lda     $1B
	jsr     Lc7da
	bcs     @loop	
LC81A ; Used to table_routine E/S 
ROUTINE_I_O_NOTHING:
	sec
	rts
	
	