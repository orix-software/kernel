; RES +AY = RES and AY

.out     .sprintf("|MODIFY:RES:XADRESS")
	clc
	adc     RES
	sta     RES
	pha
	tya
	adc     RES+1
	sta     RES+1
	tay
	pla
	rts
