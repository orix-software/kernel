.export XRM_ROUTINE

.proc XRM_ROUTINE

    .out     .sprintf("|MODIFY:RES:XRM_ROUTINE")
    .out     .sprintf("CALL:_ch376_file_erase:XRM_ROUTINE")
    .out     .sprintf("CALL:XCLOSE:XRM_ROUTINE")
    .out     .sprintf("CALL:XOPEN:XRM_ROUTINE")
    ; FIXME : at this step we could remove "/"
    ; [IN] AX contains the pointer of the path
    ldy     #O_RDONLY
    jsr     XOPEN_ROUTINE
    cmp     #$FF
    bne     @continue
    cpx     #$FF
    beq     @not_such_file

@continue:
    ; save fp
    sta     RES
    stx     RES+1

    jsr     _ch376_file_erase

    lda     RES
    ldy     RES+1
    jsr     XCLOSE_ROUTINE
    lda     #$00
    rts

@not_such_file:
    lda     #ENOENT
    rts
.endproc
