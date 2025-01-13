.export kernel_free_bank

.include "telestrat.inc"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/memory.inc"
.include   "../../include/files.inc"
;.include   "../../kernel.inc"

;.segment "BANK8"

.import KERNEL_BANK_MANAGEMENT
.import kernel_process

.proc kernel_free_bank
  ;;@brief Free bank with id bank. PID is cleared in kernel bank
  ;;@inputA Contains the id of the bank to free
  ;;@modifyA
  ;;@modifyX
  ;;@modifyY

  ;;@returnsA
  ;;@returnsX
  ;;@returnsY

  stx     TR2 ; Save
  ldy     TR2
  lda     #$00
  ldx     #$00
  MEMORY_PUT_VALUE_TO_BANK KERNEL_BANK_MANAGEMENT

  lda     #kernel_bank_management_struct::KERNEL_BANK_PROCESS_ID
  clc
  adc     TR2
  tay

  lda     #$00
  ldx     #$00
  MEMORY_PUT_VALUE_TO_BANK KERNEL_BANK_MANAGEMENT

  rts
.endproc
