.proc _XEXEC
;PARSE_VECTOR
    ; A & Y contains the string command to execute
    sta     TR6        ; Save string pointer
    sty     TR7        ;

    lda     #$05       ; start at bank 05
    sta     KERNEL_TMP_XEXEC


next_bank:

    lda     #$07
    sta     RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM

    lda     #<PARSE_VECTOR ; get PARSE_VECTOR
    sta     ADDRESS_READ_BETWEEN_BANK

    lda     #>PARSE_VECTOR
    sta     ADDRESS_READ_BETWEEN_BANK+1

    lda     KERNEL_TMP_XEXEC
    sta     BNK_TO_SWITCH ; for $4AF call

    ldy     #$00
    jsr     $4AF
    sta     VEXBNK+1

    ldy     #$01
    jsr     $4AF
    sta     VEXBNK+2

    ; Now we check if  VEXBNK+1 & VEXBNK+2 equal to 00 then skip
    bne     @continue
    lda     VEXBNK+1
    bne     @continue
    ; if we are here we skip bank
    beq     next
@continue:
    lda     #$07  ; kernel
    sta     VAPLIC
    lda     KERNEL_TMP_XEXEC ; Shell bank
    sta     BNKCIB
    lda     #<next
    sta     VAPLIC+1
    lda     #>next
    sta     VAPLIC+2
    lda     TR6
    ldy     TR7
    jsr     EXBNK

next:
    ; Here continue
    ldx     KERNEL_TMP_XEXEC
    dex
    cpx     #$03        ; Read only bank 5 to 4 for instance
    beq     @out1
    stx     KERNEL_TMP_XEXEC
    jmp     next_bank
@out1:
    lda     #$05 ; Shell bank
    sta     BNK_TO_SWITCH

    rts

 
.endproc

