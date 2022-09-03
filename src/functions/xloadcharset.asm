.proc XLOADCHARSET_ROUTINE
    ldx     #$00
@loop:
    lda     charset_text,x
    sta     $B400+8*32,x

    lda     charset_text+256,x
    sta     $B500+8*32,x
    lda     charset_text+512,x
    sta     $B600+8*32,x
    inx
    bne     @loop
    rts

.endproc
