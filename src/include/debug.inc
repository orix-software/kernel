.define XDEBUG_CREATE_PROCESS_PRINT $00
.define XDEBUG_XFREE_ENTER_PRINT    $01
.define XDEBUG_GARBAGE_IN           $02
.define XDEBUG_GARBAGE_OUT          $03
.define XDEBUG_FOUND                $04
.define XDEBUG_FSEEK                $05
.define XDEBUG_FCLOSE               $06
.define XDEBUG_XOPEN_ENTER          $07
.define XDEBUG_XOPEN_ALLOCATE_FP    $08
.define XDEBUG_XCLOSE_FD_NOT_FOUND  $09


.define XDEBUG_FD                   $00
.define XDEBUG_ERROR_FP_REACH       $01
.define XDEBUG_FCLOSE_ENTER         $02
.define XDEBUG_KILL_PROCESS_ENTER   $03

.struct kernel_debug_struct
RA           .res 1
RY           .res 1
RX           .res 1
RES          .res 2
RESB         .res 2
TR0          .res 1
TR1          .res 1
TR2          .res 1
TR3          .res 1
TR4          .res 1
TR5          .res 1
TR6          .res 1
TR7          .res 1
DDRA         .res 1
PRA          .res 1
ID_PRIMITIVE .res 1
.endstruct
