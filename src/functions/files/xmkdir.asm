.proc XMKDIR_ROUTINE
  ; [IN] AY contains the pointer of the path
  ; FIXME
  
    sta     ptr1
    sty     ptr1+1

    jsr     _ch376_verify_SetUsbPort_Mount
    cmp     #$01
    bne     @next  
    lda     #ENODEV 
    rts
@next:

    ; is it an absolute path ?
    ldy     #$00
    lda     (ptr1),y
    cmp     #"/"
    beq     @isabsolute
    ; FOPEN cwd
;    FOPEN_INTO_BANK7 ORIX_PATH_CURRENT,O_RDONLY

    ldy     #$00
   

    jsr     XGETCWD_ROUTINE
    ; A & Y
    sty     RES
    ldy     #O_RDONLY
    ldx     RES


    jsr     XOPEN_ROUTINE
    
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
    cpy     #13                    ; because we don't manage longfilename shortname =11
    bne     @mloop
    lda     #$00
    ;rts
@mend:    
    sta     CH376_DATA

    ;jsr     _ch376_set_file_name
    sta     KERNEL_ERRNO
    jsr     _ch376_dir_create    
    rts
@launch_xopen:
    lda     #$00
    sta     CH376_DATA
    jsr     _ch376_file_open    
    rts
 
@isabsolute:
    rts
    lda     ptr1
    ;sty     RES
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
    lda     #$00
    rts
  
@create_dir:
    sta     CH376_DATA
    sty     TR7   ; save Y
;    sta     KERNEL_ERRNO
    jsr     _ch376_dir_create
    ldy     TR7
    jmp     @next_folder ; FIXME 65c02
.endproc
