.proc XFSEEK_ROUTINE
    ;;@brief perform a seek on a file
    ;;@description This function performs a seek operation on a file, adjusting the file pointer based on the specified whence and offset.
    ;;@inputA low position 0 to 15 bits
    ;;@inputX whence
    ;;@inputY high position 0 to 15 bits
    ;;@inputMEM_RESB RESB position 0 to 31 (2 bytes)
    ;;@inputMEM_RES fd
    ;;@modifyMEM_RES5 (2 bytes)
    ;;@modifyMEM_TR0
    ;;@modifyMEM_TR4
    ;;@modifyMEM_TR7
    ;;@returnsA  EOK if successful, EBADF if the file descriptor is invalid, or EINVAL if the whence is invalid, Return A=$FF if something is wrong when seek has performed
    ;;@returnsA position 0 to 7 (1 byte)
    ;;@returnsA position 8 to 15 (1 byte)
    ;;@returnsMEM_RES position 16 to 31 (2 bytes)

  .out     .sprintf("|MODIFY:TR0:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:TR6:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:TR7:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:TR4:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:RESB:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:RES:XFSEEK_ROUTINE")
  .out     .sprintf("|MODIFY:KERNEL_XOPEN_PTR1:XFSEEK_ROUTINE") ; From checking_fp_exists

;EBADF : le descripteur de flux (FILE *) passé en paramètre est invalide.
;EINVAL : le référentiel proposé (paramètre whence) n'est pas valide.

  sta     TR0 ; 09
  lda     RES
  sta     KERNEL_XFSEEK_SAVE_RES
  lda     RES + 1
  sta     KERNEL_XFSEEK_SAVE_RES+1

  lda     RESB
  sta     RES5

  lda     RESB + 1
  sta     RES5 + 1

  sty     TR7                     ; save Y $02
  stx     TR4

  ldx     KERNEL_XFSEEK_SAVE_RES ; Load FP in order to store

  jsr     checking_fp_exists
  bcc     @continue_xfseek

 ; lda     #EBADF

  lda     #$FF
  tax
  sta     RES
  sta     RES + 1

  rts

@continue_xfseek:
  ldx     TR4 ; Whence
  ldy     TR7 ; get Y

  lda     KERNEL_XFSEEK_SAVE_RES
  sta     RES
  lda     KERNEL_XFSEEK_SAVE_RES + 1
  sta     RES + 1

  lda     KERNEL_XFSEEK_SAVE_RESB
  sta     RESB
  lda     KERNEL_XFSEEK_SAVE_RESB + 1
  sta     RESB + 1

  cpx     #SEEK_CUR
  beq     @move
  cpx     #SEEK_END
  beq     @go_end
  cpx     #SEEK_SET
  beq     @go_beginning
  ;lda     #EINVAL ; Return error

@returns_minus_1:
  lda     #$FF
  tax
  sta     RES
  sta     RES + 1

  rts

; SEEK_END : Seek from the end of the file
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

  jsr     getFileLength    ; return A, X, Y RES : 4 bytes values

  ; Send A X Y RES (from getFileLength)
  jsr     _set_to_value_seek_file

  jmp     returns_position


@error_bad_seek:
 ; lda     #$FF ; EBADSEEK
  jmp     @returns_minus_1


; SEEK_CUR : Seek from the current position
@move:
  ; A  : TR0
  ; Y  : TR7
  ; 16 to 31  : RES5 (2 bytes)

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
  adc     RES5 + 1
  sta     (KERNEL_XOPEN_PTR1),y
  sta     RESB

  lda     TR0
  ldy     TR7
  ldx     RES5
  jsr     _ch376_seek_file32
  cmp     #$14
  bne     @error_bad_seek

  jmp    returns_position


; SEEK_SET : Seek from the beginning of the file
@go_beginning:
  ;sta     TR6
  ; Seek from the beginning of the file
  lda     #$00
  tay
  tax
  sta     RESB
  jsr     _ch376_seek_file32 ; Reset pos
  cmp     #$14
  bne     @error_bad_seek

  ; And seek with offset now
  lda     RES5 + 1
  sta     RESB

  ldy     TR7 ; Get Y
  lda     TR0
  ldx     RES5


  jsr     _ch376_seek_file32 ; Reset pos
  cmp     #$14
  bne     @error_bad_seek

  ; Get fd id
  lda     KERNEL_XFSEEK_SAVE_RES
  jsr     compute_fp_struct

  jsr     _set_to_0_seek_file

  ; Add the offset passed in arg into struct
  ldy     #_KERNEL_FILE::f_seek_file
  lda     (KERNEL_XOPEN_PTR1),y
  clc
  adc     TR0
  sta     (KERNEL_XOPEN_PTR1),y

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     TR7
  sta     (KERNEL_XOPEN_PTR1),y

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     RES5
  sta     (KERNEL_XOPEN_PTR1),y

  iny
  lda     (KERNEL_XOPEN_PTR1),y
  adc     RES5+1
  sta     (KERNEL_XOPEN_PTR1),y

  ; Don't RTS here , we execute returns position

returns_position:
  ldy     #_KERNEL_FILE::f_seek_file + 3

  ; Get the position of the file pointer
  ;; Store it in RES for from 16 to 31 bits
  lda     (KERNEL_XOPEN_PTR1),y
  sta     RES + 1
  dey
  ; Store it in AX for from 0 to 15 bits
  lda     (KERNEL_XOPEN_PTR1),y
  sta     RES
  dey
  lda     (KERNEL_XOPEN_PTR1),y
  tax
  dey
  lda     (KERNEL_XOPEN_PTR1),y
  ; FIXME REMOVE ME !!!!!

  ldy     #EOK
  rts


.endproc
