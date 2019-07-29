.FEATURE labels_without_colons, pc_assignment, loose_char_term, c_comments

.include   "telestrat.inc"          ; from cc65
.include   "fcntl.inc"              ; from cc65
.include   "stdio.inc"              ; from cc65
.include   "errno.inc"              ; from cc65
.include   "cpu.mac"                ; from cc65
.include   "libs/ch376-lib/include/ch376.inc"
.include   "include/kernel.inc"
.include   "include/process.inc"
.include   "include/memory.inc"
.include   "orix.mac"
.include   "orix.inc"
.include   "build.inc"

TELEMON_UNKNWON_LABEL_62:= $62
TELEMON_UNKNWON_LABEL_72:= $72
TELEMON_UNKNWON_LABEL_7F:= $7F
TELEMON_UNKNWON_LABEL_86:= $86



FLPOLP := $85
FLPO0  := $87



PARSE_VECTOR:=$fff1

ACIADR := $031C ; DATA REGISTER
ACIASR := $031D ; STATUS REGISTER
ACIACR := $031E ; command register
ACIACT := $031F ; control register


.org      $C000
.code
start_rom:
  sei
  CLD
  ldx     #$FF
  TXS                         ; init stack
.IFPC02
.pc02
  stz     NEXT_STACK_BANK
.p02  
.else  
  inx
  stx     NEXT_STACK_BANK               ; Store in BNKCIB ?? ok but already init with label data_adress_418, when loading_vectors_telemon is executed
.endif

  lda     #$07 ; Kernel bank
  sta     RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM

  jsr     init_screens
  jsr     init_via
  jsr     XLOADCHARSET_ROUTINE
  jsr     init_printer 
  jsr     XALLKB_ROUTINE
 

  ldx     #$0F
@loop:
  lsr     IOTAB0,X ; init channels (0 to 3)
  DEX
  bpl     @loop

  lda     IRQVECTOR ; testing if IRQVECTOR low byte is $4C ?
  cmp     #$4C
  bne     @L1 ; non equal to $4C
  lda     KBDCOL+5
  and     #$20
  bne     @L1
@L1:

next1:
  ldx     #$2F
@loop:
  lda     adress_of_adiodb_vector,X
  sta     ADIOB,X 
  DEX
  bpl     @loop

set_todefine6:
  ldx     #$04
@loop:
  lda     data_to_define_6,X 
  sta     CSRND,X
  DEX
  bpl     @loop

  ldx     #$00

loading_vectors_telemon:
; This routine fills some memory with some code
; notice that $700 is fill but could be used for others things, because $700 will be in RAM overlay 
; This means that $700 could be erase. $600 should be deleted too (how many bytes ?), because some parts are used to read banks
@loop:
  lda     loading_vectors_page_4,X    ; X should be equal to 0
  sta     ORIX_MEMORY_DRIVER_ADDRESS,X
  lda     loading_code_to_page_6,X 
  sta     $0600,X
  lda     data_to_define_4,X 
  sta     $0700,X                     ; used to copy in Overlay RAM ... see  loop40 label
  inx                                 ; loop until 256 bytes are filled
  bne     @loop

; Just fill ram with BUFROU
  jsr     $0600
 
compute_rom_ram:
; this code sets buffers
  lda     #$00   ; Start from 0

@loop:
  pha
  tax     ; first loop X=0, it means that XDEFBU_ROUTINE call will set the first buffer in overlayram

  jsr     XDEFBU_ROUTINE 

  pla
  clc
  adc     #$0C
  cmp     #$30
  bne     @loop
 
  jsr     XDEFBU_ROUTINE 
skip:
  lda     #$00                        ; INIT VALUE of the rom to 0 bytes
  sta     KOROM

  lda     #$40                        ; INIT VALUE of the RAM to 64 KBytes
  sta     KORAM
 
  lda     #$00; value in bytes
  sta     MEMTOTAL
  sta     MEMTOTAL+1
  sta     MEMTOTAL+3
  lda     #$01 ; 64 KB
  sta     MEMTOTAL+2

.ifdef TWILIGHTE_CARD_V04
  lda     #$40
.else
  lda     #$40-16                     ; store 48 Kbytes for roms
.endif  
  sta     KOROM

  ldx     #$0B                            ; copy to $2F4 12 bytes
@loop:
  lda     data_vectors_VNMI_IRQVECTOR_VAPLIC,X ; SETUP VNMI, IRQVECTOR, VAPLIC
  sta     VNMI,X ; 
  DEX
  bpl     @loop

  jsr     init_keyboard

next5:

  lda     KBDCOL+4 ; 
  and     #$90
  beq     @skip
  lda     FLGTEL
  ora     #$40
  sta     FLGTEL
@skip:

  
.ifdef WITH_ACIA  
  jsr     init_rs232 ; $DB54 
.endif  
  lda     #XKBD ; Setup keyboard on channel 0
  BRK_TELEMON XOP0
  
  lda     #XSCR ; Setup screen !  on channel 0
  BRK_TELEMON XOP0 

  BRK_TELEMON XRECLK  ; Don't know this vector
  
  bit     FLGRST ; COLD RESET ?
  bpl     telemon_hot_reset  ; no
  
  ; display telestrat at the first line
  PRINT str_telestrat

  ; it's similar to lda #10 brk xwr0 lda #13 brk XWR0
  RETURN_LINE
  ; fetch KORAM and display
  lda     KORAM
  jsr     telemon_convert_to_decimal ; convert in decimal accumulator A
  ; display KORAM
  PRINT str_KORAM


  lda     KOROM
  jsr     telemon_convert_to_decimal
  PRINT str_KOROM


telemon_hot_reset
  nop ; keep theses nops, because hot reset won't work (still don't know why)

don_t_display_telemon_signature:
  lda     #<str_tofix
  ldy     #>str_tofix
  BRK_TELEMON XWSTR0

  ;JSR $0600 ; CORRECTME
    
don_t_display_signature:
  jsr     routine_to_define_19

  
display_cursor:

  ldx     #$00
  BRK_TELEMON XCSSCR ; display cursors

  lda     #<str_binary_to_start
  sta     RES
  lda     #>str_binary_to_start
  sta     RES+1
  ; copy to BUFEDT
  ldy     #$00
@L1:  
  lda     (RES),y
  beq     @S1
  sta     BUFEDT,y
  iny
  bne     @L1
@S1:
  sta     BUFEDT,y 
  lda     #<BUFEDT
  ldy     #>BUFEDT


  jmp     _XEXEC ; start shell
   
  

call_routine_in_another_bank  
  sta     $0415 ; BNK_ADDRESS_TO_JUMP_LOW
  sty     $0416 ; BNK_ADDRESS_TO_JUMP_HIGH
  stx     BNKCIB
  jmp     SWITCH_TO_BANK_ID

routine_to_define_19:
  CLI
.ifdef WITH_TWILIGHTE_BOARD
.else  
  lda     #$02
  sta     TIMEUD
@loop:
  lda     TIMEUD
  bne     @loop
.endif
  
  ldx     #$0C
  BRK_TELEMON XVIDBU              ; Flush buffers

.ifdef WITH_ACIA
  lda     ACIACR
  and     #$F3
  ora     #$08
  sta     ACIACR
.endif

  rts
str_binary_to_start:
  .asciiz "sh"

telemon_convert_to_decimal:
; FIXME macro
  ldy     #$00 ; 00
  ldx     #$20 ;
  stx     DEFAFF
  ldx     #$01
  jmp     XDECIM_ROUTINE 

init_via:
  lda     #$7F 
  sta     VIA::IER ; Initialize via1
  sta     VIA2::IER ; Initialize via2
  
.ifdef WITH_ACIA
  sta     ACIASR ; Init ACIA
.endif

  lda     #$FF
  sta     VIA::DDRA
  
  lda     #$F7
  sta     VIA::PRB
  sta     VIA::DDRB

.ifdef WITH_32BANKS
  lda     #%00000111 ; Switch to bank7
  sta     VIA2::PRA
  lda     #%00011111 ; But manage 31 banks
  sta     VIA2::DDRA
.else
  lda     #$17 ; 0001 0111
  sta     VIA2::PRA
  sta     VIA2::DDRA
.endif

  lda     #$E0 ; %1110 0000
  sta     VIA2::PRB
  sta     VIA2::DDRB

  lda     #$CC
  sta     VIA::PCR
  sta     VIA2::PCR

  rts

loading_code_to_page_6:
  lda     #$00 ; 2 bytes
  sta     VIA2::PRA ; 3 bytes ; switch to overlay ram ?

  lda     #$00
  tax
@loop:
  lda     $0700,X
  sta     BUFROU,X ; store data in c500 
  inx
  bne     @loop ; copy 256 bytes to BUFROU in OVERLAY RAM
 

  ldx     #$07 ; loops with all banks
  stx     VIA2::PRA ; Switch to each Bank ;
  rts


data_vectors_VNMI_IRQVECTOR_VAPLIC:
  ; 12 bytes
  .byt    $07,<str_telestrat,>str_telestrat ; VAPLIC vectors : bank + address ? useless
;$2f7  
  .byt    $4c,$00,$00 ; ADIOB vector
IRQVECTOR_CODE:
  jmp     $0406 ; stored in $2FA (IRQVECTOR) 
  .byt    $80 ; will be stored in $2fd
  .byt    $00 ; will be stored in $2fE
  .byt    $00 ; will be stored in $2FF


; **************************** END LOOP ON DEVELOPPR NAME !*/

str_telestrat:  
  .byte     $0c,$97,$96,$95,$94,$93,$92,$91,$90," ORIX 1.0",$90,$91,$92,$93,$94,$95,$96,$97,$90
.IFPC02
.pc02
  .byte     "  CPU : 65C02"
.p02  
.else
  .byte     "    CPU : 6502"
.endif
  .byt     $00 ; end of string
  
  
  
str_KORAM:
  .ASCIIZ  " Ko RAM,"

str_KOROM:
  .byt     " Ko ROM"," - "
  .byt    __DATE__
  .byt      $00

str_tofix:
  .byt     $0D,$18,$00

data_to_define_6:
  ; FIVE Bbytes to load in CSRND
  .byt     $80,$4F,$C7,$52,$58

  
XDEFBU_ROUTINE:
  stx     RESB ; store the id of the buffer to set
  txa     ; save A
  ldx     #$FF 
@loop:
  sec
  sbc     #$03 ; let's loop to get the right buffer table 
  inx
  bcs     @loop

  lda     orix_buffer_table,X 
  sta     RES
  lda     orix_buffer_table+1,X ; Get high adress of the buffer
  sta     RES+1
  
  lda     end_keyboard_buffer,X
  ldy     end_keyboard_buffer+1,X 

  ldx     RESB

XINIBU_ROUTINE:
  bit     XLISBU_ROUTINE
  BVC     skip2003

XVIDBU_ROUTINE: 
  lda     #$00
  .byt    $2c
XTSTBU_ROUTINE: 
  lda     #$01
  bit     code_adress_400

skip2003:
  sec
  
  jmp     ORIX_MEMORY_DRIVER_ADDRESS+9
XLISBU_ROUTINE:
  bit     XLISBU_ROUTINE
  BVC     skipme2002
XECRBU_ROUTINE: 
  bit     loading_vectors_page_4
skipme2002:
  clc
  jmp     ORIX_MEMORY_DRIVER_ADDRESS+9

;*********************************************************************************  
; CODE INSERTED IN PAGE 4  
;*********************************************************************************  

loading_vectors_page_4:
code_adress_400:
  jmp     $0493 ;code_adress_493
code_adress_403:
  jmp     $04A1 ;code_adress_4A1
code_adress_406:  
  jmp     $047E ; see code_adress_47E
code_adress_409:  
  jmp     $0419 ; see code_adress_419  
code_adress_40c:
  jmp     $0436 ; 436 see  code_adress_436
code_adress_40f:
  .byt    $00 ; init old bank to 0
; 410  
  .byt    $00 ; used for  bank switching
; 411
; VECTOR to read byte in overlay ram
  jmp     $04AF
; 414  
  .byt    $4c,$00,$00
data_adress_417:   
  .byt    $00 ; Init BNKCIB with 0
data_adress_418:
  .byt    $00 ; init also 418 but it already initialized !

; This routines is used to read buffers in RAM overlay
code_adress_419:  
  php
  sei
  pha
  lda     VIA2::PRA
  and     #%11111000 ; switch to OVERLAY RAM
  sta     VIA2::PRA
  pla
  jsr     BUFROU     ; Read buffer
  tay            ; A contains the value read in the buffer, backup it
  lda     VIA2::PRA
  ora     #$07
  sta     VIA2::PRA
  ROR
  PLP
  asl 
  tya
  rts

code_adress_436:
  php
  sei
  pha
  txa
  pha
  
  lda     VIA2::PRA
  ldx     NEXT_STACK_BANK
  
  sta     STACK_BANK,X ; FIXME
  inc     NEXT_STACK_BANK   ; FIXME
  pla
  tax
  lda     BNKCIB
  jsr     $046A ; see code_adress_46A  
 
  pla
  PLP
  jsr     VEXBNK

  php
  sei
  pha
  txa
  pha
  dec     NEXT_STACK_BANK
  ldx     NEXT_STACK_BANK
  lda     STACK_BANK,X
  jsr     $046A ; FIXME
  pla
  tax
  pla
  PLP
  rts	

code_adress_46A:
  php
  sei
  and     #$07
  sta     FIXME_DUNNO
  lda     VIA2::PRA
  and     #$F8
  ora     FIXME_DUNNO
  sta     VIA2::PRA
  PLP
  rts
code_adress_47E:  ; brk gestion 
  sta     IRQSVA
  lda     VIA2::PRA
  and     #$07      
  sta     BNKOLD ; store old bank before interrupt ?
  lda     VIA2::PRA  ; Switch to telemon bank and jump
  ora     #$07
  sta     VIA2::PRA
  jmp     brk_management   
code_adress_493
  lda     VIA2::PRA
  and     #$F8
  ora     BNKOLD
  sta     VIA2::PRA
  lda     IRQSVA
  RTI
code_adress_4A1
  pha
  lda     VIA2::PRA
  and     #$F8
  ora     BNK_TO_SWITCH
  sta     VIA2::PRA
  pla
  rts

  
; this routine read a value in a bank
; 
code_adress_4AF  
  lda     VIA2::PRA
.ifdef EXTEND_TO_31_BANK
  and     #%11100000
.else
  and     #%11111000                     ; switch to RAM overlay
.endif
  ora     BNK_TO_SWITCH                  ; but select a bank in BNK_TO_SWITCH
  sta     VIA2::PRA
  lda     (ADDRESS_READ_BETWEEN_BANK),Y  ; Read byte
  pha                                 
  lda     VIA2::PRA
  ora     #%00000111                     ; Return to telemon
  sta     VIA2::PRA
  pla                                    ; Get the value
  rts
  nop
  nop
  ; Stack used to switch from any bank
code_adress_get
; used in bank command in Oric

  lda     VIA2::PRA
.ifdef EXTEND_TO_31_BANK
  and     #%11100000
.else
  and     #%11111000                     ; switch to RAM overlay
.endif
; switch to RAM overlay
  ora     tmp1                           ; but select a bank in $410
  sta     VIA2::PRA
  lda     (ptr1),Y                       ; Read byte
  pha   
  lda     RETURN_BANK_READ_BYTE_FROM_OVERLAY_RAM
  sta     VIA2::PRA
  pla                                ; Get the value
  rts
RETURN_BANK:
  .res    1
end_of_copy_page4:
; THIS ROUTINE IS COPIED IN $700 and will be in overlay RAM
data_to_define_4  
  ; should be length 256 bytes ?
  bcc     LC639  
  bvc     LC5FE  
  tay

  beq     LC61E
  lda     BUFBUF+8,x ; $c088
  ora     BUFBUF+9,x
  beq     @skip  
  clc 
  rts
@skip:
  sec
  rts
LC5FE:  
  sta     RESB
  
  sty     RESB+1
  
  sec
  sbc     RES
  sta     BUFBUF+$0A,x
  tya
  sbc     RES+1
  sta     BUFBUF+$0B,x
  
  txa
  adc     #$03
  tax
  ldy     #$03

@loop:
  lda     $0000,y ; FIXME
  sta     $c07f,x ; FIXME
  dex
  dey
  bpl     @loop

LC61E  
  lda     #$00
  ; see page 4 of "Manuel Developpeur Telestrat"
  sta     BUFBUF+8,x ; get length low
  sta     BUFBUF+9,x ; get length high
  lda     BUFBUF+2,x 
  sta     BUFBUF+4,x 
  sta     BUFBUF+6,x 
  lda     BUFBUF+3,x 
  sta     BUFBUF+5,x 
  sta     BUFBUF+7,x 
  rts

  
LC639:
  bvs     LC661 
  jsr     $c507 ; FIXME
  bcs     LC660 
  lda     BUFBUF+6,x 
  ldy     BUFBUF+7,x 
  jsr     $c5a6 ; FIXME
  sta     BUFBUF+6,x 
  tya
  sta     BUFBUF+7,x 
  lda     BUFBUF+8,x

  bne     @skip
  dec     BUFBUF+9,x
@skip:

  dec     BUFBUF+8,x
  ; 65C02 FIXME
.IFPC02
.pc02
  lda     (IRQSVP)
.p02  
.else  
  ldy     #$00
  lda     (IRQSVP),y
.endif  
  clc
LC660  
  rts
  
LC661
  pha
  lda     BUFBUF+8,X 
  cmp     BUFBUF+$0A,X
  lda     BUFBUF+9,X 
  sbc     BUFBUF+$0B,X
  bcs     LC68F 
  lda     BUFBUF+4,X
  ldy     BUFBUF+5,X
  jsr     $C5A6  ; FIXME
  sta     BUFBUF+4,X 
  tya
  sta     BUFBUF+5,X 
  inc     BUFBUF+8,X 
  bne     LC688
  inc     BUFBUF+9,X 
LC688:  
  ; 65C02 FIXME : use sta (XX)
  ldy #$00
  pla
  sta (IRQSVP),Y
  clc
  rts
LC68F:
  pla
  rts
LC691:
  ; fixme 65c02 : use "inc a"
  clc
  adc     #$01
  bcc     LC697 
  iny
LC697: 
  cmp     BUFBUF+2,x ; FIXME
  
  sta     IRQSVP ; FIXME

routine_to_define_16
  tya
  sbc     BUFBUF+3,X 
  bcc     next36 
  lda     BUFBUF,X 
  ldy     BUFBUF+1,X
  sta     IRQSVP
next36
  sty     FIXME_PAGE0_0 ; FIXME
  lda     IRQSVP
  rts

  
orix_buffer_table  
  .byt    <TELEMON_KEYBOARD_BUFFER_BEGIN,>TELEMON_KEYBOARD_BUFFER_BEGIN        ; Keyboard buffer begin $c5c4
end_keyboard_buffer  
  .byt    <TELEMON_KEYBOARD_BUFFER_END,>TELEMON_KEYBOARD_BUFFER_END            ; keyboard buffer end $c680
  .byt    <TELEMON_ACIA_BUFFER_INPUT_BEGIN,>TELEMON_ACIA_BUFFER_INPUT_BEGIN    ; buffer acia input begin
  .byt    <TELEMON_ACIA_BUFFER_INPUT_END,>TELEMON_ACIA_BUFFER_INPUT_END        ; buffer acia input end
  .byt    <TELEMON_ACIA_BUFFER_OUTPUT_BEGIN,>TELEMON_ACIA_BUFFER_OUTPUT_BEGIN  ; buffer acia output begin
  .byt    <TELEMON_ACIA_BUFFER_OUTPUT_END,>TELEMON_ACIA_BUFFER_OUTPUT_END      ; buffer acia output end
  .byt    <TELEMON_PRINTER_BUFFER_BEGIN,>TELEMON_PRINTER_BUFFER_BEGIN          ; buffer printer output begin
  .byt    <TELEMON_PRINTER_BUFFER_END,>TELEMON_PRINTER_BUFFER_END              ; buffer printer output end

.include  "functions/xcrlf.asm"
.include  "functions/XWRx.asm"
.include  "functions/XWSTRx.asm"
.include  "functions/XRDW.asm"
.include  "functions/XWRD.asm"  
.include  "functions/xmalloc.asm"
.include  "functions/XOP.asm"
.include  "functions/XCL.asm"
.include  "functions/zadcha.asm"
.include  "functions/xecrpr.asm"
.include  "functions/xdecay.asm"
.include  "functions/xinteg.asm"

send_command_A:
  sty     ADDRESS_VECTOR_FOR_ADIOB
  sty     ADDRESS_VECTOR_FOR_ADIOB+1 
  pha
  txa
  asl
  tax
  lda     ADIOB,X
  sta     ADIODB_VECTOR+1
  lda     ADIOB+1,X
  sta     ADIODB_VECTOR+2
  pla
  lsr     ADDRESS_VECTOR_FOR_ADIOB
  bit     ADDRESS_VECTOR_FOR_ADIOB+1
  jmp     ADIODB_VECTOR

; These bytes are set in  ADIOB (page 2)
adress_of_adiodb_vector:
  ; length must be $30 (48)
  ; used to set I/O vectors
  ; 0
  .byt     <manage_I_O_keyboard,>manage_I_O_keyboard ; 0
  ; 1 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  ; 2 
  .byt     <LDAF7,>LDAF7                             ; MINITEL (mde) 
  ; 3
  .byt     <LDB5D,>LDB5D                             ; RSE 
  ; 4
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ;  not used  
  ; 5
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  ; 6
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  ; 7
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING; not used 
  ; 8
  .byt     <output_window0,>output_window0
  .byt     <output_window1,>output_window1
  .byt     <output_window2,>output_window2
  .byt     <output_window3,>output_window3
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING 
  .byt     <Lda70,>Lda70 ;30
  .byt     <Ldb12,>Ldb12
  .byt     <LDB79,>LDB79 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 

  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  .byt     <ROUTINE_I_O_NOTHING,>ROUTINE_I_O_NOTHING ; not used 
  
brk_management:
  ; management of BRK $XX
  ; on the stack we have 
  ; SP = P register
  ; SP-1 = PC+2 adress of brk sent
  ; SP-2 = PC+1
.IFPC02
.pc02
  phx
  phy
.p02  
.else
  stx     IRQSVX ; save register X
  sty     IRQSVY ; save register 
.endif
  pla ; pull P (flag register)
  sta     IRQSVP ; save P (flag register)
  and     #%00010000 ; test B flag B flag means an that we reach a brk commands
  beq     next200 ; is it a break ?
  TSX     ; yes we get Stack pointer
  pla     ; we pull pointer program +2 

  bne     @skip
  dec     BUFTRV+2,X ; CORRECTME
@skip:
reset115_labels:
  sec
  sbc     #$01
  pha
  sta     ADDRESS_READ_BETWEEN_BANK
  lda     BUFTRV+2,X
  sta     ADDRESS_READ_BETWEEN_BANK+1
  lda     BNKOLD
  sta     BNK_TO_SWITCH
  ldy     #$00
  jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
  asl
  tax
  lda     #$04
  pha
  lda     #$02
  pha
  lda     vectors_telemon+1,X ; fetch vector of brk
  ldy     vectors_telemon,X 
 
  bcc     @skip
  lda     vectors_telemon_second_table+1,X ; Second table because X >127 
  ldy     vectors_telemon_second_table,X ;
@skip:

  ; push A and Y vector : when RTI is reached, the stack contains the vector to execute
  pha
  tya
  pha 
  lda     IRQSVP  ; fetch P flag
  pha ; push P flag to return in correct state
  lda     IRQSVA

.IFPC02
.pc02
  ply
  plx
.p02
.else  
  ldy     IRQSVY
  ldx     IRQSVX
.endif
  RTI
next200
  lda     IRQSVP ; fetch P flag
  pha ; push P flag to return in correct state
LC8B6    
  sec
  ror     TRANSITION_RS232
LC8B9
  jsr     routine_to_define_12
.ifdef    WITH_MULTITASKING
  jsr     _multitasking
.endif
  jmp     LC9b9  


; routine BRK ?
routine_to_define_12:
.ifdef WITH_ACIA
  tya
  pha
  lda     ACIASR 
  bpl     next23
  lsr     TRANSITION_RS232
  pha
  and     #$08
  beq     next24
  ldx     ACIADR
  pla
  pha
  and     #$07
  beq     @skip
  ora     #$B0
  .byt     $24 ; jump one byte
@skip:
  txa

  ldx     #$0C
  jsr     XECRBU_ROUTINE

next24

  pla
  and     #$10
  beq     next23
  ldx     #$18 
  jsr     XTSTBU_ROUTINE; CORRECTME
  bcs     next26

  lda     ACIASR
  and     #$20
  bne     next23

  jsr     XLISBU_ROUTINE 

  sta     ACIADR
  lda     ACIACT
  and     #$07
  sta     $3F ; FIXME
  bcc     next23

next26
  inc     $20 ; FIXME
  bne     next23
  dec     $3F ; FIXME
  bne     next23
  lda     FLGLPR
  LSR
  lsr 
  LSR


  lda     ACIACR
  and     #$F3
  bcc     @skip
  and     #$FE
@skip:
  sta     ACIACR
next23:
  pla
Lc91c:
  tay
Lc91d:
.endif
  rts

Lc91e:
  dec     FLGCLK_FLAG
  bne     Lc973
  lda     #$04
  sta     FLGCLK_FLAG
  bit     FLGLPR

  bpl     @skip
  jsr     manage_printer
@skip:

timeud_next:
  lda     TIMEUD

  bne     @skip
  dec     TIMEUD+1
@skip:
skipme12:
  dec     TIMEUD
  sec
  inc     TIMED
  lda     TIMED
  sbc     #$0A
  bcc     Lc973
  sta     TIMED
  bit     FLGCLK

  bpl     @skip
  jsr     Lca75 
@skip:


  inc     TIMES
  lda     TIMEUS
  bne     @L1
  dec     TIMEUS+1
@L1:
  dec     TIMEUS
  lda     TIMES
  sbc     #$3C
  bcc     Lc973
  sta     TIMES
  inc     TIMEM
  lda     TIMEM
  sbc     #$3C
  bcc     Lc973
  sta     TIMEM
  inc     TIMEH
Lc973:

  dec     FLGCUR
  bne     @L3
  lda     #$0A
  sta     FLGCUR
  lda     FLGCUR_STATE
  eor     #$80
  sta     FLGCUR_STATE
  bit     FLGSCR
  bpl     @L3
  BVS     @L3
  ldx     SCRNB
  jmp     LDE2D 
@L3:
  rts

manage_irq_T1_and_T2:
  lda     VIA::IFR
  and     #$20
  beq     LC9b9
  lda     VIA_UNKNOWN
  ldy     VIA_UNKNOWN+1
  sta     VIA::T2
  sty     VIA::T2+1
  lda     FLGJCK
  lsr
  bcc     routine_todefine_1
  jsr     le085 
  jmp     LC8B9 

routine_todefine_1:
  lda     #$FF
  sta     VIA::T2+1
  jmp     LC8B9 
LC9b9  
  bit     VIA::IFR

  bmi     next110
  bit     TRANSITION_RS232
  bpl     next111
  ldx     IRQSVX
  ldy     IRQSVY
  jmp     ORIX_MEMORY_DRIVER_ADDRESS
next111:  
  jmp     LC8B6 
next110:
  lsr     TRANSITION_RS232
  bit     VIA::IFR
  BVC     next112
  bit     VIA::T1
  jsr     Lc91e 
  dec     KEYBOARD_COUNTER
  bne     next113 
  jsr     _manage_keyboard 
  jsr     routine_to_define_12
  bit     KBDFLG_KEY 
  bpl     @S3
  lda     #$14 
  sta     KEYBOARD_COUNTER+1
  bne     @L5
@S3:
  lda     KEYBOARD_COUNTER+2 
  bit     KEYBOARD_COUNTER+1 
  bmi     @skip
  dec     KEYBOARD_COUNTER+1 
@L5:
  lda     #$01
@skip:  
  sta     KEYBOARD_COUNTER ;
next113  
  bit     FLGJCK
  bpl     Lca0b 
  jsr     Ldffa 
  bit     FLGJCK
Lca0b  
  BVC     Lca10
  
  jsr     Ldffb
Lca10:
  lda     FLGJCK
  LSR
  bcc     LCA19 
  jsr     Le0e1 
LCA19: 
  jmp     LC8B9 
Lca1c:
  jmp     manage_irq_T1_and_T2
next112
  lda     VIA::IFR
  and     #$02
  beq     Lca1c
  bit     VIA::PRA
  jsr     manage_printer 
  jmp     LC8B9

.proc manage_printer
  ldx     #$24
  jsr     XLISBU_ROUTINE 
  bcc     @skip
  asl     FLGLPR ; printer
  sec
  ror     FLGLPR ; printer
  rts
@skip:
  sta     VIA::PRA
  lda     VIA::PRB
  and     #$ef
  sta     VIA::PRB
  ora     #$10
  sta     VIA::PRB
  asl     FLGLPR
  lsr     FLGLPR
  rts
.endproc
    
XDIVIDE_INTEGER32_BY_1024_ROUTINE:
  ; RESB contains 2 bytes most significant
  ; RES contains 2 bytes least significant
  ; RESB and RES contains the result of the division
  ; BUG : does manage 24 bits integer
  lsr     RESB
  ror     RES+1
  ror     RES
    
  lsr     RES+1
  ror     RES
  lsr     RES+1
  ror     RES
  lsr     RES+1
  ror     RES
   
  lsr     RES+1
  ror     RES
  lsr     RES+1
  ror     RES
   
  lsr     RES+1
  ror     RES
  lsr     RES+1
  ror     RES
   
  lsr     RES+1
  ror     RES
  lsr     RES+1
  ror     RES
  rts




XWRCLK_ROUTINE
  php
  sei
  sta     ADCLK
  sty     ADCLK+1
  sec
  ror     FLGCLK
  plp
  rts
  
Lca75:
  ldy     #$00
  lda     TIMEH
  jsr     telemon_display_clock_chars
  lda     #$3A
  sta     (ADCLK),Y
  iny
  lda     TIMEM
  jsr     telemon_display_clock_chars
  lda     #$3A
  sta     (ADCLK),Y
  iny
  lda     TIMES
telemon_display_clock_chars:
; display clock at the adress specified  
  ldx     #$2F
  sec
@loop:
  sbc     #$0A
  inx
  bcs     @loop
  pha
  txa
  sta     (ADCLK),Y
  pla
  iny
  adc     #$3A
  sta     (ADCLK),Y
  iny
  rts

  ; table des vecteurs du brk
vectors_telemon:
;0
  .byt     <XOP0_ROUTINE,>XOP0_ROUTINE ; $00
  .byt     <XOP1_ROUTINE,>XOP1_ROUTINE ; $1
  .byt     <XOP2_ROUTINE,>XOP2_ROUTINE ; 2
  .byt     <XOP3_ROUTINE,>XOP3_ROUTINE

  .byt     <XCL0_ROUTINE,>XCL0_ROUTINE ; 4  
  .byt     <XCL1_ROUTINE,>XCL1_ROUTINE ; 5
  .byt     <XCL2_ROUTINE,>XCL2_ROUTINE ; 6
  .byt     <XCL3_ROUTINE,>XCL3_ROUTINE ; 7
  
  .byt     <XRD0_ROUTINE,>XRD0_ROUTINE ; 8
  .byt     <XRD1_ROUTINE,>XRD1_ROUTINE ; 9
  .byt     <XRD2_ROUTINE,>XRD2_ROUTINE ; 0a
  .byt     <XRD3_ROUTINE,>XRD3_ROUTINE ; 0b
  
  .byt     <XRDW0_ROUTINE,>XRDW0_ROUTINE ; 0c XRDW0
  .byt     <XRDW1_ROUTINE,>XRDW1_ROUTINE ; 0d
  .byt     <XRDW2_ROUTINE,>XRDW2_ROUTINE ; 0e
  .byt     <XRDW3_ROUTINE,>XRDW3_ROUTINE ; 0f
  
  .byt     <XWR0_ROUTINE,>XWR0_ROUTINE ; ;10  
  .byt     <XWR1_ROUTINE,>XWR1_ROUTINE  ; 
  .byt     <XWR2_ROUTINE,>XWR2_ROUTINE ; 
  .byt     <XWR3_ROUTINE,>XWR3_ROUTINE ; 
; 18  
  .byt     <XWSTR0_ROUTINE,>XWSTR0_ROUTINE ; 14 
  .byt     <XWSTR1_ROUTINE,>XWSTR1_ROUTINE ;
  .byt     <XWSTR2_ROUTINE,>XWSTR2_ROUTINE  ; 
  .byt     <XWSTR3_ROUTINE,>XWSTR3_ROUTINE 
; 
  .byt     <XDECAL_ROUTINE,>XDECAL_ROUTINE  ; $18
  .byt     <XTEXT_ROUTINE,>XTEXT_ROUTINE    ; XTEXT ; 19
  .byt     <XHIRES_ROUTINE,>XHIRES_ROUTINE  ; XHIRES
  .byt     <_xeffhi,>_xeffhi                ; $1b
  .byt     <XFILLM_ROUTINE,>XFILLM_ROUTINE ; XFILLM
  .byt     <ZADCHA_ROUTINE,>ZADCHA_ROUTINE ; ZADCHA
;    .byt $00,$00
  .byt     <XDIVIDE_INTEGER32_BY_1024_ROUTINE,>XDIVIDE_INTEGER32_BY_1024_ROUTINE 
  .byt     <XMINMA_ROUTINE,>XMINMA_ROUTINE
  .byt     <XMUL40_ROUTINE,>XMUL40_ROUTINE
  .byt     <XMULT_ROUTINE,>XMULT_ROUTINE
  .byt     <XADRES_ROUTINE,>XADRES_ROUTINE                                          ; XADRES
  .byt     <XDIVIS_ROUTINE,>XDIVIS_ROUTINE                                          ; 
  .byt     <XVARS_ROUTINE,>XVARS_ROUTINE                                            ; 
  .byt     <XCRLF_ROUTINE,>XCRLF_ROUTINE                                            ; $25
  .byt     <XDECAY_ROUTINE,>XDECAY_ROUTINE                                          ; XDECAY  $26
  .byt     <XREADBYTES_ROUTINE,>XREADBYTES_ROUTINE ; $27  Fread
  .byt     <XBINDX_ROUTINE,>XBINDX_ROUTINE         ; XBINDX $28
  .byt     <XDECIM_ROUTINE,>XDECIM_ROUTINE         ; $29
  .byt     <XHEXA_ROUTINE,>XHEXA_ROUTINE           ; 2a
  .byt     <XA1AFF_ROUTINE,>XA1AFF_ROUTINE ; XA1AFF  $2B
  .byt     <XMAINARGS_ROUTINE,>XMAINARGS_ROUTINE   ; $2C
  .byt     <XGETARGC_ROUTINE,>XGETARGC_ROUTINE     ; $2D
  .byt     <XGETARGV_ROUTINE,>XGETARGV_ROUTINE     ; $2E
  .byt     $00,$00
  .byt     <XOPEN_ROUTINE,>XOPEN_ROUTINE ; $30

  .byt     <XOPEN_ABSOLUTE_PATH_CURRENT_ROUTINE,>XOPEN_ABSOLUTE_PATH_CURRENT_ROUTINE ; Open from current path $31

  .byt     $00,$00; XEDTIN $32
  .byt     <XECRPR_ROUTINE,>XECRPR_ROUTINE; XECRPR $33 $ece6
  .byt     <XCOSCR_ROUTINE,>XCOSCR_ROUTINE  ;XCOSCR $34
  .byt     <XCSSCR_ROUTINE,>XCSSCR_ROUTINE ; $35 XCSSCR 
  .byt     <XSCRSE_ROUTINE,>XSCRSE_ROUTINE ; $36 
  .byt     <XSCROH_ROUTINE,>XSCROH_ROUTINE ; $37
  .byt     <XSCROB_ROUTINE,>XSCROB_ROUTINE ; $38 XSCROB
  .byt     <XSCRNE_ROUTINE,>XSCRNE_ROUTINE ; $39
  .byt     <XCLOSE_ROUTINE,>XCLOSE_ROUTINE ; $3a 
  .byt     <XWRITEBYTES_ROUTINE,>XWRITEBYTES_ROUTINE ; nothing  $3b
  .byt     <_xreclk,>_xreclk ; $3c
  .byt     <_xclcl,>_xclcl ; $3d
  .byt     <XWRCLK_ROUTINE,>XWRCLK_ROUTINE ; $3e
  .byt     <XFSEEK_ROUTINE,>XFSEEK_ROUTINE ; fseek $3f
  .byt     <XSONPS_ROUTINE,>XSONPS_ROUTINE ; $40
  .byt     <XEPSG_ROUTINE,>XEPSG_ROUTINE ; $41
  .byt     <XOUPS_ROUTINE,>XOUPS_ROUTINE ; $42 XOUPS ddd8
  .byt     <XPLAY_ROUTINE,>XPLAY_ROUTINE ;XPLAY $43
  .byt     <XSOUND_ROUTINE,>XSOUND_ROUTINE ; $44
  .byt     <XMUSIC_ROUTINE,>XMUSIC_ROUTINE ; $45
  .byt     <XZAP_ROUTINE,>XZAP_ROUTINE ; $46
  .byt     <XSHOOT_ROUTINE,>XSHOOT_ROUTINE ; 47
  .byt     $00,$00 ; $48
  .byt     $00,$00 ; $49
  .byt     $00,$00 ; $4a
  .byt     <XMKDIR_ROUTINE,>XMKDIR_ROUTINE       ; $4b
  .byt     <XHCHRS_ROUTINE,>XHCHRS_ROUTINE ; $4c
  .byt     <XRM_ROUTINE,>XRM_ROUTINE       ; $4D
  .byt     <_XFWR_routine,>_XFWR_routine ; $4E
  .byt     $00,$00 ; $4f
  .byt     <XALLKB_ROUTINE,>XALLKB_ROUTINE ; $50
  .byt     <XKBDAS_ROUTINE,>XKBDAS_ROUTINE ; $51
  .byt     $00,$00 ; $52
  .byt     $00,$00 ; $53
  .byt     <XECRBU_ROUTINE,>XECRBU_ROUTINE ; $54
  .byt     <XLISBU_ROUTINE,>XLISBU_ROUTINE ; $55
  .byt     <XTSTBU_ROUTINE,>XTSTBU_ROUTINE ; $56
  .byt     <XVIDBU_ROUTINE,>XVIDBU_ROUTINE ; $57
  .byt     <XINIBU_ROUTINE,>XINIBU_ROUTINE ; $58
  .byt     <XDEFBU_ROUTINE,>XDEFBU_ROUTINE ; $59
  .byt     <XBUSY_ROUTINE,>XBUSY_ROUTINE   ; $5a
  .byt     <XMALLOC_ROUTINE,>XMALLOC_ROUTINE                         ; $5b
  .byt     <XSDUMP_ROUTINE,>XSDUMP_ROUTINE ; $5c
  .byt     <XCONSO_ROUTINE,>XCONSO_ROUTINE ; $5d
  .byt     <XSLOAD_ROUTINE,>XSLOAD_ROUTINE ; $5e
  .byt     <XSSAVE_ROUTINE,>XSSAVE_ROUTINE ; $5f
  .byt     <XMLOAD_ROUTINE,>XMLOAD_ROUTINE ; $60 
  .byt     <XMSAVE_ROUTINE,>XMSAVE_ROUTINE ; $61
  .byt     <XFREE_ROUTINE,>XFREE_ROUTINE   ; $62
  .byt     <_XEXEC,>_XEXEC                 ; $63
  .byt     $00,$00
  .byt     $00,$00
  .byt     $00,$00
  .byt     <XSOUT_ROUTINE,>XSOUT_ROUTINE
  .byt     <XA1DEC_ROUTINE,>XA1DEC_ROUTINE
  .byt     <XDECA1_ROUTINE,>XDECA1_ROUTINE
  .byt     <XA1PA2_ROUTINE,>XA1PA2_ROUTINE
  .byt     <XA2NA1_ROUTINE,>XA2NA1_ROUTINE
  .byt     <XA1MA2_ROUTINE,>XA1MA2_ROUTINE
  .byt     <XA2DA1_ROUTINE,>XA2DA1_ROUTINE
  .byt     <XA2EA1_ROUTINE,>XA2EA1_ROUTINE
  .byt     <XNA1_ROUTINE,>XNA1_ROUTINE
  .byt     <XSIN_ROUTINE,>XSIN_ROUTINE
  .byt     <XCOS_ROUTINE,>XCOS_ROUTINE
  .byt     <XTAN_ROUTINE,>XTAN_ROUTINE
  .byt     <XATN_ROUTINE,>XATN_ROUTINE
  .byt     <XEXP_ROUTINE,>XEXP_ROUTINE
  .byt     <XLN_ROUTINE,>XLN_ROUTINE
  .byt     <XLOG_ROUTINE,>XLOG_ROUTINE
  .byt     <XRND_ROUTINE,>XRND_ROUTINE
  .byt     <XSQR_ROUTINE,>XSQR_ROUTINE
  .byt     <XRAD_ROUTINE,>XRAD_ROUTINE
  .byt     <XDEG_ROUTINE,>XDEG_ROUTINE
  .byt     <XINT_ROUTINE,>XINT_ROUTINE
  .byt     <XPI_ROUTINE,>XPI_ROUTINE
  .byt     <XRAND_ROUTINE,>XRAND_ROUTINE
  .byt     <XA1A2_ROUTINE,>XA1A2_ROUTINE
  .byt     <XA2A1_ROUTINE,>XA2A1_ROUTINE
vectors_telemon_second_table:  
  .byt     <XIYAA1_ROUTINE,>XIYAA1_ROUTINE
  .byt     <XAYA1_ROUTINE,>XAYA1_ROUTINE
  .byt     <XA1IAY_ROUTINE,>XA1IAY_ROUTINE
  .byt     <XA1XY_ROUTINE,>XA1XY_ROUTINE
  .byt     <XAA1_ROUTINE,>XAA1_ROUTINE
  .byt     <XADNXT_ROUTINE,>XADNXT_ROUTINE
  .byt     <XINTEG_ROUTINE,>XINTEG_ROUTINE
  .byt     $00,$00
  .byt     <XHRSCG_ROUTINE,>XHRSCG_ROUTINE
  .byt     <XHRSCD_ROUTINE,>XHRSCD_ROUTINE
  .byt     <XHRSCB_ROUTINE,>XHRSCB_ROUTINE
  .byt     <XHRSCH_ROUTINE,>XHRSCH_ROUTINE
  .byt     <XHRSSE_ROUTINE,>XHRSSE_ROUTINE
  .byt     <XDRAWA_ROUTINE,>XDRAWA_ROUTINE
  .byt     <XDRAWR_ROUTINE,>XDRAWR_ROUTINE
  .byt     <XCIRCL_ROUTINE,>XCIRCL_ROUTINE
  .byt     <XCURSE_ROUTINE,>XCURSE_ROUTINE
  .byt     <XCURMO_ROUTINE,>XCURMO_ROUTINE
  .byt     <XPAPER_ROUTINE,>XPAPER_ROUTINE  
  .byt     <XINK_ROUTINE,>XINK_ROUTINE ; Xink $93
  .byt     <XBOX_ROUTINE,>XBOX_ROUTINE
  .byt     <XABOX_ROUTINE,>XABOX_ROUTINE; $95
  .byt     <XFILL_ROUTINE,>XFILL_ROUTINE
  .byt     <XCHAR_ROUTINE,>XCHAR_ROUTINE ;$97
  .byt     <XSCHAR_ROUTINE,>XSCHAR_ROUTINE ; 98
  .byt     $00,$00 ; nothing $99
  .byt     $00,$00 ; nothing $9a
  .byt     $00,$00 ; nothing $9b
  .byt     <XEXPLO_ROUTINE,>XEXPLO_ROUTINE ; $9c
  .byt     <XPING_ROUTINE,>XPING_ROUTINE ; $9d


display_bar_in_inverted_video_mode:
  jsr     put_cursor_in_61_x 
  bit     FLGTEL ; Minitel ?
  bvc     Lccea 
  ldx     #$02
Lccdd  
  lda     #$09
  jsr     XWR0_ROUTINE
  dex
  bpl     Lccdd 
  lda     #$2d
  jmp     XWR0_ROUTINE 
Lccea  
  ldy     ACC1M 
  ldx     ACC1S
Lccee  
  lda     (ADSCR),y
  ora     #$80
  sta     (ADSCR),y
  iny
  dex
  bne     Lccee
  rts
Lccf9:
display_x_choice:
  tya
  pha
  txa
  pha
  pha
  jsr     put_cursor_in_61_x  
  inx
  lda     ACC2M
  ldy     ACC2M+1
  sta     ADDRESS_READ_BETWEEN_BANK
  sty     ADDRESS_READ_BETWEEN_BANK+1
  ldy     #$00
Lcd0c:
  dex
  beq     Lcd20
Lcd0f:
  iny 
  bne     @skip
  inc     ADDRESS_READ_BETWEEN_BANK+1
@skip:
  jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
  bne     Lcd0f
  
  iny
  bne     Lcd0c
  inc     ADDRESS_READ_BETWEEN_BANK+1
  bne     Lcd0c
Lcd20  
  ldx     ADDRESS_READ_BETWEEN_BANK+1
  clc
  tya
  adc     ADDRESS_READ_BETWEEN_BANK
  bcc     @skip
  inx
@skip:
  sta     RESB
  stx     RESB+1
  lda     #$20
  sta     DEFAFF
  pla
  clc
  adc     #$01
  ldy     #$00
  ldx     #$01 
  jsr     XDECIM_ROUTINE 
  
  lda     #$20
  jsr     XWR0_ROUTINE
  lda     RESB
  ldy     RESB+1
  jsr     XWSTR0_ROUTINE
  ldy     #$01
  jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
  sec
  beq     @skip2
  clc
@skip2:
  ror     ACC2E
  pla
  tax
  pla
  tay
  bit     ACC2E
  rts

put_cursor_in_61_x  
  lda     #$1F
  jsr     XWR0_ROUTINE
  tya
  ora     #$40
  jsr     XWR0_ROUTINE 
  lda     ACC1M
  ora     #$40
  jmp     XWR0_ROUTINE 

  


data_for_decimal_conversion
const_10_decimal_low
  .byt     $0a ; 19
const_100_decimal_low
  .byt     $64 ; 100 
const_1000_decimal_low  ; $3e8=1000
  .byt     $e8
const_10000_decimal_low  ; $3e8=1000  
  .byt     $10
const_10_decimal_high
  .byt     $00
  .byt     $00
  .byt     $03
  .byt     $27

Lcde5  
  ldx     #$00
  ldy     #$00
  .byt    $2c

convert_into_decimal_0_to_65535:
  
  ldx     #$03
  .byt    $2c

convert_into_decimal_0_to_9999
  ldx     #$02

; Don't put anything here ...
  
XBINDX_ROUTINE
.include  "functions/xbindx.asm"

; and here because code above needs to go to xbindx routine

.include  "functions/xdecim.asm"
  
XHEXA_ROUTINE
.include  "functions/xhexa.asm"  

XMUL40_ROUTINE
;[out] AY contains the result (and RES too)
.include  "functions/xmul40.asm"  

XADRES_ROUTINE
.include  "functions/xadress.asm"
  
XMULT_ROUTINE
.include  "functions/xmult.asm"  

XDIVIS_ROUTINE  
.include  "functions/xdivis.asm"  


_open_root_and_enter:
    lda     #"/"
    sta     BUFNOM
.IFPC02
.pc02
    stz     BUFNOM+1 ; INIT  
.p02    
.else  
    lda     #$00 ; used to write in BUFNOM
    sta     BUFNOM+1 ; INIT  
.endif
    jsr     _ch376_set_file_name
    jsr     _ch376_file_open
    rts


.include  "libs/ch376-lib/src/ch376.s"
XCHECK_VERIFY_USBDRIVE_READY_ROUTINE:
.include  "include/libs/xa65/ch376_verify.s"

XCLOSE_ROUTINE:
  jmp     _ch376_file_close
.include  "functions/xread.asm"
.include  "functions/xwrite.asm"
.include  "functions/xfseek.asm"
.include  "functions/xdecal.asm"
.include  "functions/xmkdir.asm"  
.include  "functions/xrm.asm"
.include  "functions/xexec.asm"
.include  "functions/sound/xepsg.asm"
.include  "functions/graphics/_xeffhi.asm"
.include  "functions/clock/_xclcl.asm"
.include  "functions/clock/_xreclk.asm"
.include  "functions/xfillm.asm"  
.include  "functions/xhires.asm"  
.include  "functions/xtext.asm"
.include  "functions/xfree.asm"
.include  "functions/mainargs.asm"
.include  "functions/getargc.asm"
.include  "functions/getargv.asm"
.include  "functions/text/xfwr.asm"


_multitasking:
  ;LIST_PID
  ;ORIX_CURRENT_PROCESS_FOREGROUND
  rts
  
.include "functions/time/wait_0_3_seconds.asm"

test_if_all_buffers_are_empty:

  sec
  .byt    $24 ; jump
XBUSY_ROUTINE  
  clc
  ror     ADDRESS_READ_BETWEEN_BANK
  ldx     #$00
Lcfb6  
  jsr     XTSTBU_ROUTINE 
  bcc     @S1 
  txa
  adc     #$0B
  tax
  cpx     #$30
  bne     Lcfb6 
@S1:
  php
  lda     #<table_to_define_prompt_charset
  ldy     #>table_to_define_prompt_charset
  bcs     @skip
  lda     #<table_to_define_prompt_charset_empty
  ldy     #>table_to_define_prompt_charset_empty
@skip:
  bit     ADDRESS_READ_BETWEEN_BANK
  bpl     @skip2
  jsr     Lfef9 
  plp
  rts
@skip2:
  jsr     Lfef9 
  plp
  rts

table_to_define_prompt_charset:
  .byt     $7f ; char 127
  .byt     $00,$00,$08,$3c,$3e,$3c,$08,$00,$00
table_to_define_prompt_charset_empty:
  .byt     $7f,$00,$00,$08,$34,$32,$34,$08,$00,$00

; This primitive will get the address of variables built in telemon and orix.  

XVARS_ROUTINE:
  lda     XVARS_TABLE_LOW,x
  ldy     XVARS_TABLE_HIGH,x
  rts
XVARS_TABLE:
XVARS_TABLE_LOW;
  
XVARS_TABLE_HIGH


  
XMINMA_ROUTINE:
  cmp     #"a" ; 'a'
  bcc     @skip
  cmp     #$7B ; 'z'
  bcs     @skip
  sbc     #$1F
@skip:
  rts

CTRL_G_KEYBOARD ; Send oups
  jmp     XOUPS_ROUTINE 

CTRL_O_KEYBOARD
  rts

.include "functions/_manage_keyboard.asm"

next75
  jmp     manage_function_key

XKBDAS_ROUTINE:
  jsr     routine_to_define_12 ; manage rs232
  lda     #$00
  pha
  lda     KBDFLG_KEY 
  asl
  asl
  asl
  tay
  lda     KBD_UNKNOWN ;
@loop:
  LSR
  bcs     @skip
  iny
  bcc     @loop
@skip:
  lda     KBDCOL+4
  tax
  and     #$90
  beq     @skip2
  pla
  ora     #$01
  pha
  tya
  adc     #$3F
  tay
@skip2:
  tya
  cmp     #$20
  bcc     @skip4
  sbc     #$08
  cmp     #$58
  bcc     @skip3
  sbc     #$08
@skip3:
  tay
@skip4:
  txa
  and     #$20
  bne     next75 
  lda     (ADKBD),Y 
  bit     FLGKBD 
  bpl     @skip5
  cmp     #$61
  bcc     @skip5
  cmp     #$7B
  bcs     @skip5
  sbc     #$1F
@skip5:
  tay
  txa
  and     #$04
  beq     next68
  and     KBDCOL+7 
  beq     @skip6
  lda     #$80
  sta     KBDCTC 
@skip6:
  pla
  ora     #$80
  pha
  tya
  and     #$1F
  tay
next68
  tya
Ld882  
  ldx     #$00
  pha
  cmp     #$06
  bne     @S9
  lda     FLGKBD ; CORRECTME
  eor     #$40
  bcs     @S12
@S9:

  cmp     #$14
  beq     @S11
  cmp     #$17
  bne     @S10
  lda     FLGKBD
  eor     #$20
  bcs     @S12
@S10:
  cmp     #$1B
  bne     @S13
  lda     FLGKBD
  and     #$20
  beq     @S13
  pla
  lda     #$00
  pha
@S11:
  lda     FLGKBD 
  eor     #$80
@S12:
  sta     FLGKBD
@S13:
  pla
  ldx     #$00
  jsr     XECRBU_ROUTINE
  pla
  ldx     #$00
  jsr     XECRBU_ROUTINE
  bit     FLGKBD
  BVC     @S8
  ldx     #<sound_bip_keyboard
  ldy     #>sound_bip_keyboard
  jmp     send_14_paramaters_to_psg
@S8:
  rts

sound_bip_keyboard:
  .byt     $1F
  .byt     $00,$00,$00,$00,$00,$00
  .byt     $3e,$10,$00,$00
  .byt     $1F,$00,$00
; END bip keyboard

manage_function_key:
  lda     (ADKBD),y
  cmp     #$2D
  beq     Ld8f8 
  cmp     #$3D
  beq     Ld8fb 
  pla
  ora     #$40
  pha
  lda     FLGKBD
  lsr
  bcs     Ld900 
  lda     (ADKBD),y
  and     #$1F
  ora     #$80
  .byt    $2C
Ld8f8  
  lda     #$60
  .byt    $2C
Ld8fb  
  lda     #$7E
  jmp     Ld882 
Ld900:
  jmp     (KBDFCT) ; Jump into function key vector

XALLKB_ROUTINE:
  ldy     #$07
  lda     #$7F
loop21:
  pha
  tax
  lda     #$0E
  jsr     XEPSG_ROUTINE
  lda     #$00
  sta     KBDCOL,Y
.ifdef WITH_ACIA  
  jsr     routine_to_define_12 
.endif  
  lda     VIA::PRB
  and     #$B8
  tax
  clc
  adc     #$08
  sta     $1F ; FIXME
loop20  ; d921
  stx     VIA::PRB

  inx
  lda     #$08

  and     VIA::PRB
  bne     skipme2001
loop23:  
  cpx     $1F ; FIXME
  bne     loop20
  
d930:
  beq     next22

skipme2001:
  DEX
  txa
  pha
  and     #$07
  tax
  lda     data_to_define_KBDCOL,X
  ora     KBDCOL,Y
  sta     KBDCOL,Y
  pla
  tax
  inx
  bne     loop23
next22  ;$D946
  pla
  sec
  ROR
  DEY
  bpl     loop21 ; D94A

  ldy     #$08
loop22  
  lda     SCRTRA+5,Y
  bne     out1
  cpy     #$06

  bne     @skip
  DEY
@skip:

  DEY
  bne     loop22 ; d959

out1:
  rts


manage_I_O_keyboard:
  bmi     skip2005
  lda     #$01
  sta     KEYBOARD_COUNTER+2
  sta     KEYBOARD_COUNTER 
  php
  sei
  ldx     #$00
  jsr     XLISBU_ROUTINE ; Read if we have data in keyboard buffer
  bcs     skip2004
  sta     KBDKEY ; A contains a key, we store it on KBDKEY
  ldx     #$00
  jsr     XLISBU_ROUTINE 
  bcs     skip2004
  sta     KBDSHT
  lda     KBDKEY
  plp
  clc
  rts
skip2004:
  ; at this step, there is no keyboard key in the buffer
  plp
  sec
  rts
skip2005:
  bcc     @skip3
  lda     #$40
  sta     VIA::IER
  rts
@skip3:
  lda     VIA::ACR
  ora     #$40
  sta     VIA::ACR
  
  lda     #$a8
  ldy     #$61
  sta     VIA::T1
  sty     VIA::T1+1
  lda     #$c0
  sta     VIA::IER


flush_keyboard_buffer:
  ldx     #$00
  jmp     XVIDBU_ROUTINE

  
data_to_define_KBDCOL: 
  .byt     $01,$02,$04,$08,$10,$20,$40
  .byt     $80

init_keyboard:
  lda     #$FF
  sta     VIA::DDRA
  sta     KEYBOARD_COUNTER+1
  lda     #$F7
  sta     VIA::DDRB
  lda     #$01
  sta     KBDVRL
  sta     KBDVRL+1
  sta     KEYBOARD_COUNTER+2
  sta     KEYBOARD_COUNTER
  lda     #$0E
  sta     KBDVRR
  lda     #<table_chars_qwerty
  ldy     #>table_chars_qwerty
  sta     ADKBD
  sty     ADKBD+1 ; FIXME
  lsr     KBDFLG_KEY
  lda     #$C0
  sta     FLGKBD
  lda     #$00
  sta     KBDCTC
  rts



send_14_paramaters_to_psg  
  clc
  .byt    $24
XSONPS_ROUTINE:
  sec
  php
  sei
  lda     ADDRESS_READ_BETWEEN_BANK+1
  pha
  lda     ADDRESS_READ_BETWEEN_BANK
  pha
  stx     ADDRESS_READ_BETWEEN_BANK
  sty     ADDRESS_READ_BETWEEN_BANK+1
  php
  ldy     #$00
@L1:
  plp
  php
  bcs     @S1
  lda     (ADDRESS_READ_BETWEEN_BANK),Y
  bcc     @S2
@S1:
  jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
@S2:
  tax
  tya
  pha
  jsr     XEPSG_ROUTINE 
  pla
  tay
  iny
  
  cpy     #$0E
  bne     @L1
  plp
  pla
  sta     ADDRESS_READ_BETWEEN_BANK
  pla
  sta     ADDRESS_READ_BETWEEN_BANK+1
  plp
  rts
  


init_printer:
  lda     #$07
  ldx     #$7F
  jmp     XEPSG_ROUTINE

Lda70:
  bmi     LDAD2  
next906:
  bit     FLGLPR  
  BVS     next909

  cmp     #$7F
  bne     next909
 
  lda     #$20
next909:
  pha  
  jsr     XECRBU_ROUTINE 
  pla 
  bcs     next906
  rts
LDAD2: 
  rts

Ldae1:
  jmp     LDB7D 


LDAF7
  bmi     @skip
  ldx     #$0C
  jmp     XLISBU_ROUTINE 
@skip:

.ifdef WITH_ACIA
  bcs     Ldb09
  
  lda     ACIACR
  and     #$0D
  ora     #$60
  bne     Ldb43 
.endif
Ldb09:
.ifdef WITH_ACIA
  lda     ACIACR
  ora     #$02
  sta     ACIACR
.endif
  rts


Ldb12:
;
;                        GESTION DE LA SORTIE MINITEL                           I
;                                                                               I
;                                                                               I
;Principe:N'étant guère familiarisé avec les modes de fonctionnement de l'ACIA, I
;         je vous donne le source mais je serais bien incapable d'expliciter    I
;         les modifications d'ACIACR et d'ACIACT, registres de controle et de   I
;         commande de l'ACIA 6551.                                              I
;                                                                               I
;
                          ;                                     I
  bmi     LDB3A           ;     ouverture-fermeture  ---------------------------- I
  tax                     ;     donnee dans X                                   I I
  bpl     LDB26           ;      si <128, on passe ----------------------       I I
  cmp     #$C0            ;      sinon, c'est <128+64 ?                 I       I I
  bcs     LDB26           ;                                             I       I I
  ora     #$40            ;    oui, on force b7                         I       I I
  pha                     ;                                             I       I I
  lda     #$1B            ;    et on envoie un ESC avant                I       I I
  ldx     #$18            ;      la donnée                              I       I I
  jsr     XECRBU_ROUTINE  ;                                             I       I I
  pla                     ;                                             I       I I
LDB26
  pha                     ;     <---------------------------------------        I I
  ldx     #$18            ;     on envoie la donnée                             I I
  jsr     XECRBU_ROUTINE  ;     dans le BUFFER ACIA sortie                      I I
  pla                     ;                                                     I I 
  bcs     LDB26           ;     si la donnée n'a pas été écrite, on boucle      I I
LDB2F

.ifdef WITH_ACIA
  lda     ACIACR          ;    on prend VIA2::IER                               I I
  and     #$F3            ;    %11110011 force b2 à 0                           I I
  ora     #$04            ;     et b3 à 1                                       I I
  sta     ACIACR          ;    dans ACIACR                                      I I
.endif

  rts
                           ;                                      < I
LDB3A
  bcs     LDB53            ;     C=1 on ferme ==================================  I

.ifdef    WITH_ACIA
  lda     ACIACR           ;     ouverture                                      > I
  and     #$02             ;      ACIACR ? 0 sauf b1                             I I
  ora     #$65             ;      %01101001, bits forc?s ? 1                     I I
Ldb43
  sta     ACIACR           ;     dans ACIACR <----------------------------------+--
.endif

.ifdef WITH_ACIA
  lda     #$38             ;     %00111000 dans ACIACT                          I  
  sta     ACIACT           ;                                                    I  
.endif
LDB53
  rts                  ;     et on sort--------------------------------------  

.ifdef WITH_ACIA  
init_rs232:
  ; RS232T: 
  ;  b0 to b3 : speed
  ;  b4 : external clock for 0, 1 for internal clock
  ;  b6 - b5 : 00=8 bits, 01=7 bits, 10=6 bits, 11=5 bits
  ;  b7 : 0=stop, 1= 2 or 1.5 stops

  lda     #$1E 
  sta     RS232T
  ; FIXME 65C02
  lda     #$00
  sta     RS232C
.endif  
  rts
                                                                                
               ;          GESTION DE L'ENTREE RS232                          
LDB5D
  bpl     LDAF7    ;  lecture, voir MINITEL (pourquoi pas $DAF9 ?)       
  bcs     Ldb09   ;   C=1, on ferme                                    

.ifdef    WITH_ACIA
  lda     ACIACR   ;   on ouvre                                          
  and     #$0D     ;  on fixe le mode de controle
.endif  

LDB66  
.ifdef    WITH_ACIA
  ora     RS232C      ;   de la RS232                                       
  sta     ACIACR                                                        
  lda     VIA2::PRA                                                        
  ora     #$10     ;  %00010000 on force RS232                          
  sta     VIA2::PRA                                                        
  lda     RS232T   ;   et on fixe le mode de transmission                
  sta     ACIACT   ;   dans ACIACR               
.endif
  rts                                                              

;                      GESTION DE LA SORTIE RS232                         
LDB79
  bpl     LDB26     ; Ecriture, comme MINITEL
  bcs     LDB53     ; pas de fermeture (rts) 
LDB7D
.ifdef    WITH_ACIA
  lda     ACIACR    ;  ouverture,on lit ACIACR                            
  and     #$02      ;  isole b1                                          
  ora     #$05      ;  %00000101 force b0 et b2 ? 1                      
  bne     LDB66     ;  inconditionnel          
.endif  

;                 GESTION DES SORTIES EN MODE TEXT                      

;Principe:tellement habituel que cela en devient monotone... mais bien pratique !  
output_window0:
  pha             ;   Save A & P
  php                                                              
  lda     #$00    ;   window 0                                         
  beq     skipme2000    ;   inconditionnel                                    
output_window1  
  pha                                                              
  php                                                              
  lda     #$01    ;   fen?tre 1
  bne     skipme2000    ;                                                 
output_window2
  pha                                                              
  php                                                              
  lda     #$02    ;  fen?tre 2
  bne     skipme2000
output_window3:
  pha                                                              
  php                                                              
  lda     #$03     ; fen?tre 3
skipme2000:

  sta     SCRNB       ; stocke la fen?tre dans SCRNB                      
  plp          ;  on lit la commande                                
  bpl     LDBA4    ;  ?criture -------    
  jmp     LDECE    ;  ouverture      I      
LDBA4:
  pla          ;  on lit la donn?e <                                
  sta     SCRNB+1      ;  que l'on sauve

Ldbb5:

  sta     SCRNB+1 ; store the char to display
  pha              ; Save A
  txa              ; save X
  pha              ; 
  tya              ; Save Y
  pha
  
  ldx     SCRNB     ; Get the id of the window
  lda     ADSCRL,X  ; get address of the window
  sta     ADSCR     
  lda     ADSCRH,X  
  sta     ADSCR+1  
  
  lda     SCRNB+1
  cmp     #" "       ; is it greater than space ?
  bcs     Ldc4c      ; yes let's displays it.
Ldbce   ; $d27e
  lda     FLGSCR,X

  pha

  jsr     XCOSCR_ROUTINE ; switch off cursor
  lda     #>(LDC2B-1) ; FIXME ?
  pha
  lda     #<(LDC2B-1) ; FIXME ?
  pha
  lda     SCRNB+1
  asl     ; MULT2 in order to get vector 
  tay
  lda     TABLE_OF_SHORTCUT_KEYBOARD+1,Y 
  pha
  lda     TABLE_OF_SHORTCUT_KEYBOARD  ,Y 
  pha
  lda     #$00
  sec
  rts



TABLE_OF_SHORTCUT_KEYBOARD:
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1)  ; Nothing
LDBED  
  .byt     <(CTRL_A_START-1),>(CTRL_A_START-1) ; CTRL A tabulation 
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1)
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); Already managed  
  .byt     <(CTRL_D_START-1),>(CTRL_D_START-1)
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); E
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1) ; F Already managed 
  .byt     <(CTRL_G_START-1),>(CTRL_G_START-1) ;G
  .byt     <(CTRL_H_START-1),>(CTRL_H_START-1) ;  H
  .byt     <(CTRL_I_START-1),>(CTRL_I_START-1) ; I
  .byt     <(CTRL_J_START-1),>(CTRL_J_START-1) ;
  .byt     <(CTRL_K_START-1),>(CTRL_K_START-1) ; 
  .byt     <(CTRL_L_START-1),>(CTRL_L_START-1) ;
  .byt     <(CTRL_M_START-1),>(CTRL_M_START-1) ; M
  .byt     <(CTRL_N_START-1),>(CTRL_N_START-1) ;  N
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1);  O
  .byt     <(CTRL_P_START-1),>(CTRL_P_START-1) ;P
  .byt     <(CTRL_Q_START-1),>(CTRL_Q_START-1) ;
  .byt     <(CTRL_R_START-1),>(CTRL_R_START-1) ;  R
  .byt     <(CTRL_S_START-1),>(CTRL_S_START-1) ;S 
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1) ;  T
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); U 
  .byt     <(CTRL_V_START-1)   ,>(CTRL_V_START-1)  ; V 
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1) ; W
  .byt     <(CTRL_X_START-1),>(CTRL_X_START-1) ; X
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); Y
  .byt     <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1);  Z 
  .byt     <(CTRL_ESC_START-1),>(CTRL_ESC_START-1) ;  ESC
  .byt     <(CTRL_ESC_START-1),>(CTRL_ESC_START-1) ; ??? Like ESC
  .byt     <(CTRL_CROCHET_START-1),>(CTRL_CROCHET_START-1) ;  CTRL ]
  .byt     <(CTRL_HOME_START-1)  ,>(CTRL_HOME_START-1) ;  HOME
  .byt     <(CTRL_US_START-1),>(CTRL_US_START-1) ;  US 
    

LDC2B
  ldx     SCRNB
  ldy     SCRX,x
  lda     (ADSCR),y
  sta     CURSCR,x
  lda     ADSCR
  sta     ADSCRL,x
  lda     ADSCR+1
  sta     ADSCRH,x
  pla
  sta     FLGSCR,x
  jsr     LDE2D 
; Here ? debug jede
LDC46  
  pla
  tay
  pla
  tax
  pla
  rts
Ldc4c

  lda     FLGSCR,X
  and     #%00001100 
  bne     Ldc9a
  lda     SCRNB+1
  bpl     Ldc5d
  cmp     #$A0  ; Is it higher than 128+32 
  bcs     Ldc5d ; is it a normal code ?
  ; yes don't display
  and     #$7F  ; yes let's write code
Ldc5d:
  
  sta     SCRNB+1
  jsr     display_char 
  lda     #$09
  sta     SCRNB+1
skip_code  
  jmp     Ldbce
LDC69
  sta     SCRNB+1
display_char  
  
  ldy     #$80
  lda     FLGSCR,X
  and     #$20      ; inverse video ?

  bne     @skip
  ldy     #$00
@skip:

  tya
  ora     SCRNB+1
  sta     CURSCR,X
  ldy     SCRX,X
  sta     (ADSCR),Y
  rts
  
Ldc9a
  and     #$08
  beq     LDCB8 
  lda     SCRNB+1 
  bmi     LDC46 
  cmp     #$40
  bcc     LDC46
  and     #$1F

  jsr     LDC69            ;  on le place à l'écran                            I
  lda     #$09             ;  on déplace le curseur à droite                   I
  jsr     Ldbb5            ;                                                   I
  lda     #$1B             ;  on envoie un ESC (fin de ESC)                    I
  jsr     Ldbb5            ;                                                   I
  jmp     LDC46            ; et on sort                                        I
LDCB8
  lda     FLGSCR,X         ;   US, on lit FLGSCR <-------------------------------
  pha                      ;   que l'on sauve                                    
  jsr     XCOSCR_ROUTINE   ;   on éteint le curseur                            
  pla                      ;   on prend FLGSCR                                   
  pha                                                              
  lsr                      ;   doit-on envoyer Y ou X ?                          
  bcs     LDCDC            ;   X ------------------------------------------------

  lda     SCRNB+1          ;   on lit Y                                         I
  and     #$3F             ;   on vire b4 (protocole US)                        I
  sta     SCRY,X           ;   et on fixe Y                                     I
  jsr     LDE07            ;   on ajuste l'adresse dans la fenêtre              I
  sta     ADSCRL,X         ;   dans ADSCRL                                      I
  tya                      ;                                                    I
  sta     ADSCRH,X         ;   et ADSCRH                                        I
  pla                      ;   on indique prochain code pour X                  I
  ora     #$01             ;                                                    I
  pha                      ;                                                    I
  jmp     LDC2B            ;   et on sort                                       I
LDCDC
  lda     SCRNB+1          ;  on lit X <----------------------------------------
  and     #$3F             ;   on vire b4                                        
  sta     SCRX,X           ;   dans SCRX                                         
  pla                                                              
  and     #$FA             ;   on indique fin de US                              
  pha                                                              
  jmp     LDC2B            ;  et on sort
KEYBOARD_NO_SHORTCUT       ; USED TO rts keyboard shortcut not managed  
  rts                                                                


;                       GESTION DES CODES DE CONTROLE                        

;#A055         
;Principe:Génial... la gestion des codes de controle est surement la partie la   
;         plus caractéristique de l'esprit BROCHIEN (après le BRK bien sur). La  
;         gestion est suprêmement optimisée pour tout les codes, elle est        
;         surement le fruit d'une mure reflexion. Chapeau.                       
;         En entrée de chaque routine, A=0, C=1 et la pile contient en son       
;         sommet -3, FLGSCR. Le rts branche en fait en $DC2B, routine générale   
;         de fin de gestion de code de controle.                                 

.include "functions/shortcuts/ctrl_a.asm"
  
;                             CODE 4 - CTRL D                               
CTRL_D_START:
  ror          ;  on prépare masque %00000010

 ;                               CODE 31 - US                                
CTRL_US_START:
;on prépare masque %00000100
  ROR
;                               CODE 27 - ESC                                
CTRL_ESC_START:
;                             on prépare masque %00001000                       
  ROR
;                             CODE 29 - CTRL ]                              

;                            on prépare masque %00010000   
CTRL_CROCHET_START:
  ror                                                              

;                          CODE 22 - CTRL V                              
CTRL_V_START:
 ; on prépare masque %00100000
  ror                

;                         CODE 16 - CTRL P                              
CTRL_P_START:
  ror  ;           on prépare masque %01000000                       
                                                                                
          ;                    CODE 17 - CTRL Q                              
CTRL_Q_START:
  
LDD13:
  ror    ;        on prépare masque %10000000                       

LDD14:
  tay           ; dans Y                                            
  TSX           ;  on indexe FLGSCR dans la pile                     
  eor     $0103,X   ;  on inverse le bit correspondant au code (bascule) 
  sta     $0103,X   ;  et on replace                                     
  sta     RES       ;  et dans $00                                       
  tya                                                              
  and     #$10      ;  mode 38/40 colonne ?                              
  bne     @skip     ;  oui ----------------------------------------------
  rts           ;  non on sort                                      I
@skip:
  ldx     SCRNB     ;   on prend le num?ro de fen?tre <-------------------
  and     RES       ;  mode monochrome (ou 40 colonnes) ?                
  beq     LDD3C     ;   oui ----------------------------------------------
  inc     SCRDX,X   ;  non, on interdit la première colonne             I
  inc     SCRDX,X   ;  et la deuxième                                   I
  lda     SCRX,X    ;  est-on dans une colonne                          I
  cmp     SCRDX,X   ;  interdite ?                                      I
  bcs     LDD3B     ;  non                                               I
  jmp     CTRL_M_START     ;  I  oui,on en sort                                    I
LDD3B
  rts   ;  <---                                                    I
LDD3C
  dec     SCRDX,X ;   on autorise colonne 0 et 1 <----------------------
  dec     SCRDX,X                                                      
  rts       
LDD43  
  dec     SCRX,X  ;  on ramène le curseur un cran à gauche  <----------
  rts  ;                                                           I

 ;                             CODE 8 - CTRL H                              I
 ;                                                                              I
;Action:déplace le curseur vers la gauche                                       I
CTRL_H_START
  lda     SCRX,X   ; est-on déja au début de la fenêtre ?             I
  cmp     SCRDX,X  ;                                                  I
  bne     LDD43    ; non, on ramène à gauche --------------------------
  lda     SCRFX,X  ; oui, on se place à la fin de la fenètre
  sta     SCRX,X                                                      

;                              CODE 11 - CTRL K                               

;Action:déplace le curseur vers le haut                                          
CTRL_K_START
  lda     SCRY,X            ;   et si on est pas                                  
  cmp     SCRDY,X           ; au sommet de la fenêtre,                          
  bne     LDD6E             ;   on remonte d'une ligne ---------------------------
  lda     SCRDY,X           ;   X et Y contiennent le début et la                I
  ldy     SCRFY,X           ;  fin de la fentre X                              I
  tax                       ;                                                   I
  jsr     XSCROB_ROUTINE    ;  on scrolle l'écran vers le bas ligne X ? Y       I
CTRL_M_START
  lda     SCRDX,X           ;  on place début de la fenêtre dans X              I
  sta     SCRX,X            ;                                                   I
  rts                       ;                                                   I
LDD6E
  dec     SCRY,X            ; on remontre le curseur <--------------------------
  jmp     LDE07             ;  et on ajuste ADSCR       
  
  
  
;                              CODE 14 - CTRL N                              
                                                                                
;Action:efface la ligne courante                                                 
CTRL_N_START:
  ldy     SCRDX,X ;    on prend la premi?re colonne de la fenetre        
  jmp     LDD7D   ;    et on efface ce qui suit (bpl aurait été mieux...)

;                             CODE 24 - CTRL X                              
;Action:efface la fin de la ligne courante                                       
CTRL_X_START
  ldy     SCRX,X    ;  on prend la colonne du curseur                    
LDD7D
  lda     SCRFX,X   ;  et la dernière colonne de la fen?tre              
  sta     SCRNB+1       ;  dans $29 

  lda     #$20      ;  on envoie un espace                               
@loop:
  sta     (ADSCR),Y                                                      
  iny           ; jusqu'à la fin de la ligne                        
  cpy     SCRNB+1                                                          
  bcc     @loop                                                       
  sta     (ADSCR),Y ; et à la dernière position aussi                   
  rts           ; (INC $29 avant la boucle aurait été mieux !)
LDD8E
  inc     SCRX,X                                                      
  rts                                                              
  
;                             CODE 9 - CTRL I                               

;Action:déplace le curseur à droite
CTRL_I_START
  lda     SCRX,X          ; on lit la colonne du curseur                      
  cmp     SCRFX,X         ; dernière colonne ?                                
  bne     LDD8E           ; non, on déplace le curseur                        
  jsr     CTRL_M_START    ; oui, on revient à la première colonne     

;        CODE 10 - CTRL J                              
                                                                                
;Action:déplace le curseur vers la droite                                        
CTRL_J_START
  lda     SCRY,X   ;  on est en bas de la fen?tre ?                     
  cmp     SCRFY,X  ;                                                    
  bne     @skip    ;  non ----------------------------------------------
  lda     SCRDY,X  ;  oui, X et Y contiennent d?but et fin de fen?tre  I
  ldy     SCRFY,X  ;                                                   I
  tax          ;                                                   I
  jsr     XSCROH_ROUTINE    ;  on scrolle la fen?tre                            I
  jmp     CTRL_M_START    ;  on revient en d?but de ligne                     I
@skip:
  inc     SCRY,X   ;  on incr?mente la ligne <-------------------------I 
  jmp     LDE07    ;  et on ajuste ADSCR                      

;                         CODE 12 - CTRL L                              

;Action:Efface la fenêtre
CTRL_L_START
  jsr     CTRL_HOME_START     ;  on remet le curseur en haut de la fen?tre         
@loop:
  jsr     CTRL_N_START               ;  on efface la ligne courante                       
  lda     SCRY,X              ; on est à la fin de la fen?tre ?                   
  cmp     SCRFY,X             ;                                                     
  beq     CTRL_HOME_START     ;  oui, on sort en repla?ant le curseur en haut     
  jsr     CTRL_J_START               ;  non, on déplace le curseur vers le bas            
  jmp     @loop               ; et on boucle  (Et bpl, non ?!?!)                  

;  CODE 19 - CTRL S                              
CTRL_S_START
  rts

CTRL_R_START
  rts        
  
XOUPS_ROUTINE
;                             CODE 7 - CTRL G                               
;
;Action:émet un OUPS

CTRL_G_START:
  ldx     #<XOUPS_DATA     ;   on indexe les 14 donn?es du OUPS                  
  ldy     #>XOUPS_DATA                                                         
  jsr     send_14_paramaters_to_psg   ;   et on envoie au PSG                               
  ldy     #$60     ;   I                                                 
  ldx     #$00     ;   I                                                
@loop:
  dex         ;    I D?lai d'une seconde                             
  bne     @loop     ;  I                                                 
  DEY           ;  I                                                 
  bne     @loop     ;  I                                                 
  lda     #$07      ;  un jmp init_printer suffisait ...                        
  ldx     #$3F                                                         
  jmp     XEPSG_ROUTINE

XOUPS_DATA
  .byt    $46,00,00,00,00,00;  période 1,12 ms, fréquence 880 Hz (LA 4) 
LDDF6
  .byt    00,$3E,$0F,00,00  ;  canal 1, volume 15 musical  

;                           INITIALISE UNE FENETRE
;Action:on place le curseur en (0,0) et on calcule son adresse                   
;
CTRL_HOME_START:
  lda     SCRDX,X  ;  on prend la première colonne                      
  sta     SCRX,X   ;  dans SCRX                                         
  lda     SCRDY,X  ;  la première ligne dans                            
  sta     SCRY,X   ;  SCRY                                              
LDE07
  lda     SCRY,X   ;  et on calcule l'adresse                           
  jsr     LDE12    ;  de la ligne                                       
  sta     ADSCR    ;  dans ADSCR                                        
  sty     ADSCR+1  ;
  rts      

;  CALCULE L'ADRESSE DE LA LIGNE A                       
;Action:En entrée, A contient le numèro de la ligne et en sortie, RES contient   
;       l'adresse à l'écran de cette ligne.                                      

LDE12
  jsr     XMUL40_ROUTINE    ;  RES=A*40                                          
  lda     SCRBAL,X          ;  AY=adresse de la fen?tre                          
  ldy     SCRBAH,X                                                      
  jmp     XADRES_ROUTINE    ; on calcule dans RES l'adresse de la ligne   
  
XCOSCR_ROUTINE:
  clc
  .byt    $24
XCSSCR_ROUTINE  
  sec
  php
  asl     FLGSCR,X
  PLP
  ror     FLGSCR,X
  bmi     lde53
  lda     #$80
LDE2D  
  and     FLGSCR,X
  and     #$80
  eor     CURSCR,X
  ldy     SCRX,X
  sta     (ADSCR),Y
  pha
  lda     FLGSCR,X
  and     #$02

  beq     @skip
  lda     SCRY,X
  cmp     SCRFY,X
  beq     @skip
  tya
  adc     #$28
  tay
  pla
  sta     (ADSCR),Y
  rts
@skip:

  pla
lde53  
  rts
  
.include "functions/text/xscrob_xscroh.asm"

; Action:inconnue... ne semble pas tre appelée et utilise des variables          
;       IRQ dont on ne sait rien.      

;Note de Jede : oui :  utilisée chercher le label LDECE     

LDECE 
  bcc     LDED7             ;  si C=0 on passe ------------                      
  ldx     SCRNB             ;                             I                      
  jsr     XCOSCR_ROUTINE    ;  on éteint le curseur       I                      
  pla                   ;  et on sort A de la pile    I                      
  rts          ;                             I    
LDED7
  lda     #$01     ;  on met 1 en $216 <----------                      
  sta     FLGCUR                                                        
  lda     #$80      ; on force b7 à 1 dans $217                         
  sta     FLGCUR_STATE                                                        
  pla           ; on sort A                                         
  rts           ; et on sort    

  ; text mode  Text mode bytes it will  fill SCRTXT
data_text_window:
  .byt     $00,$27 ; 0 to 39
  .byt     $01,$1B ; 1 to 27
  .byt     $80,$BB ; adress of text mode (first byte)
  ; hires mode it will  fill SCRHIR
data_hires_window
  .byt     $00,$27 ; 0 to 39
  .byt     $00,$02 ; 0 to 2
  .byt     $68,$BF ; last bytes for text mode
data_trace_window  
  .byt     $00,$27 ; 0 to 39
  .byt     $1A,$1B ; 26 to 27
  .byt     $80,$BB ; adress

XSCRSE_ROUTINE ; init window
  sec
  .byt     $24

ROUTINE_TO_DEFINE_7
  clc
  php
  sta     ADDRESS_READ_BETWEEN_BANK   ; CORRECTME
  sty     ADDRESS_READ_BETWEEN_BANK+1 ; CORRECTME
  txa
  clc
  adc     #$18
  tax
  ldy     #$05

next18
  PLP

  php
  bcs     @skip

  lda     (ADDRESS_READ_BETWEEN_BANK),Y
  bcc     @S3
@skip:

  jsr     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY

@S3:
  sta     SCRY,X

  txa
  sec
  sbc     #$04
  tax
  DEY
  bpl     next18


; loop 4 times to set color ink/paper and flags on the 4 possibles screens  
  lda     #$07
  sta     SCRCT,X ; Set ink to white
  lda     #$00
  sta     SCRCF,X ; set paper to black
  lda     #$00
  sta     FLGSCR,X
  lda     SCRDX,X
  sta     SCRX,X ; init cursor to 0 (beginning of the line)
  lda     SCRDY,X
  sta     SCRY,X
  lda     SCRBAL,X
  sta     ADSCRL,X
  lda     SCRBAH,X
  sta     ADSCRH,X
  lda     #$20
  sta     CURSCR,X
  lda     SCRNB 
  pha
  stx     SCRNB 

  lda     #$0C

  jsr     Ldbb5 

  pla 
  
  sta     SCRNB
  plp
  rts
  
.include "functions/init_screen.asm"

Ldf90
  lda     VIA2::PRB
  and     #$3F
  ora     #$40
  bne     next15
Ldf99
  lda     VIA2::PRB
  and     #$3F
  ora     #$80
  
next15:
  sta     VIA2::PRB
  lda     VIA2::PRB
  and     #$1F
  rts
  sec ; ????
  rts ; ????
  
init_joystick:
  lda     #%01000001 ; SET mouse and joystick flag
  sta     FLGJCK
; init JCKTAB values
  ldx     #$06 ; 7 bytes 
@loop:
  lda     telemon_values_for_JCKTAB,X ; data_to_define_3
  sta     JCKTAB,X
  DEX
  bpl     @loop

  lda     #$01
  sta     MOUSE_JOYSTICK_MANAGEMENT+6
  sta     MOUSE_JOYSTICK_MANAGEMENT+11
  lda     #$06
  sta     MOUSE_JOYSTICK_MANAGEMENT+7
  sta     MOUSE_JOYSTICK_MANAGEMENT+10
  lda     #$01
  sta     MOUSE_JOYSTICK_MANAGEMENT+8
  lda     #$0A
  sta     MOUSE_JOYSTICK_MANAGEMENT+9
  lda     #$03
  sta     JCKTAB+5
  sta     JCKTAB+6
  lda     #$10
  ldy     #$27
  sta     VIA_UNKNOWN
  sty     VIA_UNKNOWN+1
  sta     VIA::T2
  sty     VIA::T2+1
  lda     #$A0
  sta     VIA::IER
  rts

telemon_values_for_JCKTAB
  .byt     $0b,$0a,$20,$08,$09,$03,$03
Ldffa
  rts
Ldffb
  lda     JCGVAL
  and     #$04
  bne     Le014
  jsr     Ldf90 
  and     #$04
  bne     Le01e
  dec     MOUSE_JOYSTICK_MANAGEMENT+2 ; CORRECTME
  bne     Le037
  ldx     MOUSE_JOYSTICK_MANAGEMENT+6 ; CORRECTME
  jmp     Le01e 
Le014
  jsr     Ldf90 
  and     #$04
  bne     Le037
  ldx     MOUSE_JOYSTICK_MANAGEMENT+7 ; CORRECTME
Le01e
  stx     MOUSE_JOYSTICK_MANAGEMENT+2 ; CORRECTME
  sta     VABKP1 ; CORRECTME
  lda     JCGVAL
  and     #$1B
  ora     VABKP1 ; CORRECTME
  sta     JCGVAL
  lda     VABKP1 ; CORRECTME
  bne     Le037
  lda     JCKTAB ; CORRECTME
  jsr     Le19f 
Le037
  lda     JCGVAL
  and     #$1B
  eor     #$1B
  beq     Le05b
  jsr     Ldf90 
  and     #$1B
  sta     VABKP1 ; CORRECTME
  lda     JCGVAL
  and     #$1B
  eor     VABKP1
  bne     Le062
  dec     MOUSE_JOYSTICK_MANAGEMENT
  bne     Le084
  ldx     MOUSE_JOYSTICK_MANAGEMENT+6 ; CORRECTME
  jmp     Le065
Le05b
  jsr     Ldf90 
  and     #$1B
  sta     VABKP1 ; CORRECTME
Le062
  ldx     MOUSE_JOYSTICK_MANAGEMENT+7 ; CORRECTME
Le065
  stx     MOUSE_JOYSTICK_MANAGEMENT ; CORRECTME
  lda     JCGVAL
  and     #$04
  ora     VABKP1 ; CORRECTME
  sta     JCGVAL
  ldx     #$04
  ora     #$04
Le076
  LSR
  pha
  bcs     Le080
  lda     JCKTAB,X
  jsr     Le19f 
Le080:
  pla
  DEX
  bpl     Le076
Le084
  rts

le085


;                            GESTION DE LA SOURIS                            

;Action:Gère la souris comme précédemment le joystick gauche, à ceci près qu'il  
;       ne s'agit plus avec la souris de g?rer un délai de répétition (sauf pour 
;       les boutons), mais plutot une vitesse de répétition. Dans le buffer      
;       clavier, l'octet KBDSHT ajouté au codes ASCII souris est 8, soit b3 à 1. 

                                                                                
  jsr     Ldf99      ;  on lit la valeur souris                         
  and     #$1B       ;   on isole les directions                           
  sta     VABKP1     ;   dans VABKP1                                          
  cmp     #$1B       ;   la souris bouge ?                                 
  bne     LE095      ;   non ---------------------------------------------- 
  dec     JCKTAB+7   ;   on déplace ?                                     I
  bne     Le084      ;   non, on sort.                                    I 
LE095  
  lda     JCKTAB+8    ;  on place vitesse d?placement dans  <--------------
  sta     JCKTAB+7    ;  $2A4                                              
  lda     VABKP1      ;   on lit le code                                    
  cmp     #$1B        ;   souris fixe ?                                     
  beq     LE0B5       ;  oui ----------------------------------------------
  and     #$1B                         ;    non, on isole les valeurs direction              I
  eor     JCDVAL                       ;    et on retourne les bits de JCDVAL                I
  and     #$1B                         ;    en isolant les bits direction                    I
  bne     LE0B5                        ;    ce ne sont pas les m?mes exactement -------------O 
  dec     MOUSE_JOYSTICK_MANAGEMENT+1  ;    on r?p?te ?                                      I
  bne     LE0E0  ;    non                                              I 
  ldx     MOUSE_JOYSTICK_MANAGEMENT+8  ;     oui, on met le diviseur répétition               I
  jmp     LE0BB ;  ---dans le compteur                                 I 
LE0B5
  jsr     Ldf99  ; I  on lit la souris <-------------------------------- 
  ldx     MOUSE_JOYSTICK_MANAGEMENT+9 ;  I  on place le compteur avant répétition   
LE0BB
  stx     MOUSE_JOYSTICK_MANAGEMENT+1 ;  -->dans le décompteur
  and     #$1B  ;     on isole les bits de direction                    
  sta     VABKP1  ;      dans VABKP1                                          
  lda     JCDVAL ;     on prend JDCVAL                                   
  and     #$64 ;      %01100100, on isole les bits de Feu               
  ora     VABKP1   ;     on ajoute les bits de direction                   
  sta     JCDVAL  ;    dans JDCVAL                                       
  lda     VABKP1   ;                                                       
  ora     #$04  ;     on éteint le feu principal
  ldx     #$04  ;  
Le0d2
  lsr                                                              
  pha                                                              
  bcs     LE0DC     ;                                              
  lda     JCKTAB,X   ; et on envoie les valeurs ASCII dans le buffer     
  jsr     Le19d      ;                                                    
LE0DC
  pla                                                              
  dex                                                              
  bpl     Le0d2
LE0E0
  rts                                                              

Le0e1:
  lda     JCDVAL
  and     #$04
  bne     Le0fa
  jsr     Ldf99 
  and     #$04
  bne     Le102
  dec     MOUSE_JOYSTICK_MANAGEMENT+3 ; CORRECTME
  bne     Le11b
  ldx     MOUSE_JOYSTICK_MANAGEMENT+6 ; CORRECTME
  jmp     Le102
Le0fa
  jsr     Ldf99
  and     #$04
  ldx     MOUSE_JOYSTICK_MANAGEMENT+7 ; CORRECTME
Le102
  sta     VABKP1 ; CORRECTME
  stx     MOUSE_JOYSTICK_MANAGEMENT+3 ; CORRECTME
  lda     JCDVAL
  and     #$7B
  ora     VABKP1
  sta     JCDVAL
  lda     VABKP1
  bne     Le11b
  lda     JCKTAB ; CORRECTME
  jsr     Le19d 
Le11b
  lda     JCDVAL
  and     #$20
  bne     Le137
  jsr     Ldf99 
  lda     VIA2::PRA2
  and     #$20
  bne     Le140
  dec     MOUSE_JOYSTICK_MANAGEMENT+4 ; CORRECTME
  bne     Le15b
  ldx     MOUSE_JOYSTICK_MANAGEMENT+11 ; CORRECTME
  jmp     Le140
Le137
  jsr     Ldf99
  lda     VIA2::PRA2
  ldx     MOUSE_JOYSTICK_MANAGEMENT+10 ; CORRECTME
Le140
  stx     MOUSE_JOYSTICK_MANAGEMENT+4 ; CORRECTME
  and     #$20
  sta     VABKP1 
  lda     JCDVAL
  and     #$5F
  ora     VABKP1 
  sta     JCDVAL
  and     #$20
  bne     Le15b
  lda     JCKTAB+5
  jsr     Le19d
Le15b
  lda     JCDVAL
  and     #$40
  bne     Le177
  jsr     Ldf99
  lda     VIA2::PRA2
  and     #$80
  bne     Le180
  dec     MOUSE_JOYSTICK_MANAGEMENT+5 ; CORRECTME
  bne     Le19c
  ldx     MOUSE_JOYSTICK_MANAGEMENT+11 ; CORRECTME
  jmp     Le180
Le177
  jsr     Ldf99
  lda     VIA2::PRA2
  ldx     MOUSE_JOYSTICK_MANAGEMENT+10 ; CORRECTME
Le180
  stx     MOUSE_JOYSTICK_MANAGEMENT+5 ; CORRECTME
  LSR
  and     #$40
  sta     VABKP1
  lda     JCDVAL
  and     #$3F ; CORRECTME
  ora     VABKP1 
  sta     JCDVAL
  and     #$40
  bne     Le19c 
  lda     JCKTAB+6 ; CORRECTME
  jmp     Le19d 
Le19c
  rts
Le19d
  
  .byt    $38,$24
Le19f

  clc
  php
  stx     VABKP1 
  ldx     #$00
  jsr     XECRBU_ROUTINE 
  lda     #$08
  PLP
  bcs     Le1af
  lda     #$20
Le1af:
  ldx     #$00
  jsr     XECRBU_ROUTINE 
  ldx     VABKP1   
  rts
Le1b7  
  sec
  rts


data_for_hard_copy:
  .byt    $18,$33,$1b,$0a,$0d,$00,$f0,$4b,$1b,$0d,$0a,$40,$1b,$0a,$0a

XHCHRS_ROUTINE:

execute_hard_copy_hires:
  jmp     (HARD_COPY_HIRES)

hard_copy_hires:

LE25E  
  
  DEX
  bne     LE25E
  stx     TR0
LE269  
  ldx     #$06
LE26B  

  
LE276  
  lda     #$05
  sta     TR2
LE27A  
  lda     TR0
  asl
  asl
  asl
  jsr     XMUL40_ROUTINE 
  sta     TR5
  tya
  clc
  adc     #$A0
  sta     TR6
  lda     #$08
  sta     TR4
  ldy     TR1
LE290  
  lda     (TR5),Y
  tax
  and     #$40
  bne     LE29B 
  txa
  and     #$80
  tax
LE29B  
  txa
  bpl     LE2A0
  eor     #$3F
LE2A0  
  ldx     TR2
LE2A2  
  LSR
  DEX
  bpl     LE2A2 
  rol     TR3
  tya
  clc
  adc     #$28
  tay
  bcc     LE2B1 
  inc     TR6
LE2B1  

LE2D0  

  rts
Le2de
put_cursor_on_last_char_of_the_line
  ldy     SCRFX,X
  .byt    $24
@L1:
  dey
  lda     (RES),Y
  cmp     #$20
  bne     test_if_prompt_is_on_beginning_of_the_line
  tya
  cmp     SCRDX,X
  bne     @L1 
  rts
  
test_if_prompt_is_on_beginning_of_the_line
  cmp     #$7F
  bne     @skip
  tya
  cmp     SCRDX,x
@skip:
  rts
Le2f9
  ldy     SCRDX,X
  lda     (RES),Y
  cmp     #$7F
  rts
LE301
  ldx     SCRNB
  lda     SCRY,X
  sta     ACC1M
Le2ed  
  lda     ACC1M
  jsr     LDE12 
  jsr     Le2f9 ;

  beq     @S1
  lda     ACC1M
  cmp     SCRDY,X
  
  beq     @S2
  dec     ACC1M
  bcs     Le2ed
@S1:
  clc
  iny
  sty     ACC1E
@S2:
  rts

put_cursor_on_beginning_of_the_line:
  ldx     SCRNB
  lda     SCRY,X
  sta     MENDFY
  jsr     LDE12
  jsr     put_cursor_on_last_char_of_the_line
Le32f  
  sty     MENDDY
  beq     Le34e 
  lda     MENDFY
  cmp     SCRFY,X
  beq     Le34d 
  inc     MENDFY
  lda     MENDFY
  jsr     LDE12
  jsr     Le2f9 
  beq     Le34b 
  jsr     put_cursor_on_last_char_of_the_line 
  bne     Le32f 
Le34b  
  dec     MENDFY
Le34d  
  rts
Le34e  
  rts


LE34F
  jsr     LE301 
  jmp     LE361

send_the_end_of_line_in_bufedt  
  ldx     SCRNB
  lda     SCRX,X
  sta     ACC1E ; FIXME label
  lda     SCRY,X
  sta     ACC1M ; FIXME label
LE361  
  jsr     put_cursor_on_beginning_of_the_line
    
  lda     ACC1M ; FIXME label
  sta     ACC1S ; FIXME label
  cmp     MENDFY
  bne Le378

  lda     MENDDY
  cmp     ACC1E ; FIXME label
  bcs     Le378
  lda     #$00    ; FIXME 65c02
  sta     BUFEDT
  rts
Le378  

  lda     #$00 ; FIXME 65C02
  sta     MENX
  lsr     ACC1EX ; FIXME label
Le37e  
  lda     ACC1S ; FIXME label
  jsr     LDE12
  ldy     ACC1E ; FIXME label
  lda     ACC1S ; FIXME label
  cmp     ACC1M ; FIXME label
  beq     Le390
  ldx     SCRNB
  ldy     SCRDX,X
Le390  
  lda     (RES),Y
  cmp     #$20
  bcs     Le398
  ora     #$80
Le398  
  ldx     MENX
  bit     ACC1EX
  bpl     @S1
  lda     #$20
  sta     (RES),Y
  bne     Le3b1
@S1:
  sta     BUFEDT,X
  inc     MENX
  cpx     ACC1J
  bcc     Le3b1
  dec     MENX
  ror     ACC1EX
Le3b1  
  tya
  iny
  ldx     ACC1S
  cpx     MENDFY
  bne     Le3c5
  cmp     MENDDY
  bne     Le390
  ldx     MENX
  lda     #$00        ; FIXME 65C02
  sta     BUFEDT,X
  rts
Le3c5  

  ldx     SCRNB
  cmp     SCRFX,X
  bne     Le390
  inc     ACC1S
  bne     Le37e
  
display_bufedt_content:
  ror     ACC1EX
  lda     #$00    ; FIXME 65c02
  sta     MENX
  lda     ADSCR
  ldy     ADSCR+1
  sta     RES
  sty     RES+1
  ldx     SCRNB
  ldy     SCRX,X
Le3e3:
  ldx     MENX ; fixme
  lda     BUFEDT,X
  beq     Le41c 
  lda     #$20
  bit     ACC1EX
  bmi     @S1
  lda     BUFEDT,X
  bpl     @S1
  cmp     #$A0
  bcs     @S1
  and     #$1F
@S1:
  sta     (RES),Y

  bit     FLGTEL ; Minitel ?
  BVC     Le405
  jsr     LE656
Le405  
  tya
  iny
  ldx     SCRNB
  cmp     SCRFX,X
  bne     Le418
  lda     #$28
  ldy     #$00
  jsr     XADRES_ROUTINE 
  ldy     SCRDX,X
Le418  
  inc     MENX
  bne     Le3e3
Le41c  
  bit     FLGTEL ; Minitel ?
  BVC     Le42a 
  ldx     SCRX
  ldy     SCRY

  jsr     Le62a 
Le42a    
  ldy     SCRX
  lda     (ADSCR),Y
  ldx     SCRNB     ; FIXME 65C02
  sta     CURSCR,X
  rts

  
Le45a  
Le479  
  rts


 
  
manage_code_control
  cmp     #$08
  bne     Le5d5
  pha
  lda     KBDSHT
  lsr
  bcs     Le5cb
Le5c4  
  pla
  jsr     Le648 
  jmp     Le45a 
Le5cb  
  jsr     LE301 
  ldx     ACC1E
Le5d2  
  ldy     ACC1M
  jmp     LE5E7
Le5d5
  cmp     #$09
  bne     Le5ee
  pha
  lda     KBDSHT
  lsr
  bcc     Le5c4
  jsr     put_cursor_on_beginning_of_the_line
  ldx     MENDDY
  ldy     MENDFY
LE5E7  
  pla
  
  jsr     Le62a 
  jmp     Le45a  
Le5ee  
  cmp     #$0A
  bne     Le604
  ldx     SCRNB
  lda     SCRY,X
  cmp     SCRFY,X
  bne     Le615
  lda     #$0A
  .byt    $2C
Le5ff  
  lda     #$0B
  
  jmp     Le479 
Le604  
  cmp     #$0B
  bne     Le617
  ldx     SCRNB
  lda     SCRY,X
  cmp     SCRDY,X
  beq     Le5ff
  lda     #$0B
  
  .byt    $2c
Le615  
  lda     #$0A
Le617  
  cmp     #$0C
  bne     Le624
  
  jsr     Le648 
  jsr     XECRPR_ROUTINE 
  jmp     Le45a
Le624  
  jsr     Le648 
  jmp     Le45a 


;POSITIONNE LE CURSEUR EN X,Y                        

; Action:positionne le curseur à l'écran et sur le minitel s'il est actif en tant 
; que sortie vidéo.

Le62a
  lda     #$1F       ; on envoie un US                                   
  jsr     Le648                                                     
  tya                ;  on envoie Y+64                                    
  ora     #$40                                                         
  jsr     Le648                                                    
  txa                ;   et X+64                                           
  ora     #$40                                                         
  jsr     Ldbb5
.ifdef WITH_MINITEL                                                         
  bit     FLGTEL     ; mode minitel ?                                    
  BVC     @S1        ; non                                              
  inx                ; on ajoute une colonne                             
  txa                ; dans A                                            
  dex                ; et on revient en arrière                          
  ora     #$40       ;  on ajoute 40                                      
  jmp     LE656      ;  et on envoie au minitel
.endif  
@S1:
  rts

;                   ENVOIE UN CODE SUR LE TERMINAL VIDEO                    
                                                                                
;Action:envoie un code sur l'écran et éventuellement sur le minitel s'il est     
;       actif comme sortie vidéo. Seule la fenêtre 0 est gérée, ce qui ote       
;       définitivement tout espoir de gestion d'entrée de commande sur une autre 
;       fenêtre.                                                                 

Le648                                                                        
  bit     Le648    ;  V=0 et N=0 pour écriture <------------------------ 
  jmp     output_window0    ;  dans la fenêtre 0                               
                                                                               

;                 ENVOIE UN CODE AU BUFFER SERIE SORTIE                    

LE656
  sta     TR0              ;  on sauve le code <--------------------------------
  tya                  ;  on sauve Y                                       I
  pha                  ;                                                   I
  txa                  ;  et X                                             I
  pha                  ;                                                   I
  ldx     #$18             ;  on indexe buffer ACIA sortie (minitel sortie)    I
  lda     TR0              ;  on envoie le code                                I
  jsr     XECRBU_ROUTINE   ;                                                   I
  pla                  ;  on restaure les registres                        I
  tax                  ;                                                   I
  pla                  ;                                                   I
  tay                  ;                                                   I
  lda     TR0              ;                                                   I
  bcs     LE656            ;  si l'envoi s'est mal passé, on recommence --------
LE66B
  rts                     



data_for_hires_display
  .byt    $20,$10,$08,$04
  .byt    $02,$01

  
XHRSSE_ROUTINE:
  clc            ;  C=0                                               
  bit     HRS5+1     ;  on fait tourner HRS5+1 sur lui-même               
  bpl     @skip      ;   afin de conserver le pattern                     
  sec 
@skip:
  rol     HRS5+1                                                          
  bcc     Le7c0      ;    si b7 de $56   ? 0, on saute <-------------------- 
LE79C
  ldy     HRSX40     ;   sinon on prend X/6                               I
  lda     (ADHRS),Y  ;   on lit le code actuel                            I
  asl            ;   on sort b7                                       I
  bpl     Le7c0      ;   pas pixel, on sort ------------------------------O
  ldx     HRSX6      ;   on prend le reste de X/6                         I
  lda     data_for_hires_display,X  ;  on lit le bit correspondant                      I 
  bit     HRSFB      ;   b7 de HRSFB ? 1 ?                                I
  bmi     @S2      ;   b7 ? 1, donc 3 ou 2                              I 
  bvc     @S1       ;   FB=0 ----------------------------------------    I 
  ora     (ADHRS),Y  ;   FB=1, on ajoute le code                     I    I
  sta     (ADHRS),Y  ;   et on le place                              I    I
  rts
@S1:
  eor     #$7F       ;   on inverse le bit  <-------------------------    I
  and     (ADHRS),Y  ;   et on l'?teint                                   I
  sta     (ADHRS),Y  ;   avant de le placer                               I
  rts            ;                                                    I
@S2:
  bvs     Le7c0      ;   FB=3, on sort -----------------------------------O 
  eor     (ADHRS),Y  ;   FB=2, on inverse le bit                          I
  sta     (ADHRS),Y  ;    et on sort       a                               I
Le7c0
  rts  

.include "functions/xhrscb.asm"
.include "functions/xhrsch.asm"
.include "functions/xhrscd.asm"
.include "functions/xhrscg.asm"

;                         PLACE LE CURSEUR EN X,Y                           

;Action:calcule l'adresse du curseur en calculant la position de la ligne par    
;       $A000+40*Y, la colonne dans X/6 et la position dans l'octet par X mod 6. 
;       Suite à une erreur dans la table des vecteur TELEMON, cette routine n'est
;       pas appel?e (alors qu'elle devrait l'?tre) par BRK XHRSSE...             
       ;En sortie, HSRX,Y,X40,X6 et ADHRS sont ajust?s en fonction de X et Y.    
;

hires_put_coordinate:
  sty HRSY            ;     Y dans HRSY                                       
  stx HRSX            ;     X dans HRSX                                       
  tya                 ;     et Y dans A                                       
  ldy #$00            ;     AY=A, ligne du curseur                            
  jsr XMUL40_ROUTINE  ;    on calcule 40*ligne                            
  sta ADHRS           ;                                           
  clc                                                              
  tya                                                              
  adc #$A0            ;   et on ajoute $A000, ?cran HIRES                   
  sta ADHRS+1         ;    dans ADHRS                                        
  stx RES             ;    on met la colonne dans RES                        
  lda #$06            ;    A=6                                               
  ldy #$00            ;    et Y=0  (dans RES+1)                              
  sty RES+1           ;     AY=6 et RES=colonne                               
  jsr XDIVIS_ROUTINE  ;     on divise la colonne par 6                       
  lda RES             ;     on sauve colonne/6 dans HSRX40                    
  sta HRSX40          ;                                                        
  lda RESB            ;      et le reste dans HRSX6                            
  sta HRSX6           ;                                                        
  rts                 ;      I
 
                           
; These 3 includes must be kept together
.include "functions/graphics/xbox.asm" ; don't move this include
.include "functions/graphics/xabox.asm" ; don't move this include
.include "functions/graphics/xdrawa.asm" ; don't move this include

;                          TRACE DE TRAIT EN RELATIF

;Principe:Le principe du tracé des droites est en fait assez complexe. On aurait 
;         aimé que F. BROCHE nous ponde une routine hyper-optimisée dont il a le 
;         secret. Ce n'est malheureusement pas le cas puisque cette routine      
;         l'algorithme des ROM V1.0 et 1.1. Sans doute parce qu'il est très      
;         efficace...                                                            
;         Pour tracer un trait le plus rapidement possible, on cherche lequel des
;         deux axes est le plus grand et on trace selon cet axe. Pour tracer,    
;         on avance sur l'axe de t points (t est la valeur de la tangente) et on 
;         avance d'un point sur l'autre axe, et ainsi de suite jusqu'à ce qu'on  
;         ait parcouru tout l'axe.                                               
;         Ainsi DRAW 10,2,1 donnera en fait 2 paliers de 5 pixels de large.      
;         Le cas dX=dY (déplacements égaux) est traité avec t=-1, de plus les    
;         poids fort des déplacements gardent le signe car on prend la valeur    
;         absolue de dX et dY pour les calculs.                                  


; NOERROR
   
.proc XDRAWR_ROUTINE
  lda     HRSPAT         ;   sauve le pattern                                  
  sta     HRS5+1         ;   FIXME Jede : Erreur entre le commentaire et la valeur (avant $56) dans HRS1+1     
  jsr     check_relative_parameters          ;   vérifie la validité de dX et dY                  
  stx     HRSX           ;   X et Y contiennent HRSX+dX et HRSY+dY             
  sty     HRSY           ;   dans HRSX et HRSY                                 
  bit     HRS1+1         ;   dX négatif ?                                      
  bpl     @S1            ;   non ----------------------------------------------
  lda     HRS1           ;   oui, on complèmente                              I
  eor     #$FF           ;   dX                                               I
  sta     HRS1           ;                                                    I
  inc     HRS1           ;   à 2                                              I
@S1:
  bit     HRS2+1         ;   dY négatif ? <------------------------------------
  bpl     @S2            ;   non ---------------------------------------------- 
  lda     HRS2           ;   oui on complèmente                               I
  eor     #$FF           ;   dY                                               I
  sta     HRS2           ;                                                    I
  inc     HRS2           ;   à 2                                              I
@S2:
  lda     HRS1           ;   on teste dX et dY <-------------------------------
  cmp     HRS2                                                          
  bcc     LE8ED          ;   dX<dY -------------------------------------------- 
  php                    ;   dX>=dY , on trace selon dX                       I
  lda     HRS1           ;   on prends dX                                     I
  beq     LE8EB          ;   dX=0, on sort -------------------------------    I 
  ldx     HRS2           ;   X=dY                                        I    I
  jsr     Le921          ;   on calcule dY/dX                            I    I 
  plp                    ;                                               I    I
  bne     LE8C0          ;   dX<>dY -----------------------------------  I    I 
  lda     #$FF           ;   dX=dY, la tangente est 1                 I  I    I
  sta     RES            ;   en fait, -1, mais c'est la même chose    I  I    I
LE8C0  
  bit     HRS1+1         ; I
  bpl     @S2            ; I dX>0 -------------------------------------  I    I
  jsr     XHRSCG_ROUTINE ; I dX<0, on d?place le curseur à gauche     I  I    I 
  jmp     @S3            ; I---                                       I  I    I  
@S2:
  jsr     XHRSCD_ROUTINE ; II  on on déplace le curseur à droite <-------  I    I 
@S3:
  clc                    ; I-->a-t-on parcouru une valeur de la tangente   I    I
  lda     RES            ; I                                               I    I
  adc     RESB           ; I   on stocke le résultat dans RESB              I    I
  sta     RESB           ; I                                               I    I
  bcc     @S5          ;I   non, on continue -------------------------  I    I 
  bit     $50            ; I   oui, dY<0 ?                              I  I    I FIXME
  bmi     @S4          ; I   oui -------------------------------      I  I    I
  jsr     XHRSCB_ROUTINE ; I   non, on déplace le curseur        I      I  I    I 
  jmp     @S5          ;I---vers le bas                       I      I  I    I 
@S4:
  jsr     XHRSCH_ROUTINE ; II  on déplace vers le haut <----------      I  I    I
@S5:
  jsr     XHRSSE_ROUTINE    ;I-->on affiche le point <---------------------  I    I 
  dec     HRS1   ; I   on d?cremente dX,                           I    I
  bne     LE8C0 ; ----on n'a pas parcouru tout l'axe              I    I 
LE8EA
  rts       ;  -->sinon, on sort                              I    I
LE8EB
  plp      ;   I  <--------------------------------------------    I
  rts       ;  I                                                   I
LE8ED
  lda     HRS2   ;  I  on trace la droite selon dY <---------------------
  beq     LE8EA  ; ---dY=0, on sort                                      
  ldx     HRS1   ;     X=dX                                              
  jsr     Le921 ;     on calcule dX/dY dans RES                          
LE8F6
  bit     HRS2+1                                                          
  bpl     LE900  ;    dY>0 --------------------------------------------- 
  jsr     XHRSCH_ROUTINE ;    dY<0, on déplace vers le haut                    I 
  jmp     LE903  ; ---et on saute                                      I 
LE900
  jsr     XHRSCB_ROUTINE  ; I  on déplace vers le bas <-------------------------- 
LE903  
  clc       ;  -->a-t-on parcouru la tangente ?                     
  lda     RES                                                          
  adc     RESB                                                          
  sta     RESB     ;   (dans RESB)                                        
  bcc     LE919   ;   non ---------------------------------------------- 
  bit     HRS1+1     ;                                                    I
  bpl     LE916   ;   dX>0 ------------------------------------        I
  jsr     XHRSCG_ROUTINE   ;   dX<0, on déplace vers                   I        I 
  jmp     LE919  ; ---la gauche                               I        I 
LE916  
  jsr     XHRSCD_ROUTINE  ; I  on déplace vers la droite <--------------        I 
LE919  
  jsr     XHRSSE_ROUTINE   ; -->on affiche le point <----------------------------- 
  dec     HRS2    ;    et on décrit dY       FIXME
  bne     LE8F6                                                       ;
  rts         ;   avant de sortir de longueur des lignes            
.endproc 


  ;   CALCUL LA TANGENTE (*256) D'UN TRAIT                    
Le921

  stx     RES+1             ;   dX (ou dY)*256 dans RES+1                         
  ldy     #$00              ;   dY (ou dX) dans AY                                 FIXME 65C02
  sty     RES                                                          
  jsr     XDIVIS_ROUTINE    ;  calcul dX*256/dY (ou dY/dX)                    
  lda     #$FF              ;  reste =-1                                         
  sta     RESB              ;    resultat dans RES                                 
  rts   

.include "functions/graphics/xcurse.asm"

;                          ROUTINE CURMOV
.proc XCURMO_ROUTINE
  jsr      check_relative_parameters    ;  on vérifie les paramêtres                        
  jmp      XCURSE_ROUTINE::put          ;   et on déplace
.endproc  
 

; VERIFIE LA VALIDITE DES PARAMETRES RELATIFS                 
                                                                                
;Action:Vérifie si l'adressage relatif du curseur est dans les limites de l'écran
;       HIRES, soit si 0<=X+dX<240 et 0<=Y+dY<200.                               
check_relative_parameters:
  clc                                                              
  lda      HRSX     ;   on prend HRSX                                     
  adc      HRS1     ;   plus le déplacement horizontal                    
  tax               ;  dans X                                            
  clc                                                              
  lda      HRSY     ;   HRSY                                              
  adc      HRS2     ;   plus le déplacement vertical                      
  tay               ;   dans Y           

;                       TESTE SI X ET Y SONT VALIDES                        
; Principe:Si X>239 ou Y>199 alors on ne retourne pas au programme appelant, mais son appelant, en indiquant l'erreur dans HRSERR.                     

hires_verify_position:
  cpx     #$F0     ;  X>=240 ?                                          
  bcs     @skip    ;   oui ---------------------------------------------- 
  cpy     #$C8     ;   Y>=200 ?                                         I
  bcs     @skip    ;   oui ---------------------------------------------O
  rts              ;   coordonnées ok, on sort.                         I
@skip:
  pla              ;  on dépile poids fort (>0) <-----------------------
  sta     HRSERR   ;  dans HRSERR                                       
  pla              ;  et poids faible de l'adresse de retour            
  rts              ;  et on retourne ? l'appelant de l'appelant    



XPAPER_ROUTINE:
  clc
  .byt     $24

XINK_ROUTINE:
  sec

;                    FIXE LA COULEUR DE FOND OU DU TEXTE                     

;Principe:A contient la couleur, X la fenêtre ou 128 si mode HIRES et C=1 si la  
;couleur est pour l'encre, 0 pour le fond.                              
;         Changer la couleur consiste à remplir la colonne couleur correspondante
;         avec le code de couleur. Auncun test de validité n'étant fait, on peut 
;         utiliser ce moyen pour remplir les colonnes 0 et 1 de n'importe quel   
;         attribut.                                                              

  pha           ; on sauve la couleur                               
  php           ; et C                                              
  stx     RES       ; fenêtre dans RES                                  
  bit     RES       ; HIRES ?                                           
  bmi     LE9A7     ; oui ---------------------------------------------- 
  stx     SCRNB      ; TEXT, on met le num?ro de fen?tre dans $28       I
  bcc     @S2     ; si C=0, c'est PAPER                              I 
  sta     SCRCT,X  ;  on stocke la couleur d'encre                     I
  bcs     @S1    ;  si C=1 c'est INK                                 I 
@S2:
  sta     SCRCF,X  ;  ou la couleur de fond  
@S1:
  lda     FLGSCR,X  ;  est on en 38 colonnes ?                          I
  and     #$10     ;                                                   I
  bne     LE987    ; mode 38 colonnes ------------------------------  I
  lda     #$0C     ;  mode 40 colonnes, on efface l'?cran           I  I
  jsr     Ldbb5    ;  (on envoie CHR$(12))                          I  I 
  lda     #$1D     ;  et on passe en 38 colonnes                    I  I
  jsr     Ldbb5    ;  (on envoie CHR$(29))                          I  I 
  ldx     SCRNB      ;  on prend X=num?ro de fen?tre                  I  I
LE987  
  lda     SCRDY,X           ;  on prend la ligne 0 de la fen?tre <------------  I
  jsr     XMUL40_ROUTINE    ;  *40 dans RES                                     I 
  lda     SCRBAL,X          ;  AY=adresse de base de la fen?tre                 I
  ldy     SCRBAH,X  ;                                                   I
  jsr     XADRES_ROUTINE   ;   on ajoute l'adresse à RES (ligne 0 *40) dans RES I 
  ldy     SCRDX,X  ;  on prend la premi?re colonne de la fen?tre       I
  DEY         ;   on enl?ve deux colonnes                          I
  DEY         ;                                                    I
  sec         ;                                                    I
  lda     SCRFY,X ;   on calcule le nombre de lignes                   I
  sbc     SCRDY,X ;   de la fen?tre                                    I
  tax         ;   dans X                                           I
  inx         ;                                                    I
  tya         ;   colonne 0 dans Y                                 I
  bcs     LE9B3   ;   inconditionnel --------------------------------- I 
LE9A7
  lda     #$00     ;  <----------------------------------------------+-- FIXME 65C02
  ldx     #$A0     ;                                                 I  
  sta     RES      ;  RES=$A000 , adresse HIRES                      I  
  stx     RES+1     ;                                                  I  
  ldx      #$C8    ;   X=200 pour 200 lignes                          I  
  lda     #$00    ;   A=0 pour colonne de début = colonne 0          I  
LE9B3
  plp         ;   on sort C <-------------------------------------  
  adc     #$00    ;   A=A+C                                             
  tay        ;    dans Y                                            
  pla        ;    on sort le code                                   *
LE9B8
  sta     (RES),Y; -->on le place dans la colonne correspondante        
  pha        ; I  on le sauve                                       
  clc        ; I                                                    
  lda     RES    ; I  on passe 28 colonnes                              
  adc     #$28    ;I  (donc une ligne)                                  
  sta     RES     ;I                                                    
  bcc     LE9C6  ; I                                                    
  inc     RES+1    ; I                                                    
LE9C6
  pla        ; I  on sort le code                                   
  dex        ; I  on compte X lignes                                
  bne     LE9B8   ;---                                                 
  rts         ;   et on sort----------------------------------------

.include "functions/graphics/xcircl.asm"

;  
XFILL_ROUTINE
  lda     ADHRS
  ldy     ADHRS+1
  sta     RES 
  sty     RES+1
@loop2:
  ldx     HRS2
  ldy     HRSX40
  lda     HRS3
@loop:
  sta     (RES),y
  iny
  dex
  bne     @loop
  lda     #$28
  ldy     #00
  jsr     XADRES_ROUTINE 
  dec     HRS1
  bne     @loop2
Lea92  
  rts
  
  
XSCHAR_ROUTINE:
  sta     HRS3
  sty     HRS3+1
  stx     HRS2
  lda     #$40
  sta     HRSFB
  ldy     #$00
Lea9f
  sty     HRS2+1
  cpy     HRS2
  bcs     Lea92 
  lda     (HRS3),y
  jsr     LEAB5 
  ldy     HRS2+1
  iny
  bne     Lea9f

XCHAR_ROUTINE
  lda     HRS1
  asl
  lsr     HRS2
  ror
LEAB5  
  pha
  lda     HRSX
  cmp     #$EA
  bcc     Lead3
  ldx     HRSX6
  lda     HRSY
  adc     #$07
  tay
  sbc     #$BF
  bcc     Lead0   
  beq     Lead0   
  cmp     #$08
  bne     Leacf 
  lda     #$00
Leacf  
  tay
Lead0  
  jsr     hires_put_coordinate
Lead3  
  pla
  jsr     ZADCHA_ROUTINE 
  ldy     #$00
Lead9  
  sty     RES
  lda     HRSX40
  pha
  lda     HRSX6
  pha
  lda     (RESB),Y
  asl
Leae4  
  asl
  beq     Leaf3 
  pha
  bpl     Leaed 
  jsr     LE79C 
Leaed  
  jsr     XHRSCD_ROUTINE 
  pla
  bne     Leae4 
Leaf3  
  jsr     XHRSCB_ROUTINE
  pla
  sta     HRSX6
  pla
  sta     HRSX40
  ldy     RES
  iny
  cpy     #$08
  bne     Lead9
  lda     HRSX
  adc     #$05
  tax
  ldy     HRSY
  jmp     hires_put_coordinate 

.include  "functions/sound/sounds.asm"  


READ_A_SERIAL_BUFFER_CODE_INPUT
  ldx     #$0c
  jmp     LDB5D 
wait_code_on_SERIAL_BUFFER_INPUT:
@loop:
  jsr     READ_A_SERIAL_BUFFER_CODE_INPUT 
  bcs     @loop
  rts

write_caracter_in_output_serial_buffer
  bit     write_caracter_in_output_serial_buffer
  jmp     LDB79

;Minitel  
send_a_to_minitel:
  bit     INDRS
  bvs     Lec49 
  tax
  bmi     next910
  cmp     #$20
  bcs     Lec49 
  adc     #$20
next912  
  pha
  lda     #$02
  jsr Lec49 
  pla 
  jmp Lec49 
next910
  cmp #$A0
  
  bcs next911 
  adc #$c0
  
  bcs next912 
next911  
  and #$7F
  pha 
  lda #$01
  jsr Lec49
  pla

Lec49  
  bit Lec49
  jmp Ldb12 
  
send_A_to_serial_output_with_check:
; MINITEL
  stx     TR0
  sty TR1
  pha
  bit INDRS
  bpl Lec5e 
  jsr send_a_to_minitel
  jmp LEC61
Lec5e  
  jsr write_caracter_in_output_serial_buffer
LEC61  
  pla
  eor TR2
  sta TR2
  ldx TR0
  ldy TR1 
  rts

Lec6b
  stx TR0
  sty TR1
Lec6f  
  asl KBDCTC
  bcc Lec77
  pla
  pla
  rts
Lec77  
  bit     INDRS
  bmi     Lec8b
  jsr     READ_A_SERIAL_BUFFER_CODE_INPUT
  bcs     Lec6f
LEC80
  pha
  eor     TR2
  sta     TR2
  pla
  ldx     TR0
  ldy     TR1
  rts
  
Lec8b
  jsr     LECB4
  bcs     Lec6f
  bit     INDRS
  BVS     LEC80 
  cmp     #$20
  bcs     LEC80
  pha
  jsr     LECB9 
  tax
  pla
  tay
  txa
  cpy     #$01
  bne     LECA8 
  ora     #$80
  bmi     LEC80
LECA8
  cmp     #$40
  bcs     LECB0 
  sbc     #$1F
  bcs     LEC80 
LECB0  
  adc     #$3F
  bcc     LEC80
LECB4  
  ldx     #$0C
  jmp     XLISBU_ROUTINE
LECB9  
  jsr     LECB4   
  bcs     LECB9 
  rts
Lecbf
  sec
  .byt    $24
LECC1  
  clc
  lda     #$80
  jmp     LDB5D 
LECC7
  sec 
  .byt    $24
LECC9  
  clc
  lda     #$80

  jmp     LDB79 
LECCF
  sec
  .byt    $24
LECD1
  clc
  lda     #$80
  jmp     LDAF7  
  
LECD7  
  sec
  .byt    $24
LECD9  
  clc 
  lda     #$80
  jmp     Ldb12 

compute_file_size
  sec
  lda     $052F ; FIXME
  sbc     $052D ; FIXME
  sta     $052A ; FIXME
  lda     $0530 ; FIXME
  sbc     $052E ; FIXME
  sta     $052B ; FIXME
  lda     $052D ; FIXME
  ldy     $052E ; FIXME
  sta     RES
  sty     RES+1
  rts

send_serial_header_file
  ldx     #$32
LECFF  
  lda     #$16
  jsr     send_A_to_serial_output_with_check 
  DEX
  bne     LECFF
  lda     #$24
  jsr     send_A_to_serial_output_with_check
  lda     #$00   ; FiXME 65C02
  sta     TR2
  ldx     #$00
LED12  
  lda     BUFNOM+1,X 
  jsr     send_A_to_serial_output_with_check 
  inx
  cpx     #$0C
  bne     LED12 
  lda     #$00
  jsr     send_A_to_serial_output_with_check 
  
  ldx     #$00
LED24  
  lda     $052C,X ; FIXME
  jsr     send_A_to_serial_output_with_check
  inx
  cpx     #$07
  bne     LED24 
  lda     TR2
  jmp     send_A_to_serial_output_with_check 


read_header_file:
  jmp     Ldbb5

 
.include "functions/serial/xconso.asm"   
.include "functions/serial/xsdump.asm"   
.include "functions/serial/xssave.asm"   
.include "functions/serial/xmsave.asm"   
.include "functions/serial/xsload.asm"  
.include "functions/serial/xmload.asm"

;;;;;;;;;;;;;;;;;;  
save_file_rs232_minitel:
  bit INDRS
  BVS LEE11 
  jsr send_serial_header_file 
LEE11  
  jsr compute_file_size

  lda #$00
  sta TR2
LEE18  
  lda $052A
  beq LEE2F 
  ldy #$00
  lda (RES),Y
  jsr send_A_to_serial_output_with_check 
  dec $052A ; FIXME
  inc RES
  bne LEE18
  inc RES+1
  bne LEE18 
LEE2F  
  lda $052B   ; FIXME
  beq LEE51 
  ldy #$00
LEE36  
  lda (RES),Y
  jsr send_A_to_serial_output_with_check 
  iny
  bne LEE36 
  dec $052B ; FIXME
  inc RES+1
  bit INDRS ; FIXME
  bpl LEE2F 
  lda #$30 
  sta TIMEUD ; FIXME
LEE4B  
  lda TIMEUD; FIXME
  bne     LEE4B 
  beq     LEE2F
LEE51  
  lda     TR2
  jmp     send_A_to_serial_output_with_check 
  
read_a_file_rs232_minitel:
  bit     INDRS 
  bvs     @skip  
  jsr     read_header_file  
@skip: 
  jsr     compute_file_size 
  bit     INDRS
  BVC     LEE6C  
  lda     #$FF
  sta     $052A  ;FIXME
  sta     $052B  ;FIXME
LEE6C  
  ldy     #$00
  sty     TR2
LEE70  
  lda     $052A ; FIXME
  beq     LEE86  
  jsr     Lec6b 
  sta     (RES),Y
  dec     $052A   ; FIXME
  inc     RES
  bne     LEE70  
  inc     RES+1
  jmp     LEE70 
LEE86  
  lda     $052B
  beq     LEE9D  
  ldy     #$00
LEE8D  
  jsr     Lec6b 
  sta     (RES),Y
  iny
  bne     LEE8D  
  inc     RES+1
  dec     $052B

  jmp     LEE86  
LEE9D  
  jsr     Lec6b  
  ora     #$30
  jmp     Ldbb5  

_strcpy:
  ldy     #$00
@loop:
  lda     (RES),y
  beq     @end
  sta     (RESB),y
  iny
  jmp     @loop
@end:
  sta     (RESB),y
  ; y return the length
  rts
  
.proc     XOPEN_ABSOLUTE_PATH_CURRENT_ROUTINE
  ; A & Y is the ptr of the string to enter
  sta     RES
  sty     RES+1

  jsr     _open_root_and_enter

@restart:  
  ldy     #$00
@loop:
  
  lda     (RES),y
  beq     @send_set_filename_and_fileopen
  cmp     #"/"
  beq     @send_set_filename_and_fileopen
  sta     BUFNOM,y
  iny
  
.IFPC02
.pc02
  bra     @loop
.p02  
.else  
  jmp     @loop
.endif  

@send_set_filename_and_fileopen:
  lda     #$00
  sta     BUFNOM,y ; FIXME can be done in 65C02 with X register instead of Y

.IFPC02
.pc02
  phy
.p02  
.else  
  sty     TR6
.endif

  jsr     _ch376_set_file_name
  jsr     _ch376_file_open
  cmp     #CH376_ERR_MISS_FILE
  bne     @next

  lda     #$01
  rts
@next:  
  sta     ERRNO
.IFPC02
.pc02
  ply
  lda     (RES),y
  beq     end2000
  bra     @restart
.p02  
.else
  ldy     TR6
  lda     (RES),y
  beq     @end
  iny
  tya
  clc
  adc     RES
  bcc     @skip
  inc     RES+1
@skip:
  sta     RES  


  jmp     @restart
.endif  
@end:
  rts
.endproc
  
;.include  "functions/XOPEN.asm"

; Use RES, A X Y TR4 cd   
XOPEN_ROUTINE:
  ; A and X contains char * pointer ex /usr/bin/toto.txt but it does not manage the full path yet
  sta     RES
  sta     RESB
  stx     RES+1
  stx     RESB+1
  sty     TR4 ; save flags
  
  ; check if usbkey is available
  jsr     _ch376_verify_SetUsbPort_Mount
  cmp     #$01
  bne     @L1
  ; impossible to mount
  ldx     #$00
  txa
  rts
@L1:
  ldy     #$00
  lda     (RES),y
  ;
  cmp     #"/"
  beq     @it_is_absolute
  
  ; here it's relative
  jsr     XOPEN_ABSOLUTE_PATH_CURRENT_ROUTINE ; Read current path (and open)
  ldy     #$00
  ldx     #$00
  jmp     @read_file

  
@it_is_absolute:

@init_and_go:
  jsr     _open_root
  ldx     #$00
  jsr     open_and_read_go

@read_file:

@loop:
  lda     (RES),y 
  beq     @end
  cmp     #"/"
  bne     @next_char
.IFPC02
.pc02
  stz     BUFNOM,x
.p02  
.else
  lda     #$00
  sta     BUFNOM,x
.endif  

  jsr     open_and_read_go
  
  cmp     #CH376_ERR_MISS_FILE
  beq     file_not_found   
  jmp     @loop
@next_char:
  sta     BUFNOM,x

  iny
  inx
.IFPC02
.pc02
  bra     @loop
.p02  
.else
  jmp     @loop
.endif
  
; not_slash_first_param
  ; Call here setfilename
  ldx     #$00 ; Flush param in order to send parameter
  iny
  bne     @loop
@end:
  sta     BUFNOM,x
  cpy     #$00
; reset_labels_g1
  beq     longskip1
 
  ; Optimize, it's crap
  lda     TR4 ; Get flags
  and     #O_RDONLY
  cmp     #O_RDONLY
  beq     @read_only
  lda     TR4
  and     #O_WRONLY
  cmp     #O_WRONLY
  beq     @write_only

  ; In all others keys, readonly read :!
.IFPC02
.pc02
  bra     @read_only
.p02  
.else  
  jmp     @read_only ; FIXME : replace jmp by bne to earn one byte
.endif  
@write_only:
  jsr     _ch376_set_file_name
  jsr     _ch376_file_create
  rts

@read_only:
  jsr     _ch376_set_file_name
  jsr     _ch376_file_open  
  cmp     #CH376_ERR_MISS_FILE
  beq     file_not_found   


  ; register filehandle call_routine_in_another_bank  
  ;call_routine_in_another_bank  
  lda     #ORIX_REGISTER_FILEHANDLE ; register file handle
  sta     TR0                       ; store the id of the routine that will be launched by ORIX_ROUTINES primitive
  lda     #<ORIX_ROUTINES           ; load the adress $ffe0 : it contains the routine in orix which will handle the ORIX_REGISTER_FILEHANDLE call
  ldy     #>ORIX_ROUTINES           ; Orix is used because there is not enough space in Telemon bank. With the 65C816, it could be easier
  ldx     #ORIX_ID_BANK             ; id of Orix bank
  jsr     call_routine_in_another_bank

  ; cc65 needs everything except $ff : if it returns $ff cc65 launch return0 (null)
  ; A is return from Orix filehandle
  ;lda #$00
  ldx     #$00
  rts


longskip1:
  ldx     #$ff
  txa
  rts

open_and_read_go:
.IFPC02
.pc02
  phy
.p02  
.else
  sty     TR7
.endif  
  jsr     _ch376_set_file_name
  jsr     _ch376_file_open
  sta     TR6 ; store return 
  ldx     #$00
.IFPC02
.pc02
  ply
.p02  
.else
  ldy     TR7 ; because it's "/" in the first char, it means that we are here _/_usr/bin/toto.txt
.endif    

  iny
  lda     TR6 ; GET error of _ch376_file_open return
  rts
file_not_found:
  ; return NULL
  ldx     #$FF
  lda     #$FF
  rts
  


_open_root:
  lda     #"/"
  sta     BUFNOM
.IFPC02
.pc02
  stz     BUFNOM+1 ; INIT  
.p02  
.else  
  lda     #$00 ; used to write in BUFNOM
  sta     BUFNOM+1 ; INIT  
.endif
  rts
    
_call_orix_routine
  sta     TR0
  lda     #<ORIX_ROUTINES
  ldy     #>ORIX_ROUTINES
  ldx     #ORIX_ID_BANK  ; id of Orix bank
  jsr     call_routine_in_another_bank
  rts

.include  "functions/minitel/xligne.asm"
.include  "functions/serial/xsout.asm"


  
add_0_5_A_ACC1:
  lda     #<const_zero_dot_half 
  ldy     #>const_zero_dot_half 
  jmp     AY_add_acc1 ; AY+acc1
Lef97:
  rts ; Don't know why there is this rts !

  
ACC2_ACC1:
  jsr     LF1EC 
XA2NA1_ROUTINE  
  lda     ACC1S ;$65 
  eor     #$ff
  sta     ACC1S ; $65
  eor     ACC2S
  sta     ACCPS
  lda     ACC1E
  jmp     XA1PA2_ROUTINE
mantisse_A:
  jsr     LF0E5
  bcc     next802 

AY_add_acc1:
  jsr     LF1EC
XA1PA2_ROUTINE:
ACC2_ADD_ACC1:
  bne     @L1
  jmp     XA2A1_ROUTINE 
@L1:
  tsx
  stx     FLSVS
  ldx     ACC1EX
  stx     TELEMON_UNKNWON_LABEL_7F
  ldx     #$68
  lda     ACC2E
LEFC2:  
  tay 
  beq     Lef97 
  sec
  sbc     ACC1E
  beq     next802  
  bcc     @next801 
  sty     ACC1E
  ldy     ACC2S
  sty     ACC1S
  eor     #$FF
  adc     #$00
  
  ldy     #$00
  sty     TELEMON_UNKNWON_LABEL_7F ; FIXME
  ldx     #$60
  bne     @L2
@next801:
  ldy     #$00
  sty     ACC1EX
@L2:
  cmp     #$F9
  bmi     mantisse_A
  tay
  lda     ACC1EX
  lsr     RES+1,x
  
  jsr     LF0FC 
next802  
  bit     ACCPS
  bpl     Lf049 
  ldy     #$60
  cpx     #$68
  beq     LEFFA 
  ldy     #$68
LEFFA:
  sec
  eor     #$FF
  adc     TELEMON_UNKNWON_LABEL_7F   ; FIXME
  sta     ACC1EX
  lda     $0004,y ; FIXME
  sbc     $04,x ; FIXME
  sta     MENX  ; FIXME
  lda     $0003,y ; FIXME
  sbc     RESB+1,x
  sta     MENDFY
  lda     $0002,y ; FIXME
  sbc     RESB,x
  sta     TELEMON_UNKNWON_LABEL_62  ; FIXME
  lda     $0001,y ; FIXME
  sbc     RES+1,x
  sta     ACC1M
LF01D:
  bcs     Lf022 
  
  jsr     Lf090 
Lf022:
  ldy     #$00
  tya
  clc
LF026:  
  ldx     ACC1M
  
  bne     LF074 
  ldx     TELEMON_UNKNWON_LABEL_62 ; FIXME
  stx     ACC1M 
  
  ldx     MENDFY
  stx     TELEMON_UNKNWON_LABEL_62

  ldx     MENX
  
  stx     MENDFY

  ldx     ACC1EX
  stx     MENX
  sty     ACC1EX

  adc     #$08
  cmp     #$28
  bne     LF026 
Lf042:
  lda     #$00          ; FIXME 65C02
  sta     ACC1E
LF046:
  sta     ACC1S  
  rts
Lf049:

  adc     TELEMON_UNKNWON_LABEL_7F
  sta     ACC1EX
  lda     MENX
  adc     ACC2M+3
  sta     MENX
  lda     MENDFY
  adc     ACC2M+2
  sta     MENDFY
  lda     TELEMON_UNKNWON_LABEL_62
  adc     ACC2M+1
  sta     TELEMON_UNKNWON_LABEL_62

  lda     ACC1M
  adc     ACC2M
  sta     ACC1M
  jmp     Lf081
Ld068:
  adc     #$01
  asl     ACC1EX
  rol     MENX
  rol     MENDFY
  rol     TELEMON_UNKNWON_LABEL_62
  rol     ACC1M
LF074:  
  bpl     Ld068
  
  sec
  
  sbc     ACC1E
  bcs     Lf042 
  eor     #$FF
  adc     #$01
  sta     ACC1E
Lf081:
  bcc     Lf08f
LF083:  
  inc     ACC1E
  
  beq     LF0C7 
  ror     ACC1M
  ror     TELEMON_UNKNWON_LABEL_62
  ror     MENDFY
  ror     MENX
Lf08f
  rts
Lf090  

  lda     ACC1S
  eor     #$FF
  sta     ACC1S
LF096:
  lda     ACC1M
  eor     #$FF
  sta     ACC1M
  lda     TELEMON_UNKNWON_LABEL_62
  eor     #$FF
  sta     TELEMON_UNKNWON_LABEL_62
  lda     MENDFY
  eor     #$FF
  sta     MENDFY
  lda     MENX
  eor     #$FF
  sta     MENX
  lda     ACC1EX
  eor     #$FF
  sta     ACC1EX
  inc     ACC1EX
  bne     LF0C6
LF0B8:
  inc     MENX
  bne     LF0C6
  inc     MENDFY
  bne     LF0C6
  inc     TELEMON_UNKNWON_LABEL_62
  bne     LF0C6
  inc     ACC1M
LF0C6:
  rts

LF0C7:
  lda     #$01
LF0C9:
  sta     FLERR
  ldx     FLSVS
  txs
  rts
 
justify__to_the_right_with_A_and_X
  ldx     #$6E
LF0D1: 
  ldy     DECDEB,x
  sty     ACC1EX
  ldy     RESB+1,x
  sty     $04,x
  ldy     RESB,x
  sty     RESB+1,x
  ldy     RES+1,x
  sty     RESB,x
  ldy     ACC1J
  sty     RES+1,x
LF0E5:
  adc     #$08
  bmi     LF0D1
  beq     LF0D1
  sbc     #$08
  tay
  lda     ACC1EX
  bcs     LF106
LF0F2:
  asl     RES+1,x
  bcc     LF0F8
  inc     RES+1,x
LF0F8:
  ror     RES+1,x
  ror     RES+1,x
LF0FC:
  ror     RESB,x
  ror     RESB+1,x
  ror     DECDEB,x
  ror   
  iny
  bne     LF0F2
LF106:
  clc
  rts  
const_ln_10:
  .byt    $82,$13,$5D,$8D,$DE ; 2.302585093 = ln(10)
const_pi_radians:
  .byt    $82,$49,$0F,$DA,$9E ; PI in radians (3.14159265)
const_pi_degree:  
  .byt    $88,$34,$00,$00,$00

polynome_ln_coef:
  .byt    $03,$7F,$5E,$56,$CB,$79,$80,$13,$9B
  .byt    $0B,$64,$80,$76,$38,$93,$16
  .byt    $82,$38,$AA,$3F,$20 ; 2.885390073 = 2/ln(2)

  
const_for_ln: 
const_sqr_two_divided_by_two:
  .byt    $80,$35,$04,$F3,$34 ; sqr(2/2) = 0.7071067812
const_sqr_two:  
  .byt    $81,$35,$04,$F3,$34 ; sqr(2) = 1.414213562
const_negative_zero_dot_five:
  .byt    $80,$80,$00,$00,$00 ; -0.5
const_ln_2:  
  .byt $80,$31,$72,$17,$F8 ; ln(2) = 0.683147806
LF140
  rts
LF141  
  lda     #$02
  jmp     LF0C9 

XLN_ROUTINE:
  tsx
  stx     FLSVS
LF149:
  jsr     LF3BD  
  beq     LF141
  bmi     LF141
  lda     ACC1E
  sbc     #$7F
  pha
  lda     #$80
  sta     ACC1E
  lda     #<const_for_ln 
  ldy     #>const_for_ln 
  jsr     AY_add_acc1  
  lda     #<const_sqr_two 
  ldy     #>const_sqr_two 
  jsr     Lf287  
  lda     #<const_atn_1 
  ldy     #>const_atn_1 
  jsr     ACC2_ACC1 
  lda     #<polynome_ln_coef
  ldy     #>polynome_ln_coef
  jsr     LF6E1  
  lda     #<const_negative_zero_dot_five 
  ldy     #>const_negative_zero_dot_five 
  jsr     AY_add_acc1  
  pla
  jsr     LF9E9  
  lda     #<const_ln_2   
  ldy     #>const_ln_2   
   
LF184:
  jsr     LF1EC 
  beq     LF140
  bne     LF190
XA1MA2_ROUTINE: 
  beq     LF140

  tsx
  stx     FLSVS
LF190:
  jsr     LF217 
  lda     #$00
  sta     ACC3
  sta     $70
  sta     $71
  sta     TELEMON_UNKNWON_LABEL_72
  lda     ACC1EX
  jsr     LF1B9  
  lda     MENX
  jsr     LF1B9  
  lda     MENDFY
  jsr     LF1B9  
  lda     TELEMON_UNKNWON_LABEL_62 ; FIXME
  jsr     LF1B9 
  lda     ACC1M
  jsr     LF1BE  
  jmp     Lf301  

LF1B9:
  bne     LF1BE
  jmp     justify__to_the_right_with_A_and_X

LF1BE:
  lsr
  ora     #$80
LF1C1:
  tay
  bcc     LF1DD
  clc
  lda     TELEMON_UNKNWON_LABEL_72
  adc     ACC2M+3
  sta     TELEMON_UNKNWON_LABEL_72
  lda     $71
  adc     ACC2M+2
  sta     $71
  lda     $70
  adc     ACC2M+1
  sta     $70
  lda     ACC3
  adc     ACC2M
  sta     ACC3
LF1DD:
  ror     ACC3
  ror     $70
  ror     $71
  ror     TELEMON_UNKNWON_LABEL_72
  ror     ACC1EX
  tya
  lsr
  bne     LF1C1
  rts
  
;ay -> acc2

LF1EC:
  sta     FLTR0
  sty     FLTR1
  ldy     #$04
  lda     (FLTR0),y
  sta     ADMEN+3 ; $6C
  dey
  lda     (FLTR0),y
  sta     ADMEN+2 ; $6B
  dey
  lda     (FLTR0),y
  sta     ADMEN+1 ; $6a
  dey
  lda     (FLTR0),y
  sta     ADMEN+4
  eor     ACC1S
  sta     ADMEN+5; $6E
  lda     ADMEN+4 ; $6d
  ora     #$80
  sta     ADMEN ; $69
  dey
  lda     (FLTR0),y
  sta     ACC2E ; $68
  lda     ACC1E
  rts
  

LF217:
  lda     ACC2E
LF219:
  beq     LF237
  clc
  adc     ACC1E
  bcc     LF224 
  bmi     Lf23c
  clc
  .byte   $2C
LF224:
  bpl     LF237
  adc     #$80
  sta     ACC1E
  beq     Lf23f
  lda     ACCPS
  sta     ACC1S
  rts

LF231:
  lda     ACC1S
  eor     #$FF
  bmi    Lf23c
LF237:
  pla
  pla
  jmp     Lf042 
Lf23c
  jmp     LF0C7 
Lf23f    
  jmp     LF046 
; 10*acc1->acc1  
Lf242
  jsr     XA1A2_ROUTINE
  tax
  beq     Lf258
  clc
  adc     #$02
  bcs     Lf23c
  ldx     #$00
  stx     ACCPS
  jsr     LEFC2 
  inc     ACC1E
  beq     Lf23c
Lf258
  rts
ten_in_floating_point
  .byt     $84,$20,$00,$00,$00 ; Ten in floating point
Lf25e
acc1_1_divide_10_in_acc1
  jsr     XA1A2_ROUTINE 
  ldx     #$00
  lda     #<ten_in_floating_point
  ldy     #>ten_in_floating_point
LF267
  stx     ACCPS

  jsr     XAYA1_ROUTINE 
  jmp     XA2DA1_ROUTINE  
  
XLOG_ROUTINE:
  tsx
  stx     FLSVS
  jsr     LF149 
  jsr     XA1A2_ROUTINE 
  lda     #<const_ln_10
  ldy     #>const_ln_10
  jsr     XAYA1_ROUTINE 
  jmp     XA2DA1_ROUTINE  

display_divide_per_0:
  lda     #$03
  sta     FLERR ; FLERR
  rts
Lf287:
  jsr     LF1EC
  
XA2DA1_ROUTINE:
  beq     display_divide_per_0
  TSX
  stx     FLSVS
  jsr     XAA1_ROUTINE
  lda     #$00
  sec
  sbc     ACC1E
  sta     ACC1E
  jsr     LF217 
  inc     ACC1E
  beq     Lf23c
  ldx     #$FC
  lda     #$01
LF2A4  

  ldy     ACC2M 
  cpy     ACC1M
  bne     LF2BA 
  ldy     ACC2M+1
  cpy     TELEMON_UNKNWON_LABEL_62   ; FIXME
  bne     LF2BA
  ldy     ACC2M+2
  cpy     MENDFY
  bne     LF2BA
  ldy     ACC2M+3
  cpy     MENX

LF2BA  
  php
  rol
  bcc     LF2CA 
  inx

  sta     TELEMON_UNKNWON_LABEL_72,X
  beq     LF2C8
  bpl     LF2F8 
  lda     #$01

Lf2c7  
  .byt     $2c
LF2C8  
  lda     #$40
  ;
LF2CA  
  plp
  bcs     LF2DB 
LF2CD  

  asl     ACC2M+3
  rol     ACC2M+2
  rol     ACC2M+1
  rol     ACC2M
  bcs     LF2BA 
  bmi     LF2A4 
  bpl     LF2BA

LF2DB  
  tay
  lda     ACC2M+3
  sbc     MENX
  sta     ACC2M+3
  lda     ACC2M+2
  sbc     MENDFY
  sta     ACC2M+2
  lda     ACC2M+1
  sbc     TELEMON_UNKNWON_LABEL_62   ; FIXME
  sta     ACC2M+1
  lda     ACC2M
  sbc     ACC1M
  sta     ACC2M
  tya 
  jmp     LF2CD 
LF2F8  
  asl
  asl
  asl
  asl
  asl
  asl
  sta     ACC1EX
  plp

; acc3->acc1  
Lf301


  lda     ACC3
  sta     ACC1M
  lda     $70  ; FIXME
  sta     TELEMON_UNKNWON_LABEL_62
  lda     $71
  sta     MENDFY
  lda     TELEMON_UNKNWON_LABEL_72
  sta     MENX
  jmp     Lf022


XPI_ROUTINE  
; pi->acc1
  jsr     test_if_degree_mode 
  beq     @S1 ; is it in radian mode ?
  lda     #<const_pi_degree
  ldy     #>const_pi_degree
  bne     XAYA1_ROUTINE
@S1:
  lda     #<const_pi_radians 
  ldy     #>const_pi_radians

XAYA1_ROUTINE:
  sta     FLTR0
  sty     FLTR1
  ldy     #$04
  lda     (FLTR0),Y
  sta     MENX
  dey
  lda     (FLTR0),Y
  sta     MENDFY
  DEY
  lda     (FLTR0),Y
  sta     TELEMON_UNKNWON_LABEL_62 ; FIXME
  DEY
  lda     (FLTR0),Y
  sta     ACC1S
  ora     #$80
  sta     ACC1M
  DEY
  lda     (FLTR0),Y
  sta     ACC1E
  sty     ACC1EX
  rts
LF348
  ldx     #$73
  .byt    $2C
LF34B
  ldx     #$78
  ldy     #$00

  jsr     XAA1_ROUTINE 

XA1XY_ROUTINE:
  stx     FLTR0
  sty     FLTR1
  
  ldy     #$04
  lda     MENX
  sta     (FLTR0),Y
  dey
  lda     MENDFY
  sta     (FLTR0),Y
  dey
  lda     TELEMON_UNKNWON_LABEL_62 ; FIXME
  sta     (FLTR0),Y
  dey
  lda     ACC1S
  ora     #$7F
  and     ACC1M
  sta     (FLTR0),Y
  dey
  lda     ACC1E
  sta     (FLTR0),Y
  sty     ACC1EX
  rts
XA2A1_ROUTINE  
  lda     ACC2S
LF379  
  sta     ACC1S
  ldx     #$05
@L1:  
  lda     ACC1J,x
  sta     $5f,x ; FIXME
  dex
  bne     @L1
  stx     ACC1EX
  rts


XA1A2_ROUTINE:
  ; arrondi ACC1 in ACC2_ACC1
  jsr     XAA1_ROUTINE
  
LF38A:
  ldx     #$06
LF38C:
  lda     $5F,x
  sta     ACC1J,x
  dex
  bne     LF38C
  stx     ACC1EX
LF395:
  rts
XAA1_ROUTINE
  lda     ACC1E
  beq     LF395
  asl     ACC1EX
  bcc     LF395
  jsr     LF0B8 
  bne     LF395
  jmp     LF083

XA1IAY_ROUTINE:  
  lda     ACC1S
  bmi     LF3B8 
  lda     ACC1E
  cmp     #$91
  bcs     LF3B8
  jsr     LF439
  lda     MENX
  ldy     MENDFY
  rts  

LF3B8  
  lda     #$0A
  jmp     LF0C9  

LF3BD:
  lda     ACC1E
  beq     LF3CA
LF3C1:
  lda     ACC1S
LF3C3:
  rol   
  lda     #$FF
  bcs     LF3CA
  lda     #$01
LF3CA:
rts

  jsr     LF3BD ; FIXME
  .byt     $2c

LF3CD
;  ACC=-
  lda      #$ff
LF3D1  
  sta      ACC1M
  lda      #$00
  sta      TELEMON_UNKNWON_LABEL_62
  ldx      #$88
  lda      ACC1M
  eor      #$FF
  rol
LF3DE  
  lda      #$00
  sta      MENDFY
  sta      MENX
  stx      ACC1E
  sta      ACC1EX
  sta      ACC1S
  jmp      LF01D 

XIYAA1_ROUTINE:  
  sta     ACC1M
  sty     MENDDY
  ldx     #$90
  sec
  bcs     LF3DE
ABS_ROUTINE  
  lsr     ACC1S
LF3F8  
  rts

LF3F9:
  sta     FLTR0
  sty     FLTR1
  ldy     #$00
  lda     (FLTR0),Y
  iny
  tax 
  beq     LF3BD  
  lda     (FLTR0),Y
  eor     ACC1S
  bmi     LF3C1 
  cpx     ACC1E
  bne     LF430 
  lda     (FLTR0),Y
  ora     #$80
  cmp     ACC1M
  bne     LF430
  iny
  lda     (FLTR0),Y
  cmp     MENDDY
  bne     LF430
  iny
  lda     (FLTR0),Y
  cmp     MENDFY
  bne     LF430  
  iny
  lda     #$7F
  cmp     ACC1EX
  lda     (FLTR0),Y
  sbc     MENX
  beq     LF3F8 
LF430  
  lda     ACC1S
  bcc     LF436  
  eor     #$FF
LF436  
  jmp     LF3C3 


LF439
  lda     ACC1E
  beq     LF487
  sec
  sbc     #$A0
  bit     ACC1S
  bpl     @S1
  tax
  lda     #$FF
  sta     ACC1J
  jsr     LF096 
  txa
@S1:
  ldx     #$60
  cmp     #$F9
  bpl     LF459 
  jsr     LF0E5
  sty     ACC1J
  rts

LF459: 
  tay
  lda     ACC1S
  and     #$80
  lsr     ACC1M
  ora     ACC1M
  sta     ACC1M
  jsr     LF0FC 
  sty     ACC1J
LF469  
  rts
  
XINT_ROUTINE:
  lda     ACC1E
  cmp     #$A0
  bcs     LF469 
  jsr     LF439 
  sty     ACC1EX
  lda     ACC1S
  sty     ACC1S
  eor     #$80
  rol
  lda     #$A0
  sta     ACC1E
  lda     MENX
  sta     FLINT
  jmp     LF01D
LF487  
  sta     ACC1M
  sta     MENDDY
  sta     MENDFY
  sta     MENX
  tay
  rts
LF491 ; FIXME ??? label seul
  sta     ACC1M
  stx     MENDDY
  ldx     #$90
  sec
  jmp     LF3DE

XA1AFF_ROUTINE: 
  jsr     XA1DEC_ROUTINE   
  lda     #$00
  ldy     #$01
  jmp     XWSTR0_ROUTINE 

XA1DEC_ROUTINE:
  ldy     #$00
  lda     #$20
  bit     ACC1S
  bpl     LF4AF 
  lda     #$2D
LF4AF  
  sta     $0100,Y
  sta     ACC1S
  sty     FLSVY
  iny
  lda     #$30
  ldx     ACC1E
  bne     LF4C0 
  
  jmp     LF5C8
LF4C0  
  lda     #$00
  cpx     #$80
  beq     LF4C8
  bcs     LF4D1 
LF4C8  
  lda     #<const_for_decimal_convert 
  ldy     #>const_for_decimal_convert
  jsr     LF184 
  lda     #$F7 ; Should be indexed ?.= FIXME
LF4D1  
  sta     ACC4M
LF4D3  
  lda     #<const_999_999_999
  ldy     #>const_999_999_999 
  jsr     LF3F9 ;
  beq     @S4 
  bpl     @S2
@L1:
  lda     #<const_999_999_dot_9
  ldy     #>const_999_999_dot_9
  jsr     LF3F9 ; 
  beq     @S1 
  bpl     @S3 
@S1:
  jsr     Lf242 ;
  dec     ACC4M 
  bne     @L1
@S2:  
  jsr     acc1_1_divide_10_in_acc1 ; 
  inc     ACC4M
  bne     LF4D3
@S3:
  jsr     add_0_5_A_ACC1
@S4:
  jsr     LF439 
  ldx     #$01
  lda     ACC4M
  clc
  adc     #$0A
  bmi     LF50F 
  cmp     #$0B
  bcs     LF511
  adc     #$FF
  tax
  lda     #$02
LF50F  
  sec
LF511
  sbc     #$02
  sta     FLDT1
  stx     ACC4M
  txa
  beq     LF51B 
  bpl     LF52E 
LF51B  
  ldy     FLSVY
  lda     #$2E
  iny
  sta     $0100,Y
  txa
  beq     LF52C 
  lda     #$30
  iny
  sta     $0100,Y
LF52C  
  sty     FLSVY
LF52E

  ldy     #$00
  ldx     #$80
LF532  
  clc
LF533  
  lda     MENX
  adc     const_negative_100_000_000+3,Y 
  sta     MENX
  lda     MENDFY
  adc     const_negative_100_000_000+2,Y 
  sta     MENDFY
  lda     TELEMON_UNKNWON_LABEL_62
  adc     const_negative_100_000_000+1,Y
  sta     TELEMON_UNKNWON_LABEL_62
  lda     ACC1M
  adc     const_negative_100_000_000,Y 
  sta     ACC1M
  inx
  bcs     LF556
  bpl     LF533
  bmi     LF558
LF556  
  bmi     LF532
LF558  
  txa 
  bcc     LF55F
  eor     #$FF
  adc     #$0A
LF55F  
  adc     #$2F
  iny
  iny
  iny
  iny
  sty     FLDT2
  ldy     FLSVY
  iny
  tax
  and     #$7F
  sta     $0100,Y
  dec     ACC4M
  bne     @S1
  lda     #$2E
  iny
  sta     $0100,Y
@S1:
  sty     FLSVY
  ldy     FLDT2
  txa
  eor     #$FF
  and     #$80
  tax
  cpy     #$24
  bne     LF533 
  ldy     FLSVY
LF58A  
  lda     $0100,Y
  DEY
  cmp     #$30
  beq     LF58A 
  cmp     #$2E
  beq     @S1
  iny
@S1:
  lda     #$2B
  ldx     FLDT1
  beq     LF5CB 
  bpl     LF5A7 
  lda     #$00
  sec
  sbc     FLDT1
  tax
  lda     #$2D
LF5A7  
  sta     $0102,Y
  lda     #$45
  sta     $0101,Y
  txa
  ldx     #$2F
  sec
LF5B3  
  inx
  sbc     #$0A
  bcs     LF5B3 
  adc     #$3A
  sta     $0104,Y
  txa
  sta     $0103,Y
  
  lda     #$00
  sta     $0105,Y
  beq     LF5D0 
LF5C8  
  sta     $0100,Y
LF5CB  
  lda     #$00
  sta     $0101,Y
LF5D0  
  lda     #$00
  ldy     #$01
  rts

  
const_for_decimal_convert:
const_one_billion  
  .byt     $9e,$6E,$6B,$28,$00 ; 1 000 000 000  float
const_999_999_999:
  .byt     $9e,$6e,$6b,$27,$FD ; 999 999 999
const_999_999_dot_9
  .byt     $9b,$3e,$bc,$1f,$FD ; 999 999.9
const_zero_dot_half  
  .byt     $80,$00,$00,$00,$00 ; 0.5 
const_negative_100_000_000 ; 32 bits binary signed
  .byt     $FA,$0A,$1F,$00
const_ten_million
  .byt     $00,$98,$96,$80 ; 10 000 000 
  .byt     $ff,$f0,$BD,$C0 ; -1 000 000

  .byt     $00,$01,$86,$a0,$ff,$ff,$d8,$f0,$00,$00,$03
  .byt     $e8,$ff,$ff,$ff,$9c,$00,$00,$00,$0a
LF609  
  .byt     $ff,$ff,$ff,$ff
LF60D
  jmp     Lf042

  
.include "functions/math/xsqr.asm"

XA2EA1_ROUTINE:
  beq     XEXP_ROUTINE  
  TSX
  stx     FLSVS
  lda     ACC2E
  beq     LF60D 
  ldx     #$80
  ldy     #$00
  jsr     XA1XY_ROUTINE 
  lda     ACC2S
  bpl     @S1
  jsr     XINT_ROUTINE  
  lda     #$80
  ldy     #$00
  jsr     LF3F9 
  bne     @S1
  tya
  ldy     FLINT
@S1:
  jsr     LF379  
  tya
  pha
  jsr     LF149  ; 
  lda     #$80
  ldy     #$00
  jsr     LF184  
  jsr     LF68F ; 
  pla
  lsr
  bcc     LF65D  

XNA1_ROUTINE:
  ; negative number
  lda     ACC1E
  beq     LF65D 
  lda     ACC1S
  eor     #$FF
  sta     ACC1S
LF65D  
  rts
const_1_divide_ln_2 ; 1/ln(2)  
  .byt    $81,$38,$AA,$3B,$29
coef_polynome:
  .byt    $07 ; for 8 coef
  .byt    $71,$34,$58,$3E,$56
  .byt    $74,$16,$7E,$B3,$1B
  .byt    $77,$2F,$EE,$E3,$85
  .byt    $7A,$1D,$84,$1C,$2A
  .byt    $7C,$63,$59,$58,$0A
  .byt    $7E,$75,$FD,$E7,$C6
  .byt    $80,$31,$72,$18,$10
  .byt    $81,$00,$00,$00,$00 ; 1

XEXP_ROUTINE:
  tsx
  stx     FLSVS
LF68F  
  lda     #<const_1_divide_ln_2
  ldy     #>const_1_divide_ln_2
  jsr     LF184 
  lda     ACC1EX
  adc     #$50
  bcc     LF69F 
  jsr     XAA1_ROUTINE 
LF69F  
  sta     TELEMON_UNKNWON_LABEL_7F
  jsr     LF38A 
  lda     ACC1E
  cmp     #$88
  bcc     @S1
@L1:
  jsr     LF231 
@S1:
  jsr     XINT_ROUTINE 
  
  lda     FLINT
  clc
  adc     #$81
  beq     @L1
  sec
  sbc     #$01
  pha
  ldx     #$05
@S2:
  lda     ACC2E,X
  ldy     ACC1E,X
  sta     ACC1E,X
  sty     ACC2E,X
  dex
  bpl     @S2
  lda     TELEMON_UNKNWON_LABEL_7F
  sta     ACC1EX
  jsr     XA2NA1_ROUTINE
  jsr     XNA1_ROUTINE 
  lda     #<coef_polynome 
  ldy     #>coef_polynome 
  jsr     LF6F7 
  lda     #$00      ; FIXME 65c02
  sta     ACCPS
  pla
  jmp     LF219 


LF6E1  
  sta     FLPOLP
LF6E3  
  sty     TELEMON_UNKNWON_LABEL_86
LF6E5  
  jsr     LF348 
LF6E8  
  lda     #$73
  jsr     LF184
  jsr     LF6FB 
  lda     #$73
  ldy     #$00
  jmp     LF184  

  
LF6F7
  sta     FLPOLP
  sty     TELEMON_UNKNWON_LABEL_86
LF6FB  
  jsr     LF34B 
  lda     (FLPOLP),Y
  sta     FLPO0
  ldy     FLPOLP
  iny
  tya
  bne     @S1
  inc     TELEMON_UNKNWON_LABEL_86
@S1:
  sta     FLPOLP
  ldy     TELEMON_UNKNWON_LABEL_86
LD70E  
  jsr     LF184 
  lda     FLPOLP
  ldy     TELEMON_UNKNWON_LABEL_86
  clc
  adc     #$05
  bcc     LF71B 
  iny
LF71B  
  sta     FLPOLP
  sty     TELEMON_UNKNWON_LABEL_86
  jsr     AY_add_acc1  
  lda     #$78
  ldy     #$00
  dec     FLPO0
  bne     LD70E  
LF72A
  rts
  
 
.include "functions/math/xrnd.asm"
.include "functions/math/xrand.asm"
.include "functions/math/xcos.asm"
.include "functions/math/xsin.asm"

CONST_SIN_AND_COS
CONST_PI_DIVIDED_BY_TWO:
  .byt    $81,$49,$0F,$DA,$A2
const_pi_mult_by_two:
  .byt    $83,$49,$0F,$DA,$A2 ; 6.283185307
const_0_dot_twenty_five: ; 0.25
  .byt    $7F,$00,$00,$00,$00
coef_polynome_sin:
  .byt    $05 ; 6 coef
  .byt    $84,$E6,$1A,$2D,$1B
  .byt    $86,$28,$07,$FB,$F8
  .byt    $87,$99,$68,$89,$01
  .byt    $87,$23,$35,$DF,$E1
  .byt    $86,$A5,$5D,$E7,$28
  .byt    $83,$49,$0F,$DA,$A2


.include "functions/math/xtan.asm"
.include "functions/math/xdeg.asm"
.include "functions/math/xatn.asm"

const_atn_1:
  .byt    $81,$00,$00,$00,$00 ; 1 coef 0

LF8B1
  jsr     test_if_degree_mode  
  beq     LF8CC  

XRAD_ROUTINE
  lda     #<const_pi_divided_by_180   
  ldy     #>const_pi_divided_by_180  
  jmp     LF184
 
const_pi_divided_by_180:
  .byt     $7B,$0E,$FA,$35,$19

test_if_degree_mode
  lda     FLGTEL
  and     #$20
LF8CC
  rts

XADNXT_ROUTINE  
  sta     RES
  sty     RES+1
  jsr     AY_add_acc1
  ldx     RES
  ldy     RES+1
  jmp     XA1XY_ROUTINE

LF8DB:
  jsr     LF9FC 
  bcc     LF8E7
  cmp     #$41
  bcc     LF915
  sbc     #$37
  .byt    $2C
LF8E7:
  sbc     #$2F
  cmp     #$10
  bcs     LF915
  asl   
  asl    
  asl    
  asl    
  ldx     #$04
LF8F3:
  asl    
  rol     MENDDY
  rol     ACC1M
  bcs     LF912
  dex
  bne     LF8F3
  beq     LF8DB
LF8FF:
  jsr     LF9FC
  bcs     LF915
  cmp     #$32
  bcs     LF915
  cmp     #$31
  rol     MENDDY
  rol     ACC1M
  bcs     LF912
  bcc     LF8FF
LF912:
  jmp     LF0C7 

LF915:
  ldx     #$90
  sec
  jsr     LF3DE 
  ldx     #$00
  rts  

;;;;;;;;;;;;;;; 
XDECA1_ROUTINE
  sta     RES
  sty     RES+1
  tsx
  stx     FLSVS
  lda     #$00
  sta     RESB
  sta     RESB+1
  sta     ACC1EX
  ldx     #$05
@L1:
  sta     ACC1E,x
  sta     ACC4E,x
  dex
  bpl     @L1
  jsr     LF9FE
  bcc     LF951
  cmp     #$23
  beq     LF8DB
  cmp     #$25
  beq     LF8FF
  cmp     #$2D
  beq     LF94C
  cmp     #$2B
  bne     LF953
  .byte   $2C
LF94C:
  stx     RESB+1
LF94E:
  jsr     LF9FC
LF951:
  bcc     LF9CD
LF953:
  cmp     #$2E
  beq     LF9A6
  cmp     #$45
  beq     LF95F
  cmp     #$65
  bne     LF9AC
LF95F:
  ldx     RESB
  jsr     LF9FC
  bcc     LF976
  cmp     #$2D
  beq     LF96F
  cmp     #$2B
  bne     LF998
  .byte   $2C
LF96F:
  ror     FLSVY
LF971:
  jsr     LF9FC
  bcs     LF99A
LF976:
  lda     FLDT1
  cmp     #$0A
  bcc     LF985
  lda     #$64
  bit     FLSVY
  bmi     LF993
  jmp     LF0C7

LF985:
  asl    
  asl    
  clc
  adc     FLDT1
  asl    
  clc
  ldy     RESB
  adc     (RES),y
  sec
  sbc     #$30
LF993:
  sta     FLDT1
  jmp     LF971
LF998:
  stx     RESB
LF99A:
  bit     FLSVY
  bpl     LF9AC
  lda     #$00
  sec
  sbc     FLDT1
  jmp     LF9AE

LF9A6:
  ror     FLDT2
  bit     FLDT2
  bvc     LF94E
LF9AC:
  lda     FLDT1
LF9AE:
  sec
  sbc     ACC4M
  sta     FLDT1
  beq     LF9C7
  bpl     LF9C0
LF9B7:
  jsr     acc1_1_divide_10_in_acc1
  inc     FLDT1
  bne     LF9B7
  beq     LF9C7
LF9C0:
  jsr     Lf242 
  dec     FLDT1
  bne     LF9C0
LF9C7:
  lda     RESB+1
  bmi     LF9E1
  bpl     LF9E4
LF9CD:
  pha
  bit     FLDT2
  bpl     LF9D4
  inc     ACC4M
LF9D4:
  jsr     Lf242
  pla
  sec
  sbc     #$30
  jsr     LF9E9
  jmp     LF94E

LF9E1:
  jsr     XNA1_ROUTINE
LF9E4:
  ldx     #$00
  jmp     XAA1_ROUTINE

LF9E9:
  pha
  jsr     XA1A2_ROUTINE
  pla
  jsr     LF3D1
  lda     ACC2S
  eor     ACC1S
  sta     ACCPS
  ldx     ACC1E
  jmp     XA1PA2_ROUTINE 
LF9FC:
  inc     RESB
LF9FE:
  ldy     RESB
  lda     (RES),y
  jsr     XMINMA_ROUTINE
  cmp     #$20
  beq     LF9FC 
  cmp     #$30
  bcc     LFA10
  cmp     #$3A
  rts

LFA10:
  sec
  rts


; ****** BEGIN CHARSET ********************



.include "functions/charsets/charset_qwerty.asm"  

.ifdef WITH_CHARSET_AZERTY
.include "functions/charsets/charset_azerty.asm"  
.endif

.include "functions/charsets/charset.asm"  
.include "functions/xloadcharset.asm"  

codes_for_calc_alternates:
  .byt     $00,$38,$07,$3f

XGOKBD_ROUTINE
  lda     #$B9 ;  index of alternate chars
.ifdef WITH_TWILIGHTE_BOARD
.else
  bit     FLGTEL
  bpl     @L1
  lda     #$9D ; FILL CHARSET ?
@L1:
.endif  
  ldy     #$00
  sty     RES
  sta     RES+1
  tya

@loop:
  pha
  jsr      put_an_alternate_char_in_memory
  pla
  clc
  adc     #$01
  cmp     #$40
  bne     @loop
 
  lda     RES+1
  sbc     #$03
  sta     TR0
  sbc     #$04
  sta     RES+1
  lda     #<charset_text
  ldy     #>charset_text
  sta     RESB
  sty     RESB+1
  ldy     #$00
loop70:
  ldx     #$00
  lda     (RESB,X)
  tax
  inc     RESB
  bne     @L1
  inc     RESB+1
@L1:
  jsr     routine_to_define_23 

  txa
  and     #$C0
  beq     loop70
  cmp     #$C0
  beq     @S1
  cmp     #$40
  beq     next76
  jsr     routine_to_define_23 
  
  .byt    $2c 
@S1:
  ldx     #$00

next76:  
  jsr     routine_to_define_23
  bne     loop70
  

  
routine_to_define_23:
  txa
  and     #$3F
  sta     (RES),Y
  iny
  bne     @skip
  inc     RES+1
  lda     RES+1
  cmp     TR0
  bne     @skip
  pla
  pla
@skip:
  rts

put_an_alternate_char_in_memory:
  ldx     #$03
  stx     RESB
next81:
  pha
  and     #$03
  tax
  lda     codes_for_calc_alternates,X
  sta     (RES),Y
  iny
  sta     (RES),Y
  iny
  ldx     RESB
  cpx     #$02
  beq     @skip
  sta     (RES),Y
  iny
  bne     @skip
  inc     RES+1
@skip:
  pla
  lsr
  lsr
  dec     RESB
  bne     next81
  rts
  

move_chars_text_to_hires:
  ldy     #$05
  .byt    $2c
move_chars_hires_to_text:
  ldy     #$0B
  ldx     #$05
@loop:
  lda     code_in_order_to_move_chars_tables,y 
  sta     DECDEB,x
  dey
  dex
  bpl     @loop
  jmp     XDECAL_ROUTINE

code_in_order_to_move_chars_tables
  ; Text to hires 6 bytes
  .byt    $00,$b4,$80,$BB,$00,$98
  ; hires to text 6 bytes
  .byt    $00,$98,$80,$9f,$00,$B4

XSCRNE_ROUTINE:
; define a char in the adress AY 
; it take the first byte : it's the ascii char
; Next 8 bytes is the definition of the char
  clc
  .byt    $24 ; jump a byte
Lfef9: 
  sec
  ror     RES
  sta     ADDRESS_READ_BETWEEN_BANK
  sty     ADDRESS_READ_BETWEEN_BANK+1

Lff00:
  ldy     #$00
  jsr     read_a_code_in_15_and_y 
  beq     Lff26
  jsr     ZADCHA_ROUTINE
  inc     ADDRESS_READ_BETWEEN_BANK

  bne     @loop
  inc     ADDRESS_READ_BETWEEN_BANK+1
@loop:
  jsr     read_a_code_in_15_and_y
  sta     (RESB),y
  iny
  cpy     #$08
  bne     @loop

  tya
  clc
  adc     ADDRESS_READ_BETWEEN_BANK
  sta     ADDRESS_READ_BETWEEN_BANK
  bcc     Lff00
  inc     ADDRESS_READ_BETWEEN_BANK+1
  bcs     Lff00
Lff26:
  rts
read_a_code_in_15_and_y:
  bit     RES
  bpl     @skip
  lda     (ADDRESS_READ_BETWEEN_BANK),y
  rts
@skip:
  jmp     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY

.ifdef WITH_ACIA
  KERN_ACIA_CONFIG=1
.else
  KERN_ACIA_CONFIG=0
.endif

.ifdef WITH_SDCARD_FOR_ROOT
  KERN_SDCARD_FOR_ROOT_CONFIG=2
.else
  KERN_SDCARD_FOR_ROOT_CONFIG=0
.endif

; Byte for compile options
kernel_compile_option:
  .byt    KERN_ACIA_CONFIG+KERN_SDCARD_FOR_ROOT_CONFIG



;$fff8-9 : copyright address
;$fffa : software version BCD : 1.4 -> $14
;$fffb : b7 if copyright
;  b6 : if it's autostart
;  b5 : 1 if rom, 0 if ram
;  b0,b3 : 7 for 8 KB, 16 for KB
;$fffc-d : adresse  d'execution
;$fffe-f :  IRQ (02fa)

signature:
  .byt     "Kernel-"
  .byt     __DATE__
.IFPC02
.pc02
  .byt     " 65C02"
.p02  
.else
  .byt     " 6502"
.endif  
  .byt     $00

kernel_version:
  .byt 0
  .byt 0
  .byt 1
  .byt 1 ; patch

free_bytes: ; 26 bytes
  .res     $FFF8-*
  .org     $FFF8

  .byt     <signature
  .byt     >signature

END_ROM:
; fffa
NMI:
  .byt     <start_rom,>start_rom
; fffc
RESET:
  .byt     <start_rom,>start_rom
; fffe
BRK_IRQ:  
  .byt     <IRQVECTOR,>IRQVECTOR

