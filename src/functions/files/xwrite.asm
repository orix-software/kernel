.export XWRITEBYTES_ROUTINE

.proc XWRITEBYTES_ROUTINE
; [IN] AY contains the length to write
; [IN] PTR_READ_DEST must be set because it's the ptr_dest
; [MODIFIED] TR0,PTR_READ_DEST, YA
; X contains the fp

; fwrite( void * restrict buffer, size_t blocSize, FILE * restrict stream );
; [UNCHANGED] X

  .out     .sprintf("|MODIFY:PTR_READ_DEST:XWRITEBYTES_ROUTINE")
  .out     .sprintf("|MODIFY:RES:XWRITEBYTES_ROUTINE")
  .out     .sprintf("|MODIFY:RESB:XWRITEBYTES_ROUTINE")

  pha
  lda     PTR_READ_DEST
  sta     RES

  lda     PTR_READ_DEST+1
  sta     RES+1
  
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
  ; Save PTR_READ_DEST to compute bytes


@continue:

  cmp     #CH376_USB_INT_SUCCESS    ; finished
  beq     @writeme

@check_byte:
  cmp     #CH376_USB_INT_DISK_WRITE
  beq     @writeme
  ; FIXME ???

  rts


@writeme:
  lda     #CH376_CMD_WR_REQ_DATA
  sta     CH376_COMMAND

  ldy     #$00

  ldx     CH376_DATA
  beq     @end

 @loop:
  lda     (PTR_READ_DEST),y
  sta     CH376_DATA
  iny
  dex
  bne     @loop
 @end:
  sty     RESB ; save Y
  jsr     ByteWrGo
  bne     @finished
  ; Returns number of bytes
 
 
  lda      RESB ; Get last Y value
  clc                               ; 
  adc     PTR_READ_DEST
  bcc     @next
  inc     PTR_READ_DEST+1
@next:
  sta     PTR_READ_DEST
  jmp     @writeme


@finished:
  ;; at this step PTR_READ_DEST is updated
  ;;  Compute nb of written bytes


  jsr     _update_fp_position


  rts

.endproc

