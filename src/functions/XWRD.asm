XRDW0_ROUTINE:
   .out     .sprintf("|MODIFY:$1B:XRDW0")
   .out     .sprintf("|MODIFY:work_channel:XRD0")
   .out     .sprintf("|MODIFY:i_o_counter:XRD0")
   .out     .sprintf("|MODIFY:ADDRESS_VECTOR_FOR_ADIOB:XRD0") ; with send_command_A call
   .out     .sprintf("|MODIFY:ADIODB_VECTOR:XRD0") ; with send_command_A call
   .out     .sprintf("|MODIFY:KEYBOARD_COUNTER:XRD0") ; with send_command_A call (manage_I_O_keyboard)
   .out     .sprintf("|MODIFY:KBDKEY:XRD0") ; with send_command_A call (manage_I_O_keyboard)
   .out     .sprintf("|MODIFY:KBDSHT:XRD0") ; with send_command_A call (manage_I_O_keyboard)

	lda     #$00
	sta     $1B

@loop:
	lda     $1B
	jsr     Lc7da
	bcs     @loop

ROUTINE_I_O_NOTHING:
	sec
	rts
