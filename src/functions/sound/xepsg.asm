.proc XEPSG_ROUTINE
	pha
	sta     VIA::PRA2
	cmp     #$07
	bne     @skip
	txa
	ORA     #$40
	tax
@skip:
	TYA
	PHA
	PHP
	SEI
	LDA     VIA::PCR
	AND     #$11
	TAY
	ORA     #$EE
	STA     VIA::PCR
	TYA
	ORA     #$CC
	STA     VIA::PCR
	stx     $030F
	tya
	ORA     #$EC
	STA     VIA::PCR
	TYA
	ORA     #$CC
	STA     VIA::PCR
	PLP
	PLA
	TAY
	PLA
	rts
.endproc
