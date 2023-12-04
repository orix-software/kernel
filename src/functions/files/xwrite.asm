.proc XWRITEBYTES_ROUTINE

  .out     .sprintf("|MODIFY:PTR_READ_DEST:XWRITEBYTES_ROUTINE")
  .out     .sprintf("|MODIFY:RES:XWRITEBYTES_ROUTINE")
  .out     .sprintf("|MODIFY:RESB:XWRITEBYTES_ROUTINE")
; [IN] AY contains the length to write
; [IN] PTR_READ_DEST must be set because it's the ptr_dest
; [MODIFIED] TR0,PTR_READ_DEST, YA
; X contains the fp

; fwrite( void * restrict buffer, size_t blocSize, FILE * restrict stream );
; [UNCHANGED] X

  pha
  lda     PTR_READ_DEST
  sta     RES

  lda     PTR_READ_DEST+1
  sta     RES+1

  ; Checking if fp exists
  jsr     checking_fp_exists
  bcc     @continue_xfwrite
  pla
  ; Error return 0 bytes read
  lda     #$00
  tax
  rts

@continue_xfwrite:
  pla

  jsr     _ch376_set_bytes_write

  cmp     #CH376_USB_INT_SUCCESS
  beq     @writeme
  cmp     #CH376_USB_INT_DISK_WRITE    ; finished
  beq     @writeme

  lda     #$00
  tax
  rts

@writeme:
  jsr     @we_write

  lda     #CH376_BYTE_WR_GO
  sta     CH376_COMMAND
  jsr     _ch376_wait_response

@continue:
  cmp     #CH376_USB_INT_DISK_WRITE
  beq     @writeme

  ;; at this step PTR_READ_DEST is updated
  ;;  Compute nb of written bytes
  jmp     _update_fp_position

@we_write:
  lda     #CH376_CMD_WR_REQ_DATA
  sta     CH376_COMMAND

  ldx     CH376_DATA
  beq     @end

  ldy     #$00

@loop:
  lda     (PTR_READ_DEST),y
  sta     CH376_DATA
  iny
  dex
  bne     @loop

@end:
  tya

  ; Returns number of bytes

  ;lda     RESB ; Get last Y value
  clc                               ;
  adc     PTR_READ_DEST
  bcc     @next
  inc     PTR_READ_DEST+1
@next:
  sta     PTR_READ_DEST

  rts

.endproc
