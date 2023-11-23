.proc restore_position_into_file

    ldy     #_KERNEL_FILE::f_seek_file

    lda     (KERNEL_XOPEN_PTR1),y
    sta     RES
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RES+1
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    tax
    iny
    lda     (KERNEL_XOPEN_PTR1),y
    sta     RESB

    lda     RES
    ldy     RES+1

    jmp     _ch376_seek_file32

.endproc

