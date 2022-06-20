XWR0_ROUTINE:
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
	lda     KERNEL_ADIOB,X  ; GET vectors  
	sta     ADIODB_VECTOR+1
	lda     KERNEL_ADIOB+1,X
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
