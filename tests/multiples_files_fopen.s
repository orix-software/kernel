
.export _fopen_kernel
.export _fclose_kernel
.export _fread_kernel
.export _fwrite_kernel
.export _fseek_kernel

.include   "telestrat.inc"
.include   "fcntl.inc"
.include   "cpu.mac"
.include   "errno.inc"

;.include "orix-sdk/macros/SDK_utils.mac"
.include "SDK_file.mac"
.include "orix-sdk/macros/SDK_print.mac"

.importzp ptr1

.import popax,popa

; fopen (string, flag)
.proc _fopen_kernel
    sta flag

    ldx     #06     ; XVARS_KERNEL_BINARY_VERSION
    BRK_TELEMON $24 ; XVARS
;@me:
    ;jmp @me
    jsr popax

    sta ptr1
    stx ptr1+1
    fopen (ptr1), O_RDONLY

    rts
flag:    
    .res     1
.endproc

.proc _fclose_kernel
    rts
.endproc

.proc _fwrite_kernel
    rts
.endproc

; fread_kernel(void *ptr, unsigned char size,  unsigned char id);
;AY contains the length to read
;PTR_READ_DEST must be set because it's the ptr_dest
;X contains the fd id

.proc _fread_kernel
    sta fd
    ; Id 
    jsr popax ; Size

    sta size
    stx size+1


    jsr popax ; ptr


    sta PTR_READ_DEST
    stx PTR_READ_DEST+1
    ldx fd
    lda size
    ldy size+1

    BRK_TELEMON XFREAD
    rts 
.endproc

fd:
    .byte 0
size:
    .byte 0,0
whence:
    .byte 0
offset:
    .byte 0,0,0,0
tmp1:
    .byte 0
; fseek_kernel( int offset, unsigned char whence,unsigned char fd);
.proc _fseek_kernel
; [IN] X whence
; [IN] AY position 0 to 15
; [IN] RESB position 0 to 31
; [IN] RES fd
    sta     RES
    sta     fd

    jsr     popa
    sta     whence

    lda     #$00
    sta     RESB
    sta     RESB+1

    sta     offset+3
    sta     offset+2

    jsr     popax

    stx      tmp1

    sta     offset
    stx     offset+1
    
    
    ldy    tmp1
    
    ldx    whence

XFSEEK           = $3F
;

    fseek fd, offset, whence
  ;  BRK_TELEMON XFSEEK





    rts

.endproc
