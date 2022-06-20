init_joystick:
  lda     #%01000001 ; SET mouse and joystick flag
  sta     FLGJCK
; init JCKTAB values
  ldx     #$06 ; 7 bytes 
@loop:
  lda     telemon_values_for_JCKTAB,X ; data_to_define_3
  sta     JCKTAB,X
  dex
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
