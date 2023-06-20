.proc kernel_create_process
.out     .sprintf("|MODIFY:RES:kernel_create_process")
.out     .sprintf("|MODIFY:RESB:kernel_create_process")
.out     .sprintf("|MODIFY:TR4:kernel_create_process")
.out     .sprintf("|MODIFY:TR5:kernel_create_process")
.out     .sprintf("|MODIFY:KERNEL_ERRNO:kernel_create_process")
.out     .sprintf("|MODIFY:KERNEL_MALLOC_TYPE:kernel_create_process")
.out     .sprintf("|MODIFY:KERNEL_XKERNEL_CREATE_PROCESS_TMP:kernel_create_process")

; [in]     => A & Y : pointer of the string command
; [modify] => TR4, TR5, TR7 (XMALLOC), A, X, Y, RESB, RES, KERNEL_ERRNO, kernel_process+kernel_process_struct::kernel_pid_list, KERNEL_MALLOC_TYPE
; [out]    => A contains the id of the process created if 0 then error.

; RESB contains the ptr of the string name of the comamnd

; it returns in A if it's ok or not :
; 0 Process error
; return the id of the process

;  kernel_process+kernel_process_struct::kernel_current_process contains the index of the pid list not the PID value !

; kernel_process+kernel_process_struct::kernel_current_process  doit contenir l'offset dans kernel_process+kernel_process_struct::kernel_pid_list
; kernel_process+kernel_process_struct::kernel_pid_list doit contenir le pid

  sta     RESB
  sta     TR4

  sty     RESB+1
  sty     TR5


.ifdef WITH_DEBUG
    ldx     #XDEBUG_CREATE_PROCESS_PRINT
  ;  jsr     xdebug_print
.endif

; Try to find the next PID available

; Get first pid
  ldx     #$00   ; Because the first is init (

@L3:
  lda     kernel_process+kernel_process_struct::kernel_pid_list,x
  beq     @found
  inx
  cpx     #KERNEL_MAX_PROCESS
  bne     @L3
  ; Error here  KERNEL_MAX_PROCESS reached

  PRINT   str_max_process_reached
  jsr     XCRLF_ROUTINE
  PRINT   str_kernel_panic
@loop:
  jmp     @loop

  lda     #KERNEL_ERRNO_MAX_PROCESS_REACHED
  sta     KERNEL_ERRNO

  lda     #NULL
  tay

  rts

@found:
  ; At this step KERNEL_XKERNEL_CREATE_PROCESS_TMP contains the current PID
  stx     KERNEL_XKERNEL_CREATE_PROCESS_TMP

  lda     #$01
  sta     kernel_process+kernel_process_struct::kernel_pid_list,x

  ; Malloc process for init process
  lda     #KERNEL_PROCESS_STRUCT_MALLOC_TYPE
  sta     KERNEL_MALLOC_TYPE

  lda     #<.sizeof(kernel_one_process_struct)
  ldy     #>.sizeof(kernel_one_process_struct)

  jsr     XMALLOC_ROUTINE

  ;       Get current process entry
  cmp     #NULL
  bne     @S2
  cpy     #NULL
  bne     @S2
  ; erreur OOM
  lda     #KERNEL_UNKNOWN_MALLOC_TYPE
  sta     KERNEL_MALLOC_TYPE

  lda     #ENOMEM
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

  ldy     #kernel_one_process_struct::ppid

  lda     kernel_process+kernel_process_struct::kernel_current_process   ; $57A
  sta     (RES),y ; $6AE

@register_processname:
  ldy     #kernel_one_process_struct::process_name ; It works because it's the first item

@L2:
  lda     (RESB),y
  beq     @S1
  cmp     #' '
  beq     @S1
  sta     (RES),y

  iny
  cpy     #(KERNEL_MAX_LENGTH_COMMAND+1)
  bne     @L2
@S1:
  lda     #$00
  sta     (RES),y

; ***********************************************************************************************************************
;                                          Save command line in process struct
; ***********************************************************************************************************************

save_command_line:
  lda     RES+1
  sta     TR5

  lda     RES
  clc
  adc     #kernel_one_process_struct::cmdline
  bcc     @S7
  inc     TR5
@S7:
  sta     TR4

; Now TR4 & TR5 are set the the beginning of cmdline

  ldy     #$00
@L10:
  lda     (RESB),y
  beq     @S8
  sta     (TR4),y
  iny
  cpy     #KERNEL_LENGTH_MAX_CMDLINE
  bne     @L10
  lda     #$00    ; Store 0
@S8:
  sta     (TR4),y

  ; Init fp to $00
  ldy     #kernel_one_process_struct::fp_ptr
  lda     #$00
@L5:
  sta     (RES),y
  iny
  cpy     #(kernel_one_process_struct::fp_ptr+KERNEL_MAX_FP_PER_PROCESS*2)
  bne     @L5

  ; Set to "/" cwd of init process
  ; Get the offset
  ; FIXME cwd_str must be a copy from cwd_str of PPID !
  ldx     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  cpx     #$01  ; First process after init (should be sh) ; COMMENT TO HAVE WORKING MAX PROCESS
  beq     @initialize_to_slash

  ldx     kernel_process+kernel_process_struct::kernel_current_process
  jsr     kernel_get_struct_process_ptr
  sta     KERNEL_CREATE_PROCESS_PTR1
  sty     KERNEL_CREATE_PROCESS_PTR1+1


; Copy cwd from ppid
  ldy     #kernel_one_process_struct::cwd_str

@loop:
  lda     (KERNEL_CREATE_PROCESS_PTR1),y
  beq     @out
  sta     (RES),y  ; Store / at the first car
  iny
  bne     @loop
@out:
  lda     #$00
  sta     (RES),y  ; Store 0 for the last string

  jmp     @skip

; initialize  cwd to slash when pid equinit
@initialize_to_slash:
  ldy     #kernel_one_process_struct::cwd_str
  lda     #"/"
  sta     (RES),y  ; Store / at the first car
  iny
  lda     #$00
  sta     (RES),y  ; Store 0 for the last string

@skip:
  ; Set pid number in the struct
  ldx     KERNEL_XKERNEL_CREATE_PROCESS_TMP
  stx     kernel_process+kernel_process_struct::kernel_current_process
  rts

  ; at this step, list pid contains 1 : init

.endproc

str_max_process_reached:
  .asciiz "Max process reached"
