XRD0_ROUTINE:
	lda     #$00
	.byt    $2C
XRD1_ROUTINE:	
	lda     #$04
	.byt    $2C
XRD2_ROUTINE:		
	lda     #$08
	.byt    $2C
XRD3_ROUTINE:		
	lda     #$0C
; read keyboard	
Lc7da:
	sta     work_channel   ; Save the channel
	lda     #$04
	sta     i_o_counter
	txa
	pha
	tya
	pha
@loop:
	ldx     work_channel
	lda     IOTAB0,x
	bpl     @skip

	cmp     #$88
	bcs     @skip

	tax
	ldy     #$40
	jsr     send_command_A
	sta     $1D
	bcc     @skip2
@skip:
	inc     work_channel
	dec     i_o_counter
	bne     @loop
@skip2:
	pla
	tay
	pla
	tax
	lda 	$1D
	rts
	
	