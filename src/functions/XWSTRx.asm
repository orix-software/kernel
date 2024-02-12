; Modify :
; i_o_save
; ADDRESS_READ_BETWEEN_BANK

.proc XWSTR0_ROUTINE
   .out     .sprintf("|MODIFY:i_o_save:XWSTR0")
   .out     .sprintf("|MODIFY:work_channel:XWSTR0")
   .out     .sprintf("|MODIFY:ADDRESS_READ_BETWEEN_BANK:XWSTR0")
   .out     .sprintf("|MODIFY:i_o_save:XWR0")
   .out     .sprintf("|MODIFY:i_o_counter:XWR0")
   .out     .sprintf("|MODIFY:ADIODB_VECTOR:XWR0")
   .out     .sprintf("|MODIFY:SCRNB:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:ADSCR:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:FLGCUR:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:FLGCUR_STATE:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:CURSCR:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:ADSCRL:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:ADSCRH:XWR0") ; IOTAB
   .out     .sprintf("|MODIFY:FLGSCR:XWR0") ; IOTAB

    ldx     #$00
	stx     i_o_save+1
	sta     ADDRESS_READ_BETWEEN_BANK
	sty     ADDRESS_READ_BETWEEN_BANK+1

@loop:
	lda     i_o_save+1
	sta     work_channel

	ldy     #$00
	jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
	beq     Lc7a7

	jsr     XWSTR0_re_enter_from_XDECAL
	inc     ADDRESS_READ_BETWEEN_BANK
	bne     @loop
	inc     ADDRESS_READ_BETWEEN_BANK+1
	bne     @loop
.endproc
