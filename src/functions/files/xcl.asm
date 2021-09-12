XCL0_ROUTINE
	;ldx     #$00
	;ldy     #$03
	;cmp     #$00
	;beq     Lc74e
;@loop:
;	cmp     IOTAB
;	beq     Lc73b 
	;inx
	;dey
	;bpl     @loop
;Lc73a:	
	rts
;Lc73b:	
;	lsr     IOTAB
;	ldx     #$0F
;@L1:	
;	cmp     IOTAB
;	beq     Lc73a
;	dex
;	bpl     @L1
	;tax
	;ldy     #$81
	;jmp     send_command_A
;Lc74e:	
;	lsr     IOTAB0,x
	;inx
	;dey
	;bpl     Lc74e
	;rts
	
