XWR0_ROUTINE
	pha                     ; Push byte to write
	lda     #$00

	BEQ     skip2_XWR0_ROUTINE
XWR1_ROUTINE	
	PHA
	LDA     #$04
	BNE     skip2_XWR0_ROUTINE
XWR2_ROUTINE
	PHA
	LDA     #$08
	BNE     skip2_XWR0_ROUTINE
XWR3_ROUTINE	
	PHA
	LDA     #$0C
skip2_XWR0_ROUTINE:

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
	lda     IOTAB0,X        ; X contains 0, 4, 8 $0c
	cmp     #$88
	bcc     @skip            ; If it's higher than $88, it means that it's not an input 
	asl                     ; It's an input set it *2
	TAX                     ; 
	LDA     ADIOB,X         ; GET vectors  
	STA     ADIODB_VECTOR+1
	LDA     ADIOB+1,X
	STA     ADIODB_VECTOR+2 ; 
	LDA     i_o_save        ; Get Byte to write
@loop:
	BIT     @loop             
	JSR     ADIODB_VECTOR   ;  and write this byte

@skip:
	INC     work_channel
	DEC     i_o_counter
	BNE     @loop2
	PLA
	TAY
	PLA
	TAX
	LDA     i_o_save
Lc7a7:
	rts

	
	
	