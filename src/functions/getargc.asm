

;.struct XMAINARGS_STRUCT
;__argc       .byte    ; number of args
;next_arg_ptr .word
;argv_ptr      .res     (3 * 2)
;argv_value    .res     
;.endstruct

.proc XGETARGC_ROUTINE
    sta     RES
    sty     RES+1

    ldy     #$00
    lda     (RES),y     ; Return __argc from struct FIXME 65C02
    
	rts
.endproc        


