.export XPUTCWD_ROUTINE

; A & Y is the pointer to the string
.proc XPUTCWD_ROUTINE

    sta     RES
    sty     RES+1
    ; let's trim
    jsr     _trim

    ldy     #$00
    lda     (RES),y
    cmp     #"/"    ; is it a slash ? Yes it's absolute then compute
    bne     @concat
    
    ;     it's absolute
    jsr     @compute
     ; Copy the arg to pid struct.
    ldy     #$00
@L1:
    lda     (RES),y
    beq     @S2
    sta     (RESB),y
    iny
    bne     @L1
@S2:
    sta     (RESB),y

    rts
@concat:
    jsr     @compute
    ; let's concat now
    ldy     #$00    
@L2:
    lda     (RESB),y

    beq     @S3
    iny
    bne     @L2
    ; we are at char 0 of the current path
    ; Add y to RES in order to align Y with RESB : 
@S3:
    cpy     #$01
    beq     @skip_add_slash
    lda     #'/'
    sta     (RESB),y
    iny
@skip_add_slash:    
    tya
    clc
    adc     RESB
    bcc     @S4
    inc     RESB+1
@S4:    
    sta     RESB
    
    ; let's concat now
    ldy     #$00
@L3:    
    lda     (RES),y
    beq     @S5
    sta     (RESB),y
    iny
    bne     @L3
@S5:
    sta     (RESB),y    

    rts



@compute:
    ldx     kernel_process+kernel_process_struct::kernel_current_process


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
    rts    
.endproc
