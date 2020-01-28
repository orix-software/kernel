XCL0_ROUTINE
	ldx     #$00
	.byt    $2c
XCL1_ROUTINE	
	ldx     #$04
	.byt    $2c
XCL2_ROUTINE	
	ldx     #$08
	.byt    $2c	
XCL3_ROUTINE

	ldx     #$0c
	ldy     #$03
	cmp     #$00
	beq     Lc74e
@loop:
	cmp     IOTAB0,x
	beq     Lc73b 
	inx
	dey
	bpl     @loop
Lc73a	
	rts
Lc73b	
	lsr     IOTAB0,x
	ldx     #$0F
@L1:	
	cmp     IOTAB0,x
	beq     Lc73a
	dex
	bpl     @L1
	tax
	ldy     #$81
	jmp     send_command_A
Lc74e	
	lsr     IOTAB0,x
	inx
	dey
	bpl     Lc74e
	rts
	
