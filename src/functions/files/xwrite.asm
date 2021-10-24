.export XWRITEBYTES_ROUTINE

.proc XWRITEBYTES_ROUTINE
; [IN] AY contains the length to write
; [IN] PTR_READ_DEST must be set because it's the ptr_dest
; [MODIFIED] TR0,PTR_READ_DEST, YA
; Xcontains the fp

; fwrite( void * restrict buffer, size_t blocSize, FILE * restrict stream );
; [UNCHANGED] X
  jsr     _ch376_set_bytes_write

  ; Save PTR_READ_DEST to compute bytes
  lda     PTR_READ_DEST
  sta     RES

  lda     PTR_READ_DEST+1
  sta     RES+1

@continue:
  cmp     #CH376_USB_INT_DISK_WRITE  ; something to read
  beq     @writeme
  cmp     #CH376_USB_INT_SUCCESS    ; finished
  beq     @finished 
  ; TODO  in A : $ff X: $ff
  lda     #$00
  tax
  rts
@writeme:
  jsr     @we_write
  lda     #CH376_BYTE_WR_GO 
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
  ;  Compute nb of bytes read
  lda     PTR_READ_DEST+1
  sec
  sbc     RES+1
  tax
  lda     PTR_READ_DEST
  sec
  sbc     RES

  rts	

@we_write:
  lda     #CH376_CMD_WR_REQ_DATA
  sta     CH376_COMMAND

  lda     CH376_DATA                ; contains length write
  beq     @finished                 ; we don't have any bytes to write then stops (Assinie report)
  sta     TR0                       ; Number of bytes to read, storing this value in order to loop
  
  ldy     #$00
@loop:
  lda     (PTR_READ_DEST),y         ; read the data
  sta     CH376_DATA                ; send data in the ptr address
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

