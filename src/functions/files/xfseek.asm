.proc XFSEEK_ROUTINE
; [IN] X whence
; [IN] AY position 0 to 15
; [IN] RESB position 0 to 31
; [IN] RES fd
  .out     .sprintf("|MODIFY:TR0:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:TR7:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:TR4:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:RESB:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:RES:XFSEEK_ROUTINE")

;EBADF : le descripteur de flux (FILE *) passé en paramètre est invalide.
;EINVAL : le référentiel proposé (paramètre whence) n'est pas valide.

  pha

  sta     TR0
  lda     RES
  sta     KERNEL_XFSEEK_SAVE_RES
  lda     RES+1
  sta     KERNEL_XFSEEK_SAVE_RES+1

  lda     RESB
  sta     RES5
  lda     RESB+1
  sta     RES5+1

  sty     TR7                    ; save Y
  stx     TR4

  ldx     KERNEL_XFSEEK_SAVE_RES ; Load FP in order to store

  jsr     checking_fp_exists
  bcc     @continue_xfseek

  lda     #EBADF
  rts
@continue_xfseek:
  ldx     TR4 ; Whence
  ldy     TR7 ; save Y

  lda     KERNEL_XFSEEK_SAVE_RES
  sta     RES
  lda     KERNEL_XFSEEK_SAVE_RES+1
  sta     RES+1

  lda     KERNEL_XFSEEK_SAVE_RESB
  sta     RESB
  lda     KERNEL_XFSEEK_SAVE_RESB+1
  sta     RESB+1

  pla

  cpx     #SEEK_CUR
  beq     @move
  cpx     #SEEK_END
  beq     @go_end
  cpx     #SEEK_SET
  beq     @go_beginning
  lda     #EINVAL ; Return error
  rts
@go_end:

  lda     CH376_DATA
  ldx     CH376_DATA
  ldy     CH376_DATA
  pha
  lda     CH376_DATA
  sta     RES
  pla

  jsr     getFileLength

  jsr     _ch376_seek_file32
  cmp     #$14
  bne     @error_bad_seek

  lda     KERNEL_XFSEEK_SAVE_RES

  jsr     compute_fp_struct

  jsr     getFileLength    ; return A,X,Y RES : 4 bytes values

  ; Send A X Y RES (from getFileLength)
  jsr     _set_to_value_seek_file

  lda     #EOK ; Return ok
  rts
@error_bad_seek:
  lda     #$FF ; EBADSEEK
  rts

@move:
  ; A  : TR0
  ; Y  : TR7
  ; 16 to 31  : RES5 (2 bytes)

;  jsr     _ch376_seek_file32


  lda     KERNEL_XFSEEK_SAVE_RES

  jsr     compute_fp_struct

  ldy     #_KERNEL_FILE::f_seek_file
  lda     (KERNEL_XOPEN_PTR1),y
  clc
  adc     TR0
  sta     (KERNEL_XOPEN_PTR1),y
  sta     TR0

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     TR7
  sta     (KERNEL_XOPEN_PTR1),y
  sta     TR7


  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     RES5
  sta     (KERNEL_XOPEN_PTR1),y
  sta     RES5

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     RES5+1
  sta     (KERNEL_XOPEN_PTR1),y
  sta     RESB



  lda     TR0
  ldy     TR7
  ldx     RES5
  jsr     _ch376_seek_file32
  cmp     #$14
  bne     @error_bad_seek


  lda     #EOK ; Return ok
  rts
@go_beginning:
  pha
  ; Seek from the beginning of the file
  lda     #$00
  tay
  tax
  sta     RESB
  jsr     _ch376_seek_file32 ; Reset pos
  cmp     #$14
  bne     @error_bad_seek

  ; And seek with offset now

  lda     RES5+1
  sta     RESB

  ldy     TR7
  pla
  ldx     RES5


  jsr     _ch376_seek_file32 ; Reset pos
  cmp     #$14
  bne     @error_bad_seek

  ; Get fd id
  lda     KERNEL_XFSEEK_SAVE_RES
  jsr     compute_fp_struct


  jsr     _set_to_0_seek_file

  lda     RES ; Get fd
  sec
  sbc     #KERNEL_FIRST_FD

  lda     #EOK ; Return ok
  rts
.endproc
