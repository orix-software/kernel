
userzp                  := VARLNG

RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM := $78

NEXT_STACK_BANK := $0418

MOUSE_JOYSTICK_MANAGEMENT := $291 ; 12 bytes ?
i_o_counter     := $1A ; 1 byte
i_o_save        := $1B ; 3 bytes ?
TRANSITION_RS232:= $1E;  3 bytes

KEYBOARD_COUNTER:=$02A6 ; 4 bytes
VIA_UNKNOWN     :=$028F ; seems tobe a backup of timer  2 bytes

TELEMON_ID_BANK   		= $07
ATMOS_ID_BANK     		= $06
ORIX_ID_BANK      		= $05
MONITOR_ID_BANK   		= $04
TELEFORTH_ID_BANK     	= $03
ORIX_MEMORY_DRIVER_ADDRESS:=$400
SWITCH_TO_BANK_ID              :=     $040C
;NEXT_STACK_BANK:=$418
FIXME_PAGE0_0:=$25
ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY:=$411 ; .dsb 3

work_channel  :=$19     ; 1 byte
KBD_UNKNOWN   :=$271  ;FIXME

; ORIX_PATH_CURRENT:=$0525  ;FIXME
FUFTRV=$0100; working Buffer 


TELEMON_KEYBOARD_BUFFER_BEGIN    = $C5C4
TELEMON_KEYBOARD_BUFFER_END      = $C680  
TELEMON_ACIA_BUFFER_INPUT_BEGIN  = $C680
TELEMON_ACIA_BUFFER_INPUT_END    = $C800

TELEMON_ACIA_BUFFER_OUTPUT_BEGIN = $C800
TELEMON_ACIA_BUFFER_OUTPUT_END   = $CA00
  
TELEMON_PRINTER_BUFFER_BEGIN     = $CA00
TELEMON_PRINTER_BUFFER_END       = $D200

HISTORY_BUFFER_BEGIN             =  TELEMON_PRINTER_BUFFER_END+1
HISTORY_BUFFER_END               =  TELEMON_PRINTER_BUFFER_END+200

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

.bss
.org $4C7
FIXME_DUNNO
.res 1
STACK_BANK
.res SIZE_OF_STACK_BANK
READ_BYTE_FROM_OVERLAY_RAM
; this contains a routine length : 20 bytew
.res 20

.bss
.org $500

kernel_ch376_current_mode_fs:
    .res $00

kernel_end_of_variables_before_BUFNOM:
KERNEL_TMP_XEXEC:
    .res 1
.if  kernel_end_of_variables_before_BUFNOM > BUFNOM
  .error  "Error BUFNOM is written by kernel variables try to move some variables in orix.inc after BUFNOM or BUFEDT"
.endif    


.bss
.org BUFNOM
.res 14
kernel_malloc:
    .tag    kernel_malloc_struct

.ifdef WITH_DEBUG
kernel_debug:
    .tag   kernel_debug_struct
.endif


kernel_process:
    .tag    kernel_process_struct

    
kernel_end_of_variables_before_BUFEDT:    
.if     kernel_end_of_variables_before_BUFEDT > BUFEDT
  .error  "Error BUFEDT is written by kernel variables try to move some variables in orix.inc after $590"
.endif    

.bss
.org BUFEDT
.res 110

BASH_MAX_ARGS                      = 3       ;  Number of possible args in the command line


BASH_MAX_BUFEDT_LENGTH         = 110

ORIX_ARGV_NAME:
    .res    MAX_LENGTH_OF_FILES  ; name
ORIX_ARGV:
	.res    MAX_LENGTH_OF_FILES*BASH_MAX_ARGS
; used to check term
TEMP_ORIX_1:
    .res 1
ORIX_ARGC:
    .res 1
KERNEL_DRIVER_MEMORY:
    .res 128
;.proc kernel_memory_driver
;.include "functions/memory/memory_driver.asm"
;.endproc
;.res  end_read_command_from_bank_driver-begin_read_command_from_bank_driver



kernel_end_of_memory_for_kernel:

.out     .sprintf("kernel_end_of_memory_for_kernel  : %x", kernel_end_of_memory_for_kernel)

kernel_end_of_variables_after_BUFEDT:    
.if     kernel_end_of_variables_after_BUFEDT > $7FF
  .error  "Error start of execution program for binary ($800) is written by kernel variables try to move some variables in orix.inc before $800"
.endif    


