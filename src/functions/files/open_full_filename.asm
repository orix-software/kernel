.proc open_full_filename
    jsr     compute_fp_struct

@set_filename:
    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND

    jsr     ch376_open_filename
    cmp     #$00
    beq     @send_end_out

; send

    iny
    sty     TR5

    jsr     send_0_to_ch376_and_open

    ldy     TR5
    jmp     @set_filename

@send_end_out:
    jsr     send_0_to_ch376_and_open
    jsr     restore_position_into_file

    rts
.endproc
