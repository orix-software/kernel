.proc _set_to_value_seek_file
  ; KERNEL_XOPEN_PTR1 contains the ptr of the file struct
  ; A & X Y contains the offset
  ; KERNEL_XOPEN_PTR1 must be set to the fd struct
  .out     .sprintf("|MODIFY:RES:_set_to_value_seek_file")

  sty     RES+1
  ldy     #_KERNEL_FILE::f_seek_file
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  lda     RES+1 ; Y value
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  txa
  sta     (KERNEL_XOPEN_PTR1),y
  iny
  lda     RES
  sta     (KERNEL_XOPEN_PTR1),y
  rts
.endproc
