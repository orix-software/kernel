XWSTR0_ROUTINE
	ldx     #$00
	.byt    $2c
XWSTR1_ROUTINE	
	ldx     #$04
	.byt    $2c
XWSTR2_ROUTINE		
	ldx     #$08
	.byt    $2c
XWSTR3_ROUTINE
	ldx     #$0c
	STX     i_o_save+1
	STA     ADDRESS_READ_BETWEEN_BANK
	STY     ADDRESS_READ_BETWEEN_BANK+1
Lc7b9
@loop:
	LDA     i_o_save+1 ; FIXME
	STA     work_channel

	LDY     #$00
	JSR     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
	beq     Lc7a7

	JSR     XWSTR0_re_enter_from_XDECAL
	INC     ADDRESS_READ_BETWEEN_BANK
	bne     @loop
	INC     ADDRESS_READ_BETWEEN_BANK+1
	bne     @loop

	
