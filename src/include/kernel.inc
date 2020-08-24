.define XVARS_KERNEL_PROCESS     0
.define XVARS_KERNEL_MALLOC      1
.define XVARS_KERNEL_CH376_MOUNT 2
.define XVARS_KERNEL_CONF        3



.macro  BRK_KERNEL   value
        .byte $00,value
.endmacro

.define PATH_CURRENT_MAX_LEVEL                    4 ; Only in telemon 3.0 number of level, if we add more, we should have more RAM, if you need to set more level add bytes here : ptr_path_current_low and ptr_path_current_high
.define MAX_LENGTH_OF_FILES                       8+3+1+1 ;  We say 8 chars for file  and end of string 
.define KERNEL_MAX_LENGTH_OF_FILES                8+3+1+1 ;  We say 8 chars for file  and end of string 


.define ORIX_MAX_PATH_LENGTH                      MAX_LENGTH_OF_FILES*PATH_CURRENT_MAX_LEVEL+PATH_CURRENT_MAX_LEVEL

.define KERNEL_MAX_PATH_LENGTH                    9*PATH_CURRENT_MAX_LEVEL+MAX_LENGTH_OF_FILES ;	 

.out     .sprintf("KERNEL_MAX_PATH_LENGTH                                 : %s", .string(KERNEL_MAX_PATH_LENGTH))

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
.define KERNEL_NUMBER_BUFFER 4+6

TELEMON_KEYBOARD_BUFFER_BEGIN    = $C5C4
TELEMON_KEYBOARD_BUFFER_END      = $C680  
TELEMON_ACIA_BUFFER_INPUT_BEGIN  = $C680
TELEMON_ACIA_BUFFER_INPUT_END    = $C800

TELEMON_ACIA_BUFFER_OUTPUT_BEGIN = $C800
TELEMON_ACIA_BUFFER_OUTPUT_END   = $CA00
  
TELEMON_PRINTER_BUFFER_BEGIN     = $CA00
TELEMON_PRINTER_BUFFER_END       = $D200

;HISTORY_BUFFER_BEGIN             =  TELEMON_PRINTER_BUFFER_END+1
;HISTORY_BUFFER_END               =  TELEMON_PRINTER_BUFFER_END+200

KERNEL_CONF_BEGIN                :=  $D201
KERNEL_CONF_END                  :=  $D210


