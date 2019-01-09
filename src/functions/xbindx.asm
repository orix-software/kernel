; AY contains the number
; X ...

	STA TR1
	STY TR2
	
	LDA #$00 ; 65c02
	STA TR3
	STA TR4
@L5:
	LDA #$FF
	STA TR0
	
@L4:
	INC TR0
	SEC
	LDA TR1
	TAY
	SBC const_10_decimal_low,X 
	STA TR1
	LDA TR2
	PHA
	SBC const_10_decimal_high,X ; 
	STA TR2
	PLA
	BCS @L4
	STY TR1
	STA TR2
	LDA TR0
	BEQ @L2
	STA TR3
	BNE @L3+1
@L2:
	LDY TR3
	BNE @L3+1
	LDA DEFAFF
@L3:
	.byt $2c
	ora #$30	

	JSR @L1
	DEX
	BPL @L5
	LDA TR1
	ORA #$30
@L1:	
	LDY TR4

	STA (TR5),Y
	INC TR4
	RTS

