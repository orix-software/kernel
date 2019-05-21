.macro  BRK_KERNEL   value
        .byte $00,value
.endmacro

KERNEL_MAX_ARGS_COMMAND_LINE                      = 3       ;  Number of possible args in the command line