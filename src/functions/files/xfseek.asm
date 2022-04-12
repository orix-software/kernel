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
  lda     RES
  sta     KERNEL_XFSEEK_SAVE_RES
  lda     RES+1
  sta     KERNEL_XFSEEK_SAVE_RES+1
  
  lda     RESB
  sta     KERNEL_XFSEEK_SAVE_RESB
  lda     RESB+1
  sta     KERNEL_XFSEEK_SAVE_RESB+1


  jsr     checking_fp_exists

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

  lda     #$00 ; Return ok
  rts
@go_beginning:
  lda     #$00
  tay
  tax
  sta     RESB
  jsr     _ch376_seek_file32

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
