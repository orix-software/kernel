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
   
;@loop:
    ;lda     (ptr1),y
    ;beq     @end2
    ;sta     BUFNOM,y
    ;sta     $bb80,y
    ;iny
    ;bne     @loop
;@end2:
;    sta     BUFNOM,y

 ;   sta     ptr1
    ;stx     ptr1+1
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
    beq     @mend                    ; we reached 0 value
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
    
 
@isabsolute:
    rts
    lda     ptr1
    ;sty     RES
    ldy     #O_RDONLY
    ldx     ptr1+1


    jsr     XOPEN_ROUTINE
    rts


    lda     #"/"
    sta     BUFNOM
.IFPC02
.pc02
    stz     BUFNOM+1 ; INIT  
.p02    
.else  
    lda     #$00 ; used to write in BUFNOM
    sta     BUFNOM+1 ; INIT  
.endif
    jsr     _ch376_set_file_name
    jsr     _ch376_file_open

    ldy     #$00                   ; skip /
@next_folder:
    ldx     #$00
@next_char:
    iny
    lda     (ptr1),y
    beq     @end
    cmp     #"/"
    beq     @create_dir
    sta     BUFNOM,x

    inx
    bne     @next_char
@end:
    ; Create last folder
    ; Store 0

    sta     BUFNOM,x
    jsr     _ch376_set_file_name
    jsr     _ch376_dir_create
    lda     #$00
    rts
  
@create_dir:
    lda     #$00
    sta     BUFNOM,x
    sty     TR7   ; save Y
    jsr     _ch376_set_file_name
    sta     KERNEL_ERRNO
    jsr     _ch376_dir_create
    ldy     TR7
    jmp     @next_folder ; FIXME 65c02
.endproc
