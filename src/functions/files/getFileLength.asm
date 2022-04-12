; A,X,Y RES : 4 bytes values

.proc getFileLength

    lda     #CH376_GET_FILE_SIZE
    sta     CH376_COMMAND
    lda     #$68
    sta     CH376_DATA ; ????
    ; store file length
    lda     CH376_DATA
    ldy     CH376_DATA
    ldx     CH376_DATA
    pha
    lda     CH376_DATA
    sta     RESB
    pla

    rts
.endproc
