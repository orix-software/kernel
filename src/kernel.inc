BASH_MAX_ARGS                      = 3       ;  Number of possible args in the command line

BASH_MAX_BUFEDT_LENGTH         = 110
userzp                  := VARLNG

RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM := $78

NEXT_STACK_BANK := $0418

MOUSE_JOYSTICK_MANAGEMENT := $291 ; 12 bytes ?
i_o_counter     := $1A ; 1 byte
i_o_save        := $1B ; 3 bytes ?
TRANSITION_RS232:= $1E;  3 bytes

KEYBOARD_COUNTER:=$02A6 ; 4 bytes
VIA_UNKNOWN     :=$028F ; seems tobe a backup of timer  2 bytes

ORIX_MEMORY_DRIVER_ADDRESS:=$400
SWITCH_TO_BANK_ID              :=     $040C
;NEXT_STACK_BANK:=$418
FIXME_PAGE0_0:=$25
ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY:=$411 ; .dsb 3

work_channel  :=$19     ; 1 byte
KBD_UNKNOWN   :=$271  ;FIXME

; ORIX_PATH_CURRENT:=$0525  ;FIXME
FUFTRV=$0100; working Buffer 




NULL = 0
;#define FILE_OPEN_TABLE $D000 

; #define BUF1   $C100 ; Stratsed buffer

;#define BUFBUF $C080 ; buffers definition
BUFROU:= $C500 ; Routines for buffers gestion


SIZE_OF_STACK_BANK = 1

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
KERNEL_END_PROCESS_VARIABLES:
.if  KERNEL_END_PROCESS_VARIABLES > FLGTEL
  .error  "Error KERNEL_END_PROCESS_VARIABLES overlap FLGTEL"
.endif    

.bss
.org $4C7
FIXME_DUNNO:
.res 1

READ_BYTE_FROM_OVERLAY_RAM:
; this contains a routine length : 20 bytew
.res 20

.bss
.org $500
STACK_BANK:
    .res SIZE_OF_STACK_BANK 

kernel_end_of_variables_before_BUFNOM:

.if  kernel_end_of_variables_before_BUFNOM > BUFNOM
  .error  "Error BUFNOM is written by kernel variables try to move some variables in kernel.inc after BUFNOM or BUFEDT"
.endif    

.bss
.org BUFNOM
.res 14
kernel_malloc:
    .tag    kernel_malloc_struct


kernel_process:
    .tag    kernel_process_struct
    
kernel_end_of_variables_before_BUFEDT:    
.if     kernel_end_of_variables_before_BUFEDT > BUFEDT
  .error  "Error BUFEDT is written by kernel variables try to move some variables in kernel.inc after $590"
.endif    

.bss
.org BUFEDT
.res 110
ORIX_ARGV:
	.res    KERNEL_MAX_LENGTH_OF_FILES*BASH_MAX_ARGS
; used to check term
TEMP_ORIX_1:
    .res 1
ORIX_ARGC:
    .res 1
KERNEL_DRIVER_MEMORY:
    .res 159

.out     .sprintf("ORIX_ARGV  : %x", ORIX_ARGV)
.out     .sprintf("ORIX_ARGC  : %x", ORIX_ARGC)
.ifdef WITH_DEBUG
kernel_debug:
    .tag    kernel_debug_struct
.endif    

kernel_end_of_memory_for_kernel:

.out     .sprintf("kernel_end_of_memory_for_kernel (malloc will start at this adress) : %x", kernel_end_of_memory_for_kernel)

kernel_end_of_variables_after_BUFEDT:    
.if     kernel_end_of_variables_after_BUFEDT > $7FF
  .error  "Error start of execution program for binary ($800) is written by kernel variables try to move some variables in kernel.inc before $800"
.endif    


