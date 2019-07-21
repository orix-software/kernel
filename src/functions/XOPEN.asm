.proc XOPEN_ROUTINE
  ; A and X contains char * pointer ex /usr/bin/toto.txt but it does not manage the full path yet
  sta     RES
  sta     RESB
  stx     RES+1
  stx     RESB+1
  sty     TR4 ; save flags
  
  ; check if usbkey is available
  jsr     _ch376_verify_SetUsbPort_Mount
  cmp     #$01
  bne     @L1
  ; impossible to mount
  ldx     #$00
  txa
  rts
@L1:
  ldy     #$00
  lda     (RES),y
  ;
  cmp     #"/"
  beq     @it_is_absolute
  
  ; here it's relative
  jsr     XOPEN_ABSOLUTE_PATH_CURRENT_ROUTINE ; Read current path (and open)
  ldy     #$00
  ldx     #$00
  jmp     @read_file

  
@it_is_absolute:

@init_and_go:
  jsr     _open_root
  ldx     #$00
  jsr     open_and_read_go

@read_file:

@loop:
  lda     (RES),y 
  beq     @end
  cmp     #"/"
  bne     @next_char
.IFPC02
.pc02
  stz     BUFNOM,x
.p02  
.else
  lda     #$00
  sta     BUFNOM,x
.endif  

  jsr     open_and_read_go
  
  cmp     #CH376_ERR_MISS_FILE
  beq     file_not_found   
  jmp     @loop
@next_char:
  sta     BUFNOM,x

  iny
  inx
.IFPC02
.pc02
  bra     @loop
.p02  
.else
  jmp     @loop
.endif
  
; not_slash_first_param
  ; Call here setfilename
  ldx     #$00 ; Flush param in order to send parameter
  iny
  bne     @loop
@end:
  sta     BUFNOM,x
  cpy     #$00
; reset_labels_g1
  beq     longskip1
 
  ; Optimize, it's crap
  lda     TR4 ; Get flags
  and     #O_RDONLY
  cmp     #O_RDONLY
  beq     @read_only
  lda     TR4
  and     #O_WRONLY
  cmp     #O_WRONLY
  beq     @write_only

  ; In all others keys, readonly read :!
.IFPC02
.pc02
  bra     @read_only
.p02  
.else  
  jmp     @read_only ; FIXME : replace jmp by bne to earn one byte
.endif  
@write_only:
  jsr     _ch376_set_file_name
  jsr     _ch376_file_create
  rts

@read_only:
  jsr     _ch376_set_file_name
  jsr     _ch376_file_open  
  cmp     #CH376_ERR_MISS_FILE
  beq     file_not_found   

  ; register filehandle call_routine_in_another_bank  
  ;call_routine_in_another_bank  
  lda     #ORIX_REGISTER_FILEHANDLE ; register file handle
  sta     TR0                       ; store the id of the routine that will be launched by ORIX_ROUTINES primitive
  lda     #<ORIX_ROUTINES           ; load the adress $ffe0 : it contains the routine in orix which will handle the ORIX_REGISTER_FILEHANDLE call
  ldy     #>ORIX_ROUTINES           ; Orix is used because there is not enough space in Telemon bank. With the 65C816, it could be easier
  ldx     #ORIX_ID_BANK             ; id of Orix bank
  jsr     call_routine_in_another_bank

  ; cc65 needs everything except $ff : if it returns $ff cc65 launch return0 (null)
  ; A is return from Orix filehandle
  ;lda #$00
  ldx     #$00
  rts


longskip1:
  ldx     #$ff
  txa
  rts

open_and_read_go:
.IFPC02
.pc02
  phy
.p02  
.else
  sty     TR7
.endif  
  jsr     _ch376_set_file_name
  jsr     _ch376_file_open
  sta     TR6 ; store return 
  ldx     #$00
.IFPC02
.pc02
  ply
.p02  
.else
  ldy     TR7 ; because it's "/" in the first char, it means that we are here _/_usr/bin/toto.txt
.endif    

  iny
  lda     TR6 ; GET error of _ch376_file_open return
  rts
file_not_found:
  ; return NULL
  ldx     #$FF
  lda     #$FF
  rts
.endproc
