.export XWRITEBYTES_ROUTINE

.proc XWRITEBYTES_ROUTINE
; [IN] AY contains the length to write
; [IN] PTR_READ_DEST must be set because it's the ptr_dest
; [MODIFIED] TR0,PTR_READ_DEST, YA
; Xcontains the fp

; fwrite( void * restrict buffer, size_t blocSize, FILE * restrict stream );
; [UNCHANGED] X

  jsr     _ch376_set_bytes_write

  pha
  lda     PTR_READ_DEST
  sta     RES

  lda     PTR_READ_DEST+1
  sta     RES+1
  pla

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

  lda     RESB ; Get last Y value 
  clc
  adc     PTR_READ_DEST
  bcc     @no_inc

  inc     PTR_READ_DEST+1

@no_inc:
  
  sta     PTR_READ_DEST

  sec
  sbc     RES
  bcs     @no_dec
  dec     PTR_READ_DEST+1
@no_dec:
  pha     
  lda     PTR_READ_DEST+1
  sec
  sbc     RES+1
  sta     PTR_READ_DEST+1 ; for cc65 compatibility
  tax
  pla

  ;ldx     PTR_READ_DEST+1

  ;lda     PTR_READ_DEST+1
  ;sec
  ;sbc     RES+1
  ;tax
  ;lda     PTR_READ_DEST
  ;sec
  ;sbc     RES





  rts

.endproc

.proc ByteWrGo
	lda     #CH376_BYTE_WR_GO
	sta     CH376_COMMAND

	jsr     _ch376_wait_response
	cmp     #CH376_USB_INT_DISK_WRITE
	bne     error
	clc
	rts

 error:
	lda     #$FF
	sec
	rts
.endproc
