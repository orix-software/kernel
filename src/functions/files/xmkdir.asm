.proc XMKDIR_ROUTINE
  ; [IN] AY contains the pointer of the path
  ; FIXME
  
    sta     ptr1
    sty     ptr1+1

    ; is it an absolute path ?
    ldy     #$00
    lda     (ptr1),y
    cmp     #"/"
    beq     @isabsolute

    ldy     #$00

    jsr     XGETCWD_ROUTINE
    ; A & Y
    sty     RES
    ldy     #O_RDONLY
    ldx     RES

    jsr     XOPEN_ROUTINE
    cpx     #$FF
    bne     @skip2
    cmp     #$FF
    bne     @skip2
    lda     KERNEL_ERRNO

    rts
@skip2:    

    lda     #CH376_SET_FILE_NAME 
    sta     CH376_COMMAND
    ldy     #$00
@mloop:
    lda     (ptr1),y
    beq     @mend       
    cmp     #"/"
    beq     @launch_xopen 
    ; we reached 0 value
    jsr     XMINMA_ROUTINE
    sta     CH376_DATA
    iny
    cpy     #13                    ; Because we don't manage longfilename shortname =11
    bne     @mloop
    lda     #$00
@mend:    
    sta     CH376_DATA

    sta     KERNEL_ERRNO
    jmp     _ch376_dir_create    
    
@launch_xopen:
    lda     #$00
    sta     CH376_DATA
    jmp     _ch376_file_open    
    
 
@isabsolute:
    rts
    lda     ptr1
    ldy     #O_RDONLY
    ldx     ptr1+1


    jmp     XOPEN_ROUTINE
    

    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND
    lda     #"/"
    sta     CH376_DATA

    lda     #$00
    sta     CH376_DATA

    jsr     _ch376_file_open

    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND

    ldy     #$00                   ; skip /
@next_folder:
    ldx     #$00
@next_char:
    iny
    lda     (ptr1),y
    beq     @end
    cmp     #"/"
    beq     @create_dir
    cmp     #"a"                        ; 'a'
    bcc     @skip
    cmp     #$7B                        ; 'z'
    bcs     @skip
    sbc     #$1F
@skip:
    sta     CH376_DATA
    

    inx
    bne     @next_char
@end:
    ; Create last folder
    ; Store 0
    sta     CH376_DATA

    jsr     _ch376_dir_create
    jmp     _ch376_file_close
    lda     #$00
    rts
  
@create_dir:
    sta     CH376_DATA
    sty     TR7               ; Save Y
    jsr     _ch376_dir_create
    ldy     TR7
    jmp     @next_folder      ; FIXME 65c02
.endproc
