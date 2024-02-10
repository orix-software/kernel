XWR0_ROUTINE:

   .out     .sprintf("|CALL:XWR0:XCOSCR")
   .out     .sprintf("|MODIFY:work_channel:XWR0")
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

	pha                      ; Push byte to write
	lda     #$00
	sta     work_channel
	pla                      ; Get byte to write

XWSTR0_re_enter_from_XDECAL:
	sta     i_o_save         ; save the byte to write in I_O_save
	lda     #$04
	sta     i_o_counter
	txa		; X contains the id of the window
	pha
	tya
	pha

@loop2:
	ldx     work_channel    ; It contains the value of the I/O
	lda     IOTAB,X         ; X contains 0, 4, 8 $0c
	cmp     #$82
	bcc     @skip           ; If it's higher than $88, it means that it's not an input
	asl                     ; It's an input set it *2
	tax                     ;
	lda     KERNEL_ADIOB,x  ; GET vectors
	sta     ADIODB_VECTOR+1
	lda     KERNEL_ADIOB+1,x
	sta     ADIODB_VECTOR+2 ;
	lda     i_o_save        ; Get Byte to write
@loop:
	bit     @loop
	jsr     ADIODB_VECTOR   ;  and write this byte

@skip:
	inc     work_channel
	dec     i_o_counter
	bne     @loop2
	pla
	tay
	pla
	tax
	lda     i_o_save
Lc7a7:
	rts
