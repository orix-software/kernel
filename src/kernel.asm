.FEATURE labels_without_colons, pc_assignment, loose_char_term, c_comments

.include   "telestrat.inc"          ; from cc65
.include   "fcntl.inc"              ; from cc65
.include   "stdio.inc"              ; from cc65
.include   "errno.inc"              ; from cc65
.include   "cpu.mac"                ; from cc65
.include   "libs/ch376-lib/include/ch376.inc"
.include   "orix.mac"
.include   "orix.inc"
.include   "build.inc"


ACIADR := $031C ; DATA REGISTER
ACIASR := $031D ; STATUS REGISTER
ACIACR := $031E ; command register
ACIACT := $031F ; control register


.org $C000
.code
telemon:
  SEI
  CLD
  LDX     #$FF
  TXS                         ; init stack
.IFPC02
.pc02
  stz     NEXT_STACK_BANK
.p02  
.else  
  inx
  stx     NEXT_STACK_BANK               ; Store in BNKCIB ?? ok but already init with label data_adress_418, when loading_vectors_telemon is executed
.endif

  jsr     init_screens
  
  jsr     init_via
  jsr     XLOADCHARSET_ROUTINE
  jsr     init_printer 
  jsr     XALLKB_ROUTINE
 
  ; lda   #$11
  ;sta $bb80


  LDX     #$0F
@loop:
  LSR     IOTAB0,X ; init channels (0 to 3)
  DEX
  bpl     @loop

  LDA     IRQVECTOR ; testing if IRQVECTOR low byte is $4C ?
  CMP     #$4C
  BNE     @L1 ; non equal to $4C
  LDA     KBDCOL+5
  AND     #$20
  BNE     @L1
@L1:

next1:
  LDX     #$2F
@loop:
  LDA     adress_of_adiodb_vector,X
  STA     ADIOB,X 
  DEX
  bpl     @loop

set_todefine6:
  LDX     #$04
@loop:
  LDA     data_to_define_6,X 
  STA     CSRND,X
  DEX
  bpl     @loop

  ldx     #$00

loading_vectors_telemon:
; This routine fills some memory with some code
; notice that $700 is fill but could be used for others things, because $700 will be in RAM overlay 
; This means that $700 could be erase. $600 should be deleted too (how many bytes ?), because some parts are used to read banks
@loop:
  LDA     loading_vectors_page_4,X    ; X should be equal to 0
  STA     ORIX_MEMORY_DRIVER_ADDRESS,X
  LDA     loading_code_to_page_6,X 
  STA     $0600,X
  LDA     data_to_define_4,X 
  STA     $0700,X                     ; used to copy in Overlay RAM ... see  loop40 label
  INX                                 ; loop until 256 bytes are filled
  bne     @loop

; Just fill ram with BUFROU
  JSR     $0600
 
compute_rom_ram:
; this code sets buffers
  LDA     #$00   ; Start from 0

@loop:
  PHA
  TAX     ; first loop X=0, it means that XDEFBU_ROUTINE call will set the first buffer in overlayram

  JSR     XDEFBU_ROUTINE 

  PLA
  CLC
  ADC     #$0C
  CMP     #$30
  bne     @loop
 
  JSR     XDEFBU_ROUTINE 
skip:
  LDA     #$00                        ; INIT VALUE of the rom to 0 bytes
  STA     KOROM

  LDA     #$40                        ; INIT VALUE of the RAM to 64 KBytes
  STA     KORAM
 
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

  LDX     #$0B                            ; copy to $2F4 12 bytes
@loop:
  LDA     data_vectors_VNMI_IRQVECTOR_VAPLIC,X ; SETUP VNMI, IRQVECTOR, VAPLIC
  STA     VNMI,X ; 
  DEX
  BPL     @loop

  JSR     init_keyboard

next5:

  LDA     KBDCOL+4 ; 
  AND     #$90
  BEQ     @skip
  LDA     FLGTEL
  ORA     #$40
  STA     FLGTEL
@skip:

  lda #$11
  sta $bb80+40

;  JSR     init_joystick ; $DFAB
  
.ifdef WITH_ACIA  
  JSR     init_rs232 ; $DB54 
.endif  
  lda     #XKBD ; Setup keyboard on channel 0
  BRK_TELEMON XOP0
  
  lda     #XSCR ; Setup screen !  on channel 0
  BRK_TELEMON XOP0 

  BRK_TELEMON XRECLK  ; Don't know this vector
  
  BIT     FLGRST ; COLD RESET ?
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


  LDA     KOROM
  JSR     telemon_convert_to_decimal
  PRINT str_KOROM


telemon_hot_reset
  nop ; keep theses nops, because hot reset won't work (still don't know why)

don_t_display_telemon_signature:
  lda     #<str_tofix
  ldy     #>str_tofix
  BRK_TELEMON XWSTR0

  ;JSR $0600 ; CORRECTME
    
don_t_display_signature:
  JSR     routine_to_define_19

  
display_cursor:

  LDX     #$00
  BRK_TELEMON XCSSCR ; display cursors

  
  ldx     #ORIX_ID_BANK
  stx     VAPLIC
  lda     #$00
  sta     VAPLIC+1
  ldy     #$C0
  sty     VAPLIC+2
 
call_routine_in_another_bank  
  STA     $0415 ; BNK_ADDRESS_TO_JUMP_LOW
  STY     $0416 ; BNK_ADDRESS_TO_JUMP_HIGH
  STX     BNKCIB
  JMP     SWITCH_TO_BANK_ID

routine_to_define_19:
  CLI
.ifdef WITH_TWILIGHTE_BOARD
.else  
  LDA     #$02
  STA     TIMEUD
@loop:
  LDA     TIMEUD
  BNE     @loop
.endif
  
  LDX     #$0C
  BRK_TELEMON XVIDBU              ; Flush buffers

.ifdef WITH_ACIA
  LDA     ACIACR
  AND     #$F3
  ORA     #$08
  STA     ACIACR
.endif

  rts


telemon_convert_to_decimal:
; FIXME macro
  LDY     #$00 ; 00
  LDX     #$20 ;
  STX     DEFAFF
  LDX     #$01
  JMP     XDECIM_ROUTINE 

init_via:
  lda     #$7F 
  sta     VIA::IER ; Initialize via1
  sta     VIA2::IER ; Initialize via2
  
.ifdef WITH_ACIA
  sta     ACIASR ; Init ACIA
.endif

  lda     #$FF
  sta     VIA::DDRA
  
  LDA     #$F7
  STA     VIA::PRB
  STA     VIA::DDRB

.ifdef WITH_32BANKS
  LDA     #%00000111 ; Switch to bank7
  STA     VIA2::PRA
  lda     #%00011111 ; But manage 31 banks
  STA     VIA2::DDRA
.else
  LDA     #$17 ; 0001 0111
  STA     VIA2::PRA
  STA     VIA2::DDRA
.endif

  LDA     #$E0 ; %1110 0000
  STA     VIA2::PRB
  STA     VIA2::DDRB

  LDA     #$CC
  STA     VIA::PCR
  STA     VIA2::PCR

  RTS

loading_code_to_page_6:
  lda     #$00 ; 2 bytes
  sta     VIA2::PRA ; 3 bytes ; switch to overlay ram ?

  lda     #$00
  TAX
@loop:
  LDA     $0700,X
  STA     BUFROU,X ; store data in c500 
  INX
  BNE     @loop ; copy 256 bytes to BUFROU in OVERLAY RAM
 

  LDX     #$07 ; loops with all banks
  STX     VIA2::PRA ; Switch to each Bank ;
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
  .ASCIIZ     " Ko RAM,"
str_KOROM:
  .byte     " Ko ROM"," - "
  .byt    __DATE__
  .byt      $00

str_tofix:
  .byt     $0D,$18,$00

data_to_define_6:
  ; FIVE Bbytes to load in CSRND
  .byt     $80,$4F,$C7,$52,$58

  
XDEFBU_ROUTINE:
  STX     RESB ; store the id of the buffer to set
  TXA     ; save A
  LDX     #$FF 
@loop:
  SEC
  SBC     #$03 ; let's loop to get the right buffer table 
  INX
  BCS     @loop

  LDA     orix_buffer_table,X 
  STA     RES
  LDA     orix_buffer_table+1,X ; Get high adress of the buffer
  STA     RES+1
  
  LDA     end_keyboard_buffer,X
  LDY     end_keyboard_buffer+1,X 

  LDX     RESB

XINIBU_ROUTINE:
  BIT     XLISBU_ROUTINE
  BVC     skip2003

XVIDBU_ROUTINE: 
  LDA     #$00
  .byt    $2c
XTSTBU_ROUTINE: 
  lda     #$01
  bit     code_adress_400

skip2003:
  SEC
  
  JMP     ORIX_MEMORY_DRIVER_ADDRESS+9
XLISBU_ROUTINE:
  bit     XLISBU_ROUTINE
  BVC     skipme2002
XECRBU_ROUTINE: 
  bit     loading_vectors_page_4
skipme2002:
  CLC
  JMP     ORIX_MEMORY_DRIVER_ADDRESS+9

;*********************************************************************************  
; CODE INSERTED IN PAGE 4  
;*********************************************************************************  
begin_of_copy_page4:
loading_vectors_page_4:
code_adress_400:
  JMP     $0493 ;code_adress_493
code_adress_403:
  JMP     $04A1 ;code_adress_4A1
code_adress_406:  
  JMP     $047E ; see code_adress_47E
code_adress_409:  
  JMP     $0419 ; see code_adress_419  
code_adress_40c:
  JMP     $0436 ; 436 see  code_adress_436
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
  PHP
  SEI
  PHA
  LDA     VIA2::PRA
  AND     #%11111000 ; switch to OVERLAY RAM
  STA     VIA2::PRA
  PLA
  JSR     BUFROU     ; Read buffer
  TAY            ; A contains the value read in the buffer, backup it
  LDA     VIA2::PRA
  ORA     #$07
  STA     VIA2::PRA
  ROR
  PLP
  ASL 
  TYA
  RTS

code_adress_436:
  PHP
  SEI
  PHA
  TXA
  PHA
  
  LDA     VIA2::PRA
  LDX     NEXT_STACK_BANK
  
  STA     STACK_BANK,X ; FIXME
  INC     NEXT_STACK_BANK   ; FIXME
  PLA
  TAX
  LDA     BNKCIB
  JSR     $046A ; see code_adress_46A  
 
  PLA
  PLP
  JSR     VEXBNK

  PHP
  SEI
  PHA
  TXA
  PHA
  DEC     NEXT_STACK_BANK
  LDX     NEXT_STACK_BANK
  LDA     STACK_BANK,X
  JSR     $046A ; FIXME
  PLA
  TAX
  PLA
  PLP
  RTS	

code_adress_46A:
  PHP
  SEI
  AND     #$07
  STA     FIXME_DUNNO
  LDA     VIA2::PRA
  AND     #$F8
  ORA     FIXME_DUNNO
  STA     VIA2::PRA
  PLP
  RTS
code_adress_47E:  ; brk gestion 
  STA     IRQSVA
  LDA     VIA2::PRA
  AND     #$07      
  STA     BNKOLD ; store old bank before interrupt ?
  LDA     VIA2::PRA  ; Switch to telemon bank and jump
  ORA     #$07
  STA     VIA2::PRA
  JMP     brk_management   
code_adress_493
  LDA     VIA2::PRA
  AND     #$F8
  ORA     BNKOLD
  STA     VIA2::PRA
  LDA     IRQSVA
  RTI
code_adress_4A1
  PHA
  LDA     VIA2::PRA
  AND     #$F8
  ORA     BNK_TO_SWITCH
  STA     VIA2::PRA
  PLA
  RTS

  
; this routine read a value in a bank
; 
code_adress_4AF  
  LDA     VIA2::PRA
.ifdef EXTEND_TO_31_BANK
  AND     #%11100000
.else
  AND     #%11111000                     ; switch to RAM overlay
.endif
  ORA     BNK_TO_SWITCH                  ; but select a bank in BNK_TO_SWITCH
  STA     VIA2::PRA
  LDA     (ADDRESS_READ_BETWEEN_BANK),Y  ; Read byte
  PHA                                 
  LDA     VIA2::PRA
  ORA     #%00000111                     ; Return to telemon
  STA     VIA2::PRA
  PLA                                    ; Get the value
  RTS
  nop
  nop
  ; Stack used to switch from any bank
code_adress_get
; used in bank command in Oric

  LDA     VIA2::PRA
.ifdef EXTEND_TO_31_BANK
  AND     #%11100000
.else
  AND     #%11111000                     ; switch to RAM overlay
.endif
; switch to RAM overlay
  ora     tmp1                           ; but select a bank in $410
  STA     VIA2::PRA
  LDA     (ptr1),Y                       ; Read byte
  PHA   
  lda     #ORIX_ID_BANK
  sta     VIA2::PRA
  PLA                                ; Get the value
  RTS
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
  PHA
  LDA     BUFBUF+8,X 
  CMP     BUFBUF+$0A,X
  LDA     BUFBUF+9,X 
  SBC     BUFBUF+$0B,X
  BCS     LC68F 
  LDA     BUFBUF+4,X
  LDY     BUFBUF+5,X
  JSR     $C5A6  ; FIXME
  STA     BUFBUF+4,X 
  TYA
  STA     BUFBUF+5,X 
  INC     BUFBUF+8,X 
  BNE     LC688
  INC     BUFBUF+9,X 
LC688:  
  ; 65C02 FIXME : use sta (XX)
  LDY #$00
  PLA
  STA (IRQSVP),Y
  CLC
  RTS
LC68F:
  PLA
  RTS
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
  SBC     BUFBUF+3,X 
  BCC     next36 
  LDA     BUFBUF,X 
  LDY     BUFBUF+1,X
  STA     IRQSVP
next36
  STY     FIXME_PAGE0_0 ; FIXME
  LDA     IRQSVP
  RTS

  
orix_buffer_table  
  .byt     <TELEMON_KEYBOARD_BUFFER_BEGIN,>TELEMON_KEYBOARD_BUFFER_BEGIN        ; Keyboard buffer begin $c5c4
end_keyboard_buffer  
  .byt     <TELEMON_KEYBOARD_BUFFER_END,>TELEMON_KEYBOARD_BUFFER_END            ; keyboard buffer end $c680
  .byt     <TELEMON_ACIA_BUFFER_INPUT_BEGIN,>TELEMON_ACIA_BUFFER_INPUT_BEGIN    ; buffer acia input begin
  .byt     <TELEMON_ACIA_BUFFER_INPUT_END,>TELEMON_ACIA_BUFFER_INPUT_END        ; buffer acia input end
  .byt     <TELEMON_ACIA_BUFFER_OUTPUT_BEGIN,>TELEMON_ACIA_BUFFER_OUTPUT_BEGIN  ; buffer acia output begin
  .byt     <TELEMON_ACIA_BUFFER_OUTPUT_END,>TELEMON_ACIA_BUFFER_OUTPUT_END      ; buffer acia output end
  .byt     <TELEMON_PRINTER_BUFFER_BEGIN,>TELEMON_PRINTER_BUFFER_BEGIN          ; buffer printer output begin
  .byt     <TELEMON_PRINTER_BUFFER_END,>TELEMON_PRINTER_BUFFER_END              ; buffer printer output end


.include  "functions/XOP.asm"
.include  "functions/XCL.asm"

XCRLF_ROUTINE
  lda     #$0A
  jsr     XWR0_ROUTINE 
  lda     #$0D

Lc75d  
; NOERROR

.include  "functions/XWRx.asm"
.include  "functions/XWSTRx.asm"
.include  "functions/XRDW.asm"
.include  "functions/XWRD.asm"  
.include  "functions/xmalloc.asm"

send_command_A:
  STY     ADDRESS_VECTOR_FOR_ADIOB
  STY     ADDRESS_VECTOR_FOR_ADIOB+1 
  PHA
  TXA
  ASL
  TAX
  LDA     ADIOB,X
  STA     ADIODB_VECTOR+1
  LDA     ADIOB+1,X
  STA     ADIODB_VECTOR+2
  PLA
  LSR     ADDRESS_VECTOR_FOR_ADIOB
  BIT     ADDRESS_VECTOR_FOR_ADIOB+1
  JMP     ADIODB_VECTOR

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
  STX     IRQSVX ; save register X
  STY     IRQSVY ; save register 
.endif
  PLA ; pull P (flag register)
  STA     IRQSVP ; save P (flag register)
  AND     #%00010000 ; test B flag B flag means an that we reach a brk commands
  BEQ     LC8B3 ; is it a break ?
  TSX     ; yes we get Stack pointer
  PLA     ; we pull pointer program +2 

  BNE     @skip
  DEC     BUFTRV+2,X ; CORRECTME
@skip:
reset115_labels:
  SEC
  SBC     #$01
  PHA
  STA     ADDRESS_READ_BETWEEN_BANK
  LDA     BUFTRV+2,X
  STA     ADDRESS_READ_BETWEEN_BANK+1
  LDA     BNKOLD
  STA     BNK_TO_SWITCH
  LDY     #$00
  JSR     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
  ASL
  TAX
  LDA     #$04
  PHA
  LDA     #$02
  PHA
  LDA     vectors_telemon+1,X ; fetch vector of brk
  LDY     vectors_telemon,X 
 
  BCC     @skip
  LDA     vectors_telemon_second_table+1,X ; Second table because X >127 
  LDY     vectors_telemon_second_table,X ;
@skip:

  ; push A and Y vector : when RTI is reached, the stack contains the vector to execute
  PHA
  TYA
  PHA 
  LDA     IRQSVP  ; fetch P flag
  PHA ; push P flag to return in correct state
  LDA     IRQSVA

.IFPC02
.pc02
  ply
  plx
.p02
.else  
  LDY     IRQSVY
  LDX     IRQSVX
.endif
  RTI
LC8B3
next200
  LDA     IRQSVP ; fetch P flag
  PHA ; push P flag to return in correct state
LC8B6    
  SEC
  ROR     TRANSITION_RS232
LC8B9
  JSR     routine_to_define_12
.ifdef    WITH_MULTITASKING
  jsr     _multitasking
.endif
  JMP     LC9b9  


; routine BRK ?
routine_to_define_12:
.ifdef WITH_ACIA
  TYA
  PHA
  LDA     ACIASR 
  BPL     next23
  LSR     TRANSITION_RS232
  PHA
  AND     #$08
  BEQ     next24
  LDX     ACIADR
  PLA
  PHA
  AND     #$07
  BEQ     @skip
  ORA     #$B0
  .byt     $24 ; jump one byte
@skip:
  txa

  LDX     #$0C
  JSR     XECRBU_ROUTINE

next24

  PLA
  AND     #$10
  BEQ     next23
  LDX     #$18 
  JSR     XTSTBU_ROUTINE; CORRECTME
  BCS     next26

  LDA     ACIASR
  AND     #$20
  BNE     next23

  JSR     XLISBU_ROUTINE 

  STA     ACIADR
  LDA     ACIACT
  AND     #$07
  STA     $3F ; FIXME
  BCC     next23

next26
  INC     $20 ; FIXME
  BNE     next23
  DEC     $3F ; FIXME
  BNE     next23
  LDA     FLGLPR
  LSR
  LSR 
  LSR


  LDA     ACIACR
  AND     #$F3
  BCC     @skip
  AND     #$FE
@skip:
  STA     ACIACR
next23:
  PLA
Lc91c:
  TAY
Lc91d:
.endif
  RTS

Lc91e:
  DEC     FLGCLK_FLAG
  BNE     Lc973
  LDA     #$04
  STA     FLGCLK_FLAG
  BIT     FLGLPR

  BPL     @skip
  JSR     manage_printer
@skip:

timeud_next:
  LDA     TIMEUD

  BNE     @skip
  DEC     TIMEUD+1
@skip:
skipme12:
  DEC     TIMEUD
  SEC
  INC     TIMED
  LDA     TIMED
  SBC     #$0A
  BCC     Lc973
  STA     TIMED
  BIT     FLGCLK

  BPL     @skip
  JSR     Lca75 
@skip:


  INC     TIMES
  LDA     TIMEUS
  BNE     @L1
  DEC     TIMEUS+1
@L1:
  DEC     TIMEUS
  LDA     TIMES
  SBC     #$3C
  BCC     Lc973
  STA     TIMES
  INC     TIMEM
  LDA     TIMEM
  SBC     #$3C
  BCC     Lc973
  STA     TIMEM
  INC     TIMEH
Lc973:

  DEC     FLGCUR
  BNE     @L3
  LDA     #$0A
  STA     FLGCUR
  LDA     FLGCUR_STATE
  EOR     #$80
  STA     FLGCUR_STATE
  BIT     FLGSCR
  BPL     @L3
  BVS     @L3
  LDX     SCRNB
  JMP     LDE2D 
@L3:
  RTS

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
  bcc     C9b1
  jsr     le085 
  jmp     LC8B9 

routine_todefine_1:
C9b1
  LDA     #$FF
  STA     VIA::T2+1
  JMP     LC8B9 
LC9b9  
  BIT     VIA::IFR

  BMI     next110
  BIT     TRANSITION_RS232
  BPL     next111
  LDX     IRQSVX
  LDY     IRQSVY
  JMP     ORIX_MEMORY_DRIVER_ADDRESS
next111:  
  JMP     LC8B6 
next110:
  LSR     TRANSITION_RS232
  BIT     VIA::IFR
  BVC     next112
  BIT     VIA::T1
  JSR     Lc91e 
  DEC     KEYBOARD_COUNTER
  BNE     next113 
  JSR     _manage_keyboard 
  JSR     routine_to_define_12
  BIT     KBDFLG_KEY 
  BPL     @next114 
  LDA     #$14 
  STA     KEYBOARD_COUNTER+1
  BNE     @L5
@next114:
  LDA     KEYBOARD_COUNTER+2 
  BIT     KEYBOARD_COUNTER+1 
  BMI     @skip
  DEC     KEYBOARD_COUNTER+1 
@L5:
  LDA     #$01
@skip:  
  STA     KEYBOARD_COUNTER ;
next113  
  BIT     FLGJCK
  BPL     Lca0b 
  JSR     Ldffa 
  BIT     FLGJCK
Lca0b  
  BVC     Lca10
  
  JSR     Ldffb
Lca10:
  LDA     FLGJCK
  LSR
  BCC     LCA19 
  JSR     Le0e1 
LCA19: 
  JMP     LC8B9 
Lca1c:
  JMP     manage_irq_T1_and_T2
next112
  LDA     VIA::IFR
  AND     #$02
  BEQ     Lca1c
  BIT     VIA::PRA
  JSR     manage_printer 
  JMP     LC8B9

.proc manage_printer
  LDX     #$24
  JSR     XLISBU_ROUTINE 
  BCC     @skip
  ASL     FLGLPR ; printer
  SEC
  ROR     FLGLPR ; printer
  RTS
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

XRECLK_ROUTINE:
  lda     #$00
  ldx     #$04
@loop:
  sta     TIMED,x
  dex
  bpl     @loop
  lda     #$01
  sta     FLGCLK_FLAG
  rts
  
XCLCL_ROUTINE:
  lsr     FLGCLK
  rts

XWRCLK_ROUTINE:
  php
  sei
  sta     ADCLK
  sty     ADCLK+1
  sec
  ror     FLGCLK
  plp
  rts
  
Lca75:
  LDY     #$00
  LDA     TIMEH
  JSR     telemon_display_clock_chars
  LDA     #$3A
  STA     (ADCLK),Y
  INY
  LDA     TIMEM
  JSR     telemon_display_clock_chars
  LDA     #$3A
  STA     (ADCLK),Y
  INY
  LDA     TIMES
telemon_display_clock_chars:
; display clock at the adress specified  
  LDX     #$2F
  SEC
@loop:
  SBC     #$0A
  INX
  BCS     @loop
  PHA
  TXA
  STA     (ADCLK),Y
  PLA
  INY
  ADC     #$3A
  STA     (ADCLK),Y
  INY
  RTS

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
  .byt     <XEFFHI_ROUTINE,>XEFFHI_ROUTINE ; XEFFHI ; 1b
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
  .byt     <XA1AFF_ROUTINE,>XA1AFF_ROUTINE ; XA1AFF  $2b
  .byt     <XMAINARGS_ROUTINE,>XMAINARGS_ROUTINE
  ;.byt     $00,$00
  .byt     $00,$00
  .byt     $00,$00 
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
  .byt     <XRECLK_ROUTINE,>XRECLK_ROUTINE ; $3c
  .byt     <XCLCL_ROUTINE,>XCLCL_ROUTINE ; $3d
  .byt     <XWRCLK_ROUTINE,>XWRCLK_ROUTINE ; $3e
  .byt     <XFSEEK_ROUTINE,>XFSEEK_ROUTINE ; fseek $3f
  
  
  .byt     <XSONPS_ROUTINE,>XSONPS_ROUTINE ; $40
  .byt     <XEPSG_ROUTINE,>XEPSG_ROUTINE ; $41
  .byt     <XOUPS_ROUTINE,>XOUPS_ROUTINE ; $42 XOUPS ddd8
  .byt     <XPLAY_ROUTINE,>XPLAY_ROUTINE ;XPLAY $43
  .byt     <XSOUND_ROUTINE,>XSOUND_ROUTINE ; $44
  .byt <XMUSIC_ROUTINE,>XMUSIC_ROUTINE ; $45
  .byt <XZAP_ROUTINE,>XZAP_ROUTINE ; $46
  .byt <XSHOOT_ROUTINE,>XSHOOT_ROUTINE ; 47
  .byt $00,$00 ; $48
  .byt $00,$00 ; $49
  .byt $00,$00 ; $4a
  .byt <XMKDIR_ROUTINE,>XMKDIR_ROUTINE       ; $4b
  .byt <XHCHRS_ROUTINE,>XHCHRS_ROUTINE ; $4c
  .byt <XRM_ROUTINE,>XRM_ROUTINE       ; $4D
  ;.byt $00,$00 ; $4d
  .byt $00,$00 ; $4e
  .byt $00,$00 ; $4f
  .byt <XALLKB_ROUTINE,>XALLKB_ROUTINE ; $50
  .byt <XKBDAS_ROUTINE,>XKBDAS_ROUTINE ; $51
  .byt $00,$00 ; $52
  .byt $00,$00 ; $53
  .byt <XECRBU_ROUTINE,>XECRBU_ROUTINE ; $54
  .byt <XLISBU_ROUTINE,>XLISBU_ROUTINE ; $55
  .byt <XTSTBU_ROUTINE,>XTSTBU_ROUTINE ; $56
  .byt <XVIDBU_ROUTINE,>XVIDBU_ROUTINE ; $57
  .byt <XINIBU_ROUTINE,>XINIBU_ROUTINE ; $58
  .byt <XDEFBU_ROUTINE,>XDEFBU_ROUTINE ; $59
  .byt <XBUSY_ROUTINE,>XBUSY_ROUTINE   ; $5a

  .byt <XMALLOC_ROUTINE,>XMALLOC_ROUTINE                         ; $5b
  .byt <XSDUMP_ROUTINE,>XSDUMP_ROUTINE ; $5c
  .byt <XCONSO_ROUTINE,>XCONSO_ROUTINE ; $5d
  .byt <XSLOAD_ROUTINE,>XSLOAD_ROUTINE ; $5e
  .byt <XSSAVE_ROUTINE,>XSSAVE_ROUTINE ; $5f
  .byt <XMLOAD_ROUTINE,>XMLOAD_ROUTINE ; $60 
  .byt <XMSAVE_ROUTINE,>XMSAVE_ROUTINE ; $61
  .byt <XFREE_ROUTINE,>XFREE_ROUTINE   ; $62
  .byt <XEXEC_ROUTINE,>XEXEC_ROUTINE
  .byt $00,$00
  .byt $00,$00
  .byt $00,$00
  .byt <XSOUT_ROUTINE,>XSOUT_ROUTINE
  .byt <XA1DEC_ROUTINE,>XA1DEC_ROUTINE
  .byt <XDECA1_ROUTINE,>XDECA1_ROUTINE
  .byt <XA1PA2_ROUTINE,>XA1PA2_ROUTINE
  .byt <XA2NA1_ROUTINE,>XA2NA1_ROUTINE
  .byt <XA1MA2_ROUTINE,>XA1MA2_ROUTINE
  .byt <XA2DA1_ROUTINE,>XA2DA1_ROUTINE
  .byt <XA2EA1_ROUTINE,>XA2EA1_ROUTINE
  .byt <XNA1_ROUTINE,>XNA1_ROUTINE
  .byt <XSIN_ROUTINE,>XSIN_ROUTINE
  .byt <XCOS_ROUTINE,>XCOS_ROUTINE
  .byt <XTAN_ROUTINE,>XTAN_ROUTINE
  .byt <XATN_ROUTINE,>XATN_ROUTINE
  .byt <XEXP_ROUTINE,>XEXP_ROUTINE
  .byt <XLN_ROUTINE,>XLN_ROUTINE
  .byt <XLOG_ROUTINE,>XLOG_ROUTINE
  .byt <XRND_ROUTINE,>XRND_ROUTINE
  .byt <XSQR_ROUTINE,>XSQR_ROUTINE
  .byt <XRAD_ROUTINE,>XRAD_ROUTINE
  .byt <XDEG_ROUTINE,>XDEG_ROUTINE
  .byt <XINT_ROUTINE,>XINT_ROUTINE
  .byt <XPI_ROUTINE,>XPI_ROUTINE
  .byt <XRAND_ROUTINE,>XRAND_ROUTINE
  .byt <XA1A2_ROUTINE,>XA1A2_ROUTINE
  .byt <XA2A1_ROUTINE,>XA2A1_ROUTINE
vectors_telemon_second_table:  
  .byt <XIYAA1_ROUTINE,>XIYAA1_ROUTINE
  .byt <XAYA1_ROUTINE,>XAYA1_ROUTINE
  .byt <XA1IAY_ROUTINE,>XA1IAY_ROUTINE
  .byt <XA1XY_ROUTINE,>XA1XY_ROUTINE

  .byt <XAA1_ROUTINE,>XAA1_ROUTINE
  .byt <XADNXT_ROUTINE,>XADNXT_ROUTINE
  .byt <XINTEG_ROUTINE,>XINTEG_ROUTINE
  .byt $00,$00
  .byt <XHRSCG_ROUTINE,>XHRSCG_ROUTINE
  .byt <XHRSCD_ROUTINE,>XHRSCD_ROUTINE
  .byt <XHRSCB_ROUTINE,>XHRSCB_ROUTINE
  .byt <XHRSCH_ROUTINE,>XHRSCH_ROUTINE
  .byt <XHRSSE_ROUTINE,>XHRSSE_ROUTINE
  .byt <XDRAWA_ROUTINE,>XDRAWA_ROUTINE
  .byt <XDRAWR_ROUTINE,>XDRAWR_ROUTINE
  .byt <XCIRCL_ROUTINE,>XCIRCL_ROUTINE
  .byt <XCURSE_ROUTINE,>XCURSE_ROUTINE
  .byt <XCURMO_ROUTINE,>XCURMO_ROUTINE
  .byt <XPAPER_ROUTINE,>XPAPER_ROUTINE  
  .byt <XINK_ROUTINE,>XINK_ROUTINE ; Xink $93
  .byt <XBOX_ROUTINE,>XBOX_ROUTINE
  .byt <XABOX_ROUTINE,>XABOX_ROUTINE; $95
  .byt <XFILL_ROUTINE,>XFILL_ROUTINE
  .byt <XCHAR_ROUTINE,>XCHAR_ROUTINE ;$97
  .byt <XSCHAR_ROUTINE,>XSCHAR_ROUTINE ; 98
  .byt $00,$00 ; nothing $99
  .byt $00,$00 ; nothing $9a
  .byt $00,$00 ; nothing $9b
  .byt <XEXPLO_ROUTINE,>XEXPLO_ROUTINE ; $9c
  .byt <XPING_ROUTINE,>XPING_ROUTINE ; $9d

.include  "libs/ch376-lib/src/ch376.s"
XCHECK_VERIFY_USBDRIVE_READY_ROUTINE:
.include  "include/libs/xa65/ch376_verify.s"

XCLOSE_ROUTINE:
  jmp     _ch376_file_close

XFREAD_ROUTINE:
XREADBYTES_ROUTINE:
.include  "functions/xread.asm"
XWRITEBYTES_ROUTINE:
.include  "functions/xwrite.asm"
XFSEEK_ROUTINE:
.include  "functions/xfseek.asm"



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
  lda     $69
  ldy     $6A
  sta     ADDRESS_READ_BETWEEN_BANK
  sty     ADDRESS_READ_BETWEEN_BANK+1
  ldy     #$00
Lcd0c:
  dex
  beq     Lcd20
Lcd0f:
  iny 
  bne Lcd14
  inc ADDRESS_READ_BETWEEN_BANK+1
Lcd14  
  jsr ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
  bne Lcd0f
  
  iny
  bne Lcd0c
  inc ADDRESS_READ_BETWEEN_BANK+1
  bne Lcd0c
Lcd20  
  ldx ADDRESS_READ_BETWEEN_BANK+1
  clc
  tya
  adc ADDRESS_READ_BETWEEN_BANK
  bcc Lcd29 
  inx
Lcd29  
  sta RESB
  stx RESB+1
  lda #$20
  sta DEFAFF
  pla
  clc
  adc #$01
  ldy #$00
  ldx #$01 
  jsr XDECIM_ROUTINE 
  
  lda #$20
  jsr XWR0_ROUTINE
  lda RESB
  ldy RESB+1
  jsr XWSTR0_ROUTINE
  ldy #$01
  jsr ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
  sec
  beq Lcd51 
  clc
Lcd51  
  ror $68
  pla
  tax
  pla
  tay
  bit $68
  rts

put_cursor_in_61_x  
  lda #$1f
  jsr XWR0_ROUTINE
  tya
  ora #$40
  jsr XWR0_ROUTINE 
  lda ACC1M
  ora #$40
  jmp XWR0_ROUTINE 

  
XDECAL_ROUTINE  
.include  "functions/xdecal.asm"

data_for_decimal_conversion
const_10_decimal_low
  .byt $0a ; 19
const_100_decimal_low

  .byt $64 ; 100 
const_1000_decimal_low  ; $3e8=1000
  .byt $e8
const_10000_decimal_low  ; $3e8=1000  
  .byt $10
const_10_decimal_high
  .byt $00
  .byt $00
  .byt $03
  .byt $27

Lcde5  
  ldx #$00
  ldy #$00
  .byt $2c


convert_into_decimal_0_to_65535
  
  ldx #$03
  .byt $2c

convert_into_decimal_0_to_9999
  ldx #$02

; Don't put anything here ...
  
  
XBINDX_ROUTINE
.include  "functions/xbindx.asm"

; and here because code above needs to go to xbindx routine

XDECIM_ROUTINE
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

  
.include  "functions/xmkdir.asm"  
.include  "functions/xrm.asm"  

XEFFHI_ROUTINE:
  lda #<$A000
  ldy #>$A000
  sta RES
  sty RES+1
  ldy #<$BF68
  ldx #>$BF68
  lda #$40

XFILLM_ROUTINE
.include  "functions/xfillm.asm"  
  
XHIRES_ROUTINE
.include  "functions/xhires.asm"  
  
XTEXT_ROUTINE
.include  "functions/xtext.asm"


.include  "functions/xfree.asm"

.include  "functions/mainargs.asm"


_multitasking:
  ;LIST_PID
  ;ORIX_CURRENT_PROCESS_FOREGROUND
  rts
  
wait_0_3_seconds: ; Wait 0,3333 seconds 
  ldy     #$1F
  ldx     #$00
@loop:
  dex
  bne     @loop
  dey
  bne     @loop
  rts
 
test_if_all_buffers_are_empty:

  sec
  .byt $24 ; jump
XBUSY_ROUTINE  
  clc
  ror ADDRESS_READ_BETWEEN_BANK
  ldx #0
Lcfb6  
  jsr XTSTBU_ROUTINE 
  bcc Lcfc3 
  txa
  adc #$0B
  tax
  cpx #$30
  bne Lcfb6 
Lcfc3  
  php
  lda #<table_to_define_prompt_charset
  ldy #>table_to_define_prompt_charset
  bcs Lcfce 
  lda #<table_to_define_prompt_charset_empty
  ldy #>table_to_define_prompt_charset_empty
Lcfce  
  bit ADDRESS_READ_BETWEEN_BANK
  bpl Lcfd7 
  jsr Lfef9 
  plp
  rts
Lcfd7  
  jsr Lfef9 
  plp
  rts
  

table_to_define_prompt_charset
  .byt     $7f ; char 127
  .byt     $00,$00,$08,$3c,$3e,$3c,$08,$00,$00
table_to_define_prompt_charset_empty  
  .byt     $7f,$00,$00,$08,$34,$32,$34,$08,$00,$00

XEXEC_ROUTINE
    rts


; This primitive will get the address of variables built in telemon and orix.  

XVARS_ROUTINE:
  lda     XVARS_TABLE_LOW,x
  ldy     XVARS_TABLE_HIGH,x
  rts
XVARS_TABLE:
XVARS_TABLE_LOW;
  .byt     <ORIX_PATH_CURRENT ; pwd
  
XVARS_TABLE_HIGH
  .byt     >ORIX_PATH_CURRENT ; pwd

  
XMINMA_ROUTINE:
  cmp     #"a" ; 'a'
  bcc     @skip
  cmp     #$7b ; 'z'
  bcs     @skip
  sbc     #$1f
@skip:
  rts
  

CTRL_G_KEYBOARD ; Send oups
  jmp     XOUPS_ROUTINE 

CTRL_O_KEYBOARD
  rts

.proc _manage_keyboard

  jsr     XALLKB_ROUTINE 
  beq     Ld812
  ldx     KBDFLG_KEY
  bpl     skip 
  lda     KBD_UNKNOWN   ; CORRECTME
  and     $01e8,x
  bne     Ld807
skip:
  dey
  lda     KBDCOL,y
  sta     KBD_UNKNOWN  ; CORRECTME
  tya
  ora     #$80
  sta     KBDFLG_KEY
  jsr     XKBDAS_ROUTINE  ; convert in ascii and manage buffer
;  CLD
  LDA     KBDVRR 
  JMP     next60
Ld807:  
  DEC KBDVRL+1  ; CORRECTME
  BNE end2 
  JSR XKBDAS_ROUTINE
  JMP Ld815
Ld812:
  STA KBDFLG_KEY ; CORRECTME
Ld815:
  LDA KBDVRL 
next60:
  STA KBDVRL+1 ; CORRECTME
end2:
  RTS
.endproc 
next75
  jmp     manage_function_key

XKBDAS_ROUTINE:
  JSR     routine_to_define_12 ; manage rs232
  LDA     #$00
  PHA
  LDA KBDFLG_KEY 
  ASL
  ASL
  ASL
  TAY
  LDA KBD_UNKNOWN ;
next63
  LSR
  BCS @skip
  INY
  BCC next63
@skip:
  LDA KBDCOL+4
  TAX
  AND     #$90
  BEQ next64
  PLA
  ORA #$01
  PHA
  TYA
  ADC #$3F
  TAY
next64
  TYA
  CMP #$20
  BCC next65
  SBC #$08
  CMP #$58
  BCC next66
  SBC #$08
next66
  TAY
next65
  TXA
  AND #$20
  BNE next75 
  LDA (ADKBD),Y 
  BIT FLGKBD 
  BPL next67
  CMP #$61
  BCC next67
  CMP #$7B
  BCS next67
  SBC #$1F
next67
  TAY
  TXA
  AND #$04
  BEQ     next68
  AND     KBDCOL+7 
  BEQ     @skip
  LDA     #$80
  STA     KBDCTC 
@skip:

  PLA
  ORA     #$80
  PHA
  TYA
  AND #$1F
  TAY
next68
  TYA
Ld882  
  LDX #$00
  PHA
  CMP #$06
  BNE     @skip
  LDA     FLGKBD ; CORRECTME
  EOR     #$40
  BCS     next71
@skip:

  CMP     #$14
  BEQ     next72
  CMP #$17
  BNE next73
  LDA FLGKBD
  EOR #$20
  BCS next71
next73
  CMP #$1B
  BNE next74
  LDA FLGKBD
  AND #$20
  BEQ next74
  PLA
  LDA #$00
  PHA
next72
  LDA FLGKBD 
  EOR #$80
next71:
  STA FLGKBD
next74:
  PLA
  LDX #$00
  JSR XECRBU_ROUTINE
  PLA
  LDX #$00
  JSR XECRBU_ROUTINE
  BIT FLGKBD

  BVC     @skip
  LDX     #<sound_bip_keyboard
  LDY     #>sound_bip_keyboard
  JMP     send_14_paramaters_to_psg
@skip:

  RTS

sound_bip_keyboard:
  .byt     $1f
  .byt     $00,$00,$00,$00,$00,$00
  .byt     $3e,$10,$00,$00
  .byt     $1f,$00,$00
; END bip keyboard

manage_function_key:
  lda     (ADKBD),y
  cmp     #$2D
  beq     Ld8f8 
  cmp     #$3d
  beq     Ld8fb 
  pla
  ora     #$40
  pha
  lda     FLGKBD
  lsr
  bcs     Ld900 
  lda     (ADKBD),y
  and     #$1f
  ora     #$80
  .byt     $2c
Ld8f8  
  lda     #$60
  .byt     $2C
Ld8fb  
  lda     #$7e
  jmp     Ld882 
Ld900:
  jmp     (KBDFCT) ; Jump into function key vector

XALLKB_ROUTINE:
  LDY     #$07
  LDA     #$7F
loop21:
  PHA
  TAX
  LDA     #$0E
  JSR     XEPSG_ROUTINE
  LDA     #$00
  STA     KBDCOL,Y
.ifdef WITH_ACIA  
  JSR     routine_to_define_12 
.endif  
  LDA     VIA::PRB
  AND     #$B8
  TAX
  CLC
  ADC     #$08
  STA     $1F ; FIXME
loop20  ; d921
  STX     VIA::PRB

  INX
  LDA     #$08

  AND     VIA::PRB
  BNE     skipme2001
loop23:  
  CPX     $1F ; FIXME
  bne     loop20
  
d930:
  beq     next22

skipme2001:
  DEX
  TXA
  PHA
  AND     #$07
  TAX
  LDA     data_to_define_KBDCOL,X
  ORA     KBDCOL,Y
  STA     KBDCOL,Y
  PLA
  TAX
  INX
  bne     loop23
next22  ;$D946
  PLA
  SEC
  ROR
  DEY
  bpl     loop21 ; D94A

  LDY #$08
loop22  
  LDA     SCRTRA+5,Y
  BNE     out1
  CPY     #$06

  BNE     @skip
  DEY
@skip:

  DEY
  bne     loop22 ; d959

out1:
  RTS


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
  LDA     #$FF
  STA     VIA::DDRA
  STA     KEYBOARD_COUNTER+1
  LDA     #$F7
  STA     VIA::DDRB
  LDA     #$01
  STA     KBDVRL
  STA     KBDVRL+1
  STA     KEYBOARD_COUNTER+2
  STA     KEYBOARD_COUNTER
  LDA     #$0E
  STA     KBDVRR
  LDA     #<LFA3F
  LDY     #>LFA3F
  STA     ADKBD
  STY     ADKBD+1 ; FIXME
  LSR     KBDFLG_KEY
  LDA     #$C0
  STA     FLGKBD
  LDA     #$00
  STA     KBDCTC
  RTS



send_14_paramaters_to_psg  
  CLC
  .byt    $24
XSONPS_ROUTINE:
  sec
  PHP
  SEI
  LDA     ADDRESS_READ_BETWEEN_BANK+1
  PHA
  LDA     ADDRESS_READ_BETWEEN_BANK
  PHA
  STX     ADDRESS_READ_BETWEEN_BANK
  STY     ADDRESS_READ_BETWEEN_BANK+1
  PHP
  LDY     #$00
ld9f9
  PLP
  PHP
  BCS     lda01
  LDA     (ADDRESS_READ_BETWEEN_BANK),Y
  BCC     lda04
lda01
  JSR     ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY
lda04
  TAX
  TYA
  PHA
  JSR     XEPSG_ROUTINE 
  PLA
  TAY
  INY
  CPY     #$0E
  BNE     ld9f9
  PLP
  PLA
  STA     ADDRESS_READ_BETWEEN_BANK
  PLA
  STA     ADDRESS_READ_BETWEEN_BANK+1
  PLP
  RTS
  
  
XEPSG_ROUTINE:
.include  "functions/sound/xepsg.asm"  

init_printer:
  LDA #$07
  LDX #$7F
  JMP XEPSG_ROUTINE

Lda70:
  bmi LDAD2  
next906:
  BIT FLGLPR  
  BVS next909

  CMP #$7F
  BNE next909

  
  LDA #$20
next909:
  PHA  
  JSR XECRBU_ROUTINE 
  pla 
  bcs next906
  rts
LDAD2: 
  RTS

Ldae1:
  jmp     LDB7D 


LDAF7
  BMI @skip
  LDX #$0C
  JMP XLISBU_ROUTINE 
@skip:

.ifdef WITH_ACIA
  BCS Ldb09
  
  LDA ACIACR
  AND #$0D
  ORA #$60
  BNE Ldb43 
.endif
Ldb09:
.ifdef WITH_ACIA
  LDA ACIACR
  ORA #$02
  STA ACIACR
.endif
  RTS


Ldb12:
;
;                        GESTION DE LA SORTIE MINITEL                           I
;                                                                               I
;                                                                               I
;Principe:N'?tant gu?re familiaris? avec les modes de fonctionnement de l'ACIA, I
;         je vous donne le source mais je serais bien incapable d'expliciter    I
;         les modifications d'ACIACR et d'ACIACT, registres de controle et de   I
;         commande de l'ACIA 6551.                                              I
;                                                                               I
;
                          ;                                     I
  BMI     LDB3A           ;     ouverture-fermeture  ---------------------------- I
  TAX                     ;     donnee dans X                                   I I
  BPL     LDB26           ;      si <128, on passe ----------------------       I I
  CMP     #$C0            ;      sinon, c'est <128+64 ?                 I       I I
  BCS     LDB26           ;                                             I       I I
  ORA     #$40            ;    oui, on force b7                         I       I I
  PHA                     ;                                             I       I I
  LDA     #$1B            ;    et on envoie un ESC avant                I       I I
  LDX     #$18            ;      la donnée                              I       I I
  JSR XECRBU_ROUTINE      ;                                             I       I I
  PLA                     ;                                             I       I I
LDB26
  PHA                     ;     <---------------------------------------        I I
  LDX     #$18            ;     on envoie la donnée                             I I
  JSR     XECRBU_ROUTINE  ;     dans le BUFFER ACIA sortie                      I I
  PLA                     ;                                                     I I 
  BCS     LDB26           ;     si la donnée n'a pas été écrite, on boucle      I I
LDB2F

.ifdef WITH_ACIA
  LDA     ACIACR          ;    on prend VIA2::IER                               I I
  AND     #$F3            ;    %11110011 force b2 à 0                           I I
  ORA     #$04            ;     et b3 à 1                                       I I
  STA     ACIACR          ;    dans ACIACR                                      I I
.endif

  RTS
                       ;                                      < I
LDB3A
  BCS     LDB53            ;     C=1 on ferme ==================================  I

.ifdef    WITH_ACIA
  LDA     ACIACR           ;     ouverture                                      > I
  AND     #$02             ;      ACIACR ? 0 sauf b1                             I I
  ORA     #$65             ;      %01101001, bits forc?s ? 1                     I I
Ldb43
  STA     ACIACR           ;     dans ACIACR <----------------------------------+--
.endif

.ifdef WITH_ACIA
  LDA #$38             ;     %00111000 dans ACIACT                          I  
  STA ACIACT           ;                                                    I  
.endif
LDB53
  RTS                  ;     et on sort--------------------------------------  

;Ldb54  
init_rs232:
  ; RS232T: 
  ;  b0 to b3 : speed
  ;  b4 : external clock for 0, 1 for internal clock
  ;  b6 - b5 : 00=8 bits, 01=7 bits, 10=6 bits, 11=5 bits
  ;  b7 : 0=stop, 1= 2 or 1.5 stops
.ifdef WITH_ACIA
  LDA     #$1E 
  STA     RS232T
  ; FIXME 65C02
  LDA     #$00
  STA     RS232C
.endif  
  rts
                                                                                
               ;          GESTION DE L'ENTREE RS232                          
LDB5D
  BPL     LDAF7    ;  lecture, voir MINITEL (pourquoi pas $DAF9 ?)       
  BCS     Ldb09   ;   C=1, on ferme                                    

.ifdef WITH_ACIA
  LDA     ACIACR   ;   on ouvre                                          
  AND     #$0D     ;  on fixe le mode de controle
.endif  

LDB66  
.ifdef WITH_ACIA
  ORA $5A      ;   de la RS232                                       
  STA ACIACR                                                        
  LDA VIA2::PRA                                                        
  ORA #$10     ;  %00010000 on force RS232                          
  STA VIA2::PRA                                                        
  LDA RS232T   ;   et on fixe le mode de transmission                
  STA ACIACT   ;   dans ACIACR               
.endif
  RTS                                                              

;                      GESTION DE LA SORTIE RS232                         
LDB79
  BPL LDB26     ; Ecriture, comme MINITEL
  BCS LDB53     ; pas de fermeture (RTS) 
LDB7D
.ifdef     WITH_ACIA
  LDA     ACIACR    ;  ouverture,on lit ACIACR                            
  AND     #$02      ;  isole b1                                          
  ORA     #$05      ;  %00000101 force b0 et b2 ? 1                      
  BNE     LDB66     ;  inconditionnel          
.endif  

;                 GESTION DES SORTIES EN MODE TEXT                      

;Principe:tellement habituel que cela en devient monotone... mais bien pratique !  
output_window0
  PHA             ;   Save A & P
  PHP                                                              
  LDA     #$00    ;   window 0                                         
  BEQ     skipme2000    ;   inconditionnel                                    
output_window1  
  PHA                                                              
  PHP                                                              
  LDA     #$01    ;   fen?tre 1
  BNE     skipme2000    ;                                                 
output_window2
  PHA                                                              
  PHP                                                              
  LDA     #$02    ;  fen?tre 2
  BNE     skipme2000
output_window3:
  PHA                                                              
  PHP                                                              
  LDA     #$03     ; fen?tre 3
skipme2000:

  STA     SCRNB       ; stocke la fen?tre dans SCRNB                      
  PLP          ;  on lit la commande                                
  BPL     LDBA4    ;  ?criture -------    
  JMP     LDECE    ;  ouverture      I      
LDBA4:
  PLA          ;  on lit la donn?e <                                
  STA     SCRNB+1      ;  que l'on sauve

Ldbb5:

  STA     SCRNB+1 ; store the char to display
  PHA              ; Save A
  TXA              ; save X
  PHA              ; 
  TYA              ; Save Y
  PHA
  
  LDX     SCRNB     ; Get the id of the window
  LDA     ADSCRL,X  ; get address of the window
  STA     ADSCR     
  LDA     ADSCRH,X  
  STA     ADSCR+1  
  
  LDA     SCRNB+1
  CMP     #" "       ; is it space ?
  BCS     Ldc4c      ; No it's a char
Ldbce   ; $d27e
  LDA     FLGSCR,X

  PHA

  JSR     XCOSCR_ROUTINE ; switch off cursor
  LDA     #>(LDC2B-1) ; FIXME ?
  PHA
  LDA     #<(LDC2B-1) ; FIXME ?
  PHA
  LDA     SCRNB+1
  ASL     ; MULT2 in order to get vector 
  TAY
  LDA     TABLE_OF_SHORTCUT_KEYBOARD+1,Y 
  PHA
  LDA     TABLE_OF_SHORTCUT_KEYBOARD  ,Y 
  PHA
  LDA     #$00
  SEC
  RTS



TABLE_OF_SHORTCUT_KEYBOARD  
Ldbeb
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1)  ; Nothing
LDBED  
  .byt <(CTRL_A_START-1),>(CTRL_A_START-1) ; CTRL A tabulation 
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1)
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); Already managed  
  .byt <(CTRL_D_START-1),>(CTRL_D_START-1)
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); E
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1) ; F Already managed 
  .byt <(CTRL_G_START-1),>(CTRL_G_START-1) ;G
  .byt <(CTRL_H_START-1),>(CTRL_H_START-1) ;  H
  .byt <(CTRL_I_START-1),>(CTRL_I_START-1) ; I
  .byt <(CTRL_J_START-1),>(CTRL_J_START-1) ;
  .byt <(CTRL_K_START-1),>(CTRL_K_START-1) ; 
  .byt <(CTRL_L_START-1),>(CTRL_L_START-1) ;
  .byt <(CTRL_M_START-1),>(CTRL_M_START-1) ; M
  .byt <(CTRL_N_START-1),>(CTRL_N_START-1) ;  N
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1);  O
  .byt <(CTRL_P_START-1),>(CTRL_P_START-1) ;P
  .byt <(CTRL_Q_START-1),>(CTRL_Q_START-1) ;
  .byt <(CTRL_R_START-1),>(CTRL_R_START-1) ;  R
  .byt <(CTRL_S_START-1),>(CTRL_S_START-1) ;S 
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1) ;  T
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); U 
  .byt <(CTRL_V_START-1)   ,>(CTRL_V_START-1)  ; V 
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1) ; W
  .byt <(CTRL_X_START-1),>(CTRL_X_START-1) ; X
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1); Y
  .byt <(KEYBOARD_NO_SHORTCUT-1),>(KEYBOARD_NO_SHORTCUT-1);  Z 
  .byt <(CTRL_ESC_START-1),>(CTRL_ESC_START-1) ;  ESC
  .byt <(CTRL_ESC_START-1),>(CTRL_ESC_START-1) ; ??? Like ESC
  .byt <(CTRL_CROCHET_START-1),>(CTRL_CROCHET_START-1) ;  CTRL ]
  .byt <(CTRL_HOME_START-1)  ,>(CTRL_HOME_START-1) ;  HOME
  .byt <(CTRL_US_START-1),>(CTRL_US_START-1) ;  US 
    

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

  LDA     FLGSCR,X
  AND     #%00001100 
  BNE     Ldc9a
  LDA     SCRNB+1
  BPL     Ldc5d
  CMP     #$A0  ; Is it higher than 128+32 
  BCS     Ldc5d ; is it a normal code ?
  ; yes don't display
  AND     #$7F  ; yes let's write code
Ldc5d:
  
  STA     SCRNB+1
  JSR     display_char 
  LDA     #$09
  STA     SCRNB+1
skip_code  
  JMP     Ldbce
LDC69
  STA     SCRNB+1
display_char  
  
  LDY     #$80
  LDA     FLGSCR,X
  AND     #$20      ; inverse video ?

  BNE     @skip
  LDY     #$00
@skip:

  TYA
  ORA     SCRNB+1
  STA     CURSCR,X
  LDY     SCRX,X
  STA     (ADSCR),Y
  RTS
  
Ldc9a
  and #$08
  beq LDCB8 
  lda SCRNB+1 
  bmi LDC46 
  cmp #$40
  bcc LDC46
  and #$1F

  JSR LDC69            ;  on le place ? l'?cran                            I
  LDA #$09             ;  on d?place le curseur ? droite                   I
  JSR Ldbb5            ;                                                   I
  LDA #$1B             ;  on envoie un ESC (fin de ESC)                    I
  JSR Ldbb5            ;                                                   I
  JMP LDC46            ; et on sort                                        I
LDCB8
  LDA FLGSCR,X         ;   US, on lit FLGSCR <-------------------------------
  PHA                  ;   que l'on sauve                                    
  JSR XCOSCR_ROUTINE   ;   on ?teint le curseur                            
  PLA                  ;   on prend FLGSCR                                   
  PHA                                                              
  LSR                  ;   doit-on envoyer Y ou X ?                          
  BCS LDCDC            ;   X ------------------------------------------------

  LDA SCRNB+1          ;   on lit Y                                         I
  AND #$3F             ;   on vire b4 (protocole US)                        I
  STA SCRY,X           ;   et on fixe Y                                     I
  JSR LDE07            ;   on ajuste l'adresse dans la fen?tre              I
  STA ADSCRL,X         ;   dans ADSCRL                                      I
  TYA                  ;                                                    I
  STA ADSCRH,X         ;   et ADSCRH                                        I
  PLA                  ;   on indique prochain code pour X                  I
  ORA #$01             ;                                                    I
  PHA                  ;                                                    I
  JMP LDC2B            ;   et on sort                                       I
LDCDC
  LDA SCRNB+1          ;  on lit X <----------------------------------------
  AND #$3F             ;   on vire b4                                        
  STA SCRX,X           ;   dans SCRX                                         
  PLA                                                              
  AND #$FA             ;   on indique fin de US                              
  PHA                                                              
  JMP LDC2B            ;  et on sort
KEYBOARD_NO_SHORTCUT ; USED TO RTS keyboard shortcut not managed  
  RTS                                                                


;                       GESTION DES CODES DE CONTROLE                        

;#A055         
;Principe:Génial... la gestion des codes de controle est surement la partie la   
;         plus caract?ristique de l'esprit BROCHIEN (après le BRK bien sur). La  
;         gestion est supr?mement optimisée pour tout les codes, elle est        
;         surement le fruit d'une mure reflexion. Chapeau.                       
;         En entrée de chaque routine, A=0, C=1 et la pile contient en son       
;         sommet -3, FLGSCR. Le RTS branche en fait en $DC2B, routine g?n?rale   
;         de fin de gestion de code de controle.                                 

;                              CODE 01 - CTRL A                              

;Action:Place le curseur sur une tabulation, colonne multiple de 8.              
 
CTRL_A_START:
  LDA SCRX,X        ; ->on lit ala colonne                                
  AND #$F8          ;  I on la met ? 0                                     
  ADC #$07          ;  I on place sur une tabulation 8 (C=1)               
  CMP SCRFX,X       ;  I est-on en fin de ligne ?                          
  BEQ LDD09         ;  I non                                               
  BCC LDD09         ;  I --------------------------------------------------

  JSR LDD67         ;  I oui, on ram?ne le curseur en d?but de ligne      I

  JSR LDD9D         ;  I et on passe une ligne                            I
  LDX SCRNB         ;  I                                                  I

  LDA SCRX,X        ;  I on prend la colonne                              I
  AND #$07          ;  I est-on sur une tabulation                        I
  BNE CTRL_A_START  ;  --non, on tabule...                                I
  RTS               ;                                                     I
LDD09:
  STA     SCRX,X        ;   on sauve la colonne <-----------------------------
  RTS               ;   et on sort codes A                               I
  
;                             CODE 4 - CTRL D                               
CTRL_D_START:
  ROR          ;  on prépare masque %00000010

 ;                               CODE 31 - US                                
CTRL_US_START:
;on prépare masque %00000100
  ROR
;                               CODE 27 - ESC                                
CTRL_ESC_START:
;                             on pr?pare masque %00001000                       
  ROR
;                             CODE 29 - CTRL ]                              

;                            on pr?pare masque %00010000   
CTRL_CROCHET_START:
  ROR                                                              

    ;                          CODE 22 - CTRL V                              
CTRL_V_START:
  ROR           ; on prépare masque %00100000

;                         CODE 16 - CTRL P                              
CTRL_P_START:
  ROR  ;           on pr?pare masque %01000000                       
                                                                                
          ;                    CODE 17 - CTRL Q                              
CTRL_Q_START:
  
LDD13:
  ROR    ;        on pr?pare masque %10000000                       

LDD14:
  TAY           ; dans Y                                            
  TSX           ;  on indexe FLGSCR dans la pile                     
  EOR $0103,X   ;  on inverse le bit correspondant au code (bascule) 
  STA $0103,X   ;  et on replace                                     
  STA RES       ;  et dans $00                                       
  TYA                                                              
  AND #$10      ;  mode 38/40 colonne ?                              
  BNE @skip     ;  oui ----------------------------------------------
  RTS           ;  non on sort                                      I
@skip:
  LDX SCRNB     ;   on prend le num?ro de fen?tre <-------------------
  AND RES       ;  mode monochrome (ou 40 colonnes) ?                
  BEQ LDD3C     ;   oui ----------------------------------------------
  INC SCRDX,X   ;  non, on interdit la premi?re colonne             I
  INC SCRDX,X   ;  et la deuxi?me                                   I
  LDA SCRX,X    ;  est-on dans une colonne                          I
  CMP SCRDX,X   ;  interdite ?                                      I
  BCS LDD3B     ;  non                                               I
  JMP LDD67     ;  I  oui,on en sort                                    I
LDD3B
  RTS   ;  <---                                                    I
LDD3C
  DEC SCRDX,X ;   on autorise colonne 0 et 1 <----------------------
  DEC SCRDX,X                                                      
  RTS       
LDD43  
  DEC SCRX,X  ;  on ramène le curseur un cran ? gauche  <----------
  RTS  ;                                                           I

 ;                             CODE 8 - CTRL H                              I
 ;                                                                              I
;Action:d?place le curseur vers la gauche                                       I
CTRL_H_START
  LDA SCRX,X   ; est-on d?ja au d?but de la fen?tre ?             I
  CMP SCRDX,X  ;                                                  I
  BNE LDD43    ; non, on ram?ne ? gauche --------------------------
  LDA SCRFX,X  ; oui, on se place ? la fin de la fen?tre           
  STA SCRX,X                                                      

;                              CODE 11 - CTRL K                               

;Action:d?place le curseur vers le haut                                          
CTRL_K_START
  LDA SCRY,X            ;   et si on est pas                                  
  CMP SCRDY,X           ; au sommet de la fen?tre,                          
  BNE LDD6E             ;   on remonte d'une ligne ---------------------------
  LDA SCRDY,X  ;   X et Y contiennent le d?but et la                I
  LDY SCRFY,X  ;  fin de la fen?tre X                              I
  TAX          ;                                                   I
  JSR XSCROB_ROUTINE    ;  on scrolle l'?cran vers le bas ligne X ? Y       I
CTRL_M_START
LDD67
  LDA SCRDX,X  ;  on place d?but de la fen?tre dans X              I
  STA SCRX,X   ;                                                   I
  RTS          ;                                                   I
LDD6E
  DEC SCRY,X   ; on remontre le curseur <--------------------------
  JMP LDE07    ;  et on ajuste ADSCR       
  
  
  
;                              CODE 14 - CTRL N                              
                                                                                
;Action:efface la ligne courante                                                 
CTRL_N_START
LDD74                                                                              
  LDY SCRDX,X ;    on prend la premi?re colonne de la fenetre        
  JMP LDD7D   ;    et on efface ce qui suit (BPL aurait ?t? mieux...)
                       
                                                                          
;                             CODE 24 - CTRL X                              
;Action:efface la fin de la ligne courante                                       
CTRL_X_START
LDD7A                                                                                
  LDY SCRX,X    ;  on prend la colonne du curseur                    
LDD7D
  LDA SCRFX,X   ;  et la derni?re colonne de la fen?tre              
  STA SCRNB+1       ;  dans $29 

  LDA #$20      ;  on envoie un espace                               
LDD84
  STA (ADSCR),Y                                                      
  INY           ; jusqu'? la fin de la ligne                        
  CPY SCRNB+1                                                          
  BCC LDD84                                                       
  STA (ADSCR),Y ; et ? la derni?re position aussi                   
  RTS           ; (INC $29 avant la boucle aurait ?t? mieux !)      
LDD8E
  INC SCRX,X                                                      
  RTS                                                              
  
;                             CODE 9 - CTRL I                               

;Action:déplace le curseur à droite
CTRL_I_START
  LDA SCRX,X    ;  on lit la colonne du curseur                      
  CMP SCRFX,X   ; dernière colonne ?                                
  BNE LDD8E     ;   non, on déplace le curseur                        
  JSR LDD67     ;    oui, on revient à la première colonne     

;        CODE 10 - CTRL J                              
                                                                                
;Action:d?place le curseur vers la droite                                        
CTRL_J_START
LDD9D                                                                               
  LDA SCRY,X   ;  on est en bas de la fen?tre ?                     
  CMP SCRFY,X  ;                                                    
  BNE LDDB2    ;  non ----------------------------------------------
  LDA SCRDY,X  ;  oui, X et Y contiennent d?but et fin de fen?tre  I
  LDY SCRFY,X  ;                                                   I
  TAX          ;                                                   I
  JSR XSCROH_ROUTINE    ;  on scrolle la fen?tre                            I
  JMP LDD67    ;  on revient en d?but de ligne                     I
LDDB2  
  INC SCRY,X   ;  on incr?mente la ligne <-------------------------I 
  JMP LDE07    ;  et on ajuste ADSCR                      

;                         CODE 12 - CTRL L                              

;Action:Efface la fen?tre                                                     
CTRL_L_START
  JSR LDDFB    ;  on remet le curseur en haut de la fen?tre         
LDDBB
  JSR LDD74    ;  on efface la ligne courante                       
  LDA SCRY,X   ; on est ? la fin de la fen?tre ?                   
  CMP SCRFY,X  ;                                                     
  BEQ LDDFB    ;  oui, on sort en repla?ant le curseur en haut     
  JSR LDD9D    ;  non, on déplace le curseur vers le bas            
  JMP LDDBB    ; et on boucle  (Et BPL, non ?!?!)                  

;  CODE 19 - CTRL S                              
CTRL_S_START
  rts

CTRL_R_START
    RTS        
  
XOUPS_ROUTINE
;                             CODE 7 - CTRL G                               
;
;Action:émet un OUPS

CTRL_G_START:
  LDX #<XOUPS_DATA     ;   on indexe les 14 donn?es du OUPS                  
  LDY #>XOUPS_DATA                                                         
  JSR send_14_paramaters_to_psg   ;   et on envoie au PSG                               
  LDY #$60     ;   I                                                 
  LDX #$00     ;   I                                                
LDDE3
  DEX         ;    I D?lai d'une seconde                             
  BNE LDDE3     ;  I                                                 
  DEY           ;  I                                                 
  BNE LDDE3     ;  I                                                 
  LDA #$07      ;  un JMP init_printer suffisait ...                        
  LDX #$3F                                                         
  JMP XEPSG_ROUTINE

XOUPS_DATA
LDDF0                                                                               
  .byt $46,00,00,00,00,00;  période 1,12 ms, fréquence 880 Hz (LA 4) 
LDDF6
  .byt  00,$3E,$0F,00,00  ;  canal 1, volume 15 musical  

;                           INITIALISE UNE FENETRE
;Action:on place le curseur en (0,0) et on calcule son adresse                   
;
CTRL_HOME_START  
LDDFB
  LDA SCRDX,X  ;  on prend la premi?re colonne                      
  STA SCRX,X   ;  dans SCRX                                         
  LDA SCRDY,X  ;  la premi?re ligne dans                            
  STA SCRY,X   ;  SCRY                                              
LDE07
  LDA SCRY,X   ;  et on calcule l'adresse                           
  JSR LDE12    ;  de la ligne                                       
  STA ADSCR    ;  dans ADSCR                                        
  STY ADSCR+1  ;

  RTS      

/*
  CALCULE L'ADRESSE DE LA LIGNE A                       

Action:En entrée, A contient le num?ro de la ligne et en sortie, RES contient   
       l'adresse ? l'?cran de cette ligne.                                      
*/
LDE12
  JSR XMUL40_ROUTINE    ;  RES=A*40                                          
  LDA SCRBAL,X          ;  AY=adresse de la fen?tre                          
  LDY SCRBAH,X                                                      
  JMP XADRES_ROUTINE    ; on calcule dans RES l'adresse de la ligne   
  
XCOSCR_ROUTINE

  CLC
  .byt $24
XCSSCR_ROUTINE  
  sec
  PHP
  ASL FLGSCR,X
  PLP
  ROR FLGSCR,X
  bmi lde53
  LDA #$80
LDE2D  
  AND     FLGSCR,X
  AND     #$80
  EOR     CURSCR,X
  LDY     SCRX,X
  STA     (ADSCR),Y
  PHA
  LDA     FLGSCR,X
  AND     #$02

  beq     @skip
  LDA     SCRY,X
  CMP     SCRFY,X
  BEQ     @skip
  TYA
  ADC     #$28
  TAY
  PLA
  STA     (ADSCR),Y
  RTS
@skip:

  pla
lde53  
  rts
  

XSCROH_ROUTINE
/*                                                                             
                      SCROLLE UNE FENETRE VERS LE BAS                       

Action:scrolle vers le bas de la ligne X ? la ligne Y la fen?tre courante.      
*/                                                                            
  LDA #$00     ;  on prend $0028, soit 40                           
  STA DECFIN+1                                                          
  LDA #$28                                                         
  BNE LDE62    ;  inconditionnel                                    

/*                                                                               
                      SCROLLE UNE FENETRE VERS LE HAUT                      
Action:scrolle vers le haut de la ligne X ? la ligne Y la fen?tre courante.     
*/

XSCROB_ROUTINE:
  LDA     #$FF       ;    on prend $FFD8, soit -40 en compl?ment ? 2        fixme 
  STA DECFIN+1                                                          
  LDA #$D8                                                         
LDE62                                  
  STA DECFIN     ;   $06-07 contiennent le d?placement                 
  STX RES        ;    on met la ligne de d?part en RES                  
  TYA                                                              
  SEC                                                              
  SBC RES        ;   on calcule le nombre de lignes                    
  PHA            ;    on sauve le nombre de lignes                      
  TXA            ;    ligne de d?but dans A                             
  BIT DECFIN                                                          
  BPL LDE71      ;    d?placement n?gatif ?                             
  TYA            ;    oui, ligne de fin dans A
LDE71  
  LDX SCRNB                                                          
  JSR LDE12      ;   on calcule l'adresse de la ligne                 
  CLC                                                              
  ADC SCRDX,X    ;   l'adresse exacte de la ligne dans la fen?tre      
  BCC LDE7D                                                       
  INY
LDE7D  
  STA DECCIB     ;  est dans $08-09                                   
  STY DECCIB+1                                                          
  CLC            ; on ajoute le d?placement                          
  ADC DECFIN                                                          
  STA DECDEB
  TYA                                                              
  ADC DECFIN+1                                                          
  STA DECDEB+1   ;   dans $04-05                                       
  PLA            ;   on sort le nombre de lignes                       
  STA RES        ;   dans RES                                          
  BEQ LDEC4      ;   si nul on fait n'importe quoi ! on devrait sortir!
  BMI LDECD      ;  si n?gatif, on sort ------------------------------
  SEC            ;  on calcule                                       I
  LDX SCRNB      ;                                                   I
  LDA SCRFX,X    ; la largeur de la fen?tre                          I
  SBC SCRDX,X    ;                                                   I
  STA RES+1      ;  dans RES+1                                       I
LDE9D
  LDY RES+1 
LDE9F            ;                                                   I
  LDA (DECDEB),Y ;   on transf?re une ligne                          I
  STA (DECCIB),Y ;                                                   I
  DEY            ;                                                   I
  BPL LDE9F      ;                                                   I
  CLC            ;                                                   I
  LDA DECDEB     ;   on ajoute le d?placement                        I
  ADC DECFIN     ;   à l'adresse de base                             I
  STA DECDEB     ;                                                   I
  LDA DECDEB+1   ;                                                   I
  ADC DECFIN+1   ;                                                   I
  STA DECDEB+1   ;                                                   I
  CLC            ;                                                   I
  LDA DECCIB     ;   et à l'adresse d'arriv?e                        I
  ADC DECFIN     ;                                                   I
  STA DECCIB     ;                                                   I
  LDA DECCIB+1   ;                                                   I
  ADC DECFIN+1   ;                                                   I
  STA DECCIB+1   ;                                                   I
  DEC RES        ;  on décompte une ligne de faite                   I
  BNE LDE9D      ;  et on fait toutes les lignes                     I
LDEC4
  LDY RES+1      ;  on remplit la derni?re ligne                     I
  LDA #$20       ;                                                   I
LDEC8
  STA (DECCIB),Y ;  avec de espaces                                  I
  DEY            ;                                                   I
  BPL LDEC8      ;                                                   I
LDECD
  RTS            ;  <-------------------------------------------------
 

; Action:inconnue... ne semble pas ?tre appel?e et utilise des variables          
;       IRQ dont on ne sait rien.      

;Note de Jede : oui :  utilisée chercher le label LDECE     

LDECE 
  BCC LDED7             ;  si C=0 on passe ------------                      
  LDX SCRNB             ;                             I                      
  JSR XCOSCR_ROUTINE    ;  on éteint le curseur       I                      
  PLA                   ;  et on sort A de la pile    I                      
  RTS          ;                             I    
LDED7
  LDA #$01     ;  on met 1 en $216 <----------                      
  STA FLGCUR                                                        
  LDA #$80      ; on force b7 ? 1 dans $217                         
  STA FLGCUR_STATE                                                        
  PLA           ; on sort A                                         
  RTS           ; et on sort    

  ; text mode  Text mode bytes it will  fill SCRTXT
data_text_window
  
  .byt $00,$27 ; 0 to 39
  .byt $01,$1B ; 1 to 27
  .byt $80,$BB ; adress of text mode (first byte)
  ; hires mode it will  fill SCRHIR
data_hires_window
  .byt $00,$27 ; 0 to 39
  .byt $00,$02 ; 0 to 2
  .byt $68,$BF ; last bytes for text mode
data_trace_window  
  .byt     $00,$27 ; 0 to 39
  .byt $1A,$1B ; 26 to 27
  .byt $80,$BB ; adress
data_videotex_window ; minitel FIXME REMOVE
  .byt $00,$27 ; 0 to 39
  .byt $01,$18 ; 1 to 24
  .byt $80,$BB
XSCRSE_ROUTINE ; init window
  sec
  .byt $24

ldefd  
ROUTINE_TO_DEFINE_7
;  LDA     #<SCRTXT
  ;LDY     #>SCRTXT

;  LDX     #$00

  CLC
  PHP
  STA ADDRESS_READ_BETWEEN_BANK ; CORRECTME
  STY ADDRESS_READ_BETWEEN_BANK+1 ; CORRECTME
  TXA
  CLC
  ADC #$18
  TAX
  LDY #$05

next18
  PLP

  PHP
  BCS     @skip

  LDA     (ADDRESS_READ_BETWEEN_BANK),Y
  BCC next17
@skip:

  JSR ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY

next17
  STA SCRY,X

  TXA
  SEC
  SBC #$04
  TAX
  DEY
  BPL next18


; loop 4 times to set color ink/paper and flags on the 4 possibles screens  
  LDA #$07
  STA SCRCT,X ; Set ink to white
  LDA     #$00
  STA SCRCF,X ; set paper to black
  LDA #$00
  STA FLGSCR,X
  LDA SCRDX,X
  STA SCRX,X ; init cursor to 0 (beginning of the line)
  LDA SCRDY,X
  STA SCRY,X
  LDA SCRBAL,X
  STA ADSCRL,X
  LDA SCRBAH,X
  STA ADSCRH,X
  LDA #$20
  STA CURSCR,X
  LDA SCRNB 
  PHA
  STX SCRNB 

  LDA     #$0C

  JSR Ldbb5 

  PLA 
  
  STA SCRNB
  PLP
  rts
  ; $d3fd DEBUGGER
  ; d411 ?
  ; cc3a
  ; d4dc
  ; $d1b6
  ; d3e6
  ; cycle : 1549 (d24C) tay,pla tax pla)
  
.proc init_screens
  LDA     #$1A
  STA     $BFDF    ; Switch to text mode
  ; fill the first line with space characters
  LDX     #$27     ; loop on #$28 caracters
  LDA     #$20

@loop:
  STA     $BB80,X  ; display space on first line in mode text
  DEX
  BPL     @loop
  
  LDY     #$11     ; loop with $12 to fill text definitions and Hires
@L1:
  LDA     data_text_window,Y ; data_to_define_2
  STA     SCRTXT,Y ; thise fill also  SCRHIR
  DEY
  BPL     @L1

  LDA     #<SCRTXT
  LDY     #>SCRTXT

  LDX     #$00

  JMP     ROUTINE_TO_DEFINE_7 ; $DEFD
.endproc

Ldf90
  LDA VIA2::PRB
  AND #$3F
  ORA #$40
  BNE next15
Ldf99
  LDA VIA2::PRB
  AND #$3F
  ORA #$80
  
next15:
  STA VIA2::PRB
  LDA VIA2::PRB
  AND #$1F
  rts
  sec
  rts
  
init_joystick:
  LDA     #%01000001 ; SET mouse and joystick flag
  STA     FLGJCK
; init JCKTAB values
  LDX     #$06 ; 7 bytes 
@loop:
  LDA     telemon_values_for_JCKTAB,X ; data_to_define_3
  STA     JCKTAB,X
  DEX
  BPL     @loop


  LDA #$01
  STA MOUSE_JOYSTICK_MANAGEMENT+6
  STA MOUSE_JOYSTICK_MANAGEMENT+11
  LDA #$06
  STA MOUSE_JOYSTICK_MANAGEMENT+7
  STA MOUSE_JOYSTICK_MANAGEMENT+10
  LDA #$01
  STA MOUSE_JOYSTICK_MANAGEMENT+8
  LDA #$0A
  STA MOUSE_JOYSTICK_MANAGEMENT+9
  LDA #$03
  STA JCKTAB+5
  STA JCKTAB+6
  LDA #$10
  LDY #$27
  STA VIA_UNKNOWN
  STY VIA_UNKNOWN+1
  STA VIA::T2
  STY VIA::T2+1
  LDA #$A0
  STA VIA::IER
  RTS

telemon_values_for_JCKTAB
  .byt $0b,$0a,$20,$08,$09,$03,$03
Ldffa
  rts
Ldffb
  LDA JCGVAL
  AND #$04
  BNE Le014
  JSR Ldf90 
  AND #$04
  BNE Le01e
  DEC MOUSE_JOYSTICK_MANAGEMENT+2 ; CORRECTME
  BNE Le037
  LDX MOUSE_JOYSTICK_MANAGEMENT+6 ; CORRECTME
  JMP Le01e 
Le014
  JSR Ldf90 
  AND #$04
  BNE Le037
  LDX MOUSE_JOYSTICK_MANAGEMENT+7 ; CORRECTME
Le01e
  STX MOUSE_JOYSTICK_MANAGEMENT+2 ; CORRECTME
  STA VABKP1 ; CORRECTME
  LDA JCGVAL
  AND #$1B
  ORA VABKP1 ; CORRECTME
  STA JCGVAL
  LDA VABKP1 ; CORRECTME
  BNE Le037
  LDA JCKTAB ; CORRECTME
  JSR Le19f 
Le037
  LDA     JCGVAL
  AND #$1B
  EOR #$1B
  BEQ Le05b
  JSR Ldf90 
  AND #$1B
  STA VABKP1 ; CORRECTME
  LDA JCGVAL
  AND #$1B
  EOR VABKP1
  BNE Le062
  DEC MOUSE_JOYSTICK_MANAGEMENT
  BNE Le084
  LDX MOUSE_JOYSTICK_MANAGEMENT+6 ; CORRECTME
  JMP Le065
Le05b
  JSR Ldf90 
  AND #$1B
  STA VABKP1 ; CORRECTME
Le062
  LDX MOUSE_JOYSTICK_MANAGEMENT+7 ; CORRECTME
Le065
  STX MOUSE_JOYSTICK_MANAGEMENT ; CORRECTME
  LDA JCGVAL
  AND #$04
  ORA VABKP1 ; CORRECTME
  STA JCGVAL
  LDX     #$04
  ORA #$04
Le076
  LSR
  PHA
  BCS Le080
  LDA JCKTAB,X
  JSR Le19f 
Le080
  PLA
  DEX
  BPL Le076
Le084
  RTS

le085

/*                                                                             
                            GESTION DE LA SOURIS                            

Action:G?re la souris comme pr?c?demment le joystick gauche, ? ceci pr?s qu'il  
       ne s'agit plus avec la souris de g?rer un d?lai de r?p?tition (sauf pour 
       les boutons), mais plutot une vitesse de r?p?tition. Dans le buffer      
       clavier, l'octet KBDSHT ajout? au codes ASCII souris est 8, soit b3 ? 1. 
*/                                                                              
                                                                                
  JSR Ldf99      ;  on lit la valeur souris                         
  AND #$1B       ;   on isole les directions                           
  STA VABKP1     ;   dans VABKP1                                          
  CMP #$1B       ;   la souris bouge ?                                 
  BNE LE095      ;   non ---------------------------------------------- 
  DEC JCKTAB+7   ;   on d?place ?                                     I
  BNE Le084      ;   non, on sort.                                    I 
LE095  
  LDA JCKTAB+8    ;  on place vitesse d?placement dans  <--------------
  STA JCKTAB+7    ;  $2A4                                              
  LDA VABKP1      ;   on lit le code                                    
  CMP #$1B        ;   souris fixe ?                                     
  BEQ LE0B5       ;  oui ----------------------------------------------
  AND #$1B                         ;    non, on isole les valeurs direction              I
  EOR JCDVAL                       ;    et on retourne les bits de JCDVAL                I
  AND     #$1B                         ;    en isolant les bits direction                    I
  BNE     LE0B5                        ;    ce ne sont pas les m?mes exactement -------------O 
  DEC     MOUSE_JOYSTICK_MANAGEMENT+1  ;    on r?p?te ?                                      I
  BNE     LE0E0  ;    non                                              I 
  LDX     MOUSE_JOYSTICK_MANAGEMENT+8  ;     oui, on met le diviseur r?p?tition               I
  JMP     LE0BB ;  ---dans le compteur                                 I 
LE0B5
  JSR     Ldf99  ; I  on lit la souris <-------------------------------- 
  LDX     MOUSE_JOYSTICK_MANAGEMENT+9 ;  I  on place le compteur avant r?p?tition   
LE0BB
  STX     MOUSE_JOYSTICK_MANAGEMENT+1 ;  -->dans le d?compteur                                
  AND     #$1B  ;     on isole les bits de direction                    
  STA VABKP1  ;      dans VABKP1                                          
  LDA JCDVAL ;     on prend JDCVAL                                   
  AND #$64 ;      %01100100, on isole les bits de Feu               
  ORA VABKP1   ;     on ajoute les bits de direction                   
  STA JCDVAL  ;    dans JDCVAL                                       
  LDA VABKP1   ;                                                       
  ORA #$04  ;     on ?teint le feu principal                        
  LDX #$04  ;  
Le0d2
  LSR                                                              
  PHA                                                              
  BCS LE0DC     ;                                              
  LDA JCKTAB,X   ; et on envoie les valeurs ASCII dans le buffer     
  JSR Le19d      ;                                                    
LE0DC
  PLA                                                              
  DEX                                                              
  BPL Le0d2
LE0E0
  RTS                                                              

Le0e1

  LDA JCDVAL
  AND #$04
  BNE Le0fa
  JSR Ldf99 
  AND #$04
  BNE Le102
  DEC MOUSE_JOYSTICK_MANAGEMENT+3 ; CORRECTME
  BNE Le11b
  LDX MOUSE_JOYSTICK_MANAGEMENT+6 ; CORRECTME
  JMP Le102
Le0fa
  JSR Ldf99
  AND #$04
  LDX MOUSE_JOYSTICK_MANAGEMENT+7 ; CORRECTME
Le102
  STA VABKP1 ; CORRECTME
  STX MOUSE_JOYSTICK_MANAGEMENT+3 ; CORRECTME
  LDA JCDVAL
  AND #$7B
  ORA VABKP1
  STA JCDVAL
  LDA VABKP1
  BNE Le11b
  LDA JCKTAB ; CORRECTME
  JSR Le19d 
Le11b
  LDA     JCDVAL
  AND #$20
  BNE Le137
  JSR Ldf99 
  LDA VIA2::PRA2
  AND #$20
  BNE Le140
  DEC MOUSE_JOYSTICK_MANAGEMENT+4 ; CORRECTME
  BNE Le15b
  LDX MOUSE_JOYSTICK_MANAGEMENT+11 ; CORRECTME
  JMP Le140
Le137
  JSR Ldf99
  LDA VIA2::PRA2
  LDX MOUSE_JOYSTICK_MANAGEMENT+10 ; CORRECTME
Le140
  STX MOUSE_JOYSTICK_MANAGEMENT+4 ; CORRECTME
  AND #$20
  STA VABKP1 
  LDA JCDVAL
  AND #$5F
  ORA VABKP1 
  STA JCDVAL
  AND #$20
  BNE Le15b
  LDA JCKTAB+5
  JSR Le19d
Le15b
  LDA JCDVAL
  AND #$40
  BNE Le177
  JSR Ldf99
  LDA VIA2::PRA2
  AND #$80
  BNE Le180
  DEC MOUSE_JOYSTICK_MANAGEMENT+5 ; CORRECTME
  BNE Le19c
  LDX MOUSE_JOYSTICK_MANAGEMENT+11 ; CORRECTME
  JMP Le180
Le177
  JSR Ldf99
  LDA VIA2::PRA2
  LDX MOUSE_JOYSTICK_MANAGEMENT+10 ; CORRECTME
Le180
  STX MOUSE_JOYSTICK_MANAGEMENT+5 ; CORRECTME
  LSR
  AND     #$40
  STA     VABKP1
  LDA     JCDVAL
  AND     #$3F ; CORRECTME
  ORA     VABKP1 
  STA     JCDVAL
  AND     #$40
  BNE     Le19c 
  LDA     JCKTAB+6 ; CORRECTME
  JMP Le19d 
Le19c
  RTS
Le19d
  
  .byt $38,$24
Le19f

  CLC
  PHP
  STX     VABKP1 
  LDX     #$00
  JSR     XECRBU_ROUTINE 
  LDA #$08
  PLP
  BCS Le1af
  LDA #$20
Le1af
  LDX #$00
  JSR XECRBU_ROUTINE 
  LDX VABKP1   
  RTS
Le1b7  
  sec
  rts



data_for_hard_copy:
  .byt $18,$33,$1b,$0a,$0d,$00,$f0,$4b,$1b,$0d,$0a,$40,$1b,$0a,$0a

XHCHRS_ROUTINE:

execute_hard_copy_hires:
  jmp (HARD_COPY_HIRES)
hard_copy_hires

LE25E  
  
  DEX
  BNE LE25E 
  STX TR0
LE269  
  LDX #$06
LE26B  

  
LE276  
  LDA #$05
  STA TR2
LE27A  
  LDA TR0
  ASL
  ASL
  ASL
  JSR XMUL40_ROUTINE 
  STA TR5
  TYA
  CLC
  ADC #$A0
  STA TR6
  LDA #$08
  STA     TR4
  LDY TR1
LE290  
  LDA (TR5),Y
  TAX
  AND #$40
  BNE LE29B 
  TXA
  AND #$80
  TAX
LE29B  
  TXA
  BPL LE2A0
  EOR #$3F
LE2A0  
  LDX TR2
LE2A2  
  LSR
  DEX
  BPL LE2A2 
  ROL TR3
  TYA
  CLC
  ADC #$28
  TAY
  BCC LE2B1 
  INC TR6
LE2B1  

LE2D0  

  RTS
Le2de
put_cursor_on_last_char_of_the_line
  LDY SCRFX,X
  .byt $24
LE2E2  
  dey
  LDA (RES),Y
  CMP #$20
  BNE test_if_prompt_is_on_beginning_of_the_line
  TYA
  CMP SCRDX,X
  BNE LE2E2 
  RTS
  
test_if_prompt_is_on_beginning_of_the_line

  cmp #$7f
  bne Le2f8
  tya
  cmp SCRDX,x
Le2f8  
  rts
Le2f9
  LDY SCRDX,X
  LDA (RES),Y
  CMP #$7F
  RTS
LE301
Le2e6
  LDX SCRNB
  LDA SCRY,X
  STA ACC1M
Le2ed  
  LDA ACC1M
  JSR LDE12 
  JSR Le2f9 ;

  beq Le302
  lda ACC1M
  CMP SCRDY,X
  
  BEQ Le306
  DEC ACC1M
  bcs Le2ed
Le302  
  CLC
  INY
  STY ACC1E
Le306  
  RTS
put_cursor_on_beginning_of_the_line  
Le322  
  LDX SCRNB
  LDA SCRY,X
  STA $63
  JSR LDE12
  JSR put_cursor_on_last_char_of_the_line
Le32f  
  STY $62
  BEQ Le34e 
  LDA $63
  CMP SCRFY,X
  BEQ Le34d 
  INC $63
  LDA $63
  JSR LDE12
  JSR Le2f9 
  BEQ Le34b 
  JSR put_cursor_on_last_char_of_the_line 
  BNE Le32f 
Le34b  
  DEC $63
Le34d  
  RTS
Le34e  
  rts


LE34F
  JSR LE301 
  JMP LE361
send_the_end_of_line_in_bufedt  
LE355  
  LDX SCRNB
  LDA SCRX,X
  STA ACC1E
  LDA SCRY,X
  STA ACC1M
LE361  
  JSR Le322
    
  LDA ACC1M
  STA ACC1S
  CMP $63
  BNE Le378

  LDA $62
  CMP ACC1E
  BCS Le378
  LDA #$00
  STA BUFEDT
  RTS
Le378  

  LDA #$00
  STA $64
  LSR $66
Le37e  
  LDA ACC1S
  JSR LDE12
  LDY ACC1E
  LDA ACC1S
  CMP ACC1M
  BEQ Le390
  LDX SCRNB
  LDY SCRDX,X
Le390  
  LDA (RES),Y
  CMP #$20
  BCS Le398
  ORA #$80
Le398  
  LDX $64
  BIT $66
  BPL Le3a4
  LDA #$20
  STA (RES),Y
  BNE Le3b1
Le3a4
  STA BUFEDT,X
  INC $64
  CPX $67
  BCC Le3b1
  DEC $64
  ROR $66
Le3b1  
  TYA
  INY
  LDX ACC1S
  CPX $63
  BNE Le3c5
  CMP $62
  BNE Le390
  LDX $64
  LDA #$00
  STA BUFEDT,X
  RTS
Le3c5  


  LDX SCRNB
  CMP SCRFX,X
  BNE Le390
  INC ACC1S
  BNE Le37e
  
display_bufedt_content  

  ROR $66
  LDA #$00
  STA $64
  LDA $26
  LDY $27
  STA RES
  STY RES+1
  LDX SCRNB
  LDY SCRX,X

Le3e3
  LDX $64 ; fixme
  LDA BUFEDT,X
  BEQ Le41c 
  LDA #$20
  BIT $66
  BMI Le3fb
  LDA BUFEDT,X
  BPL Le3fb
  CMP #$A0
  BCS Le3fb
  AND #$1F
Le3fb  
  STA (RES),Y

  BIT FLGTEL ; Minitel ?
  BVC Le405
  JSR LE656
Le405  
  TYA
  INY
  LDX SCRNB
  CMP SCRFX,X
  BNE Le418
  LDA #$28
  LDY #$00
  JSR XADRES_ROUTINE 
  LDY SCRDX,X
Le418  
  INC $64
  BNE Le3e3
Le41c  
  BIT FLGTEL ; Minitel ?
  BVC Le42a 
  LDX SCRX
  LDY SCRY

  JSR Le62a 
Le42a    
  LDY SCRX
  LDA (ADSCR),Y
  LDX SCRNB
  STA CURSCR,X
  RTS

  
Le45a  
Le479  
  RTS

manage_normal_char
 
  
manage_code_control
Le5b9
  

  CMP #$08
  BNE Le5d5
  PHA
  LDA KBDSHT
  LSR
  BCS Le5cb
Le5c4  
  PLA
  JSR Le648 
  JMP Le45a 
Le5cb  
  JSR LE301 
  LDX ACC1E
Le5d2  
  LDY ACC1M
  JMP LE5E7
Le5d5
  CMP #$09
  BNE Le5ee
  PHA
  LDA KBDSHT
  LSR
  BCC Le5c4
  JSR Le322 
  LDX $62
  LDY $63
LE5E7  
  PLA
  
  JSR Le62a 
  JMP Le45a  
Le5ee  
  CMP #$0A
  BNE Le604
  LDX SCRNB
  LDA SCRY,X
  CMP SCRFY,X
  BNE Le615
  LDA #$0A
  .byt $2c
Le5ff  
  lda #$0b
  
  JMP Le479 
Le604  
  CMP #$0B
  BNE Le617
  LDX SCRNB
  LDA SCRY,X
  CMP SCRDY,X
  BEQ Le5ff
  LDA #$0B
  
  .byt $2c
Le615  
  lda #$0a
Le617  
  CMP #$0C
  BNE Le624
  
  JSR Le648 
  JSR XECRPR_ROUTINE 
  JMP Le45a
Le624  
  JSR Le648 
  JMP Le45a 




/*
POSITIONNE LE CURSEUR EN X,Y                        

Action:positionne le curseur ? l'?cran et sur le minitel s'il est actif en tant 
       que sortie vid?o.                           
*/
Le62a
  LDA #$1F      ; on envoie un US                                   
  JSR Le648                                                     
  TYA          ;  on envoie Y+64                                    
  ORA #$40                                                         
  JSR Le648                                                    
  TXA         ;   et X+64                                           
  ORA #$40                                                         
  JSR Ldbb5                                                       
  BIT FLGTEL     ; mode minitel ?                                    
  BVC LE66B     ; non                                              
  INX           ; on ajoute une colonne                             
  TXA           ; dans A                                            
  DEX           ; et on revient en arri?re                          
  ORA #$40     ;  on ajoute 40                                      
  JMP LE656    ;  et on envoie au minitel

/*
                   ENVOIE UN CODE SUR LE TERMINAL VIDEO                    
                                                                                
Action:envoie un code sur l'?cran et ?ventuellement sur le minitel s'il est     
       actif comme sortie vid?o. Seule la fen?tre 0 est g?r?e, ce qui ote       
       d?finitivement tout espoir de gestion d'entr?e de commande sur une autre 
       fen?tre.                                                                 
*/
Le648                                                                        
LE650
  BIT LE650    ;  V=0 et N=0 pour ?criture <------------------------ 
  JMP output_window0    ;  dans la fen?tre 0                               
                                                                                
/*
                 ENVOIE UN CODE AU BUFFER SERIE SORTIE                    
*/
LE656
  STA TR0              ;  on sauve le code <--------------------------------
  TYA                  ;  on sauve Y                                       I
  PHA                  ;                                                   I
  TXA                  ;  et X                                             I
  PHA                  ;                                                   I
  LDX #$18             ;  on indexe buffer ACIA sortie (minitel sortie)    I
  LDA TR0              ;  on envoie le code                                I
  JSR XECRBU_ROUTINE   ;                                                   I
  PLA                  ;  on restaure les registres                        I
  TAX                  ;                                                   I
  PLA                  ;                                                   I
  TAY                  ;                                                   I
  LDA TR0              ;                                                   I
  BCS LE656            ;  si l'envoi s'est mal pass?, on recommence --------
LE66B
  RTS                     
/*                                      
                             AFFICHE LE PROMPT
*/  

XECRPR_ROUTINE 
  LDA #"#"    ;    on affiche un prompt <----------------------------
  JMP Ldbb5   ;   ? l'écran               
                                        



/*

                        CONVERSION ASCII -> BINAIRE                         

Principe:On lit un ? un les chiffres de la chaine stock?e en AY jusqu'? ce      
         qu'on ait plus de chiffres. On multiplie au fur et ? mesure le resultat
         par 10 avant d'ajouter le chiffre trouv?. Le principe est ais? ?       
         assimiler et la routine compacte. Un bon exemple d'optimisation.       
         En sortie, AY et RESB contient le nombre, AY l'adresse de la chaine,   
         et X le nombre de caract?res d?cod?s.                                  
*/ 
XDECAY_ROUTINE 
                                                                                
  STA RES      ;   on sauve l'adresse du nombre                      
  STY RES+1    ;    dans RES                                          
  LDY #$00     ;    et on met RESB ? 0                                
  STY RESB
  STY RESB+1                                                          
LE753
  LDA (RES),Y  ;   on lit le code <------------------------------    
  CMP #$30     ;   inf?rieur ? 0 ?                              I    
  BCC LE785    ;   oui -----------------------------------------+---- 
  CMP #$3A     ;   sup?rieur ? 9 ?                              I   I
  BCS LE785    ;   oui -----------------------------------------+---O 
  AND #$0F     ;   on isole le chiffre                          I   I
  PHA          ;    dans la pile                                I   I
  ASL RESB     ;    RESB*2                                      I   I
  ROL RESB+1   ;                                                I   I
  LDA RESB     ;    AX=RESB*2                                   I   I
  LDX RESB+1   ;                                                I   I
  ASL RESB     ;   *4                                           I   I
  ROL RESB+1   ;                                                I   I
  ASL RESB     ;   *8                                           I   I
  ROL RESB+1   ;                                                I   I
  ADC RESB     ;   +RESB*2                                      I   I
  STA RESB     ;                                                I   I
  TXA          ;                                                I   I
  ADC RESB+1   ;                                                I   I
  STA RESB+1   ;   = RESB*10                                    I   I
  PLA          ;   plus chiffre lu                              I   I
  ADC RESB     ;                                                I   I
  STA RESB     ;                                                I   I
  BCC LE782    ;                                                I   I
  INC RESB+1   ;                                                I   I
LE782
  INY          ;   on ajoute un chiffre lu                      I   I
  BNE LE753    ;     et on recommence  ----------------------------   I
LE785
  TYA       ;     nombre de chiffres lus <--------------------------
  TAX       ;     dans X                                            
  LDA RESB   ;     nombre dans AY et RESB                            
  LDY RESB+1    ;                                                      
  RTS
  
data_for_hires_display
  .byt $20,$10,$08,$04
  .byt $02,$01

  
XHRSSE_ROUTINE  
  CLC          ;     C=0                                               
  BIT HRS5+1   ;  on fait tourner HRS5+1 sur lui-même               
  BPL LE798    ;   afin de conserver le pattern                     
  SEC 
LE798  
  ROL HRS5+1                                                          
  BCC Le7c0      ;    si b7 de $56   ? 0, on saute <-------------------- 
LE79C
  LDY HRSX40     ;   sinon on prend X/6                               I
  LDA (ADHRS),Y  ;   on lit le code actuel                            I
  ASL            ;   on sort b7                                       I
  BPL Le7c0      ;   pas pixel, on sort ------------------------------O
  LDX HRSX6      ;   on prend le reste de X/6                         I
  LDA data_for_hires_display,X  ;  on lit le bit correspondant                      I 
  BIT HRSFB      ;   b7 de HRSFB ? 1 ?                                I
  BMI LE7BA      ;   b7 ? 1, donc 3 ou 2                              I 
  BVC L7B3       ;   FB=0 ----------------------------------------    I 
  ORA (ADHRS),Y  ;   FB=1, on ajoute le code                     I    I
  STA (ADHRS),Y  ;   et on le place                              I    I
  RTS
L7B3               ;                                               I    I
  EOR #$7F       ;   on inverse le bit  <-------------------------    I
  AND (ADHRS),Y  ;   et on l'?teint                                   I
  STA (ADHRS),Y  ;   avant de le placer                               I
  RTS            ;                                                    I
LE7BA
  BVS Le7c0      ;   FB=3, on sort -----------------------------------O 
  EOR (ADHRS),Y  ;   FB=2, on inverse le bit                          I
  STA (ADHRS),Y  ;    et on sort       a                               I
Le7c0
  RTS  
/*
                                                                               
                    DEPLACEMENT RELATIF DU CURSEUR HIRES                    
                                                                                
Action:Ces quatres routines permettent un d?placement extr?mement rapide du     
       curseur HIRES d'apr?s l'adresse de la ligne ou il se trouve (ADHRS),     
       la colonne dans laquelle il se trouve (HRSX40) et sa position dans       
       l'octet point? (HRSX6).                                                  
       Attention:Les coordonn?es HRSX et HRSY ne sont pas modifi?es ni v?rifi?es
                 avant le d?placement, ? vous de g?rer cela.                    
                                                                                
                    DEPLACE LE CURSEUR HIRES VERS LE BAS                      
*/
XHRSCB_ROUTINE:
  CLC           ;     on ajoute 40                                      
  LDA ADHRS     ;    à ADHRS
  ADC #$28                                                         
  STA ADHRS                                                          
  BCC Le7c0                                                     
  INC ADHRS+1                                                          
  RTS     

;                   DEPLACE LE CURSEUR HIRES VERS LE HAUT                    

XHRSCH_ROUTINE:
  SEC      ;      on soustrait 40                                   
  LDA ADHRS   ;     ? ADHRS                                           
  SBC #$28                                                         
  STA ADHRS                                                          
  BCS     Le7c0                                                     
  DEC ADHRS+1                                                          
  RTS        

;                      DEPLACE LE CURSEUR VERS LA DROITE (hires)
XHRSCD_ROUTINE:

  LDX HRSX6      ;      on déplace d'un pixel                             
  INX                                                              
  CPX #$06       ;     si on est à la fin
  BNE @skip
  LDX #$00       ;    on revient au début
  INC HRSX40     ;   et ajoute une colonne 
@skip:
  STX HRSX6                                                          
  RTS    


;                     DEPLACE LE CURSEUR VERS LA GAUCHE (hires)

XHRSCG_ROUTINE:
  LDX HRSX6                                                          
  DEX         ;   on d?place ? gauche                               
  BPL @skip   ;   si on sort                                        
  LDX #$05    ;   on se place ? droite                              
  DEC HRSX40     ;   et on enl?ve une colonne 
@skip:
  STX HRSX6                                                          
  RTS        



;                         PLACE LE CURSEUR EN X,Y                           

;Action:calcule l'adresse du curseur en calculant la position de la ligne par    
;       $A000+40*Y, la colonne dans X/6 et la position dans l'octet par X mod 6. 
;       Suite à une erreur dans la table des vecteur TELEMON, cette routine n'est
;       pas appel?e (alors qu'elle devrait l'?tre) par BRK XHRSSE...             
       ;En sortie, HSRX,Y,X40,X6 et ADHRS sont ajust?s en fonction de X et Y.    
;

hires_put_coordinate
Le7f3                                                                                
  STY HRSY            ;     Y dans HRSY                                       
  STX HRSX            ;     X dans HRSX                                       
  TYA                 ;     et Y dans A                                       
  LDY #$00            ;     AY=A, ligne du curseur                            
  JSR XMUL40_ROUTINE  ;    on calcule 40*ligne                            
  STA ADHRS           ;                                           
  CLC                                                              
  TYA                                                              
  ADC #$A0            ;   et on ajoute $A000, ?cran HIRES                   
  STA ADHRS+1         ;    dans ADHRS                                        
  STX RES             ;    on met la colonne dans RES                        
  LDA #$06            ;    A=6                                               
  LDY #$00            ;    et Y=0  (dans RES+1)                              
  STY RES+1           ;     AY=6 et RES=colonne                               
  JSR XDIVIS_ROUTINE  ;     on divise la colonne par 6                       
  LDA RES             ;     on sauve colonne/6 dans HSRX40                    
  STA HRSX40          ;                                                        
  LDA RESB            ;      et le reste dans HRSX6                            
  STA HRSX6           ;                                                        
  RTS                 ;      I
 /*                                                                               

                       TRACE UN RECTANGLE EN RELATIF                        


Principe:On calcule les coordonn?es absolues des 4 coins et on trace en absolu. 
         Pas tr?s optimis? en temps tout cela, il aurait ?t? plus simple de     
         de tracer directement en relatif !!!                                   
         Le rectangle est trac? comme ABOX avec les param?tres dans HRSx.       
*/
XBOX_ROUTINE
                                                                                
  CLC              ;   C=0                                               
  LDA     HRSX     ;   on place les coordon?es actuelles                 
  STA     DECFIN   ;   du curseur dans $06-07                            
  ADC     HRS1     ;   et les coordonn?es (X+dX,Y+dY)                    
  STA     DECCIB                                                          
  LDA     HRSY                                                          
  STA     DECFIN+1                                                          
  ADC     HRS2                                                          
  STA     DECCIB+1 ;   dans DECCIB-09                                       
  BCC     LE83A    ;   inconditionnel                                    
                                                                                
                                                  
/*                                                                              
                         TRACE UN RECTANGLE ABSOLU                          
                                                                              
Principe:Par un proc?d? tr?s astucieux, on va tracer les 4 traits (en absolu)   
         joignant les 4 points. Voila bien la seule astuce inutile ! Il aurait  
         ?t? 100 (pourquoi pas 1000 !?) fois plus simple, puisque le rectangle  
         n'est fait que de verticales et d'horizontales, de tracer le rectangle 
         imm?diatement en relatif plutot que de passer par des calculs de       
         tangentes lourds et donnant un r?sultat connu (0 et infini) !!!        
         Cette pi?tre routine n?cessite les param?tres comme ABOX dans HRSx.    
         Notez ?galement l'utilisation de l'absolu,X plutot que du page 0,X en  
         $E850... tss tss !                                                     
 */
XABOX_ROUTINE 
Le82c 
  LDY #$06    ;   on place les 4 param?tres (poids faible seulement)
  LDX #$03 
LE830
  LDA $004D,Y  ;  de HRSx                                           
  STA DECFIN,X    ;  dans $06-7-8-9                                    
  DEY                                                              
  DEY                                                              
  DEX                                                              
  BPL LE830
LE83A  
  LDX #$03     ;  on va tracer 4 traits                             
LE83C
  STX $05      ;  dans $05 <----------------------------------------
  LDA table_for_rect,X   ; on lit le code coordonn?es                       I 
  STA $04      ;  dans $04                                         I
  LDX #$06     ;  on va extraire 8 bits                            I
LE845
  LDA #$00     ;  A=0 <----------------------------------------    I
  STA $4E,X    ;  poids fort HRSx ? 0 et positif              I    I
  LSR $04     ;   on sort 2 bits                              I    I
  ROL         ;   dans A                                      I    I
  LSR $04     ;                                               I    I
  ROL         ;                                               I    I
  TAY         ;   et Y                                        I    I
  LDA $0006,Y  ;  on lit la coordonn?e correspondante         I    I
  STA HRS1,X    ;  et on stocke dans HRSx                      I    I
  DEX         ;                                               I    I
  DEX          ;                                              I    I
  BPL LE845   ;   on fait les 4 coordonn?es ADRAW -------------    I 
  JSR XDRAWA_ROUTINE  ;   on trace le trait en absolu                      I 
  LDX $05    ;                                                     I
  DEX        ;                                                     I
  BPL LE83C  ;   et on fait 4 traits ------------------------------ 
  RTS                                                              
table_for_rect
Le862
  .byt $26,$67,$73,$32
/*
                         TRACE DE TRAIT EN ABSOLU                          
                                                                                
                                                                                
Action:on calcule dX et dY les d?placements dans HRS1 et HRS2 et on trace en    
       relatif. En entr?e, comme ADRAW dans HRSx.                               
*/
XDRAWA_ROUTINE:
  LDX HRS1     ;   X=colonne                                         
  LDY HRS2     ;   Y=ligne du curseur                                
  JSR Le7f3   ;   on place le curseur en X,Y                         
  LDX #$FF    ;   on met -1 dans X pour un changement de signe      
  SEC         ;   ?ventuel dans les param?tres                      
  LDA HRS3     ;   on prend X2                                       
  SBC HRS1     ;   -X1                                               
  STA HRS1     ;   dans HRS1 (DX)                                    
  BCS LE87B   ;   si DX<0, on inverse le signe de HRS1              
  STX HRS1+1     ;   DEC $4E aurait ?t? mieux...                       
  SEC
LE87B
  LDA HRS4      ;  on prend Y2                                       
  SBC HRS2      ;  -Y1                                               
  STA HRS2     ;   dans HRS2 (DY)                                    
  BCS XDRAWR_ROUTINE   ;   et si DY n?gatif, on met signe -1                 
  STX HRS2+1     ;   ou DEC $50                                        
                                                  


/*                                                                              
                         TRACE DE TRAIT EN RELATIF                          

Principe:Le principe du trac? des droites est en fait assez complexe. On aurait 
         aim? que F. BROCHE nous ponde une routine hyper-optimis?e dont il a le 
         secret. Ce n'est malheureusement pas le cas puisque cette routine      
         l'algorithme des ROM V1.0 et 1.1. Sans doute parce qu'il est tr?s      
         efficace...                                                            
         Pour tracer un trait le plus rapidement possible, on cherche lequel des
         deux axes est le plus grand et on trace selon cet axe. Pour tracer,    
         on avance sur l'axe de t points (t est la valeur de la tangente) et on 
         avance d'un point sur l'autre axe, et ainsi de suite jusqu'? ce qu'on  
         ait parcouru tout l'axe.                                               
         Ainsi DRAW 10,2,1 donnera en fait 2 paliers de 5 pixels de large.      
         Le cas dX=dY (déplacements ?gaux) est trait? avec t=-1, de plus les    
         poids fort des d?placements gardent le signe car on prend la valeur    
         absolue de dX et dY pour les calculs.                                  
*/

; NOERROR
   
XDRAWR_ROUTINE
Le885                                                                             
  LDA HRSPAT  ;    sauve le pattern                                  
  STA $56    ;    dans HRS1+1                                       
  JSR Le942  ;    v?rifie la validit? de dX et dY                  
  STX HRSX    ;    X et Y contiennent HRSX+dX et HRSY+dY             
  STY HRSY     ;   dans HRSX et HRSY                                 
  BIT $4E    ;    dX n?gatif ?                                      
  BPL LE89D  ;    non ----------------------------------------------
  LDA HRS1    ;    oui, on compl?mente                              I
  EOR #$FF    ;   dX                                               I
  STA HRS1    ;                                                     I
  INC HRS1    ;    ? 2                                              I
LE89D
  BIT $50    ;    dY n?gatif ? <------------------------------------
  BPL LE8A9  ;    non ---------------------------------------------- 
  LDA HRS2    ;    oui on compl?mente                               I
  EOR #$FF   ;    dY                                               I
  STA HRS2    ;                                                     I
  INC HRS2    ;    ? 2                                              I
LE8A9
  LDA HRS1    ;    on teste dX et dY <-------------------------------
  CMP HRS2                                                          
  BCC LE8ED   ;   dX<dY -------------------------------------------- 
  PHP         ;   dX>=dY , on trace selon dX                       I
  LDA HRS1     ;   on prends dX                                     I
  BEQ LE8EB  ;    dX=0, on sort -------------------------------    I 
  LDX HRS2    ;    X=dY                                        I    I
  JSR Le921  ;    on calcule dY/dX                            I    I 
  PLP        ;                                                I    I
  BNE LE8C0  ;    dX<>dY -----------------------------------  I    I 
  LDA #$FF   ;    dX=dY, la tangente est 1                 I  I    I
  STA RES   ;     en fait, -1, mais c'est la m?me chose    I  I    I
LE8C0  
  BIT $4e ; I
  BPL LE8CA          ; I   dX>0 -------------------------------------  I    I
  JSR XHRSCG_ROUTINE ; I   dX<0, on d?place le curseur ? gauche     I  I    I 
  JMP LE8CD          ; I---                                         I  I    I  
LE8CA
  JSR XHRSCD_ROUTINE ; II  on on d?place le curseur ? droite <-------  I    I 
LE8CD
  CLC       ; I-->a-t-on parcouru une valeur de la tangente   I    I
  LDA RES   ; I                                               I    I
  ADC RESB   ; I   on stocke le r?sultat dans RESB              I    I
  STA RESB   ; I                                               I    I
  BCC LE8E3  ;I   non, on continue -------------------------  I    I 
  BIT $50   ; I   oui, dY<0 ?                              I  I    I
  BMI LE8E0 ; I   oui -------------------------------      I  I    I
  JSR XHRSCB_ROUTINE ; I   non, on d?place le curseur        I      I  I    I 
  JMP LE8E3  ;I---vers le bas                       I      I  I    I 
LE8E0
  JSR XHRSCH_ROUTINE ; II  on d?place vers le haut <----------      I  I    I
LE8E3
  JSR XHRSSE_ROUTINE    ;I-->on affiche le point <---------------------  I    I 
  DEC HRS1   ; I   on d?cremente dX,                           I    I
  BNE LE8C0 ; ----on n'a pas parcouru tout l'axe              I    I 
LE8EA
  RTS       ;  -->sinon, on sort                              I    I
LE8EB
  PLP      ;   I  <--------------------------------------------    I
  RTS       ;  I                                                   I
LE8ED
  LDA HRS2   ;  I  on trace la droite selon dY <---------------------
  BEQ LE8EA  ; ---dY=0, on sort                                      
  LDX HRS1   ;     X=dX                                              
  JSR Le921 ;     on calcule dX/dY dans RES                          
LE8F6
  BIT $50                                                          
  BPL LE900  ;    dY>0 --------------------------------------------- 
  JSR XHRSCH_ROUTINE ;    dY<0, on d?place vers le haut                    I 
  JMP LE903  ; ---et on saute                                      I 
LE900
  JSR XHRSCB_ROUTINE  ; I  on d?place vers le bas <-------------------------- 
LE903  
  CLC       ;  -->a-t-on parcouru la tangente ?                     
  LDA RES                                                          
  ADC RESB                                                          
  STA RESB     ;   (dans RESB)                                        
  BCC LE919   ;   non ---------------------------------------------- 
  BIT $4E     ;                                                    I
  BPL LE916   ;   dX>0 ------------------------------------        I
  JSR XHRSCG_ROUTINE   ;   dX<0, on d?place vers                   I        I 
  JMP LE919  ; ---la gauche                               I        I 
LE916  
  JSR XHRSCD_ROUTINE  ; I  on d?place vers la droite <--------------        I 
LE919  
  JSR XHRSSE_ROUTINE   ; -->on affiche le point <----------------------------- 
  DEC HRS2    ;    et on d?crit dY       FIXME                             
  BNE LE8F6                                                       ;
  RTS         ;   avant de sortir de longueur des lignes            

  ;   CALCUL LA TANGENTE (*256) D'UN TRAIT                    
Le921

  STX RES+1     ;   dX (ou dY)*256 dans RES+1                         
  LDY #$00    ;   dY (ou dX) dans AY                                
  STY RES                                                          
  JSR XDIVIS_ROUTINE    ;  calcul dX*256/dY (ou dY/dX)                    
  LDA #$FF     ;  reste =-1                                         
  STA RESB    ;    resultat dans RES                                 
  RTS   

           ;                    ROUTINE CURSET                               
XCURSE_ROUTINE
                                                                              
  LDX HRS1      ;  X=HRSX                FIXME                            
  LDY HRS2     ;   Y=HRSY                FIXME
  JSR hires_verify_position    ;  on v?rifie les coordonn?es                   
LE936
  JSR Le7f3    ;  on place le curseur en X,Y                        

  JMP LE79C    ;  et on affiche sans g?rer pattern      
  
     ;                          ROUTINE CURMOV
XCURMO_ROUTINE
Le93c
  JSR Le942    ;  on v?rifie les param?tres                        
  JMP LE936   ;   et on d?place      

/*
                VERIFIE LA VALIDITE DES PARAMETRES RELATIFS                 
                                                                                
Action:V?rifie si l'adressage relatif du curseur est dans les limites de l'?cran
       HIRES, soit si 0<=X+dX<240 et 0<=Y+dY<200.                               
*/
Le942  
  CLC                                                              
  LDA HRSX     ;   on prend HRSX                                     
  ADC HRS1     ;   plus le d?placement horizontal                    
  TAX          ;  dans X                                            
  CLC                                                              
  LDA HRSY     ;   HRSY                                              
  ADC HRS2     ;   plus le d?placement vertical                      
  TAY         ;   dans Y           

/*
                        TESTE SI X ET Y SONT VALIDES                        
Principe:Si X>239 ou Y>199 alors on ne retourne pas au programme appelant, mais son appelant, en indiquant l'erreur dans HRSERR.                     
*/

hires_verify_position:
  CPX #$F0     ;  X>=240 ?                                          
  BCS @skip     ;   oui ---------------------------------------------- 
  CPY #$C8     ;   Y>=200 ?                                         I
  BCS @skip     ;   oui ---------------------------------------------O
  RTS          ;   coordonnées ok, on sort.                         I
@skip:
  PLA          ;  on d?pile poids fort (>0) <-----------------------
  STA HRSERR   ;  dans HRSERR                                       
  PLA          ;  et poids faible de l'adresse de retour            
  RTS          ;  et on retourne ? l'appelant de l'appelant    



XPAPER_ROUTINE:
  clc
  .byt $24

XINK_ROUTINE:

  sec

;                    FIXE LA COULEUR DE FOND OU DU TEXTE                     

;Principe:A contient la couleur, X la fen?tre ou 128 si mode HIRES et C=1 si la  
;couleur est pour l'encre, 0 pour le fond.                              
;         Changer la couleur consiste ? remplit la colonne couleur correspondante
;         avec le code de couleur. Auncun test de validit? n'?tant fait, on peut 
;         utiliser ce moyen pour remplir les colonnes 0 et 1 de n'importe quel   
;         attribut.                                                              

  PHA           ; on sauve la couleur                               
  PHP           ; et C                                              
  STX RES       ; fen?tre dans RES                                  
  BIT RES       ; HIRES ?                                           
  BMI LE9A7     ; oui ---------------------------------------------- 
  STX SCRNB      ; TEXT, on met le num?ro de fen?tre dans $28       I
  BCC LE971     ; si C=0, c'est PAPER                              I 
  STA SCRCT,X  ;  on stocke la couleur d'encre                     I
  BCS LE974    ;  si C=1 c'est INK                                 I 
LE971
  STA SCRCF,X  ;  ou la couleur de fond  
LE974  
  LDA FLGSCR,X  ;  est on en 38 colonnes ?                          I
  AND #$10     ;                                                   I
  BNE LE987    ; mode 38 colonnes ------------------------------  I
  LDA #$0C     ;  mode 40 colonnes, on efface l'?cran           I  I
  JSR Ldbb5    ;  (on envoie CHR$(12))                          I  I 
  LDA #$1D     ;  et on passe en 38 colonnes                    I  I
  JSR Ldbb5    ;  (on envoie CHR$(29))                          I  I 
  LDX SCRNB      ;  on prend X=num?ro de fen?tre                  I  I
LE987  
  LDA SCRDY,X  ;  on prend la ligne 0 de la fen?tre <------------  I
  JSR XMUL40_ROUTINE    ;  *40 dans RES                                     I 
  LDA SCRBAL,X  ;  AY=adresse de base de la fen?tre                 I
  LDY SCRBAH,X  ;                                                   I
  JSR XADRES_ROUTINE   ;   on ajoute l'adresse ? RES (ligne 0 *40) dans RES I 
  LDY SCRDX,X  ;  on prend la premi?re colonne de la fen?tre       I
  DEY         ;   on enl?ve deux colonnes                          I
  DEY         ;                                                    I
  SEC         ;                                                    I
  LDA SCRFY,X ;   on calcule le nombre de lignes                   I
  SBC SCRDY,X ;   de la fen?tre                                    I
  TAX         ;   dans X                                           I
  INX         ;                                                    I
  TYA         ;   colonne 0 dans Y                                 I
  BCS LE9B3   ;   inconditionnel --------------------------------- I 
LE9A7
  LDA #$00     ;  <----------------------------------------------+--
  LDX #$A0     ;                                                 I  
  STA RES      ;  RES=$A000 , adresse HIRES                      I  
  STX RES+1     ;                                                  I  
  LDX #$C8    ;   X=200 pour 200 lignes                          I  
  LDA #$00    ;   A=0 pour colonne de d?but = colonne 0          I  
LE9B3
  PLP         ;   on sort C <-------------------------------------  
  ADC #$00    ;   A=A+C                                             
  TAY        ;    dans Y                                            
  PLA        ;    on sort le code                                   *
LE9B8
  STA (RES),Y; -->on le place dans la colonne correspondante        
  PHA        ; I  on le sauve                                       
  CLC        ; I                                                    
  LDA RES    ; I  on passe 28 colonnes                              
  ADC #$28    ;I  (donc une ligne)                                  
  STA RES     ;I                                                    
  BCC LE9C6  ; I                                                    
  INC RES+1    ; I                                                    
LE9C6
  PLA        ; I  on sort le code                                   
  DEX        ; I  on compte X lignes                                
  BNE LE9B8   ;---                                                 
  RTS         ;   et on sort----------------------------------------


/*                                                                            
                              TRACE UN CERCLE                               

Principe:Pour tracer une ellipsoide en g?n?ral, on utilise la formule :         
                                                                                
         (X*X)/(A*A)+(Y*Y)/(B*B)=1, A et B ?tant respectivement la largeur      
         et la hauteur de l'ellipse. Pour un cercle, A=B donc on ?crit :        
                                                                                
         X*X+Y*Y=R*R soit encore X=SQR(R*R-Y*Y).                                
                                                                                
         Pour tracer le cercle, il suffit de faire varier Y de 0 ? R. On        
         obtient des valeurs positives de X et de Y donc la quart inf?rieur     
         droit du cercle. On trace les 3 autres quarts par sym?tries. Le        
         probl?me d'un tel algorithme c'est qu'il n?cessite le calcul d'une     
         exponentiation (SQR(A)=A^0.5) et une soustraction d?cimale.            
         Son atout est de n'avoir ? calculer qu'un quart des valeurs.           
                                                                                
         Les concepteurs de l'ATMOS (et ? fortiori F. BROCHE) ayant jug? que cet
         algorithme ?tait par trop complexe et laborieux, on pr?f?r? le calcul  
         par suites crois?es dont la formule est :                              
                                                                                
         X0=0 et Xn=X(n-1)+Yn/R   (n et n-1 sont les indices des termes X et Y) 
         Y0=R et Yn=Y(n-1)-Xn/R                                                 
                                                                                
         Etant donn?e la priorit? de calcul, on calcule en fait les termes :    
                                                                                
         Xn = Xn-1 + Yn-1 / R                                                   
         Yn = Yn-1 - Xn   / R ce qui fait d?ja une petite erreur de calcul.     
                                                                                
         De plus, diviser ? chaque fois par R serait long. Les programmeurs,    
         et c'est l? leur g?nie, ont donc pens? ? deux choses fort astucieuses: 
                                                                                
         a) on divisera non pas par R, mais par la puissance de deux            
            imm?diatement sup?rieure ? R afin de se ramener ? des d?calages.    
            on devient ainsi trop pr?cis, ce qui rattrape l'erreur pass?e.      
                                                                                
         b) on va coder Xn et Yn sur deux octets qui seront se et sf,           
            respectivement les parties enti?res et d?cimale de Xn et Yn.        
            on calcule Xn=AB par Xn=A+B/256. Ce qui revient en fait ? consid?rer
            les 8 bits de B (b7b6b5b4b3b2b1b0) comme des bits de puissance      
            n?gatives d?croissantes (b-1b-2b-3b-4b-5b-6b-7b-8). La pr?cision    
            est donc inf?rieure a 2^-9, soit ? 0,002. Ce qui est tr?s suffisant.
                                                                                
         Une fois ces deux conventions pos?es, on peut tracer le cercle tr?s    
         facilement. Son aspect sera de sym?trie diagonales et non verticale/   
         horizontale du fait de la quadrature exerc?e sur les valeurs mais bon. 
         Pour tracer, on calcule un par un les termes des suites et si la valeur
         enti?re d'un des termes au moins change, on affiche le point. Et on    
         continue jusqu'? ce que Xn et Yn soit revenus ? leur position initiale.
                                                                                
Remarque:La routine est bugg?e, en effet si le rayon est 0, la boucle de calcul 
         de la puissance de 2 > au rayon est infinie, idem si le rayon est 128. 
         Il aurait suffit d'incr?menter le rayon avant le calcul...             
 */
XCIRCL_ROUTINE
Le9cb
                                                                               
  LDA HRSX       ; on sauve HRSX                                     
  PHA                                                              
  LDA HRSY      ;  et HRSY                                           
  PHA                                                              
  LDA HRSPAT   ;   et on met le pattern dans $56                     
  STA HRS5+1      ;  car le trac? du cercle en tient compte            
  LDA HRSY      ;  on prend HRSY                                     
  SEC                                                              
  SBC HRS1     ;   -rayon                                            
  TAY          ;  dans Y                                            
  LDX HRSX     ;   on prend HRSX                                     
  JSR Le7f3    ;  et on place le premier point du cercle (X,Y-R)      
  LDX #$08    ;   X=7+1 pour calculer N tel que Rayon<2^N.          
  LDA HRS1     ;   on prend le rayon                                 
LE9E5
  DEX         ;   on enl?ve une puissance                           
  ASL         ;   on d?cale le rayon ? gauche                       
  BPL LE9E5   ;   jusqu'? ce qu'un bit se pr?sente dans b7            
  STX TR0    ;    exposant du rayon dans $0C                        
  LDA #$80    ;   A=$80 soit 0,5 en d?cimal                         
  STA TR2     ;   dans sfX                                          
  STA TR4     ;   et sfY                                            
  ASL         ;   A=0                                               
  STA TR3     ;   dans seX                                          
  LDA HRS1     ;   A=Rayon                                           
  STA TR5     ;   dans seY                                          
LE9F8
  SEC                                                              

  ROR TR1     ;   on met b7 de TR1 ? 1 (ne pas afficherle point)    
  LDA TR4    ;    AX=sY                                             
  LDX TR5                                                          
  JSR Lea62   ;   on calcule sY/R (en fait sY/2^N)                
  CLC                                                              
  LDA TR2     ;   on calcule sX=sX+sY/R                             
  ADC TR6                                                          
  STA TR2                                                          
  LDA TR3                                                          
  STA TR6                                                          
  ADC TR7                                                          
  STA TR3      ;  la partie enti?re seX a boug? ?                   
  CMP TR6                                                          
  BEQ Lea22   ;  non ----------------------------------------------    
  BCS Lea1d    ;  elle a augment? ----------------------------     I    
  JSR XHRSCD_ROUTINE    ;;  elle ? baiss?, on d?place le curseur       I     I  
  JMP Lea20  ; ---? droite                                   I     I  
Lea1d
  JSR XHRSCG_ROUTINE ;  I  on d?place le curseur ? gauche <------------     I  
Lea20  
  LSR TR1    ; -->on indique qu'il faut afficher le point          I
Lea22
  LDA TR2    ;    AX=sX <-------------------------------------------
  LDX TR3                                                          
  JSR Lea62 ;    on calcule sX/R (en fait sX/2^N)                    
  SEC                                                              
  LDA TR4    ;    et sY=sY-sX/R                                     
  SBC TR6                                                          
  STA TR4                                                          
  LDA TR5                                                          
  STA TR6                                                          
  SBC TR7                                                          
  STA TR5    ;    seY ? chang? (faut-il se d?placer verticalement)? 
  CMP TR6                                                          
  BEQ Lea4a  ;    non ----------------------------------------------    
  BCS Lea44 ;     on est mont? --------------------------------    I  
  JSR XHRSCB_ROUTINE ;     on est descendu, on d?place le curseur      I    I   
  JMP LEA4E ;  ---vers le bas et on affiche                   I    I   
Lea44
  JSR XHRSCH_ROUTINE ;  I  on d?place le curseur vers le haut <---------    I   
Lea41  
  JMP LEA4E ;  O--et on affiche                                    I 
Lea4a  
  BIT TR1   ;  I  faut-il afficher le point ? <---------------------
  BMI Lea51 ;  I  non, on passe  -----------------------------------    
LEA4E
  JSR XHRSSE_ROUTINE   ;  -->on affiche le point nouvellement calcul?         I  
Lea51
  LDA TR3   ;     seX=0 ? <-----------------------------------------
  BNE LE9F8  ;    non, on boucle                                        
  LDA TR5    ;    oui, seY=rayon?                                   
  CMP HRS1                                                          
  BNE LE9F8  ;    non, on boucle                                  
  PLA        ;    oui, on a fait le tour                            
  TAY        ;    on reprend les coordonn?es du curseur sauv?es     
  PLA        ;    dans X et Y                                       
  TAX                                                              
  JMP Le7f3    ;  et on replace le curseur                           
  
/*
                       CALCUL LE DEPLACEMENT sX ou sY                       
                                                                                
Action:calcule dans $13,$12 la valeur de (X,A)/R, en fait (X,A)/2^N.            
*/

Lea62                                        
  STA TR6       ; on place la partie fractionnaire dans $12         
  STX TR7       ; et la partie enti?re dans $13                     
  LDX TR0       ; X=N tel que Rayon<2^N
Lea68  
  LDA TR7       ; on garde le signe du r?sultat                     
  ROL                                                              
  ROR TR7       ; et on divise par 2^X                              
  ROR TR6       ; dans $13,$12                                      
  DEX                                                              
  BNE Lea68                                                        
  RTS         

XFILL_ROUTINE
LEA73
  lda ADHRS
  ldy ADHRS+1
  sta RES 
  sty RES+1
Lea7b
  ldx HRS2
  ldy HRSX40
  lda HRS3
Lea81  
  sta (RES),y
  iny
  dex
  bne Lea81 
  lda #$28
  ldy #0
  jsr XADRES_ROUTINE 
  dec HRS1
  bne Lea7b 
Lea92  
  rts
  
XSCHAR_ROUTINE:
  sta HRS3
  sty HRS3+1
  stx HRS2
  lda #$40
  sta HRSFB
  ldy #$00
Lea9f
  sty HRS2+1
  cpy HRS2
  bcs Lea92 
  lda (HRS3),y
  jsr LEAB5 
  ldy HRS2+1
  iny
  bne Lea9f

XCHAR_ROUTINE
  LDA HRS1
  ASL
  LSR HRS2
  ROR
LEAB5  
  PHA
  LDA HRSX
  CMP #$EA
  BCC Lead3
  LDX HRSX6
  LDA HRSY
  ADC #$07
  TAY
  SBC #$BF
  BCC Lead0   
  BEQ Lead0   
  CMP #$08
  BNE Leacf 
  LDA #$00
Leacf  
  TAY
Lead0  
  JSR Le7f3
Lead3  
  PLA
  JSR ZADCHA_ROUTINE 
  LDY #$00
Lead9  
  STY RES
  LDA HRSX40
  PHA
  LDA HRSX6
  PHA
  LDA (RESB),Y
  ASL
Leae4  
  ASL
  BEQ Leaf3 
  PHA
  BPL Leaed 
  JSR LE79C 
Leaed  
  JSR XHRSCD_ROUTINE 
  PLA
  BNE Leae4 
Leaf3  
  JSR XHRSCB_ROUTINE
  PLA
  STA HRSX6
  PLA
  STA HRSX40
  LDY RES
  INY
  CPY #$08
  BNE Lead9
  LDA HRSX
  ADC #$05
  TAX
  LDY HRSY
  JMP Le7f3 

.include  "functions/sound/sounds.asm"  



READ_A_SERIAL_BUFFER_CODE_INPUT
  ldx #$0c
  jmp LDB5D 
wait_code_on_SERIAL_BUFFER_INPUT:
@loop:
  jsr READ_A_SERIAL_BUFFER_CODE_INPUT 
  bcs @loop
  rts

write_caracter_in_output_serial_buffer
  bit write_caracter_in_output_serial_buffer
  jmp LDB79

;Minitel  
send_a_to_minitel:
  bit INDRS
  bvs Lec49 
  tax
  bmi next910
  cmp #$20
  bcs Lec49 
  adc #$20
next912  
  pha
  lda #$02
  jsr Lec49 
  pla 
  jmp Lec49 
next910
  cmp #$A0
  
  bcs next911 
  adc #$c0
  
  bcs next912 
next911  
  and #$7f
  pha 
  lda #1
  jsr Lec49
  pla

Lec49  
  bit Lec49
  jmp Ldb12 
  
send_A_to_serial_output_with_check:
; MINITEL
  stx TR0
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
  STX TR0
  STY TR1
Lec6f  
  ASL KBDCTC
  BCC Lec77
  PLA
  PLA
  RTS
Lec77  
  BIT $5B
  BMI Lec8b
  JSR READ_A_SERIAL_BUFFER_CODE_INPUT
  BCS Lec6f
LEC80
  PHA
  EOR TR2
  STA TR2
  PLA
  LDX TR0
  LDY TR1
  RTS
  
Lec8b
  JSR LECB4
  BCS Lec6f
  BIT $5B
  BVS LEC80 
  CMP #$20
  BCS LEC80
  PHA
  JSR LECB9 
  TAX
  PLA
  TAY
  TXA
  CPY #$01
  BNE LECA8 
  ORA #$80
  BMI LEC80
LECA8
  CMP #$40
  BCS LECB0 
  SBC #$1F
  BCS LEC80 
LECB0  
  ADC #$3F
  BCC LEC80
LECB4  
  LDX #$0C
  JMP XLISBU_ROUTINE
LECB9  
  JSR LECB4   
  BCS LECB9 
  RTS
Lecbf
  sec
  .byt $24
LECC1  
  clc
  lda #$80
  jmp LDB5D 
LECC7
  sec 
  .byt $24
LECC9  
  clc
  lda #$80

  jmp LDB79 
LECCF
  sec
  .byt $24
LECD1
  clc
  lda #$80
  jmp LDAF7  
  
LECD7  
  sec
  .byt $24
LECD9  
  clc 
  lda #$80
  jmp Ldb12 

compute_file_size
  SEC
  LDA $052F ; FIXME
  SBC $052D ; FIXME
  STA $052A ; FIXME
  LDA $0530 ; FIXME
  SBC $052E ; FIXME
  STA $052B ; FIXME
  LDA $052D ; FIXME
  LDY $052E ; FIXME
  STA RES
  STY RES+1
  rts

send_serial_header_file
  LDX #$32
LECFF  
  LDA #$16
  JSR send_A_to_serial_output_with_check 
  DEX
  BNE LECFF
  LDA #$24
  JSR send_A_to_serial_output_with_check
  LDA #$00 
  STA TR2
  LDX #$00
LED12  
  LDA BUFNOM+1,X 
  JSR send_A_to_serial_output_with_check 
  INX
  CPX #$0C
  BNE LED12 
  LDA #$00
  JSR send_A_to_serial_output_with_check 
  
  LDX #$00
LED24  
  LDA $052C,X ; FIXME
  JSR send_A_to_serial_output_with_check
  INX
  CPX #$07
  BNE LED24 
  LDA TR2
  JMP send_A_to_serial_output_with_check 


read_header_file:
 
  JMP Ldbb5

XCONSO_ROUTINE: 
  JSR LECC1
  JSR LECC9
LED7D  
  JSR READ_A_SERIAL_BUFFER_CODE_INPUT 
  BCS LED85
  JSR Ldbb5
LED85  
  JSR XRD0_ROUTINE;
  BCS LED7D
  CMP #$03
  BEQ LED94
  JSR write_caracter_in_output_serial_buffer
  JMP LED7D  
LED94  
  JSR Lecbf 
  JMP LECC7 
  
XSDUMP_ROUTINE
  JSR LECC1
LED9D  
  ASL KBDCTC
  BCS LEDC7 
  JSR READ_A_SERIAL_BUFFER_CODE_INPUT
  BCS LED9D 
  TAX
  BMI LEDAE 
  CMP #$20
  BCS LEDC1
LEDAE:
  PHA
  LDA #$81
  JSR Ldbb5 
  PLA
  JSR XHEXA_ROUTINE 
  JSR Ldbb5 
  TYA 
  JSR Ldbb5 
  LDA #$87 
LEDC1  
  JSR Ldbb5
  JMP LED9D
LEDC7  
  JMP Lecbf 

XSSAVE_ROUTINE:
  ror $5b  ;  FIXME
  lsr $5b  ; FIXME
  jsr LECC9
  jsr Lee0a 
  jmp LECC7 

XMSAVE_ROUTINE

  ror $5b
  sec
  ror $5b
  jsr LECD9 
  jsr Lee0a 
  jmp LECD7 

XSLOAD_ROUTINE 

  ROR $5B
  LSR $5B
  LDA #$40
  STA VIA::IER
  JSR LECC1
  JSR read_a_file_rs232_minitel 
  LDA #$C0
  STA VIA::IER
  JMP Lecbf 
  
  
XMLOAD_ROUTINE:
  ROR $5B
  SEC
  ROR $5B
  jsr LECD1 
  jsr read_a_file_rs232_minitel 
  jmp LECCF 

;;;;;;;;;;;;;;;;;;  
save_file_rs232_minitel:
Lee0a
  BIT $5B
  BVS LEE11 
  JSR send_serial_header_file 
LEE11  
  JSR compute_file_size

  LDA #$00
  STA TR2
LEE18  
  LDA $052A
  BEQ LEE2F 
  LDY #$00
  LDA (RES),Y
  JSR send_A_to_serial_output_with_check 
  DEC $052A ; FIXME
  INC RES
  BNE LEE18
  INC RES+1
  BNE LEE18 
LEE2F  
  LDA $052B   ; FIXME
  BEQ LEE51 
  LDY #$00
LEE36  
  LDA (RES),Y
  JSR send_A_to_serial_output_with_check 
  INY
  BNE LEE36 
  DEC $052B ; FIXME
  INC RES+1
  BIT $5B ; FIXME
  BPL LEE2F 
  LDA #$30 
  STA $44 ; FIXME
LEE4B  
  LDA $44; FIXME
  BNE LEE4B 
  BEQ LEE2F
LEE51  
  LDA TR2
  JMP send_A_to_serial_output_with_check 
  
read_a_file_rs232_minitel:
  BIT $5B ; FIXME
  BVS @skip  
  JSR read_header_file  
@skip: 
  JSR compute_file_size 
  BIT $5B
  BVC LEE6C  
  LDA #$FF
  STA $052A  ;FIXME
  STA $052B  ;FIXME
LEE6C  
  LDY #$00
  STY TR2
LEE70  
  LDA $052A ; FIXME
  BEQ LEE86  
  JSR Lec6b 
  STA (RES),Y
  DEC $052A   ; FIXME
  INC RES
  BNE LEE70  
  INC RES+1
  JMP LEE70 
LEE86  
  LDA     $052B
  BEQ     LEE9D  
  LDY     #$00
LEE8D  
  JSR     Lec6b 
  STA     (RES),Y
  INY
  BNE     LEE8D  
  INC     RES+1
  DEC     $052B

  JMP     LEE86  
LEE9D  
  JSR     Lec6b  
  ORA     #$30
  JMP     Ldbb5  

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
  
XOPEN_ABSOLUTE_PATH_CURRENT_ROUTINE:
  jsr     _open_root_and_enter
  
  ldx     #$01
  lda     ORIX_PATH_CURRENT,x
  beq     end2000 ; Because ORIX_PATH_CURRENT= /,0 no need to continue
@restart:  
  ldy     #$00
@loop:
  
  lda     ORIX_PATH_CURRENT,x
  beq     @send_set_filename_and_fileopen
  cmp     #"/"
  beq     @send_set_filename_and_fileopen
  sta     BUFNOM,y
  iny
  inx
  
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
  phx
.p02  
.else  
  stx     TR6
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
  plx
  lda     ORIX_PATH_CURRENT,x
  beq     end2000
  inx
  bra     @restart
.p02  
.else
  ldx     TR6
  lda     ORIX_PATH_CURRENT,x
  beq     end2000
  inx
  jmp     @restart
.endif  
end2000:
  rts

  
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

  sta BUFNOM,x

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
  AND     #O_RDONLY
  cmp     #O_RDONLY
  beq     @read_only
  lda     TR4
  AND     #O_WRONLY
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
  ldx #$00
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
 
XLIGNE_ROUTINE:
  ; REMOVEME minitel
; minitel ; get the line
  jsr     LECD9 
  jsr     Lec49 
  jmp     LECD7

XSOUT_ROUTINE:
; RS232 
  pha 
  jsr     LECC9
  pla
  jsr     write_caracter_in_output_serial_buffer
  jmp     LECC7    ; FIXME 65C02
add_0_5_A_ACC1:
  lda     #<const_zero_dot_half 
  ldy     #>const_zero_dot_half 
  jmp     AY_add_acc1 ; AY+acc1
Lef97:
  rts ; Don't know why there is this RTS !

  
ACC2_ACC1:
  jsr     LF1EC 
XA2NA1_ROUTINE  
  lda     ACC1S ;$65 
  eor     #$ff
  sta     ACC1S ; $65
  eor     $6d
  sta     $6e
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
  stx     $89
  ldx     $66
  stx     $7F
  ldx     #$68
  lda     $68
LEFC2:  
  tay 
  beq     Lef97 
  sec
  sbc     ACC1E
  beq     next802  
  bcc     @next801 
  sty     ACC1E
  ldy     $6D
  sty     ACC1S
  eor     #$ff
  adc     #$00
  
  ldy     #$00
  sty     $7F
  ldx     #$60
  bne     @L2
@next801:
  ldy     #$00
  sty $66
@L2:
  cmp #$f9
  bmi mantisse_A
  tay
  lda $66
  lsr RES+1,x
  
  jsr LF0FC 
next802  
  bit $6e
  bpl Lf049 
  ldy #$60
  cpx #$68
  beq LEFFA 
  ldy #$68
LEFFA:
  sec
  eor #$ff
  adc $7f
  sta $66
  lda $0004,y
  sbc $04,x
  sta $64
  lda $0003,y
  sbc RESB+1,x
  sta $63
  lda $0002,y
  sbc RESB,x
  sta $62
  lda $0001,y
  sbc RES+1,x
  sta ACC1M
LF01D:
  bcs Lf022 
  
  jsr Lf090 
Lf022:
  ldy #00
  tya
  clc
LF026:  
  ldx ACC1M
  
  bne LF074 
  ldx $62
  stx ACC1M 
  
  ldx $63
  stx $62

  ldx $64
  
  stx $63

  ldx $66
  stx $64
  sty $66

  adc #$08
  cmp #$28
  bne LF026 
Lf042:
  lda #0
  sta ACC1E
LF046:
  sta ACC1S  
  rts
Lf049:

  ADC $7F
  STA $66
  LDA $64
  ADC $6C
  STA $64
  LDA $63
  ADC $6B
  STA $63
  LDA $62
  ADC $6A
  STA $62
  LDA ACC1M
  ADC $69
  STA ACC1M
  JMP Lf081
Ld068:
  ADC #$01
  ASL $66
  ROL $64
  ROL $63
  ROL $62
  ROL ACC1M
LF074:  
  BPL Ld068
  
  SEC
  
  SBC ACC1E
  BCS Lf042 
  EOR #$FF
  ADC #$01
  STA ACC1E
Lf081:
  BCC Lf08f
LF083:  
  INC ACC1E
  
  BEQ LF0C7 
  ROR ACC1M
  ROR $62
  ROR $63
  ROR $64
Lf08f
  RTS
Lf090  

       lda     ACC1S
        eor     #$FF
        sta     ACC1S
LF096:  lda     ACC1M
        eor     #$FF
        sta     ACC1M
        lda     $62
        eor     #$FF
        sta     $62
        lda     $63
        eor     #$FF
        sta     $63
        lda     $64
        eor     #$FF
        sta     $64
        lda     $66
        eor     #$FF
        sta     $66
        inc     $66
        bne     LF0C6
LF0B8:  inc     $64
        bne     LF0C6
        inc     $63
        bne     LF0C6
        inc     $62
        bne     LF0C6
        inc     ACC1M
LF0C6:  rts



LF0C7:  lda     #$01
LF0C9:  sta     $8B
        ldx     $89
        txs
        rts

  
justify__to_the_right_with_A_and_X
LF0CF:  ldx     #$6E
LF0D1:  ldy     $04,x
        sty     $66
        ldy     RESB+1,x
        sty     $04,x
        ldy     RESB,x
        sty     RESB+1,x
        ldy     RES+1,x
        sty     RESB,x
        ldy     $67
        sty     RES+1,x
LF0E5:  adc     #$08
        bmi     LF0D1
        beq     LF0D1
        sbc     #$08
        tay
        lda     $66
        bcs     LF106
LF0F2:  asl     RES+1,x
        bcc     LF0F8
        inc     RES+1,x
LF0F8:  ror     RES+1,x
        ror     RES+1,x
LF0FC:  ror     RESB,x
        ror     RESB+1,x
        ror     $04,x
        ror   
        iny
        bne     LF0F2
LF106:  clc
        rts  
const_ln_10
  .byt $82,$13,$5d,$8d,$de ; 2.302585093 = ln(10)
const_pi_radians
  .byt $82,$49,$0f,$da,$9e ; PI in radians (3.14159265)
const_pi_degree  
  .byt $88,$34,$00,$00,$00

polynome_ln_coef  
  
  .byt $03,$7f,$5e,$56,$cb,$79,$80,$13,$9b
  .byt $0b,$64,$80,$76,$38,$93,$16
  
  .byt $82,$38,$aa,$3b,$20 ; 2.885390073 = 2/ln(2)

  
const_for_ln: 
const_sqr_two_divided_by_two:
  .byt $80,$35,$04,$f3,$34 ; sqr(2/2) = 0.7071067812
const_sqr_two:  
  .byt $81,$35,$04,$f3,$34 ; sqr(2) = 1.414213562
const_negative_zero_dot_five:
  .byt $80,$80,$00,$00,$00 ; -0.5
const_ln_2:  
  .byt $80,$31,$72,$17,$f8 ; ln(2) = 0.683147806
LF140
  rts
LF141  
  lda #2
  jmp LF0C9 

XLN_ROUTINE:
        tsx
        stx     $89
LF149:  jsr     LF3BD  
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
   
LF184:  jsr     LF1EC 
        beq     LF140
        bne     LF190
XA1MA2_ROUTINE: 
        beq     LF140
LF18D    
        tsx
        stx     $89
LF190:  jsr     LF217 
        lda     #$00
        sta     $6F
        sta     $70
        sta     $71
        sta     $72
        lda     $66
        jsr     LF1B9  
        lda     $64
        jsr     LF1B9  
        lda     $63
        jsr     LF1B9 
        lda     $62
        jsr     LF1B9 
        lda     ACC1M
        jsr     LF1BE  
        jmp     Lf301  

LF1B9:  bne     LF1BE
        jmp     LF0CF  

LF1BE:  lsr
        ora     #$80
LF1C1:  tay
        bcc     LF1DD
        clc
        lda     $72
        adc     $6C
        sta     $72
        lda     $71
        adc     $6B
        sta     $71
        lda     $70
        adc     $6A
        sta     $70
        lda     $6F
        adc     $69
        sta     $6F
LF1DD:  ror     $6F
        ror     $70
        ror     $71
        ror     $72
        ror     $66
        tya
        lsr
        bne     LF1C1
        rts
  
;ay -> acc2

LF1EC:
    sta     $7D
        sty     $7E
        ldy     #$04
        lda     ($7D),y
        sta     ADMEN+3 ; $6C
        dey
        lda     ($7D),y
        sta     ADMEN+2 ; $6B
        dey
        lda     ($7D),y
        sta     ADMEN+1 ; $6a
        dey
        lda     ($7D),y
        sta     ADMEN+4
        eor     ACC1S
        sta     ADMEN+5; $6E
        lda     ADMEN+4 ; $6d
        ora     #$80
        sta     ADMEN ; $69
        dey
        lda     ($7D),y
        sta     FLGMEN ; $68
        lda     ACC1E
        rts
  

LF217:  lda     $68
LF219:  beq     LF237
        clc
        adc     ACC1E
        bcc     LF224 
        bmi     Lf23c
        clc
        .byte   $2C
LF224:  bpl     LF237
        adc     #$80
        sta     ACC1E
        beq     Lf23f
        lda     $6E
        sta     ACC1S
        rts

LF231:  lda     ACC1S
        eor     #$FF
        bmi    Lf23c
LF237:  pla
        pla
        jmp     Lf042 
Lf23c    
    jmp LF0C7 
Lf23f    
    jmp LF046 
; 10*acc1->acc1  
Lf242
  JSR XA1A2_ROUTINE
  TAX
  BEQ Lf258
  CLC
  ADC #$02
  BCS Lf23c
  LDX #$00
  STX $6E
  JSR LEFC2 
  INC ACC1E
  beq Lf23c
Lf258
  rts
ten_in_floating_point
  .byt $84,$20,$00,$00,$00 ; Ten in floating point
Lf25e
acc1_1_divide_10_in_acc1
  jsr XA1A2_ROUTINE 
  ldx #0
  lda #<ten_in_floating_point
  ldy #>ten_in_floating_point
LF267
  stx $6e

  jsr Lf323 
  jmp XA2DA1_ROUTINE  
  
XLOG_ROUTINE:
  tsx
  stx $89
  jsr LF149 
  jsr XA1A2_ROUTINE 
  lda #<const_ln_10
  ldy #>const_ln_10
  jsr Lf323 
  jmp XA2DA1_ROUTINE  

display_divide_per_0:
  lda #$03
  sta FLERR ; FLERR
  rts
Lf287:
  JSR LF1EC
  
XA2DA1_ROUTINE:
  BEQ display_divide_per_0
  TSX
  STX FLSVS
  JSR XAA1_ROUTINE
  LDA #$00
  SEC
  SBC ACC1E
  STA ACC1E
  JSR LF217 
  INC ACC1E
  BEQ Lf23c
  LDX #$FC
  LDA #$01
LF2A4  
  LDY $69 ; FIXME
  CPY ACC1M
  BNE LF2BA 
  LDY $6A
  CPY $62
  BNE LF2BA
  LDY $6B
  CPY $63
  BNE LF2BA
  LDY $6C
  CPY $64
LF2BA  
  PHP
  ROL
  BCC LF2CA 
  INX
  STA $72,X
  BEQ LF2C8
  BPL LF2F8 
  LDA #$01
Lf2c7  
  .byt $2c
LF2C8  
  lda #$40
  ;
LF2CA  
  PLP
  BCS LF2DB 
LF2CD  
  ASL $6C
  ROL $6B
  ROL $6A
  ROL $69
  BCS LF2BA 
  BMI LF2A4 
  BPL LF2BA
LF2DB  
  TAY
  LDA $6C
  SBC $64
  STA $6C
  LDA $6B
  SBC $63
  STA $6B
  LDA $6A
  SBC $62
  STA $6A
  LDA $69
  SBC ACC1M
  STA $69
  TYA 
  JMP LF2CD 
LF2F8  
  asl
  asl
  asl
  asl
  asl
  asl
  sta $66
  plp

; acc3->acc1  
Lf301
  
  lda $6f
  sta ACC1M
  lda $70
  sta $62
  lda $71
  sta $63
  lda $72
  sta $64
  jmp Lf022

XPI_ROUTINE  
Lf314
; pi->acc1
  jsr test_if_degree_mode 
  beq Lf31f ; is it in radian mode ?
  lda #<const_pi_degree
  ldy #>const_pi_degree
  bne Lf323
Lf31f  
  lda #<const_pi_radians 
  ldy #>const_pi_radians

XAYA1_ROUTINE:
Lf323
  STA $7D
  STY $7E
  LDY #$04
  LDA ($7D),Y
  STA $64
  DEY
  LDA ($7D),Y
  STA $63
  DEY
  LDA ($7D),Y
  STA $62
  DEY
  LDA ($7D),Y
  STA ACC1S
  ORA #$80
  STA ACC1M
  DEY
  LDA ($7D),Y
  STA ACC1E
  STY $66
  RTS
LF348
  ldx #$73
  .byt $2c
LF34B
  ldx #$78
  ldy #$00

  JSR XAA1_ROUTINE 

XA1XY_ROUTINE:
  STX $7D
  STY $7E
  
  
  LDY #$04
  LDA $64
  STA ($7D),Y
  DEY
  LDA $63
  STA ($7D),Y
  DEY
  LDA $62
  STA ($7D),Y
  DEY
  LDA ACC1S
  ORA #$7F
  AND ACC1M
  STA ($7D),Y
  DEY
  LDA ACC1E
  STA ($7D),Y
  STY $66
  RTS
XA2A1_ROUTINE  
  lda $6d
LF379  
  sta ACC1S
  ldx #$05
LF37D  
  lda $67,x
  sta $5f,x
  dex
  bne LF37D
  stx $66
  rts


XA1A2_ROUTINE:
  ; arrondi ACC1 in ACC2_ACC1
  jsr XAA1_ROUTINE
  
LF38A:  ldx     #$06
LF38C:  lda     $5F,x
        sta     $67,x
        dex
        bne     LF38C
        stx     $66
LF395:  rts
XAA1_ROUTINE
LF396:
  lda     ACC1E
    beq     LF395
    asl     $66
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
    lda     $64
    ldy     $63
    rts  

LF3B8  
  lda #$0a
  jmp LF0C9  

LF3BD:  lda     ACC1E
        beq     LF3CA
LF3C1:  lda     ACC1S
LF3C3:  rol   
        lda     #$FF
        bcs     LF3CA
        lda     #$01
LF3CA:  rts

  jsr LF3BD
  .byt $2c

LF3CD
;  ACC=-
  lda #$ff
LF3D1  
  STA ACC1M
  LDA #$00
  STA $62
  LDX #$88
  LDA ACC1M
  EOR #$FF
  ROL
LF3DE  
  LDA #$00
  STA $63
  STA $64
  STX ACC1E
  STA $66
  STA ACC1S
  JMP LF01D 

XIYAA1_ROUTINE:  
  sta ACC1M
  sty $62
  ldx #$90
  sec
  bcs LF3DE
ABS_ROUTINE  
  lsr ACC1S
LF3F8  
  rts

LF3F9:
  STA $7D
  STY $7E
  LDY #$00
  LDA ($7D),Y
  INY
  TAX 
  BEQ LF3BD  
  LDA ($7D),Y
  EOR ACC1S
  BMI LF3C1 
  CPX ACC1E
  BNE LF430 
  LDA ($7D),Y
  ORA #$80
  CMP ACC1M
  BNE LF430
  INY
  LDA ($7D),Y
  CMP $62
  BNE LF430
  INY
  LDA ($7D),Y
  CMP $63
  BNE LF430  
  INY
  LDA #$7F
  CMP $66
  LDA ($7D),Y
  SBC $64
  BEQ LF3F8 
LF430  
  LDA ACC1S
  BCC LF436  
  EOR #$FF
LF436  
  JMP LF3C3 


LF439
  LDA ACC1E
  BEQ LF487
  SEC
  SBC #$A0
  BIT ACC1S
  BPL LF44D 
  TAX
  LDA #$FF
  STA $67
  JSR LF096 
  TXA
LF44D  
  LDX #$60
  CMP #$F9
  BPL LF459 
  JSR LF0E5
  STY $67
  RTS

LF459: 
  TAY
  LDA ACC1S
  AND #$80
  LSR ACC1M
  ORA ACC1M
  STA ACC1M
  JSR LF0FC 
  STY $67
LF469  
  RTS
  
XINT_ROUTINE:
  LDA ACC1E
  CMP #$A0
  BCS LF469 
  JSR LF439 
  STY $66
  LDA ACC1S
  STY ACC1S
  EOR #$80
  ROL
  LDA #$A0
  STA ACC1E
  LDA $64
  STA $88
  JMP LF01D
LF487  
  STA ACC1M
  STA $62
  STA $63
  STA $64
  TAY
  RTS
LF491
  sta ACC1M
  stx $62
  ldx #$90
  sec
  jmp LF3DE

XA1AFF_ROUTINE: 
  jsr XA1DEC_ROUTINE   
  lda #$00
  ldy #$01
  jmp XWSTR0_ROUTINE 

XA1DEC_ROUTINE:
  LDY #$00
  LDA #$20
  BIT ACC1S
  BPL LF4AF 
  LDA #$2D
LF4AF  
  STA $0100,Y
  STA ACC1S
  STY $77
  INY
  LDA #$30
  LDX ACC1E
  BNE LF4C0 
  
  JMP LF5C8
LF4C0  
  LDA #$00
  CPX #$80
  BEQ LF4C8
  BCS LF4D1 
LF4C8  
  LDA #<const_for_decimal_convert 
  LDY #>const_for_decimal_convert
  JSR LF184 
  LDA #$F7 ; Should be indexed ?.= FIXME
LF4D1  
  STA $74
LF4D3  
  LDA #<LF5DA
  LDY #>LF5DA 
  JSR LF3F9 ;
  BEQ LF4FA 
  BPL LF4F0 
LF4DE  
  LDA #<const_999_999_dot_9
  LDY #>const_999_999_dot_9
  JSR LF3F9 ; 
  BEQ LF4E9 
  BPL LF4F7 
LF4E9  
  JSR Lf242 ;
  DEC $74 
  BNE LF4DE
LF4F0  
  JSR Lf25e ; 
  INC $74
  BNE LF4D3
LF4F7
  JSR add_0_5_A_ACC1
LF4FA  
  JSR LF439 
  LDX #$01
  LDA $74
  CLC
  ADC #$0A
  BMI LF50F 
  CMP #$0B
  BCS LF511
  ADC #$FF
  TAX
  LDA #$02
LF50F  
  SEC
LF511
  SBC #$02
  STA $75
  STX $74
  TXA
  BEQ LF51B 
  BPL LF52E 
LF51B  
  LDY $77
  LDA #$2E
  INY
  STA $0100,Y
  TXA
  BEQ LF52C 
  LDA #$30
  INY
  STA $0100,Y
LF52C  
  STY $77
LF52E

  LDY #$00
  LDX #$80
LF532  
  CLC
LF533  
  LDA $64
  ADC const_negative_100_000_000+3,Y 
  STA $64
  LDA $63
  ADC const_negative_100_000_000+2,Y 
  STA $63
  LDA $62
  ADC const_negative_100_000_000+1,Y
  STA $62
  LDA ACC1M
  ADC const_negative_100_000_000,Y 
  STA ACC1M
  INX
  BCS LF556
  BPL LF533
  BMI LF558
LF556  
  BMI LF532
LF558  
  TXA 
  BCC LF55F
  EOR #$FF
  ADC #$0A
LF55F  
  ADC #$2F
  INY
  INY
  INY
  INY
  STY $76
  LDY $77
  INY
  TAX
  AND #$7F
  STA $0100,Y
  DEC $74
  BNE LF57A 
  LDA #$2E
  INY
  STA $0100,Y
LF57A  
  STY $77
  LDY $76
  TXA
  EOR #$FF
  AND #$80
  TAX
  CPY #$24
  BNE LF533 
  LDY $77
LF58A  
  LDA $0100,Y
  DEY
  CMP #$30
  BEQ LF58A 
  CMP #$2E
  BEQ LF597
  INY
LF597  
  LDA #$2B
  LDX $75
  BEQ LF5CB 
  BPL LF5A7 
  LDA #$00
  SEC
  SBC $75
  TAX
  LDA #$2D
LF5A7  
  STA $0102,Y
  LDA #$45
  STA $0101,Y
  TXA
  LDX #$2F
  SEC
LF5B3  
  INX
  SBC #$0A
  BCS LF5B3 
  ADC #$3A
  STA $0104,Y
  TXA
  STA $0103,Y
  
  LDA #$00
  STA $0105,Y
  BEQ LF5D0 
LF5C8  
  STA $0100,Y
LF5CB  
  LDA #$00
  STA $0101,Y
LF5D0  
  LDA #$00
  LDY #$01
  RTS

  
const_for_decimal_convert:
const_one_billion  
  .byt $9e,$6e,$6b,$28,$00 ; 1 000 000 000  float
const_999_999_999
LF5DA  
  .byt $9e,$6e,$6b,$27,$fd ; 999 999 999
const_999_999_dot_9
  .byt $9b,$3e,$bc,$1f,$fd ; 999 999.9
const_zero_dot_half  
LF5E4  
  .byt $80,$00,$00,$00,$00 ; 0.5 
LF5E9 ; 
const_negative_100_000_000 ; 32 bits binary signed
  .byt $fa,$0a,$1f,$00
const_ten_million
LF5ED
  .byt $00,$98,$96,$80 ; 10 000 000 
  .byt $ff,$f0,$bd,$c0 ; -1 000 000


  .byt $00,$01,$86,$a0,$ff,$ff,$d8,$f0,$00,$00,$03
  .byt $e8,$ff,$ff,$ff,$9c,$00,$00,$00,$0a
LF609  
  .byt $ff,$ff,$ff,$ff
LF60D
  jmp Lf042
XSQR_ROUTINE

  jsr XA1A2_ROUTINE 
  lda #<const_zero_dot_half  
  ldy #>const_zero_dot_half  
  jsr XAYA1_ROUTINE 

XA2EA1_ROUTINE:
  BEQ XEXP_ROUTINE  
  TSX
  STX $89
  LDA $68
  BEQ LF60D 
  LDX #$80
  LDY #$00
  JSR XA1XY_ROUTINE 
  LDA $6D
  BPL LF63D  
  JSR XINT_ROUTINE  
  LDA #$80
  LDY #$00
  JSR LF3F9 
  BNE LF63D  
  TYA
  LDY $88
LF63D
  JSR LF379  
  TYA
  PHA
  JSR LF149  ; 
  LDA #$80
  LDY #$00
  JSR LF184  
  JSR  LF68F ; 
  PLA
  LSR
  BCC LF65D  

XNA1_ROUTINE:

  ; negative number
  lda ACC1E
  beq LF65D 
  lda ACC1S
  eor #$ff
  sta ACC1S
LF65D  
  rts
const_1_divide_ln_2 ; 1/ln(2)  
  .byt $81,$38,$aa,$3b,$29
coef_polynome

  .byt $07 ; for 8 coef
  .byt $71,$34,$58,$3e,$56
  .byt $74,$16,$7e,$b3,$1b
  .byt $77,$2f,$ee,$e3,$85
  .byt $7a,$1d,$84,$1c,$2a
  .byt $7c,$63,$59,$58,$0a
  .byt $7e,$75,$fd,$e7,$c6
  .byt $80,$31,$72,$18,$10
  .byt $81,$00,$00,$00,$00 ; 1
XEXP_ROUTINE:

  TSX
  STX $89
LF68F  
  LDA #<const_1_divide_ln_2
  LDY #>const_1_divide_ln_2
  JSR LF184 
  LDA $66
  ADC #$50
  BCC LF69F 
  JSR XAA1_ROUTINE 
LF69F  
  STA $7F
  JSR LF38A 
  LDA ACC1E
  CMP #$88
  BCC LF6AD
LF6AA  
  JSR LF231 
LF6AD  
  JSR XINT_ROUTINE 
  
  LDA $88
  CLC
  ADC #$81
  BEQ LF6AA
  SEC
  SBC #$01
  PHA
  LDX #$05
LF6BD  
  LDA $68,X
  LDY ACC1E,X
  STA ACC1E,X
  STY $68,X
  DEX
  BPL LF6BD 
  LDA $7F
  STA $66
  JSR XA2NA1_ROUTINE
  JSR XNA1_ROUTINE 
  LDA #<coef_polynome 
  LDY #>coef_polynome 
  JSR LF6F7 
  LDA #$00
  STA $6E
  PLA
  JMP LF219 


LF6E1  
  STA $85
LF6E3  
  STY $86
LF6E5  
  JSR LF348 
LF6E8  
  LDA #$73
  JSR LF184
  JSR LF6FB 
  LDA #$73
  LDY #$00
  JMP LF184  

  
LF6F7
  STA $85
  STY $86
LF6FB  
  JSR LF34B 
  LDA ($85),Y
  STA $87
  LDY $85
  INY
  TYA
  BNE LF70A 
  INC $86
LF70A  
  STA $85
  LDY $86
LD70E  
  JSR LF184 
  LDA $85
  LDY $86
  CLC
  ADC #$05
  BCC LF71B 
  INY
LF71B  
  STA $85
  STY $86
  JSR AY_add_acc1  
  LDA #$78
  LDY #$00
  DEC $87
  BNE LD70E  
LF72A
  rts
  

values_rnd

const_11879546_for_rnd
  .byt $98,$35,$44,$7a,$6b ; 11879546,42
const_3_dot_92_for_rnd_etc
LF730
  .byt $68,$28,$b1,$46,$20 ;3.927678 E-08
  
XRND_ROUTINE

  JSR LF3BD
  TAX
  BMI LF753 
  LDA #$EF
  LDY #$02
  JSR Lf323
  TXA
  BEQ LF72A 
  LDA #<const_11879546_for_rnd
  LDY #>const_11879546_for_rnd
  JSR LF184
  LDA #<const_3_dot_92_for_rnd_etc
  LDY #>const_3_dot_92_for_rnd_etc
  JSR AY_add_acc1 
LF753  
  LDX $64
  LDA ACC1M
  STA $64
  STX ACC1M
  LDA #$00
  STA ACC1S
  LDA ACC1E
  STA $66
  LDA #$80
  STA ACC1E
  JSR Lf022 
  LDX #$EF ; FIXME
  LDY #$02 ; FIXME
  JMP XA1XY_ROUTINE

XRAND_ROUTINE:
  JSR LF348
  JSR XRND_ROUTINE 
  LDA #$73
  LDY #$00
  JSR LF184 
  JMP XINT_ROUTINE 

XCOS_ROUTINE:

  JSR LF8B1 
  LDA #<CONST_PI_DIVIDED_BY_TWO
  LDY #>CONST_PI_DIVIDED_BY_TWO
  JSR AY_add_acc1
  JMP LF791

XSIN_ROUTINE:

  JSR LF8B1
LF791  
  JSR XA1A2_ROUTINE
  LDA #<const_pi_mult_by_two
  LDY #>const_pi_mult_by_two
  LDX $6D
  JSR LF267 
  JSR XA1A2_ROUTINE 
  JSR XINT_ROUTINE
  LDA #$00
  STA $6E
  JSR XA2NA1_ROUTINE
  LDA #<const_0_dot_twenty_five
  LDY #>const_0_dot_twenty_five 
  JSR ACC2_ACC1 
  LDA ACC1S
  PHA
  BPL LF7C5
  JSR add_0_5_A_ACC1
  LDA ACC1S
  BMI LF7C8 
  LDA $8A
  EOR #$FF
  STA $8A
  .byt $24
LF7C4  
  pha
LF7C5  
  JSR XNA1_ROUTINE 
LF7C8  
  LDA #<const_0_dot_twenty_five
  LDY #>const_0_dot_twenty_five
  JSR AY_add_acc1
  PLA
  BPL LF7D5
  JSR XNA1_ROUTINE
LF7D5  
  LDA #<coef_polynome_sin
  LDY #>coef_polynome_sin
  JMP LF6E1


  
CONST_SIN_AND_COS
CONST_PI_DIVIDED_BY_TWO
LF7DC
  .byt $81,$49,$0f,$da,$a2
const_pi_mult_by_two
  .byt $83,$49,$0f,$da,$a2 ; 6.283185307
const_0_dot_twenty_five ; 0.25
  .byt $7f,$00,$00,$00,$00
coef_polynome_sin
  .byt $05 ; 6 coef
  .byt $84,$e6,$1a,$2d,$1b
  .byt $86,$28,$07,$fb,$f8
  .byt $87,$99,$68,$89,$01
  .byt $87,$23,$35,$df,$e1
  .byt $86,$a5,$5d,$e7,$28
  .byt $83,$49,$0f,$da,$a2

XTAN_ROUTINE
  JSR LF8B1 
  JSR LF348
  LDA #$00
  STA $8A
  JSR LF791 
  LDX #$80
  LDY #$00
  JSR XA1XY_ROUTINE 
  LDA     #$73
  LDY     #$00
  JSR Lf323
  LDA #$00
  STA ACC1S
  LDA $8A
  JSR LF7C4
  LDA #$80
  LDY #$00
  JMP Lf287


  
XATN_ROUTINE
  LDA ACC1S
  PHA
  BPL @L1
  JSR XNA1_ROUTINE 
@L1:
  LDA ACC1E
  PHA
  CMP #$81
  BCC @L2
  LDA #<const_atn_1
  LDY #>const_atn_1 
  JSR Lf287 
@L2:  
  LDA #<const_coef_atn 
  LDY #>const_coef_atn 
  JSR LF6E1
  PLA
  CMP #$81 
  BCC @L3
  LDA #<CONST_SIN_AND_COS 
  LDY #>CONST_SIN_AND_COS
  JSR ACC2_ACC1
@L3:  
  PLA
  BPL @L4
  JSR XNA1_ROUTINE
@L4:  
  JSR test_if_degree_mode 
  BEQ @L5
  JMP XDEG_ROUTINE   
@L5:
  RTS

const_coef_atn:
  .byt $0b ; 11 coef
  .byt $76,$b3,$83,$bd,$d3
  .byt $79,$1e,$f4,$a6,$f5
  .byt $7b,$83,$fc,$b0,$10
  .byt $7c,$0c,$1f,$67,$ca
  .byt $7c,$de,$53,$cb,$c1
  .byt $7d,$14,$64,$70,$4c
  .byt $7d,$b7,$ea,$51,$7a
  .byt $7d,$63,$30,$88,$7e
  .byt $7e,$92,$44,$99,$3a
  .byt $7e,$4c,$cc,$91,$c7
  .byt $7f,$aa,$aa,$aa,$13
const_atn_1  
  .byt $81,$00,$00,$00,$00 ; 1 coef 0

XDEG_ROUTINE  

  ; convert ACC1 in defree
  lda #<const_180_divided_by_pi
  ldy #>const_180_divided_by_pi 
  jmp LF184 

LF8B1
  jsr     test_if_degree_mode  
  beq     LF8CC    
XRAD_ROUTINE
LF8B
  lda     #<const_pi_divided_by_180   
  ldy     #>const_pi_divided_by_180  
  jmp     LF184
  
const_180_divided_by_pi
LF8BD
  .byt $86,$65,$2e,$e0,$d8
const_pi_divided_by_180  
  .byt $7b,$0e,$fa,$35,$19

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

LF8DB:  jsr     LF9FC 
        bcc     LF8E7
        cmp     #$41
        bcc     LF915
        sbc     #$37
        .byt   $2C
LF8E7:  sbc     #$2F
        cmp     #$10
        bcs     LF915
        asl   
        asl    
        asl    
        asl    
        ldx     #$04
LF8F3:  asl    
        rol     $62
        rol     ACC1M
        bcs     LF912
        dex
        bne     LF8F3
        beq     LF8DB
LF8FF:  jsr     LF9FC
        bcs     LF915
        cmp     #$32
        bcs     LF915
        cmp     #$31
        rol     $62
        rol     ACC1M
        bcs     LF912
        bcc     LF8FF
LF912:  jmp     LF0C7 

LF915:  ldx     #$90
        sec
        jsr     LF3DE 
        ldx     #$00
        rts  

;;;;;;;;;;;;;;; 
XDECA1_ROUTINE
LF91E
        sta     RES
        sty     RES+1
        tsx
        stx     $89
        lda     #$00
        sta     RESB
        sta     RESB+1
        sta     $66
        ldx     #$05
LF92F:  sta     ACC1E,x
        sta     $73,x
        dex
        bpl     LF92F
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
LF94C:  stx     RESB+1
LF94E:  jsr     LF9FC
LF951:  bcc     LF9CD
LF953:  cmp     #$2E
        beq     LF9A6
        cmp     #$45
        beq     LF95F
        cmp     #$65
        bne     LF9AC
LF95F:  ldx     RESB
        jsr     LF9FC
        bcc     LF976
        cmp     #$2D
        beq     LF96F
        cmp     #$2B
        bne     LF998
        .byte   $2C
LF96F:  ror     $77
LF971:  jsr     LF9FC
        bcs     LF99A
LF976:  lda     $75
        cmp     #$0A
        bcc     LF985
        lda     #$64
        bit     $77
        bmi     LF993
        jmp     LF0C7

LF985:  asl    
        asl    
        clc
        adc     $75
        asl    
        clc
        ldy     RESB
        adc     (RES),y
        sec
        sbc     #$30
LF993:  sta     $75
        jmp     LF971

LF998:  stx     RESB
LF99A:  bit     $77
        bpl     LF9AC
        lda     #$00
        sec
        sbc     $75
        jmp     LF9AE

LF9A6:  ror     $76
        bit     $76
        bvc     LF94E
LF9AC:  lda     $75
LF9AE:  sec
        sbc     $74
        sta     $75
        beq     LF9C7
        bpl     LF9C0
LF9B7:  jsr     Lf25e
        inc     $75
        bne     LF9B7
        beq     LF9C7
LF9C0:  jsr     Lf242 
        dec     $75
        bne     LF9C0
LF9C7:  lda     RESB+1
        bmi     LF9E1
        bpl     LF9E4
LF9CD:  pha
        bit     $76
        bpl     LF9D4
        inc     $74
LF9D4:  jsr     Lf242
        pla
        sec
        sbc     #$30
        jsr     LF9E9
        jmp     LF94E

LF9E1:  jsr     XNA1_ROUTINE
LF9E4:  ldx     #$00
        jmp     XAA1_ROUTINE

LF9E9:  pha
        jsr     XA1A2_ROUTINE
        pla
        jsr     LF3D1
        lda     $6D
        eor     ACC1S
        sta     $6E
        ldx     ACC1E
        jmp     XA1PA2_ROUTINE 

LF9FC:  inc     RESB
LF9FE:  ldy     RESB
        lda     (RES),y
        jsr     XMINMA_ROUTINE
        cmp     #$20
        beq     LF9FC 
        cmp     #$30
        bcc     LFA10
        cmp     #$3A
        rts

LFA10:  sec
        rts

XINTEG_ROUTINE    
    
        jsr     XA1A2_ROUTINE
        lda     $68
        beq     LFA32
        bpl     LFA3C
        sec
        lda     #$A1
        sbc     $68
        bcc     LFA3C
        tax
LFA23:  dex
        beq     LFA39
        lsr     $69
        ror     $6A
        ror     $6B
        ror     $6C
        bcc     LFA23
        bcs     LFA3C
LFA32:  ldx     #$03
        sta     $69,x
        dex
        bpl     LFA23
LFA39:  lda     #$01
        rts

LFA3C:  lda     #$00
        rts


/****** BEGIN CHARSET ********************/
LFA3F
table_chars_qwerty
  .byt $37,$6a,$6d,$6b,$20,$75,$79,$38,$6e,$74,$36,$39,$2c,$69,$68,$6c,$35
  .byt $72,$62,$3b,$2e,$6f,$67,$30,$76,$66,$34,$2d,$0b,$70,$65,$2f,$31
  .byt $1b,$7a,$00,$08,$7f,$61,$0d,$78,$71,$32,$5c,$0a,$5d,$73,$00,$33
  .byt $64,$63,$27,$09,$5b,$77,$3d,$26,$4a,$4d,$4b,$20,$55,$59,$2a,$4e
  .byt $54,$5e,$28,$3c,$49,$48,$4c,$25,$52,$42,$3a,$3e,$4f,$47,$29,$56

  .byt $46,$24,$5f,$0b,$50,$45,$3f,$21,$1b,$5a,$00,$08,$7f,$41,$0d
  
  .byt $58

  .byt $51,$40,$7c,$0a,$7d,$53,$00,$23,$44,$43,$22,$09,$7b,$57,$2b
LFAAF
table_chars_azerty
  .byt $37

  .byt $6a,$3b,$6b,$20,$75,$79,$38,$6e,$74,$36,$39,$2c,$69,$68,$6c,$35

  .byt $72,$62,$6d,$2e,$6f,$67,$30,$76,$66,$34,$2d,$0b,$70,$65,$2f,$31
  .byt $1b,$77,$00,$08,$7f,$71,$0d,$78,$61,$32,$5c,$0a,$5d,$73,$00,$33

  .byt $64,$63,$27,$09,$5b,$7a,$3d,$26,$4a,$3a,$4b,$20,$55,$59,$2a,$4e
  .byt $54,$5e,$28,$3c,$49,$48,$4c,$25,$52,$42,$4d,$3e,$4f,$47,$29,$56

  .byt $46,$24,$5f,$0b,$50,$45,$3f,$21,$1b,$57,$00,$08,$7f,$51,$0d
  
  .byt $58
  .byt $41,$40,$7c,$0a,$7d,$53,$00,$23,$44,$43,$22,$09,$7b,$5a,$2b
LFB1F    
table_chars_french_table

LFB8F
charset_text
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $08,$08,$08,$08,$08,$00,$08,$00
        .byte   $14,$14,$14,$00,$00,$00,$00,$00
        .byte   $14,$14,$3E,$14,$3E,$14,$14,$00
        .byte   $08,$1E,$28,$1C,$0A,$3C,$08,$00
        .byte   $30,$32,$04,$08,$10,$26,$06,$00
        .byte   $10,$28,$28,$10,$2A,$24,$1A,$00
        .byte   $08,$08,$08,$00,$00,$00,$00,$00
        .byte   $08,$10,$20,$20,$20,$10,$08,$00
        .byte   $08,$04,$02,$02,$02,$04,$08,$00
        .byte   $08,$2A,$1C,$08,$1C,$2A,$08,$00
        .byte   $00,$08,$08,$3E,$08,$08,$00,$00
        .byte   $00,$00,$00,$00,$00,$08,$08,$10
        .byte   $00,$00,$00,$3E,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$04,$00,$00
        .byte   $00,$02,$04,$08,$10,$20,$00,$00
        .byte   $1C,$22,$26,$2A,$32,$22,$1C,$00
        .byte   $08,$18,$08,$08,$08,$08,$1C,$00
        .byte   $1C,$22,$02,$04,$08,$10,$3E,$00
        .byte   $3E,$02,$04,$0C,$02,$22,$1C,$00
        .byte   $04,$0C,$14,$24,$3E,$04,$04,$00
        .byte   $3E,$20,$3C,$02,$02,$22,$1C,$00
        .byte   $0C,$10,$20,$3C,$22,$22,$1C,$00
        .byte   $3E,$02,$04,$08,$10,$10,$10,$00
        .byte   $1C,$22,$22,$1C,$22,$22,$1C,$00
        .byte   $1C,$22,$22,$1E,$02,$04,$18,$00
        .byte   $00,$00,$08,$00,$00,$08,$00,$00
        .byte   $00,$00,$08,$00,$00,$08,$08,$10
        .byte   $04,$08,$10,$20,$10,$08,$04,$00
        .byte   $00,$00,$3E,$00,$3E,$00,$00,$00
        .byte   $10,$08,$04,$02,$04,$08,$10,$00
        .byte   $1C,$22,$04,$08,$08
        .byte   $00,$08,$00,$1C,$22,$2A,$2E,$2C
        .byte   $20,$1E,$00,$08,$14,$22,$22,$3E
        .byte   $22,$22,$00,$3C,$22,$22,$3C,$22
        .byte   $22,$3C,$00,$1C,$22,$20,$20,$20
        .byte   $22,$1C,$00,$3C,$22,$22,$22,$22
        .byte   $22,$3C,$00,$3E,$20,$20,$3C,$20
        .byte   $20,$3E,$00,$3E,$20,$20,$3C,$20
        .byte   $20,$20,$00,$1E,$20,$20,$20,$26
        .byte   $22,$1E,$00,$22,$22,$22,$3E,$22
        .byte   $22,$22,$00,$1C,$08,$08,$08,$08
        .byte   $08,$1C,$00,$02,$02,$02,$02,$02
        .byte   $22,$1C,$00,$22,$24,$28,$30,$28
        .byte   $24,$22,$00,$20,$20,$20,$20,$20
        .byte   $20,$3E,$00,$22,$36,$2A,$2A,$22
        .byte   $22,$22,$00,$22,$22,$32,$2A,$26
        .byte   $22,$22,$00,$1C,$22,$22,$22,$22
        .byte   $22,$1C,$00,$3C,$22,$22,$3C,$20
        .byte   $20,$20,$00,$1C,$22,$22,$22,$2A
        .byte   $24,$1A,$00,$3C,$22,$22,$3C,$28
        .byte   $24,$22,$00,$1C,$22,$20,$1C,$02
        .byte   $22,$1C,$00,$3E,$08,$08,$08,$08
        .byte   $08,$08,$00,$22,$22,$22,$22,$22
        .byte   $22,$1C,$00,$22,$22,$22,$22,$22
        .byte   $14,$08,$00,$22,$22,$22,$2A,$2A
        .byte   $36,$22,$00,$22,$22,$14,$08,$14
        .byte   $22,$22,$00,$22,$22,$14,$08,$08
        .byte   $08,$08,$00,$3E,$02,$04,$08,$10
        .byte   $20,$3E,$00,$1E,$10,$10,$10,$10
        .byte   $10,$1E,$00,$00,$20,$10,$08,$04
        .byte   $02,$00,$00,$3C,$04,$04,$04,$04
        .byte   $04,$3C,$00,$08,$14,$2A,$08,$08
        .byte   $08,$08,$00,$0E,$10,$10,$10,$3C
        .byte   $10,$3E,$00,$0C,$12,$2D,$29,$29
        .byte   $2D,$12,$0C,$00,$00,$1C,$02,$1E
        .byte   $22,$1E,$00,$20,$20,$3C,$22,$22
        .byte   $22,$3C,$00,$00,$00,$1E,$20,$20
        .byte   $20,$1E,$00,$02,$02,$1E,$22,$22
        .byte   $22,$1E,$00,$00,$00,$1C,$22,$3E
        .byte   $20,$1E,$00,$0C,$12,$10,$3C,$10
        .byte   $10,$10,$00,$00,$00,$1C,$22,$22
        .byte   $1E,$02,$1C,$20,$20,$3C,$22,$22
        .byte   $22,$22,$00,$08,$00,$18,$08,$08
        .byte   $08,$1C,$00,$04,$00,$0C,$04,$04
        .byte   $04,$24,$18,$20,$20,$22,$24,$38
        .byte   $24,$22,$00,$18,$08,$08,$08,$08
        .byte   $08,$1C,$00,$00,$00,$36,$2A,$2A
        .byte   $2A,$22,$00,$00,$00,$3C,$22,$22
        .byte   $22,$22,$00,$00,$00,$1C,$22,$22
        .byte   $22,$1C,$00,$00,$00,$3C,$22,$22
        .byte   $3C,$20,$20,$00,$00,$1E,$22,$22
        .byte   $1E,$02,$02,$00,$00,$2E,$30,$20
        .byte   $20,$20,$00,$00,$00,$1E,$20,$1C
        .byte   $02,$3C,$00,$10,$10,$3C,$10,$10
        .byte   $12,$0C,$00,$00,$00,$22,$22,$22
        .byte   $26,$1A,$00,$00,$00,$22,$22,$22
        .byte   $14,$08,$00,$00,$00,$22,$22,$2A
        .byte   $2A,$36,$00,$00,$00,$22,$14,$08
        .byte   $14,$22,$00,$00,$00,$22,$22,$22
        .byte   $1E,$02,$1C,$00,$00,$3E,$04,$08
        .byte   $10,$3E,$00,$0E,$18,$18,$30,$18
        .byte   $18,$0E,$00,$08,$08,$08,$08,$08
        .byte   $08,$08,$08,$38,$0C,$0C,$06,$0C
        .byte   $0C,$38,$00
       
        ; Tilde char (~)
        .byt    %00000000
        .byt    %00000000
        .byt    %00010000
        .byt    %00101010
        .byt    %00000100
        .byt    %00000000
        .byt    %00000000
        .byt    %00000000
;  END OF CHARSET 
  
XLOADCHARSET_ROUTINE:
    ldx     #$00
@loop:
    lda     charset_text,x
    sta     $B400+8*32,x
    
    lda     charset_text+256,x
    sta     $B500+8*32,x
    lda     charset_text+512,x
    sta     $B600+8*32,x
    inx
    bne     @loop
    rts
  
codes_for_calc_alternates:
  .byt     $00,$38,$07,$3f

routine_to_define_22:
  LDA     #$B9 ;  index of alternate chars
.ifdef WITH_TWILIGHTE_BOARD
.else
  BIT     FLGTEL
  BPL     @L1
  LDA     #$9D ; FILL CHARSET ?
@L1:
.endif  
  LDY     #$00
  STY     RES
  STA     RES+1
  TYA

@loop:
  PHA
  JSR put_an_alternate_char_in_memory
  PLA
  CLC
  ADC     #$01
  CMP     #$40
  BNE     @loop
 
  LDA     RES+1
  SBC     #$03
  STA     TR0
  SBC     #$04
  STA     RES+1
  LDA     #<charset_text
  LDY     #>charset_text
  STA     RESB
  STY     RESB+1
  LDY     #$00
loop70:
  LDX     #$00
  LDA     (RESB,X)
  TAX
  INC     RESB
  BNE     @L1
  INC     RESB+1
@L1:
  JSR     routine_to_define_23 

  TXA
  AND     #$C0
  BEQ     loop70
  CMP     #$C0
  BEQ     loop71
  CMP     #$40
  beq     next76
  JSR     routine_to_define_23 
  
  .byt    $2c 
loop71:
  ldx     #$00

next76:  
  JSR     routine_to_define_23
  BNE     loop70
  

  
routine_to_define_23:
  TXA
  AND     #$3F
  STA     (RES),Y
  INY
  BNE     @skip
  INC     RES+1
  LDA     RES+1
  CMP     TR0
  BNE     @skip
  PLA
  PLA
@skip:
  RTS

put_an_alternate_char_in_memory:
  LDX     #$03
  STX     RESB
next81:
  PHA
  AND     #$03
  TAX
  LDA     codes_for_calc_alternates,X
  STA     (RES),Y
  INY
  STA     (RES),Y
  INY
  LDX     RESB
  CPX     #$02
  BEQ     @skip
  STA     (RES),Y
  INY
  BNE     @skip
  INC     RES+1
@skip:
  PLA
  LSR
  LSR
  DEC     RESB
  BNE     next81
  RTS
  

move_chars_text_to_hires:
  ldy     #$05
  .byt $2c
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
  .byt $00,$b4,$80,$bb,$00,$98
  ; hires to text 6 bytes
  .byt $00,$98,$80,$9f,$00,$b4

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
  
ZADCHA_ROUTINE: 
  ldx     #$13
  stx     RESB+1
  asl
  rol     RESB+1
  asl
  rol     RESB+1
  asl
  rol     RESB+1
  sta     RESB
  bit     FLGTEL
  bmi     Lff4b
  lda     RESB+1
  adc     #$1c
  sta     RESB+1
Lff4b:
  rts

XGOKBD_ROUTINE:
  jsr     routine_to_define_22 
  rts

;$fff8-9 : copyright address
;$fffa : software version BCD : 1.4 -> $14
;$fffb : b7 if copyright
;        b6 : if it's autostart
;        b5 : 1 if rom, 0 if ram
;        b0,b3 : 7 for 8 KB, 16 for KB
;$fffc-d : adresse  d'execution
;$fffe-f :  IRQ (02fa)

signature:
  .byte     "Kernel-"
  .byt __DATE__
.IFPC02
.pc02
  .byte     " 65C02"
.p02  
.else
  .byte     " 6502"
.endif  
  .byt 		$00
  
free_bytes: ; 26 bytes
  .res    $FFF8-*
  .org    $FFF8

  .byt     <signature
  .byt     >signature

END_ROM:
; fffa
NMI:
  .byt     $00,$C0
; fffc
RESET:
  .byt     $00,$c0
; fffe
BRK_IRQ:  
  .byt     <IRQVECTOR,>IRQVECTOR

