XRD0_ROUTINE:
	lda     #$00
   .out     .sprintf("|MODIFY:work_channel:XRD0")
   .out     .sprintf("|MODIFY:i_o_counter:XRD0")

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
	lda     IOTAB,x
	bpl     @skip

	cmp     #$82
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
