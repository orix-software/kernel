.macro  BRK_KERNEL   value
        .byte $00,value
.endmacro


.define PATH_CURRENT_MAX_LEVEL  4 ; Only in telemon 3.0 number of level, if we add more, we should have to many RAM, if you need to set more level add bytes here : ptr_path_current_low and ptr_path_current_high
.define MAX_LENGTH_OF_FILES     9 ;  We say 8 chars for directory and end of string

MAX_LENGTH_OF_A_COMMAND = 9

ORIX_NUMBER_OF_MALLOC  = 3

ORIX_MALLOC_FREE_FRAGMENT_MAX = 6

ORIX_MALLOC_MAX_MEM_ADRESS = $B3FF

.define MAX_LENGTH_OF_A_COMMAND       9

.define ORIX_MAX_PATH_LENGTH MAX_LENGTH_OF_FILES*PATH_CURRENT_MAX_LEVEL+PATH_CURRENT_MAX_LEVEL

MAX_LENGTH_BUFEDT    =  ORIX_MAX_PATH_LENGTH+9

.define KERNEL_MAX_LENGTH_BUFEDT    ORIX_MAX_PATH_LENGTH+9

ORIX_MALLOC_FREE_TABLE_SIZE  = 3*ORIX_MALLOC_FREE_FRAGMENT_MAX
ORIX_MALLOC_BUSY_TABLE_SIZE  = 6*ORIX_NUMBER_OF_MALLOC

; command line
.define KERNEL_MAX_ARGS_COMMAND_LINE   2       ;  Number of possible args in the command line

; path define
; KERNEL_PATH_CURRENT_MAX_LEVEL : 
; * numbers of levels on filesystem /usr/share/ means 2 levels
; * It means that OS can't enter in directory folder :  /usr/share/folder/ if it's set to 2
; You can increase this number but when this number is increased, there is more memory consumed for many features
.define KERNEL_PATH_CURRENT_MAX_LEVEL  PATH_CURRENT_MAX_LEVEL  
.define KERNEL_MAX_LENGTH_OF_FILES     MAX_LENGTH_OF_FILES

