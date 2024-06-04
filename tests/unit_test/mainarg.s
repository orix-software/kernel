; Code to test XMAINARGS

.include "telestrat.inc"
.include "../../dependencies/orix-sdk/macros/SDK_mainargs.mac"
.include "../../dependencies/orix-sdk/macros/SDK_print.mac"
.include "../../dependencies/orix-sdk/macros/SDK_conio.mac"

.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

.segment "CODE"
_main:

userzp := $80

start_adress:
    argv            := userzp     ; 2 bytes
    argc            := userzp + 2 ; 1 byte

    initmainargs argv, argc, 0

nop
    lda     argc
    cmp     #$03
    bne     @no_arg
nop
nop

nop

nop
    getmainarg #1, (argv)
    BRK_TELEMON XWSTR0
    crlf
nop
nop

nop

nop
    getmainarg #2, (argv)
    BRK_TELEMON XWSTR0
    crlf

    rts
nop
@no_arg:
    print str_there_not_two_arg
    lda     #$01
    ldy     #$00
    rts

str_there_not_two_arg:
    .asciiz "There is not 2 arg"


    lda         #$41