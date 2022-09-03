.proc _manage_keyboard

  jsr     XALLKB_ROUTINE
  beq     @S3
  ldx     KBDFLG_KEY
  bpl     @S1
  lda     KBD_UNKNOWN
  and     $01e8,x
  bne     @S2
@S1:
  dey
  lda     KBDCOL,y
  sta     KBD_UNKNOWN
  tya
  ora     #$80
  sta     KBDFLG_KEY
  jsr     XKBDAS_ROUTINE ; convert in ascii and manage buffer
  lda     KBDVRR
  jmp     @S5
@S2:
  dec     KBDVRL+1
  bne     @S6
  jsr     XKBDAS_ROUTINE
  jmp     @S4
@S3:
  sta     KBDFLG_KEY
@S4:
  lda     KBDVRL
@S5:
  sta     KBDVRL+1
@S6:
  rts
.endproc
