.proc XDECAL_ROUTINE

; DOC_PRIMITIVE_NAME=XDECAL
; DOC_REGISTER_X_MODIFIED=yes
; DOC_REGISTER_Y_MODIFIED=yes
; DOC_ACCUMULATOR_A_MODIFIED=yes
; DOC_MEMORY_WRITE_0=DECFIN
; DOC_MEMORY_WRITE_1=DECTRV

; This routine could be replace with a simple routine in 65C816 mode
	pha
	txa
	pha 
	tya
	pha
	sec
	lda     DECFIN
	sbc     DECDEB
	tay
	lda     DECFIN+1
	sbc     DECDEB+1
	tax
	bcc     Lcdb9 
	stx     DECTRV+1

	lda     DECCIB
	cmp     DECDEB
	lda     DECCIB+1
	sbc     DECDEB+1
	bcs     Lcdbf 
	tya
	eor     #$FF
	adc     #$01
	tay 
	sta     DECTRV
	bcc     @S1
	dex
	inc     DECFIN+1
@S1:
	sec
	lda     DECCIB
	sbc     DECTRV
	sta     DECCIB
	bcs     @S3

	dec     DECCIB+1
@S3:	
	clc
	lda     DECFIN+1
	sbc     DECTRV+1
	sta     DECFIN+1
	inx
@L2:
	lda     (DECFIN),y
	sta     (DECCIB),y
	iny 
	bne     @L2
	inc     DECFIN+1
	inc     DECCIB+1
	dex
	bne     @L2
Lcdb8	
	sec
Lcdb9	
	pla
	tay
	pla
	tax
	pla
	rts
Lcdbf
	txa
	clc
	adc     DECDEB+1
	sta     DECDEB+1
	txa
	clc
	adc     DECCIB+1
	sta     DECCIB+1
	inx
@L1:	
	dey
	lda     (DECDEB),y
	sta     (DECCIB),y
	tya
	bne     @L1
	dec     DECDEB+1
	dec     DECCIB+1
	dex
	bne     @L1
	beq     Lcdb8
.endproc
