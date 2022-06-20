.proc ByteWrGo
	lda     #CH376_BYTE_WR_GO
	sta     CH376_COMMAND

	jsr     _ch376_wait_response
	cmp     #CH376_USB_INT_DISK_WRITE
	bne     error
	clc
	rts

 error:
	lda     #$FF
	sec
	rts
.endproc
