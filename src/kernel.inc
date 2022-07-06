BASH_MAX_ARGS                           = 3       ;  Number of possible args in the command line
BASH_MAX_BUFEDT_LENGTH                  = 110
userzp                                 := VARLNG
RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM := $78
NEXT_STACK_BANK                        := $0418
MOUSE_JOYSTICK_MANAGEMENT              := $291 ; 12 bytes ?
i_o_counter                            := $1A ; 1 byte
i_o_save        := $1B ; 3 bytes ?
TRANSITION_RS232:= $1E;  3 bytes

FILESYS_BANK := $20C

KEYBOARD_COUNTER:=$02A6 ; 4 bytes
VIA_UNKNOWN     :=$028F ; seems tobe a backup of timer  2 bytes

ORIX_MEMORY_DRIVER_ADDRESS:=$400
SWITCH_TO_BANK_ID              :=     $040C
;NEXT_STACK_BANK:=$418
FIXME_PAGE0_0:=$25
ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY:=$411 ; .dsb 3

work_channel  :=$19     ; 1 byte
KBD_UNKNOWN   :=$271  ;FIXME

FUFTRV=$0100; working Buffer

NULL = 0
BUFROU:= $C500 ; Routines for buffers gestion

SIZE_OF_STACK_BANK = 3

BNKOLD:=$40F

ADDRESS_READ_BETWEEN_BANK:=$15
ADDRESS_VECTOR_FOR_ADIOB:=$17
BNK_TO_SWITCH:=$410

tmp1:=$34
ptr1:=$32

.bss
.org $200
KERNEL_ERRNO:
    .res 1
KERNEL_CH376_MOUNT:
    .res 1
KERNEL_XFREE_TMP:
    .res 1
KERNEL_XKERNEL_CREATE_PROCESS_TMP:
    .res 1

KERNEL_TMP_XEXEC:
    .res 1
KERNEL_KERNEL_XEXEC_BNKOLD:
    .res 1
KERNEL_MALLOC_TYPE:
    .res 1
KERNEL_SAVE_XEXEC_CURRENT_SET:
    .res 1
KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM:
    .res 1
KERNEL_END_PROCESS_VARIABLES:
.if  KERNEL_END_PROCESS_VARIABLES > FLGTEL
  .error  "Error KERNEL_END_PROCESS_VARIABLES overlap FLGTEL"
.endif

.org $282
; Was VDTPIL


.org $2AE
IOTAB:
    .res 4 ; KERNEL_SIZE_IOTAB
KERNEL_ADIOB:
    .res 8
kernel_malloc_busy_begin:
    .tag kernel_malloc_busy_begin_struct
    .out     .sprintf("kernel_malloc_busy_begin : %x", kernel_malloc_busy_begin)
kernel_malloc_free_size:
    .tag kernel_malloc_free_chunk_size_struct
kernel_xmalloc_call:
    .res 40 ; XMALLOC_ROUTINE_TO_RAM_OVERLAY
KERNEL_ADIOB_END:
.if  KERNEL_ADIOB_END > VNMI
  .error  "Error malloc table overlap VNMI"
.endif

.bss
.org $4C7

.res 1 ;Was before FIXME_DUNNO, it could remove when READ_BYTE_FROM_OVERLAY_RAM will be aligned correctly with kernel load

READ_BYTE_FROM_OVERLAY_RAM:
; this contains a routine length : 20 bytew
.res 20
.org $4FF
FIXME_DUNNO:
    .res  1

.bss
.org $500
STACK_BANK:
    .res SIZE_OF_STACK_BANK

kernel_end_of_variables_before_BUFNOM:

.if  kernel_end_of_variables_before_BUFNOM > BUFNOM
  .error  "Error BUFNOM is written by kernel variables try to move some variables in kernel.inc after BUFNOM or BUFEDT"
.endif

.out     .sprintf("kernel_end_of_variables_before_BUFNOM : %x", kernel_end_of_variables_before_BUFNOM)

.bss
.org BUFNOM
    .res 14
BUFNOM_END:

kernel_malloc:
    .tag    kernel_malloc_struct
kernel_malloc_end:
kernel_process:
    .tag    kernel_process_struct
kernel_process_end:
kernel_end_of_variables_before_BUFEDT:
.out     .sprintf("kernel_end_of_variables_before_BUFEDT : %x", kernel_end_of_variables_before_BUFEDT)
.if     kernel_end_of_variables_before_BUFEDT > BUFEDT
  .error  "Error BUFEDT is written by kernel variables try to move some variables in kernel.inc after $590"
.endif

.bss
.org BUFEDT

.ifdef WITH_DEBUG
;.org BUFNOM
kernel_debug:
    .tag    kernel_debug_struct
    .out   .sprintf("Size of kernel_debug_struct $%x ", .sizeof(kernel_debug_struct))
.else
.res 110
.endif

BUFEDT_END:

KERNEL_DRIVER_MEMORY:
    .res 166
KERNEL_DRIVER_MEMORY_END:



kernel_end_of_memory_for_kernel:

.out     .sprintf("kernel_end_of_memory_for_kernel (malloc will start at this adress) : %x", kernel_end_of_memory_for_kernel)

kernel_end_of_variables_after_BUFEDT:
.if     kernel_end_of_variables_after_BUFEDT > $7FF
  .error  "Error start of execution program for binary ($800) is written by kernel variables try to move some variables in kernel.inc before $800"
.endif


