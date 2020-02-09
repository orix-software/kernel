
.proc kernel_create_process
; RESB contains the ptr of the string name of the comamnd
; it returns in A if it's ok or not :
; 0 Process is OK
; 1 We reached the max process KERNEL_MAX_PROCESS
; 2 : FIXME if malloc return NULL

;  kernel_process+kernel_process_struct::kernel_current_process contains the index of the pid list not the PID value !

.ifdef WITH_DEBUG
jsr   xdebug_enter_create_process_XMALLOC
.endif


; Get first pid
  ldx     #$00
@L3:  
  lda     kernel_process+kernel_process_struct::kernel_pid_list,x
  beq     @found
  inx
  cpx     #KERNEL_MAX_PROCESS
  bne     @L3
  ; Error here  KERNEL_MAX_PROCESS reached

  lda     #$01
  rts

@found:
  stx     kernel_process+kernel_process_struct::kernel_current_process

; Malloc process for init process
  lda     #<.sizeof(kernel_one_process_struct)
  ldy     #>.sizeof(kernel_one_process_struct)

  jsr     XMALLOC_ROUTINE

  ;       get current process entry
  cmp     #$00
  bne     @S2
  cpy     #$00
  bne     @S2
  ; erreur OOM

  lda     #$02
  rts
@S2:

  ; now register ptr adress of process
  ldx     kernel_process+kernel_process_struct::kernel_current_process


  sta     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  sta     RES
  tya

  sta     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x

  ; prepare to copy 'process' string

  sty     RES+1

  ldy     #kernel_one_process_struct::process_name

@L2:
  lda     (RESB),y

  beq     @S1
  sta     (RES),y
  
  iny
  bne     @L2
@S1:
  sta     (RES),y
  
  
  ; set to "/" cwd of init process
  ; get the offset
  ; FIXME cwd_str must be a copy from cwd_str of PPID ! 

  ; init fp to $00
  ldy     #kernel_one_process_struct::fp_ptr 
  lda     #$00
@L4:
  sta     (RES),y
  iny     ; for address
  sta     (RES),y
  iny
  cpy     #(kernel_one_process_struct::fp_ptr+KERNEL_MAX_FP_PER_PROCESS*2)
  bne     @L4


  ldy     #kernel_one_process_struct::cwd_str
  lda     #"/"
  sta     (RES),y  ; Store / at the first car
  iny
  lda     #$00
  sta     (RES),y  ; Store 0 for the last string

  ; init child list to $00
  ldy     #kernel_one_process_struct::child_pid
  ldx     #$00
  lda     #$00
@L1:  
  sta     (RES),y
  iny
  inx
  cpx     #KERNEL_NUMBER_OF_CHILD_PER_PROCESS


  ; Set pid number in the stuct
  ldx     kernel_process+kernel_process_struct::kernel_current_process


  lda     kernel_process+kernel_process_struct::kernel_next_process_pid
  sta     kernel_process+kernel_process_struct::kernel_pid_list,x
  inc     kernel_process+kernel_process_struct::kernel_next_process_pid
  
  lda     #$00  ; process is ok
  rts

  ; at this step, list pid contains 1 : init

.endproc