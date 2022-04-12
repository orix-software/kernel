.proc _set_to_0_seek_file
  ; KERNEL_XOPEN_PTR1 contains the ptr of the file struct

  ; Set now seek position to 0 ("32 bits")
  ldy     #_KERNEL_FILE::f_seek_file
  lda     #$00
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  sta     (KERNEL_XOPEN_PTR1),y
  rts
.endproc
