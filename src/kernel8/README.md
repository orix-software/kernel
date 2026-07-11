# How to add a new routine into bank8

* A is checked to switch to the function 

1) Declare id function in .inc KERNEL_LOAD_QWERTY_CHARSET (ex : src/include/memory.inc), the id must be greater than the previous id
2) Build your function, and store it in a folder and declare in the source file function  .segment "BANK8"

3) Add it in Makefile for example : @$(AS) --cpu 6502 -tnone src/functions/xloadcharset.asm -o tmp/xloadcharset.o
4) Add the check in src/kernel8.s :

Ex :
    cmp     #KERNEL_LOAD_QWERTY_CHARSET           ; $0C
    beq     @load_qwerty_charset_routine

5) add in Makefile .o in kernel_bank8.lib	 @$(AR) r tmp/kernel_bank8.lib xloadcharset.o

6) in kernel.asm, call it :

  lda     #KERNEL_LOAD_QWERTY_CHARSET
  jsr     XBANK_routine
