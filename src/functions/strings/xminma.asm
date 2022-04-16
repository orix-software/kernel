.proc XMINMA_ROUTINE
  cmp     #"a" ; 'a'
  bcc     @skip
  cmp     #$7B ; 'z'
  bcs     @skip
  sbc     #$1F
@skip:
  rts
.endproc