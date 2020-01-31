.define XVARS_KERNEL_PROCESS     0
.define XVARS_KERNEL_MALLOC      1
.define XVARS_KERNEL_CH376_MOUNT 2

.macro  BRK_KERNEL   value
        .byte $00,value
.endmacro

.define PATH_CURRENT_MAX_LEVEL                    4 ; Only in telemon 3.0 number of level, if we add more, we should have more RAM, if you need to set more level add bytes here : ptr_path_current_low and ptr_path_current_high
.define MAX_LENGTH_OF_FILES                       8+3+1+1 ;  We say 8 chars for file  and end of string 

MAX_LENGTH_OF_A_COMMAND = 9

.define MAX_LENGTH_OF_A_COMMAND       9

.define ORIX_MAX_PATH_LENGTH                      MAX_LENGTH_OF_FILES*PATH_CURRENT_MAX_LEVEL+PATH_CURRENT_MAX_LEVEL

.define KERNEL_MAX_PATH_LENGTH                    MAX_LENGTH_OF_FILES*PATH_CURRENT_MAX_LEVEL+1 ;	 

.define KERNEL_MAX_LENGTH_BUFEDT    ORIX_MAX_PATH_LENGTH+9

; command line
.define KERNEL_MAX_ARGS_COMMAND_LINE   2       ;  Number of possible args in the command line

; path define
; KERNEL_PATH_CURRENT_MAX_LEVEL : 
; * numbers of levels on filesystem /usr/share/ means 2 levels
; * It means that OS can't enter in directory folder :  /usr/share/folder/ if it's set to 2
; You can increase this number but when this number is increased, there is more memory consumed for many features
.define KERNEL_PATH_CURRENT_MAX_LEVEL  PATH_CURRENT_MAX_LEVEL  
.define KERNEL_MAX_LENGTH_OF_FILES     MAX_LENGTH_OF_FILES


KERNEL_XOPEN_PTR1 = $04 ; DECBIN
KERNEL_XOPEN_PTR2 = $06 ; DECFIN


