

;.struct XMAINARGS_STRUCT
;__argc       .byte    ; number of args
;next_arg_ptr .word
;argv_ptr      .res     (3 * 2)
;argv_value    .res     
;.endstruct

; Contain the id of the argument
.proc XGETARGV_ROUTINE
    sta     RES
    sty     RES+1
    ; X contains the ID of the param
	txa
    asl
	sta		TR4

    lda     #XMAINARGS_STRUCT::argv_ptr+1
	clc
	adc		TR4
    clc
    adc     RES
    bcc     skip
    inc     RES+1
skip:
    ldy     RES+1

	rts
.endproc        


