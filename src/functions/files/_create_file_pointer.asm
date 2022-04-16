
; Use RES 

; input
; A & Y contains the string
; XOPEN_FLAGS contains the flag

; Output : A,Y the pointer

.proc     _create_file_pointer

  sta     RES
  sty     RES+1

.ifdef WITH_DEBUG2
  jsr     kdebug_save
  ldx     #XDEBUG_XOPEN_ALLOCATE_FP
  jsr     xdebug_print
  jsr     kdebug_restore
.endif

  lda     #KERNEL_FP_MALLOC_TYPE
  sta     KERNEL_MALLOC_TYPE
  lda     #<.sizeof(_KERNEL_FILE)
  ldy     #>.sizeof(_KERNEL_FILE)
  jsr     XMALLOC_ROUTINE               ; Malloc Size of kernel_file MODIFY TR7

  cmp     #NULL
  bne     @not_null_2
  cpy     #NULL
  bne     @not_null_2

  lda     #ENOMEM
  sta     KERNEL_ERRNO
  lda     #NULL
  rts

@not_null_2:
  sta     KERNEL_XOPEN_PTR1            ; save ptr
  sty     KERNEL_XOPEN_PTR1+1

  sta     KERNEL_XOPEN_PTR2            ; save ptr
  sty     KERNEL_XOPEN_PTR2+1

  
  ldy     #_KERNEL_FILE::f_flags      ; get Offset
  ; Store flag
  lda     #_FOPEN
  sta     (KERNEL_XOPEN_PTR1),y  

  ldy     #_KERNEL_FILE::f_mode      ; get Offset
  ; Store flag
  lda     XOPEN_FLAGS
  sta     (KERNEL_XOPEN_PTR1),y  


  ; set FD
  
  ;ldy     #_KERNEL_FILE::f_fd      ; get Offset
  ;lda     kernel_process+kernel_process_struct::kernel_next_fd
  ;sta     (KERNEL_XOPEN_PTR1),y  
  

  ; FIXME put readonly/writeonly etc mode

  lda     #_KERNEL_FILE::f_path
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


  jsr     _set_to_0_seek_file
  ; Set now seek position to 0 ("32 bits")
 ; ldy     #_KERNEL_FILE::f_seek_file
  ;lda     #$00
 ; sta     (KERNEL_XOPEN_PTR1),y
 ; iny
  ;sta     (KERNEL_XOPEN_PTR1),y
 ; iny
 ; sta     (KERNEL_XOPEN_PTR1),y
  ;iny
 ; sta     (KERNEL_XOPEN_PTR1),y

  ; return fp or null
  lda     KERNEL_XOPEN_PTR1 ; $7c3
  ldy     KERNEL_XOPEN_PTR1+1

  rts
.endproc
