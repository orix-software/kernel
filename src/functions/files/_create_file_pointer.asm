
; Use RES 
.proc     _create_file_pointer
  lda     #<.sizeof(_KERNEL_FILE)
  ldy     #>.sizeof(_KERNEL_FILE)
  jsr     XMALLOC_ROUTINE               ; Malloc Size of kernel_file
  
  sta     KERNEL_XOPEN_PTR1             ; get pter
  sta     KERNEL_XOPEN_PTR2             ; get pter

  sty     KERNEL_XOPEN_PTR1+1
  sty     KERNEL_XOPEN_PTR2+1
  
  ldy     #(_KERNEL_FILE::f_flags)      ; get Offset
  ; Store flag
  lda     TR4
  sta     (KERNEL_XOPEN_PTR1),y  


  ; FIXME put readonly/writeonly etc mode

  ldy     #(_KERNEL_FILE::f_path)
  tya
  clc
  adc     KERNEL_XOPEN_PTR2
  bcc     @S1
  inc     KERNEL_XOPEN_PTR2+1
@S1:
  sta     KERNEL_XOPEN_PTR2
  ; Copy PATH
  ldy     #$00
@L1:  
  lda     (RES),y
  beq     @S2
  sta     (KERNEL_XOPEN_PTR2),y  
  iny
  cpy     #KERNEL_MAX_PATH_LENGTH
  bne     @L1
  lda     #$00
@S2:
  sta     (KERNEL_XOPEN_PTR2),y  
  ; FIXME : set path in the struct

  ; return fp or null
  lda     KERNEL_XOPEN_PTR1
  ldy     KERNEL_XOPEN_PTR1+1
  ldx     KERNEL_XOPEN_PTR1+1  ; for cc65 compatibility
  
  rts
.endproc
