.include "telestrat.inc"
.include "include/kernel.inc"
.include "include/process.inc"
.include "include/memory.inc"

.export  KERNEL_ERRNO
.export  KERNEL_CH376_MOUNT
.export  KERNEL_XFREE_TMP
.export  KERNEL_XKERNEL_CREATE_PROCESS_TMP
.export  KERNEL_TMP_XEXEC
.export  KERNEL_KERNEL_XEXEC_BNKOLD
.export  KERNEL_MALLOC_TYPE
.export  KERNEL_SAVE_XEXEC_CURRENT_SET
.export  KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM
.export  KERNEL_END_PROCESS_VARIABLES
.export  SCRFX_KERNEL
.export  IOTAB
.export  KERNEL_ADIOB
.export  kernel_malloc_free_chunk_size
.export  kernel_xmalloc_call
.export  KERNEL_ADIOB_END
.export  READ_BYTE_FROM_OVERLAY_RAM
.export  FIXME_DUNNO
.export  STACK_BANK
;.export  BUFNOM
.export  kernel_malloc
.export  KERNEL_DRIVER_MEMORY
.export  kernel_process
.export  BUSY_BANK_TABLE_RAM
.export  kernel_end_of_memory_for_kernel
.export  KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM


.bss
    .org $200
KERNEL_ERRNO:
    .res 1
KERNEL_CH376_MOUNT:
    .res 1
KERNEL_XFREE_TMP:
    .res 1
KERNEL_XKERNEL_CREATE_PROCESS_TMP:
    .res 1
KERNEL_TMP_XEXEC:
    .res 1
KERNEL_KERNEL_XEXEC_BNKOLD:
    .res 1
KERNEL_MALLOC_TYPE:
    .res 1
KERNEL_SAVE_XEXEC_CURRENT_SET:
    .res 1
KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM:
    .res 1
;KERNEL
KERNEL_END_PROCESS_VARIABLES:
.if  KERNEL_END_PROCESS_VARIABLES > FLGTEL
  .error  "Error KERNEL_END_PROCESS_VARIABLES overlap FLGTEL"
.endif

.org SCRX+1
BUSY_BANK_TABLE_RAM:
    .res 3

.org SCRDX
    ; SCRDX
    .res 1
SCRFX_KERNEL:
    .res 1

.org $282
; Was VDTPIL


.org $2AE
IOTAB:
    .res 4 ; KERNEL_SIZE_IOTAB
KERNEL_ADIOB:
    .res 8
kernel_malloc_free_chunk_size:
    .tag    kernel_malloc_free_chunk_size_struct
kernel_xmalloc_call:
    .res 40 ; XMALLOC_ROUTINE_TO_RAM_OVERLAY
KERNEL_ADIOB_END:
.if  KERNEL_ADIOB_END > VNMI
  .error  "Error malloc table overlap VNMI"
.endif

.bss
.org $4C7

.res 1 ;Was before FIXME_DUNNO, it could remove when READ_BYTE_FROM_OVERLAY_RAM will be aligned correctly with kernel load

READ_BYTE_FROM_OVERLAY_RAM:
; this contains a routine length : 20 bytew
.res 20
.org $4FF
FIXME_DUNNO:
    .res  1

.bss
.org $500
STACK_BANK:
    .res SIZE_OF_STACK_BANK

kernel_end_of_variables_before_BUFNOM:

.if  kernel_end_of_variables_before_BUFNOM > BUFNOM
  .error  "Error BUFNOM is written by kernel variables try to move some variables in kernel.inc after BUFNOM or BUFEDT"
.endif

.out     .sprintf("kernel_end_of_variables_before_BUFNOM : %x", kernel_end_of_variables_before_BUFNOM)

.bss
.org BUFNOM
    .res 14
BUFNOM_END:

kernel_malloc:
    .tag    kernel_malloc_struct

kernel_malloc_end:
kernel_process:
    .tag    kernel_process_struct

kernel_process_end:
kernel_end_of_variables_before_BUFEDT:
.out     .sprintf("kernel_end_of_variables_before_BUFEDT : %x", kernel_end_of_variables_before_BUFEDT)
.if     kernel_end_of_variables_before_BUFEDT > BUFEDT
  .error  "Error BUFEDT is written by kernel variables try to move some variables in kernel.inc after $590"
.endif

.bss
.org BUFEDT

.ifdef WITH_DEBUG
kernel_debug:
    .tag    kernel_debug_struct
    .out   .sprintf("Size of kernel_debug_struct $%x ", .sizeof(kernel_debug_struct))
.else
.res 110
.endif

BUFEDT_END:

KERNEL_DRIVER_MEMORY:
    .res 163
KERNEL_DRIVER_MEMORY_END:

kernel_end_of_memory_for_kernel:

.out     .sprintf("kernel_end_of_memory_for_kernel (malloc will start at this adress) : %x", kernel_end_of_memory_for_kernel)

kernel_end_of_variables_after_BUFEDT:
.if     kernel_end_of_variables_after_BUFEDT > $7FF
  .error  "Error start of execution program for binary ($800) is written by kernel variables try to move some variables in kernel.inc before $800"
.endif


