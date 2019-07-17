.export XRM_ROUTINE

.proc XRM_ROUTINE
    ; FIXME : at this step we could remove "/"
    ; [IN] AX contains the pointer of the path
    ldy     #O_RDONLY
    jsr     XOPEN_ROUTINE
    cmp     #$FF
    beq     @dont_remove
    
    jsr     _ch376_file_erase   ; Should be replaced by jmp
    lda     #$00
    rts
@dont_remove:
    lda     #ENOENT
    rts
.endproc

