.proc send_0_to_ch376_and_open

.IFPC02
.pc02
    stz     CH376_DATA
.p02
.else
    lda     #$00
    sta     CH376_DATA
.endif

    jmp     _ch376_file_open ; Open slash

.endproc
