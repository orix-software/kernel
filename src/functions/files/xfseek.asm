.proc XFSEEK_ROUTINE
; [IN] X whence
; [IN] AY position 0 to 15
; [IN] RESB position 0 to 31
; [IN] RES fd
; 


;#define SEEK_CUR        0 
;#define SEEK_END        1
;#define SEEK_SET        2  	Beginning of file
  pha

  sta     TR6
  lda     RES
  sta     KERNEL_XFSEEK_SAVE_RES
  lda     RES+1
  sta     KERNEL_XFSEEK_SAVE_RES+1
  
  lda     RESB
  sta     KERNEL_XFSEEK_SAVE_RESB
  lda     RESB+1
  sta     KERNEL_XFSEEK_SAVE_RESB+1

  sty     TR7 ; save Y
  stx     TR4

  ldx     KERNEL_XFSEEK_SAVE_RES ; Load FP in order to store

  jsr     checking_fp_exists

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
  lda     #$01 ; Return error
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

  lda     KERNEL_XFSEEK_SAVE_RES
  sec
  sbc     #KERNEL_FIRST_FD
  tax

  jsr     compute_fp_struct

  jsr     getFileLength
  sta     RES
  sty     RES+1
  lda     RESB
  sta     RESB+1
  ldx     RESB

  jsr     _set_to_value_seek_file

  lda     #$00 ; Return ok
  rts

@move:



  ldx      RESB

  jsr      _ch376_seek_file32


  lda     KERNEL_XFSEEK_SAVE_RES
  sec
  sbc     #KERNEL_FIRST_FD
  tax

  jsr     compute_fp_struct

  ldy     #_KERNEL_FILE::f_seek_file
  lda     (KERNEL_XOPEN_PTR1),y
;  clc
;  adc     TR6
;;;  bcc     @do_not_inc_low8
  iny
;  pha
  ;lda     (KERNEL_XOPEN_PTR1),y
 ; clc
 ; adc     #$01
  ;pla
;  dey
;@do_not_inc_low8:
 ; sta     (KERNEL_XOPEN_PTR1),y
 ; iny
 ; sta     (KERNEL_XOPEN_PTR1),y
;  iny
 ; sta     (KERNEL_XOPEN_PTR1),y
  ;iny
 ; sta     (KERNEL_XOPEN_PTR1),y


  lda     #$00 ; Return ok
  rts
@go_beginning:

  ; Seek from the beginning of the file
  lda     #$00
  tay
  tax
  sta     RESB
  jsr     _ch376_seek_file32 ; Reset pos

  
  
  ; And seek with offset now
@me:
  jmp     @me
  lda     KERNEL_XFSEEK_SAVE_RESB+1
  sta     RESB+1

  lda     TR6
  ldy     TR7
  ldx     KERNEL_XFSEEK_SAVE_RESB

  
  ;jsr     _ch376_seek_file32 ; Reset pos




  ; Get fd id
  lda     KERNEL_XFSEEK_SAVE_RES
  sec
  sbc     #KERNEL_FIRST_FD
  tax

  jsr     compute_fp_struct


  jsr     _set_to_0_seek_file

  lda     RES ; Get fd
  sec
  sbc     #KERNEL_FIRST_FD

  lda     #$00 ; Return ok
  rts
.endproc
