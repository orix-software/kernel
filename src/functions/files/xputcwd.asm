.export XPUTCWD_ROUTINE

; A & Y is the pointer to the string
.proc XPUTCWD_ROUTINE
    ;ORIX_CURRENT_PROCESS_FOREGROUND
    sta     RES
    sty     RES+1
  
    ldx     ORIX_CURRENT_PROCESS_FOREGROUND

    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     RESB
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     RESB+1

    lda     #kernel_one_process_struct::cwd_str
    clc
    adc     RESB
    bcc     @S1 
    inc     RESB+1
@S1:
    sta     RESB

    ; Copy the arg to pid struct.
@L1:
    ldy     #$00
    lda     (RES),y
    beq     @S2
    sta     (RESB),y
    iny
    bne     @L1
@S2:
    sta     (RESB),y

    rts
.endproc
