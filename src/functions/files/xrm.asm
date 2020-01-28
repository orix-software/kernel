.export XRM_ROUTINE

.proc XRM_ROUTINE
    ; FIXME : at this step we could remove "/"
    ; [IN] AX contains the pointer of the path
    ldy     #O_RDONLY
    jsr     XOPEN_ROUTINE
    ; save fp
    sta     RES
    sty     RES+1    
    cmp     #$FF
    beq     @dont_remove
    

    jsr     _ch376_file_erase   ; Should be replaced by jmp
    lda     RES
    ldy     RES+1    
    jsr     XCLOSE_ROUTINE
    lda     #$00
    rts
@dont_remove:
    lda     RES
    ldy     RES+1    
    jsr     XCLOSE_ROUTINE
    lda     #ENOENT
    rts
.endproc

