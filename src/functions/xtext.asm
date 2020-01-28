.export     XTEXT_ROUTINE

.proc XTEXT_ROUTINE
	lda     FLGTEL
	bpl     @skip ; already in text mode
	php 
	
	sei
	and     #$7F
	sta     FLGTEL
	jsr     move_chars_hires_to_text 
	lda     #$56
	ldy     #$02
	ldx     #$00
	jsr     ROUTINE_TO_DEFINE_7
	
	lda     #$1A
	sta     $BFDF
	jsr     wait_0_3_seconds
	ldx     #$28
	lda     #$20

@loop:
	sta     $BB7F,x
	dex
	bne     @loop
	jsr     XCSSCR_ROUTINE
	plp
@skip:
	rts
.endproc	

