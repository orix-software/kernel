.proc init_screens
  lda     #$1A
  sta     $BFDF    ; Switch to text mode
  ; fill the first line with space characters
  ldx     #$27     ; loop on #$28 caracters
  lda     #$20

@loop:
  sta     $BB80,X  ; display space on first line in mode text
  dex
  bpl     @loop
  
  ldy     #$11     ; loop with $12 to fill text definitions and Hires
@L1:
  lda     data_text_window,Y ; data_to_define_2
  sta     SCRTXT,Y ; thise fill also  SCRHIR
  dey
  bpl     @L1

  lda     #<SCRTXT
  ldy     #>SCRTXT

  ldx     #$00

  jmp     ROUTINE_TO_DEFINE_7 ; $DEFD
.endproc
