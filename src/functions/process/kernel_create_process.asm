.proc kernel_create_process

; [in]     => A & Y : pointer of the string command
; [modify] => TR4, TR5, A, X, Y, RESB, RES
; [out]    => A contains the id of the process created if 0 then error.

; RESB contains the ptr of the string name of the comamnd

; it returns in A if it's ok or not :
; 0 Process error
; return the id of the process

;  kernel_process+kernel_process_struct::kernel_current_process contains the index of the pid list not the PID value !


.ifdef WITH_DEBUG
jsr   xdebug_enter_create_process_XMALLOC
.endif

  sta     RESB
  sta     TR4

  sty     RESB+1
  sty     TR5



; Get first pid
  ldx     #$00

@L3:  
  lda     kernel_process+kernel_process_struct::kernel_pid_list,x
  beq     @found
  inx
  cpx     #KERNEL_MAX_PROCESS
  bne     @L3
  ; Error here  KERNEL_MAX_PROCESS reached

  lda     #$02
  sta     KERNEL_ERRNO
  lda     #NULL
  ldy     #NULL  

  rts

@found:

  ;stx     kernel_process+kernel_process_struct::kernel_current_process
  stx     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  txa
  sta     kernel_process+kernel_process_struct::kernel_pid_list,x


; Malloc process for init process
  lda     #<.sizeof(kernel_one_process_struct)
  ldy     #>.sizeof(kernel_one_process_struct)

  jsr     XMALLOC_ROUTINE

  ;       get current process entry
  cmp     #NULL
  bne     @S2
  cpy     #NULL
  bne     @S2
  ; erreur OOM

  lda     #$02
  rts
@S2:

  ; now register ptr adress of process
  ldx     KERNEL_XKERNEL_CREATE_PROCESS_TMP


  sta     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
  sta     RES

  tya

  sta     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
  sty     RES+1



  ; prepare to copy 'process' string


; ***********************************************************************************************************************
;                                          Save ppid
; ***********************************************************************************************************************



  lda     kernel_process+kernel_process_struct::kernel_current_process

  ldy     #kernel_one_process_struct::ppid
  sta     (RES),y



@register_processname:
  ldy     #kernel_one_process_struct::process_name ; It works because it's the first item

@L2:
  lda     (RESB),y
  beq     @S1
  cmp     #' '
  beq     @S1  
  sta     (RES),y
  
  iny
  bne     @L2
@S1:
  lda     #$00
  sta     (RES),y




; ***********************************************************************************************************************
;                                          Save command line in process struct
; ***********************************************************************************************************************
save_command_line:
  lda     RESB+1
  sta     TR5

  lda     RESB
  clc
  adc     #kernel_one_process_struct::cmdline
  bcc     @S7
  inc     TR5
@S7:
  sta     TR4
; now TR4 & TR5 are set the the beginning of cmdline

  ldy     #$00
@L10:  
  lda     (RESB),y
  beq     @S8
  sta     (TR4),y
  iny
  cpy     #KERNEL_LENGTH_MAX_CMDLINE
  bne     @L10
  
@S8:
  sta     (TR4),y


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

  ; set to "/" cwd of init process
  ; get the offset
  ; FIXME cwd_str must be a copy from cwd_str of PPID ! 

  ldy     #kernel_one_process_struct::cwd_str
  lda     #"/"
  sta     (RES),y  ; Store / at the first car



  iny
  lda     #$00
  sta     (RES),y  ; Store 0 for the last string

  ; init child list to $00
  ;ldy     #kernel_one_process_struct::child_pid
  ;ldx     #$00
  ;lda     #$00
;@L1:  
  ;sta     (RES),y
  ;iny
  ;inx
  ;cpx     #KERNEL_NUMBER_OF_CHILD_PER_PROCESS


  ; Set pid number in the struct
  lda     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  sta     kernel_process+kernel_process_struct::kernel_current_process
  rts

  ; at this step, list pid contains 1 : init

.endproc
