; Modify : 
; i_o_save
; ADDRESS_READ_BETWEEN_BANK
XWSTR3_ROUTINE:
XWSTR2_ROUTINE:		
XWSTR1_ROUTINE:	
XWSTR0_ROUTINE:
    ldx     #$00
	;.byt    $2C

	;ldx     #$04
	;.byt    $2C

	;ldx     #$08
	;.byt    $2C

	;ldx     #$0C
	stx     i_o_save+1
	sta     ADDRESS_READ_BETWEEN_BANK
	sty     ADDRESS_READ_BETWEEN_BANK+1
@loop:
	lda     i_o_save+1 ; FIXME
	sta     work_channel

	ldy     #$00
	jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
	beq     Lc7a7

	jsr     XWSTR0_re_enter_from_XDECAL
	inc     ADDRESS_READ_BETWEEN_BANK
	bne     @loop
	inc     ADDRESS_READ_BETWEEN_BANK+1
	bne     @loop

	
