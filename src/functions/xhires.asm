.export XHIRES_ROUTINE

.proc XHIRES_ROUTINE
	ldx     #$00
	ldy     #$FF
	sty     HRSPAT ; pattern
	iny
	jsr     hires_put_coordinate                                                                                
	lda     FLGTEL ; we are already in Hires ?
	bmi     _xeffhi 
	ora     #$80
	sta     FLGTEL ; Set to Hires flag
	php 
	sei
	lda     #$1F
	sta     $BF67 
	jsr     wait_0_3_seconds 
	jsr     move_chars_text_to_hires 
	lda     #$5C
	ldy     #$02
	ldx     #$00
	jsr     ROUTINE_TO_DEFINE_7 
	jsr     _xeffhi
	plp
	rts
.endproc
