XMKDIR_ROUTINE:
  ; [IN] AX contains the pointer of the path
  ; FIXME
  
    sta     ptr1
    stx     ptr1+1

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
    FOPEN_INTO_BANK7 ORIX_PATH_CURRENT,O_RDONLY

    ldy     #$00
   
@loop:
    lda     (ptr1),y
    beq     @end2
    sta     BUFNOM,y
    iny
    bne     @loop
@end2:
    sta     BUFNOM,y
    
    jsr     _ch376_set_file_name
    sta     ERRNO
    jsr     _ch376_dir_create    
    rts
    
 
@isabsolute:
    jsr     _open_root_and_enter
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
    sta     ERRNO
    jsr     _ch376_dir_create
    ldy     TR7
    jmp     @next_folder ; FIXME 65c02

