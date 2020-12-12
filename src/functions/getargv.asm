

;.struct XMAINARGS_STRUCT
;argc              .byte    ; number of args 
;argv_ptr          .res     KERNEL_MAX_ARGS_COMMAND_LINE
;argv_value_ptr    .res     KERNEL_LENGTH_MAX_CMDLINE+KERNEL_MAX_ARGS_COMMAND_LINE ; add 0 to string
;.endstruct
; X Contain the id of the argument
.proc XGETARGV_ROUTINE
 
   ; lda     RES
    sty     RES+1
    sty     RESB+1
    sta     RES

    txa
    tay

    lda     (RES),y ; get id arg
    clc
    adc     RES
    bcc     @S1
    inc     RESB+1
@S1:    
    ldy     RESB+1
    ; A & Y return ptr of the param

	rts
.endproc        


