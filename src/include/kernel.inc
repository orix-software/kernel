.define XVARS_KERNEL_PROCESS              0
.define XVARS_KERNEL_MALLOC               1
.define XVARS_KERNEL_CH376_MOUNT                         2
.define XVARS_KERNEL_CONF                                3
.define XVARS_KERNEL_ERRNO                               4
.define XVARS_KERNEL_BINARY_VERSION                      6 ; used in untar version
.define XVARS_KERNEL_MAX_PROCESS                         8
.define KERNEL_XVARS_MAX_NUMBER_OF_MALLOC_AND_FREE_CHUNK $05
.define KERNEL_XVARS_CURRENT_VERSION_BINARY              $06
.define KERNEL_XVARS_KERNEL_MAX_PROCESS                  $08
.define KERNEL_XVARS_PID_LIST_PTR                        $0A

.define KERNEL_XVALUES_FREE_MALLOC_TABLE                            $02
.define KERNEL_XVALUES_BUSY_MALLOC_TABLE                            $07
.define KERNEL_XVALUES_GET_CURRENT_PROCESSNAME_FROM_PID             $08
.define KERNEL_XVALUES_PATH_FROM_FD                                 $09
.define KERNEL_XVALUES_GET_FTELL_FROM_FD                            $0A
.define KERNEL_XVALUES_GET_PROCESS_TREE                             $0B
.define KERNEL_XVALUES_GET_PROCESS_ID_LIST                          $0C
.define KERNEL_XVALUES_GET_PROCESS_NAME_WITH_PID                    $0D
.define KERNEL_XVALUES_GET_OSNAME                                   $0E
.define KERNEL_XVALUES_GET_TIME                                     $0F
.define KERNEL_XVALUES_GET_FREE_BANK                                $10
.define KERNEL_XVALUES_GET_FILESIZE                                 $11

; Returns the string of the opened file of the current process
;.define KERNEL_XVALUES_GET_PROCESS_ID                       $0A

.macro  BRK_KERNEL   value
        .byte $00,value
.endmacro

.define PATH_CURRENT_MAX_LEVEL                    4 ; Only in telemon 3.0 number of level, if we add more, we should have more RAM, if you need to set more level add bytes here : ptr_path_current_low and ptr_path_current_high
.define MAX_LENGTH_OF_FILES                       8+3+1+1 ;  We say 8 chars for file  and end of string
.define KERNEL_MAX_LENGTH_OF_FILES                8+3+1+1 ;  We say 8 chars for file  and end of string

.define ORIX_MAX_PATH_LENGTH                      MAX_LENGTH_OF_FILES*PATH_CURRENT_MAX_LEVEL+PATH_CURRENT_MAX_LEVEL

.define KERNEL_MAX_PATH_LENGTH                    9*PATH_CURRENT_MAX_LEVEL+MAX_LENGTH_OF_FILES ;




.define KERNEL_MAX_LENGTH_BUFEDT    ORIX_MAX_PATH_LENGTH+9

; command line
.define KERNEL_MAX_ARGS_COMMAND_LINE   6       ;  Number of possible args in the command line

; path define
; KERNEL_PATH_CURRENT_MAX_LEVEL :
; * numbers of levels on filesystem /usr/share/ means 2 levels
; * It means that OS can't enter in directory folder :  /usr/share/folder/ if it's set to 2
; You can increase this number but when this number is increased, there is more memory consumed for many features
;.define KERNEL_PATH_CURRENT_MAX_LEVEL  PATH_CURRENT_MAX_LEVEL

; 4 systems Buffers 6 for user (telemon historical)
.define KERNEL_NUMBER_BUFFER 4 + 6

KERNEL_FORK_PROCESS              = 0
KERNEL_NOFORK_PROCESS            = 1 ; Performs an EXEC like unix/linux, it destroy memory from current process

ADDRESS_READ_BETWEEN_BANK_DOUBLON      := $32
BNKCIB_DOUBLON                         := $34
RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM := $78

BASH_MAX_ARGS                           = 3       ;  Number of possible args in the command line
BASH_MAX_BUFEDT_LENGTH                  = 110
userzp                                 := VARLNG
NEXT_STACK_BANK                        := $0418
MOUSE_JOYSTICK_MANAGEMENT              := $291 ; 12 bytes ?
i_o_counter                            := $1A ; 1 byte
i_o_save                               := $1B ; 3 bytes ?
TRANSITION_RS232                       := $1E;  3 bytes
FILESYS_BANK                           := $20C
KEYBOARD_COUNTER                       := $02A6 ; 4 bytes
VIA_UNKNOWN                            := $028F ; seems tobe a backup of timer  2 bytes
ORIX_MEMORY_DRIVER_ADDRESS             := $400
SWITCH_TO_BANK_ID                      := $040C
;NEXT_STACK_BANK:=$418
FIXME_PAGE0_0                          := $25
ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY:= $411 ; .dsb 3

KERNEL_XOPEN_PTR1                      := $04 ; DECBIN

work_channel                           := $19     ; 1 byte
KBD_UNKNOWN                            := $271  ;FIXME

FUFTRV                                 = $0100; working Buffer

NULL = 0
;BUFROU                                 := $C500 ; Routines for buffers gestion

SIZE_OF_STACK_BANK = 3

BNKOLD:=$40F

ADDRESS_READ_BETWEEN_BANK := $15
ADDRESS_VECTOR_FOR_ADIOB  := $17
BNK_TO_SWITCH             := $410


RES5                       := $0A

;RESC                       := DECDEB  ; $04
;RESD                       := DECFIN  ; $06
;RESE                       := DECCIB  ;
;RESF                       := DECTRV  ;
;RESG                       := ACCPS   ;
;RESH                       := ACC1E

;KERNEL_XOPEN_PTR1          := $04 ; DECBIN
KERNEL_XOPEN_PTR2          := $06 ; DECFIN

KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_Y := $51 ; DECBIN
KERNEL_XWRITE_XCLOSE_XFSEEK_XFREAD_SAVE_X := $52 ; DECBIN

KERNEL_XFSEEK_SAVE_RES  := $06; DECBIN
KERNEL_XFSEEK_SAVE_RESB := $4D ; DECBIN
;KERNEL_XOPEN_PTR2          := $06 ; DECFIN


KERNEL_CREATE_PROCESS_PTR1 := ACC1E ; $60 & $61
XOPEN_RES                := $4D ; Also HRS1 2 bytes
XOPEN_RESB               := $4F ; Also HRS2 2 bytes
XOPEN_RES_SAVE           := $51 ; Also HRS3 2 bytes
XOPEN_RESB_SAVE          := $53 ; Also HRS4 2 bytes
XOPEN_SAVEY              := $55 ; Also HRS4 2 bytes
XOPEN_SAVEA              := $56 ; Also HRS4 2 bytes
XOPEN_FLAGS              := $57 ; also HRSFB 1 byte
TELEMON_UNKNWON_LABEL_62 := $62
TELEMON_UNKNWON_LABEL_70 := $70
TELEMON_UNKNWON_LABEL_71 := $71
TELEMON_UNKNWON_LABEL_72 := $72
TELEMON_UNKNWON_LABEL_7F := $7F
TELEMON_UNKNWON_LABEL_86 := $86
FLPOLP                   := $85
FLPO0                    := $87

.macro addsym symbole
  .out .sprintf("%s = $%x", .string(symbole), symbole)
.endmacro


.ifdef DISPLAY_INFO
        .out     .sprintf("KERNEL_MAX_PATH_LENGTH                                   : %s bytes ", .string(KERNEL_MAX_PATH_LENGTH))
.endif


.define KERNEL_SIZE_IOTAB $04

XMALLOC_ROUTINE_TO_RAM_OVERLAY = 39
ADIODB_LENGTH = $08


.macro  STZ_ABS    arg             ; Define macro ldax
  lda     #$00
  sta     arg
.endmacro

.macro  STZ_ABS_X    arg           ; Define macro ldax
  lda     #$00
  sta     arg,x
.endmacro

.macro  INCA
  clc
  adc     #$01
.endmacro


