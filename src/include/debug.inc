.define XDEBUG_CREATE_PROCESS_PRINT $00
.define XDEBUG_XFREE_ENTER_PRINT    $01
.define XDEBUG_GARBAGE_IN           $02
.define XDEBUG_GARBAGE_OUT          $03
.define XDEBUG_FOUND                $04
.define XDEBUG_FSEEK                $05
.define XDEBUG_FCLOSE               $06

.define XDEBUG_XOPEN_ALLOCATE_FP    $08
.define XDEBUG_XCLOSE_FD_NOT_FOUND  $09
.define XDEBUG_XCLOSE_FD_FOUND      $0A
.define XDEBUG_XOPEN_FILE_NOT_FOUND $0B
.define XDEBUG_XFORK_TRYING_DEVICE  $0C
.define XDEBUG_XFORK_STARTING       $0D
.define XDEBUG_UNKNOWN              $0E
.define XDEBUG_TYPE                 $0F
.define XDEBUG_TYPE_MAINARGS        $10
.define XDEBUG_TYPE_PROCESSSTRUCT   $11
.define XDEBUG_TYPE_FPSTRUCT        $12


.define XDEBUG_XMALLOC_ENTER_AY     $02


.define XDEBUG_XEXEC_ENTER          $00
.define XDEBUG_XOPEN_ENTER          $01

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
BNKCIB       .res 1
BNKOLD       .res 1
VEXBNK       .res 2
FIXME_DUNNO  .res 1
.endstruct


