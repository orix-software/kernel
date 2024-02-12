.proc _ch376_seek_file32
    ; A Y X RESB : 32 bits
    pha
    lda     #CH376_BYTE_LOCATE
    sta     CH376_COMMAND
    pla
    sta     CH376_DATA
    sty     CH376_DATA
    stx     CH376_DATA

    lda     RESB
    sta     CH376_DATA

    jmp     _ch376_wait_response

.endproc
