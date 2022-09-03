.proc _ch376_verify_SetUsbPort_Mount
	jsr _ch376_check_exist
	cmp #CH376_DETECTED
	beq @detected



	; let's start reset
	jsr _ch376_reset_all
	lda #$01 ; error
	rts
@detected:
	jsr _ch376_set_usb_mode_kernel

	jsr _ch376_disk_mount
	cmp #CH376_USB_INT_SUCCESS
	beq @ok
	clc
	lda #$01
	rts
@ok:
	sec ; Carry = 1
	lda #$00
	rts
.endproc
