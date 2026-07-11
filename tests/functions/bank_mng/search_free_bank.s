; Code to test XMAINARGS

.include "telestrat.inc"
.include "../../../dependencies/orix-sdk/macros/SDK_mainargs.mac"
.include "../../../dependencies/orix-sdk/macros/SDK_print.mac"
.include "../../../dependencies/orix-sdk/macros/SDK_conio.mac"

.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

.segment "CODE"

_main:

.define KERNEL_RAM_BANK_APPLICATION_TYPE $01
.define KERNEL_ALLOCATE_BANK $01
.define KERNEL_FREE_BANK     $02

userzp := $80

tmp1 := userzp
tmp2 := userzp + 1
tmp3 := userzp + 2

start_adress:
    ; argv            := userzp     ; 2 bytes
    ; argc            := userzp + 2 ; 1 byte

    print str_bank_id_given
    lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    BRK_TELEMON $01 ; GET free bank
    sta     tmp1
    stx     tmp2
    sty     tmp3

    ldy     #00
    print_int  ,2, 2
    print str_set
    lda     tmp2 ; Load set
    ldy     #00
    print_int  ,2, 2
    print str_bank
    lda     tmp3 ; Load bank
    ldy     #00
    print_int  ,2, 2
    crlf

    ; Free
    print str_free_id
    lda     tmp1
    print_int  ,2, 2
    lda     #KERNEL_FREE_BANK   ; Mode
    ldx     tmp1 ; X the type of bank
    BRK_TELEMON $01 ; GET free bank
    crlf
    ;

    print str_bank_id_given
    lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    BRK_TELEMON $01 ; GET free bank
    sta     tmp1
    stx     tmp2 ; Set
    sty     tmp3

    ldy     #00
    print_int  ,2, 2
    print str_set
    lda     tmp2 ; Load set
    ldy     #00
    print_int  ,2, 2
    print str_bank
    lda     tmp3 ; Load bank
    ldy     #00
    print_int  ,2, 2
    crlf

    print str_bank_id_given
    lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    BRK_TELEMON $01 ; GET free bank
    sta     tmp1
    stx     tmp2
    sty     tmp3

    ldy     #00
    print_int  ,2, 2
    print str_set
    lda     tmp2 ; Load set
    ldy     #00
    print_int  ,2, 2
    print str_bank
    lda     tmp3 ; Load bank
    ldy     #00
    print_int  ,2, 2
    crlf

    print str_bank_id_given
    lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    BRK_TELEMON $01 ; GET free bank
    sta     tmp1
    stx     tmp2
    sty     tmp3

    ldy     #00
    print_int  ,2, 2
    print str_set
    lda     tmp2 ; Load set
    ldy     #00
    print_int  ,2, 2
    print str_bank
    lda     tmp3 ; Load bank
    ldy     #00
    print_int  ,2, 2
    crlf

    ;initmainargs argv, argc, 0
    rts

    ; appel de la lib curl

    ; brk XEXECLIB, #curl_exec, id_bank

    ; Macro :

    ; XEXECLIB #curl_exec, bank.
    ; Ce qui donnerait :
    ; pha
    ; lda bank
    ; sta bank_lib ; Offset
    ; lda func
    ; sta func_id ; Offset
    ; pla
    ; brk_kernel xexec lib
    
    ; Initialisation d'une banque pour charger une lib curl: 

    ; lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ; ldx     #KERNEL_RAM_BANK_LIB_TYPE ; X the type of bank
    ; BRK_TELEMON $01 ; GET free bank

    ; lda     #KERNEL_LOAD_LIB
    ; ldx     #<libcurl_so
    ; ldy     #>libcurl_so
    ; BRK_TELEMON $01
    ; ; Relocation de la lib
    ; referencement de la lib

    ; rts
    ;libcurl_so:
    ; .asciiz "/lib/2024.1/libcurl.so"
    ; 



;     lda     argc
;     cmp     #$03
;     bne     @no_arg

;     getmainarg #1, (argv)
;     BRK_TELEMON XWSTR0
;     crlf

;     getmainarg #2, (argv)
;     BRK_TELEMON XWSTR0
;     crlf

;     rts

; @no_arg:
;     print str_there_not_two_arg
;     lda     #$01
;     ldy     #$00
;     rts

str_there_not_two_arg:
    .asciiz "There is not 2 arg"

str_bank_id_given:
    .asciiz "Allocate bank id : "

str_free_id:
    .asciiz "Free bank id : "

str_set:
    .asciiz " Set :"

str_bank:
    .asciiz " bank :"