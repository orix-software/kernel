.proc XREADBYTES_ROUTINE

  .out     .sprintf("|MODIFY:PTR_READ_DEST:XREADBYTES_ROUTINE")
  .out     .sprintf("|MODIFY:RES:XREADBYTES_ROUTINE")
  .out     .sprintf("|MODIFY:TR0:XREADBYTES_ROUTINE")
; [IN] AY contains the length to read
; [IN] PTR_READ_DEST must be set because it's the ptr_dest
; [IN] X contains the fd id

; Modify : RES, PTR_READ_DEST, TR0

; Modify : RES, PTR_READ_DEST, TR0

; [OUT]  PTR_READ_DEST updated


; [OUT]  A could contains 0 or the CH376 state
; [OUT]  Y contains the last size of bytes
  ;jmp     XREADBYTES_ROUTINE


  ; Save PTR_READ_DEST to compute bytes


  pha
  lda     PTR_READ_DEST
  sta     RES
;
  lda     PTR_READ_DEST+1
  sta     RES+1

  ; Compute the fp

  ; Checking if fp exists
  jsr     checking_fp_exists
  bcc     @continue_xfread
  pla
  ; Error return 0 bytes read
  lda     #$00
  tax
  rts

@continue_xfread:

  pla


  jsr     _ch376_set_bytes_read



@continue:
  cmp     #CH376_USB_INT_DISK_READ  ; something to read
  beq     @readme
  cmp     #CH376_USB_INT_SUCCESS    ; finished
  beq     @finished
  ; TODO  in A : $ff X: $ff
  lda     #$00
  tax
  rts
@readme:
  jsr     @we_read

  lda     #CH376_BYTE_RD_GO
  sta     CH376_COMMAND
  jsr     _ch376_wait_response


.IFPC02
.pc02
  bra     @continue
.p02
.else
  jmp     @continue
.endif

@finished:
  ; at this step PTR_READ_DEST is updated
  ; return now length
  ;  Compute nb of bytes read




  jsr     _update_fp_position

  rts

@we_read:
  lda     #CH376_RD_USB_DATA0
  sta     CH376_COMMAND



  lda     CH376_DATA                ; contains length read
  beq     @finished                 ; we don't have any bytes to read then stops (Assinie report)


  sta     TR0                       ; Number of bytes to read, storing this value in order to loop

  ldy     #$00
@loop:
  lda     CH376_DATA                ; read the data
  sta     (PTR_READ_DEST),y         ; send data in the ptr address
  iny                               ; inc next ptr addrss
  cpy     TR0                       ; do we read enough bytes
  bne     @loop                     ; no we read

  tya                               ; We could do "lda TR0" but TYA is quicker. Add X bytes to A in order to update ptr (Y contains the size of the bytes reads)
  clc                               ;
  adc     PTR_READ_DEST
  bcc     @next
  inc     PTR_READ_DEST+1
@next:
  sta     PTR_READ_DEST
  rts
.endproc
