.proc XEPSG_ROUTINE
	PHA
	STA VIA::PRA2
	CMP #$07
	BNE @skip
	TXA
	ORA #$40
	TAX
@skip:
	TYA
	PHA
	PHP
	SEI
	LDA VIA::PCR
	AND #$11
	TAY
	ORA #$EE
	STA VIA::PCR
	TYA
	ORA #$CC
	STA VIA::PCR
	STX $030F
	TYA
	ORA #$EC
	STA VIA::PCR
	TYA
	ORA #$CC
	STA VIA::PCR
	PLP
	PLA
	TAY
	PLA
	rts
.endproc
