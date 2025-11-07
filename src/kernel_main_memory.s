.include "telestrat.inc"
.include "include/kernel.inc"
.include "include/process.inc"
.include "include/memory.inc"
.include   "include/network.inc"
.include   "include/files.inc"
.include   "include/ori2.inc"
.include   "versions/versions.inc"


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
.export  RESC
.export  RESD
.export  RESE
.export  RESF
.export  RESG
.export  RESH
.export  RESI
.export  RESCONCAT


.export KERNEL_BANK_EXTENDED_AVAILABLE

.import code_adress_419
.import code_adress_436

.bss
.org $04
RESC: ; is also DECDEB
  .res 2
RESD: ; is also DECFIN
  .res 2
RESE: ; is also DECCIB
  .res 2
RESF: ; is also  DECTRV
  .res 2
.org $59 ;  RS232T          := $59 & RS232C          := $5A
RESG:
  .res 2
.org $60  ; ACC1E
RESH:
  .res 2 ; ACC1M+1 $62
RESI:
  .res 2 ; $ACC1M+3 $64
RESCONCAT:
  .res 2  ; ACC1S+1 $66


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
; KERNEL_BANK_AVAILABLE is used to know if a bank is available or not (example : Kernel extended)
KERNEL_BANK_EXTENDED_AVAILABLE:
    .res 1

KERNEL_FREE1_MEMORY:
KERNEL_END_PROCESS_VARIABLES:
.if  KERNEL_END_PROCESS_VARIABLES > FLGTEL
  .error  "Error KERNEL_END_PROCESS_VARIABLES overlap FLGTEL"
.endif

.org SCRX + 1
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
.out     .sprintf("kernel_malloc_struct : 0x%x", kernel_malloc)

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


.ifdef MEMMAP_GENERATE




.out     "=================================================================="
.out     "File memory"
.out     "=================================================================="
.out     .sprintf("_KERNEL_FILE size (One fp struct) : $%X bytes",  .sizeof(_KERNEL_FILE))

.out     .sprintf("kernel_one_process_struct size (struct for one process)  : $%X bytes", .sizeof(kernel_one_process_struct))
.out     .sprintf("With all the parameter all process could use %s bytes in memory, if it's allocated", .string(.sizeof(kernel_one_process_struct)*KERNEL_MAX_PROCESS+.sizeof(kernel_process_struct)))

.out     .sprintf("KERNEL_MAX_PROCESS (Max process in the system)           : %s", .string(KERNEL_MAX_PROCESS))
.out     .sprintf("KERNEL_MAX_FP_PER_PROCESS  (Max file pointer per process): %s", .string(KERNEL_MAX_FP_PER_PROCESS))
.out     .sprintf("KERNEL_USERZP_SAVE_LENGTH                                : %s bytes", .string(KERNEL_USERZP_SAVE_LENGTH))
.out     .sprintf("KERNEL_LENGTH_MAX_CMDLINE                                : %s", .string(KERNEL_LENGTH_MAX_CMDLINE))

.out     .sprintf("kernel_process_struct size (struct init process)         : $%X bytes", .sizeof(kernel_process_struct))



.out .sprintf("int MALLOC_BUSY_SIZE_LOW = 0x%x;",  kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_low)
.out .sprintf("int MALLOC_BUSY_SIZE_HIGH = 0x%x;", kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_size_high)
.out .sprintf("int MALLOC_BUSY_BEGIN_HIGH = 0x%x;", kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high)
.out .sprintf("int MALLOC_BUSY_END_HIGH = 0x%x;", kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_high)
.out .sprintf("int MALLOC_BUSY_BEGIN_LOW = 0x%x;", kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low)
.out .sprintf("int MALLOC_BUSY_END_LOW = 0x%x;", kernel_malloc + kernel_malloc_struct::kernel_malloc_busy_chunk_end_low)
.out .sprintf("int KERNEL_MAX_NUMBER_OF_MALLOC = 0x%x;", KERNEL_MAX_NUMBER_OF_MALLOC)



.out .sprintf("int MALLOC_FREE_SIZE_HIGH =0x%x;",kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_high)
.out .sprintf("int MALLOC_FREE_SIZE_LOW =0x%x;",kernel_malloc_free_chunk_size+kernel_malloc_free_chunk_size_struct::kernel_malloc_free_chunk_size_low)

.out .sprintf("int MALLOC_FREE_BEGIN_HIGH=0x%x;",kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high)
.out .sprintf("int MALLOC_FREE_BEGIN_LOW=0x%x;",kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low)

.out .sprintf("int MALLOC_FREE_END_HIGH=0x%x;",kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high)
.out .sprintf("int MALLOC_FREE_END_LOW=0x%x;",kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low)

.out .sprintf("int KERNEL_MALLOC_FREE_CHUNK_MAX=0x%x;",KERNEL_MALLOC_FREE_CHUNK_MAX)



.out     .sprintf("|#MEMMAP: Memmap")
; \n
.out     .sprintf("MEMMAP:")
.out     .sprintf("|##MEMMAP: Page 0")
; \nr
.out     .sprintf("MEMMAP:")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|RES                            | $%02X-$%02X     |  2   |", RES, RES+1)
.out     .sprintf("|MEMMAP:RAM|RESB                           | $%02X-$%02X     |  2   |", RESB, RESB + 1)
.out     .sprintf("|MEMMAP:RAM|RESC                           | $%02X-$%02X     |  2   |", RESC, RESC + 1)
.out     .sprintf("|MEMMAP:RAM|RESD                           | $%02X-$%02X     |  2   |", RESD, RESD + 1)
.out     .sprintf("|MEMMAP:RAM|RESE                           | $%02X-$%02X     |  2   |", RESE, RESE + 1)
.out     .sprintf("|MEMMAP:RAM|RESF                           | $%02X-$%02X     |  2   |", RESF, RESF + 1)
.out     .sprintf("|MEMMAP:RAM|RESG                           | $%02X-$%02X     |  2   |", RESG, RESG + 1)
.out     .sprintf("|MEMMAP:RAM|RESH                           | $%02X-$%02X     |  2   |", RESH, RESH + 1)
.out     .sprintf("|MEMMAP:RAM|RESI                           | $%02X-$%02X     |  2   |", RESI, RESI + 1)
.out     .sprintf("|MEMMAP:RAM|RESCONCAT                      | $%02X-$%02X     |  2   |", RESCONCAT, RESCONCAT + 1)
.out     .sprintf("|MEMMAP:RAM|TR0                            | $%02X-$%02X     |  1   |", TR0, TR0)
.out     .sprintf("|MEMMAP:RAM|TR1                            | $%02X-$%02X     |  1   |", TR1 ,TR1)
.out     .sprintf("|MEMMAP:RAM|TR2                            | $%02X-$%02X     |  1   |", TR2, TR2)
.out     .sprintf("|MEMMAP:RAM|TR3                            | $%02X-$%02X     |  1   |", TR3, TR3)
.out     .sprintf("|MEMMAP:RAM|TR4                            | $%02X-$%02X     |  1   |", TR4, TR4)
.out     .sprintf("|MEMMAP:RAM|TR5                            | $%02X-$%02X     |  1   |", TR5, TR5)
.out     .sprintf("|MEMMAP:RAM|TR6                            | $%02X-$%02X     |  1   |", TR6, TR6)
.out     .sprintf("|MEMMAP:RAM|TR7                            | $%02X-$%02X     |  1   |", TR7, TR7)
.out     .sprintf("|MEMMAP:RAM|DEFAFF                         | $%02X-$%02X     |  1   |", DEFAFF, DEFAFF)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $15-$16     |  2   |")
.out     .sprintf("|MEMMAP:RAM|ADDRESS_VECTOR_FOR_ADIOB       | $%02X-$%02X     |  2   |", ADDRESS_VECTOR_FOR_ADIOB, ADDRESS_VECTOR_FOR_ADIOB + 1)
.out     .sprintf("|MEMMAP:RAM|work_channel                   | $%02X-$%02X     |  1   |", work_channel, work_channel)
.out     .sprintf("|MEMMAP:RAM|i_o_counter                    | $%02X-$%02X     |  2   |", i_o_counter, i_o_counter + 1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $1C-$1C     |  1   |")
.out     .sprintf("|MEMMAP:RAM|GS                             | $1D-$1D     |  1   |")
.out     .sprintf("|MEMMAP:RAM|FREE                           | $1E-$1E     |  1   |")
.out     .sprintf("|MEMMAP:RAM|TOFIX                          | $1F-$1F     |  1   |")
.out     .sprintf("|MEMMAP:RAM|TOFIX                          | $20-$20     |  1   |")
.out     .sprintf("|MEMMAP:RAM|IRQSVA                         | $%02X-$%02X     |  1   |", IRQSVA, IRQSVA)
.out     .sprintf("|MEMMAP:RAM|IRQSVX                         | $%02X-$%02X     |  1   |", IRQSVX, IRQSVX)
.out     .sprintf("|MEMMAP:RAM|IRQSVY                         | $%02X-$%02X     |  1   |", IRQSVY, IRQSVY)
.out     .sprintf("|MEMMAP:RAM|IRQSVP                         | $%02X-$%02X     |  1   |", IRQSVP, IRQSVP)
.out     .sprintf("|MEMMAP:RAM|FIXME_PAGE0_0                  | $%02X-$%02X     |  1   |", FIXME_PAGE0_0, FIXME_PAGE0_0)
.out     .sprintf("|MEMMAP:RAM|ADSCR                          | $%02X-$%02X     |  2   |", ADSCR,ADSCR + 1)
.out     .sprintf("|MEMMAP:RAM|SCRNB                          | $%02X-$%02X     |  2   |", SCRNB,SCRNB + 1)
.out     .sprintf("|MEMMAP:RAM|ADKBD                          | $%02X-$%02X     |  2   |", ADKBD,ADKBD + 1)
.out     .sprintf("|MEMMAP:RAM|PTR_READ_DEST                  | $%02X-$%02X     |  2   |", PTR_READ_DEST, PTR_READ_DEST + 1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $%02X-$%02X     |      |", PTR_READ_DEST + 2, ADDRESS_READ_BETWEEN_BANK - 1)
.out     .sprintf("|MEMMAP:RAM|ADDRESS_READ_BETWEEN_BANK      | $%02X-$%02X     |  2   |", ADDRESS_READ_BETWEEN_BANK, ADDRESS_READ_BETWEEN_BANK + 1)
.out     .sprintf("|MEMMAP:RAM|BNKCIB_DOUBLON                 | $%02X-$%02X     |  1   |", BNKCIB_DOUBLON, BNKCIB_DOUBLON)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $%02X-$%02X     |      |", BNKCIB_DOUBLON + 1, ADCLK -1)
.out     .sprintf("|MEMMAP:RAM|ADCLK                          | $%02X-$%02X     |  2   |", ADCLK, ADCLK + 1)
.out     .sprintf("|MEMMAP:RAM|TIMEUS                         | $%02X-$%02X     |  2   |", TIMEUS, TIMEUS + 1)
.out     .sprintf("|MEMMAP:RAM|TIMEUD (used in cc65 clock function)| $%02X-$%02X     |  2   |", TIMEUD, TIMEUD + 1)
.out     .sprintf("|MEMMAP:RAM|HRSX                           | $%02X-$%02X     |  1   |", HRSX, HRSX)
.out     .sprintf("|MEMMAP:RAM|HRSY                           | $%02X-$%02X     |  1   |", HRSY, HRSY)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $48-$48     |  1   |")
.out     .sprintf("|MEMMAP:RAM|HRSX40                         | $%02X-$%02X     |  1   |", HRSX40, HRSX40)
.out     .sprintf("|MEMMAP:RAM|HRSX6                          | $%02X-$%02X     |  1   |", HRSX6, HRSX6)
.out     .sprintf("|MEMMAP:RAM|ADHRS                          | $%02X-$%02X     |  2   |", ADHRS, ADHRS + 1)
.out     .sprintf("|MEMMAP:RAM|HRS1                           | $%02X-$%02X     |  2   |", HRS1, HRS1 + 1)
.out     .sprintf("|MEMMAP:RAM|HRS2                           | $%02X-$%02X     |  2   |", HRS2, HRS2 + 1)
.out     .sprintf("|MEMMAP:RAM|HRS3                           | $%02X-$%02X     |  2   |", HRS3, HRS3 + 1)
.out     .sprintf("|MEMMAP:RAM|HRS4                           | $%02X-$%02X     |  2   |", HRS4, HRS4 + 1)
.out     .sprintf("|MEMMAP:RAM|HRS5                           | $%02X-$%02X     |  2   |", HRS5, HRS5 + 1)
.out     .sprintf("|MEMMAP:RAM|HRSFB                          | $%02X-$%02X     |  1   |", HRSFB, HRSFB)
.out     .sprintf("|MEMMAP:RAM|VABPK1                         | $%02X-$%02X     |  1   |", VABKP1, VABKP1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $59-$5A     |  2   |")
.out     .sprintf("|MEMMAP:RAM|INDRS                          | $%02X-$%02X     |  1   |", INDRS, INDRS)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $5C-$5F     |  2   |")


.out     .sprintf("|MEMMAP:RAM|FREE                           | $%02X-$FF     |  %d   |",VARLNG, $FF - VARLNG)



.out     .sprintf("|##MEMMAP: Page 2")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|KERNEL_ERRNO                   | $%04X-$%04X |  1   |", KERNEL_ERRNO, KERNEL_ERRNO)
.out     .sprintf("|MEMMAP:RAM|KERNEL_CH376_MOUNT             | $%04X-$%04X |  1   |", KERNEL_CH376_MOUNT, KERNEL_CH376_MOUNT)
.out     .sprintf("|MEMMAP:RAM|KERNEL_XFREE_TMP             | $%04X-$%04X |  1   |", KERNEL_XFREE_TMP, KERNEL_XFREE_TMP)

.out     .sprintf("|MEMMAP:RAM|KERNEL_XKERNEL_CREATE_PROCESS_TMP| $%04X-$%04X |  1   |", KERNEL_XKERNEL_CREATE_PROCESS_TMP, KERNEL_XKERNEL_CREATE_PROCESS_TMP)

.out     .sprintf("|MEMMAP:RAM|KERNEL_TMP_XEXEC             | $%04X-$%04X |  1   |", KERNEL_TMP_XEXEC, KERNEL_TMP_XEXEC)
.out     .sprintf("|MEMMAP:RAM|KERNEL_KERNEL_XEXEC_BNKOLD   | $%04X-$%04X |  1   |", KERNEL_KERNEL_XEXEC_BNKOLD, KERNEL_KERNEL_XEXEC_BNKOLD)

.out     .sprintf("|MEMMAP:RAM|KERNEL_MALLOC_TYPE           | $%04X-$%04X |  1   |", KERNEL_MALLOC_TYPE, KERNEL_MALLOC_TYPE)
.out     .sprintf("|MEMMAP:RAM|KERNEL_SAVE_XEXEC_CURRENT_SET| $%04X-$%04X |  1   |", KERNEL_SAVE_XEXEC_CURRENT_SET, KERNEL_SAVE_XEXEC_CURRENT_SET)
.out     .sprintf("|MEMMAP:RAM|KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM| $%04X-$%04X |  1   |", KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM, KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM+1)

.out     .sprintf("|MEMMAP:RAM|FREE                           | $%04X-$%04X |  %d   |", KERNEL_FREE1_MEMORY, FLGTEL - 1, FLGTEL - KERNEL_FREE1_MEMORY)

; KOROM and KORAM are not used

.out     .sprintf("|MEMMAP:RAM|FLGTEL                          | $%04X-$%04X |  1   |", FLGTEL, FLGTEL )
.out     .sprintf("|MEMMAP:RAM|TIMED                           | $%04X-$%04X |  1   |", TIMED, TIMED )
.out     .sprintf("|MEMMAP:RAM|TIMES                           | $%04X-$%04X |  1   |", TIMES, TIMES)
.out     .sprintf("|MEMMAP:RAM|TIMEM                           | $%04X-$%04X |  1   |", TIMEM , TIMEM)
.out     .sprintf("|MEMMAP:RAM|TIMEH                           | $%04X-$%04X |  1   |", TIMEH, TIMEH)

.out     .sprintf("|MEMMAP:RAM|FLGCLK                          | $%04X-$%04X |  1   |", FLGCLK, FLGCLK)
.out     .sprintf("|MEMMAP:RAM|FLGCLK_FLAG                     | $%04X-$%04X |  1   |", FLGCLK_FLAG, FLGCLK_FLAG)

.out     .sprintf("|MEMMAP:RAM|FLGCUR                          | $%04X-$%04X |  1   |", FLGCUR, FLGCUR)
.out     .sprintf("|MEMMAP:RAM|FLGCUR_STATE                         | $%04X-$%04X |  1   |", FLGCUR_STATE, FLGCUR_STATE)

.out     .sprintf("|MEMMAP:RAM|ADSCRL                          | $%04X-$%04X |  4   |", ADSCRL,ADSCRL+3)
.out     .sprintf("|MEMMAP:RAM|ADSCRH                          | $%04X-$%04X |  4   |", ADSCRH,ADSCRH+3)

.out     .sprintf("|MEMMAP:RAM|SCRX                         | $%04X-$%04X |  1   |", SCRX, SCRX)

.out     .sprintf("|MEMMAP:RAM|BUSY_BANK_TABLE_RAM             | $%04X-$%04X |  %d   |", BUSY_BANK_TABLE_RAM, BUSY_BANK_TABLE_RAM+3, 3)

.out     .sprintf("|MEMMAP:RAM|SCRY                         | $%04X-$%04X |  4   |", SCRY, SCRY+3)

.out     .sprintf("|MEMMAP:RAM|SCRDX                         | $%04X-$%04X |  1   |", SCRDX, SCRDX)
.out     .sprintf("|MEMMAP:RAM|SCRFX                         | $%04X-$%04X |  1   |", SCRFX, SCRFX)

.out     .sprintf("|MEMMAP:RAM|SCRFY                         | $%04X-$%04X |  1   |", SCRFY, SCRFY)
.out     .sprintf("|MEMMAP:RAM|SCRDY                         | $%04X-$%04X |  1   |", SCRDY, SCRDY)

.out     .sprintf("|MEMMAP:RAM|SCRBAL                         | $%04X-$%04X |  1   |", SCRBAL, SCRBAL)

.out     .sprintf("|MEMMAP:RAM|SCRBAH                         | $%04X-$%04X |  1   |", SCRBAH, SCRBAH)


.out     .sprintf("|MEMMAP:RAM|SCRCT                         | $%04X-$%04X |  1   |", SCRCT, SCRCT)
.out     .sprintf("|MEMMAP:RAM|SCRCF                         | $%04X-$%04X |  1   |", SCRCF, SCRCF)


.out     .sprintf("|MEMMAP:RAM|FIXME                          | $%04X-$%04X |  %d   |", SCRCF+4,ADSCRH+4,KBDCOL-ADSCRH+4)

.out     .sprintf("|MEMMAP:RAM|FLGSCR                          | $%04X-$%04X |  4   |", FLGSCR,FLGSCR+4) ; $248
.out     .sprintf("|MEMMAP:RAM|CURSCR                          | $%04X-$%04X |  1   |", CURSCR,CURSCR+1) ; $248

.out     .sprintf("|MEMMAP:RAM|FREE                          | $%04X-$%04X |  %d   |", CURSCR+1,SCRTXT,SCRTXT-CURSCR+1) ; $248

.out     .sprintf("|MEMMAP:RAM|SCRTXT                          | $%04X-$%04X |  4   |", SCRTXT,SCRHIR+4) ; $248
.out     .sprintf("|MEMMAP:RAM|SCRHIR  (not used)              | $%04X-$%04X |  %d   |", SCRHIR,SCRHIR+4,4) ; $248

.out     .sprintf("|MEMMAP:RAM|SCRTRA                          | $%04X-$%04X |  %d   |", SCRTRA,SCRTRA+4,6) ; $248

.out     .sprintf("|MEMMAP:RAM|KBDCOL                          | $%04X-$%04X |  %d   |", KBDCOL,KBDCOL+8,8)
.out     .sprintf("|MEMMAP:RAM|KBDFLG_KEY                      | $%04X-$%04X |  %d  |", KBDFLG_KEY, KBDFLG_KEY+2,2)

.out     .sprintf("|MEMMAP:RAM|KBDVRR                      | $%04X-$%04X | %d   |", KBDVRR, KBDVRR + 1,1)
.out     .sprintf("|MEMMAP:RAM|KBDVRL                      | $%04X-$%04X | %d   |", KBDVRL, KBDVRL + 2,2)
.out     .sprintf("|MEMMAP:RAM|FLGKBD                      | $%04X-$%04X | %d   |", FLGKBD, FLGKBD + 1,1)

.out     .sprintf("|MEMMAP:RAM|KBDFCT                      | $%04X-$%04X | %d   |", KBDFCT, KBDFCT + 1,1)

.out     .sprintf("|MEMMAP:RAM|KBDSHT                      | $%04X-$%04X | %d   |", KBDSHT, KBDSHT + 1,1)

.out     .sprintf("|MEMMAP:RAM|KBDKEY                       | $%04X-$%04X | %d   |", KBDKEY, KBDKEY + 5,1)

.out     .sprintf("|MEMMAP:RAM|KBDCTC                          | $%04X-$%04X |  2   |", KBDCTC, KBDCTC+1)

.out     .sprintf("|MEMMAP:RAM|FREE                            | $%04X-$%04X |  %d   |", KBDCTC + 1, KEYBOARD_COUNTER - 1,KEYBOARD_COUNTER - KBDCTC)

.out     .sprintf("|MEMMAP:RAM|KEYBOARD_COUNTER               | $%04X-$%04X |  %d   |", KEYBOARD_COUNTER, KEYBOARD_COUNTER+3,3)
.out     .sprintf("|MEMMAP:RAM|HRSPAT                            | $%04X-$%04X |  %d   |", HRSPAT, HRSPAT,1)

.out     .sprintf("|MEMMAP:RAM|IOTAB                          | $%04X-$%04X |  X   |", IOTAB, IOTAB + KERNEL_SIZE_IOTAB - 1)
.out     .sprintf("|MEMMAP:RAM|KERNEL_ADIOB                   | $%04X-$%04X | %d   |", KERNEL_ADIOB, KERNEL_ADIOB+ADIODB_LENGTH-1,KERNEL_ADIOB+ADIODB_LENGTH-KERNEL_ADIOB)

.out     .sprintf("|MEMMAP:RAM|kernel_malloc_free_chunk_size                   | $%04X-$%04X | %d   |", kernel_malloc_free_chunk_size, kernel_malloc_free_chunk_size + .sizeof(kernel_malloc_free_chunk_size_struct)-1,.sizeof(kernel_malloc_free_chunk_size_struct))

.out     .sprintf("|MEMMAP:RAM|kernel_xmalloc_call            | $%04X-$%04X |    %d  |", kernel_xmalloc_call, kernel_xmalloc_call + XMALLOC_ROUTINE_TO_RAM_OVERLAY,kernel_xmalloc_call+XMALLOC_ROUTINE_TO_RAM_OVERLAY-kernel_xmalloc_call)

.out     .sprintf("|MEMMAP:RAM|FLGRST                            | $%04X-$%04X |  %d   |", FLGRST, FLGRST,1)
.out     .sprintf("|MEMMAP:RAM|CSRND                            | $%04X-$%04X |  %d   |", CSRND, CSRND,1)


.out     .sprintf("|MEMMAP:RAM|FREE                           | $%04X-$%04X | %d   |", KERNEL_ADIOB_END, FLGRST-1, FLGRST-KERNEL_ADIOB_END)

.out     .sprintf("|MEMMAP:RAM|VNMI            | $%04X-$%04X |   3   |", VNMI, VNMI+3)

.out     .sprintf("|MEMMAP:RAM|ADIODB_VECTOR            | $%04X-$%04X |   %d   |", ADIODB_VECTOR, ADIODB_VECTOR+3,3)

.out     .sprintf("|MEMMAP:RAM|IRQVECTOR            | $%04X-$%04X |   %d   |", IRQVECTOR, IRQVECTOR + 3,3)

.out     .sprintf("|MEMMAP:RAM|VAPLIC            | $%04X-$%04X |   %d   |", VAPLIC, VAPLIC + 3,3)

.out     .sprintf("|##MEMMAP: Page 3")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:IO |VIA1                           | $0300-$030F     |     |")

.out     .sprintf("|##MEMMAP: Page 4")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|page4 ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY       | $%04X-$%04X |  3  |", ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY,ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY+3)
;.out     .sprintf("|MEMMAP:RAM|page4 overlay_access       | $%04X-$%04X |  %d  |", $400 + code_adress_419 - code_adress_400, $400 + code_adress_436 - code_adress_400, code_adress_436 - code_adress_400)

.out     .sprintf("|##MEMMAP: Page 5&6")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|FREE                         | $%04X-$%04X |  %d  |", BUFNOM, BUFNOM_END, BUFNOM_END - BUFNOM)
.out     .sprintf("|MEMMAP:RAM|Malloc table                   | $%04X-$%04X |  %d    |", kernel_malloc, kernel_malloc_end,kernel_malloc_end-kernel_malloc)
.out     .sprintf("|MEMMAP:RAM|main kernel process struct     | $%04X-$%04X |  %d    |", kernel_process, kernel_process_end,kernel_process_end-kernel_process)

.out     .sprintf("|MEMMAP:RAM|BUFEDT                         | $%04X-$%04X |   %d   |", BUFEDT, BUFEDT_END,BUFEDT_END-BUFEDT)
.out     .sprintf("|MEMMAP:RAM|KERNEL_MEMORY_DRIVER           | $%04X-$%04X |   %d   |", KERNEL_DRIVER_MEMORY, KERNEL_DRIVER_MEMORY_END, KERNEL_DRIVER_MEMORY_END - KERNEL_DRIVER_MEMORY)


.endif
