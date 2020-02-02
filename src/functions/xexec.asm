.proc _XEXEC
;PARSE_VECTOR
    ; A & Y contains the string command to execute
    sta     TR6        ; Save string pointer
    sty     TR5        ;
    
    sta     RESB
    sty     RESB+1
    jsr     kernel_create_process
    cmp     #$00
    beq     @S1
    ; Error impossible to fork
    
    rts
@S1:
    lda     BNKOLD
    pha

    lda     #$05       ; start at bank 05
    sta     KERNEL_TMP_XEXEC

next_bank:
    ; We says that we return to Bank 7 

    lda     #$07
    sta     RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM
    ; Get parse vector
    lda     #<PARSE_VECTOR ; get PARSE_VECTOR
    sta     ADDRESS_READ_BETWEEN_BANK

    lda     #>PARSE_VECTOR
    sta     ADDRESS_READ_BETWEEN_BANK+1
    ; We get the bank to test
    lda     KERNEL_TMP_XEXEC
    sta     BNK_TO_SWITCH ; for $4AF call
    
    ; We get value of PARSE_VECTOR
    ldy     #$00
    jsr     $4AF
    sta     VEXBNK+1

    ldy     #$01
    jsr     $4AF
    sta     VEXBNK+2


    ; if we get $0000 value un PARSE_VECTOR (copy in VEXBNK), then there is no command
    ; Now we check if  VEXBNK+1 & VEXBNK+2 equal to 00 then skip
    bne     @continue
    lda     VEXBNK+1
    bne     @continue
    ; if we are here we skip bank
    beq     next
@continue:
    ; At this step, we should :
    ; -     create a new process
    ; -     attached this new process to current PID
    ; -     fix current foreground process to this new one
    ; -     malloc of getcwd
    lda     #$07  ; kernel
    sta     VAPLIC
    lda     KERNEL_TMP_XEXEC ; Shell bank
    sta     BNKCIB
    lda     #<next
    sta     VAPLIC+1
    lda     #>next
    sta     VAPLIC+2
    lda     TR6
    ldy     TR5


    jsr     EXBNK
    ; if there is an error destroy struct
    

next:
    ; Here continue
    ldx     KERNEL_TMP_XEXEC
    dex
    ;cpx     #$01        ; Read only bank 5 to 4 for instance FIXME BUG
    bne     @out1
    stx     KERNEL_TMP_XEXEC
    jmp     next_bank
@out1:
    ; Back to calling bank
    pla
    sta     BNK_TO_SWITCH
    rts
.endproc

