
.out     .sprintf("|#MEMMAP: Page 0")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|RES                            | $%02X-$%02X     |  2   |", RES,RES+1)
.out     .sprintf("|MEMMAP:RAM|RESB                           | $%02X-$%02X     |  2   |", RESB,RESB+1)
.out     .sprintf("|MEMMAP:RAM|RESC                           | $%02X-$%02X     |  2   |", RESC,RESC+1)
.out     .sprintf("|MEMMAP:RAM|RESD                           | $%02X-$%02X     |  2   |", RESD,RESD+1)
.out     .sprintf("|MEMMAP:RAM|RESE                           | $%02X-$%02X     |  2   |", RESE,RESE+1)
.out     .sprintf("|MEMMAP:RAM|RESF                           | $%02X-$%02X     |  2   |", RESF,RESF+1)
.out     .sprintf("|MEMMAP:RAM|TR0                            | $%02X-$%02X     |  1   |", TR0,TR0)
.out     .sprintf("|MEMMAP:RAM|TR1                            | $%02X-$%02X     |  1   |", TR1,TR1)
.out     .sprintf("|MEMMAP:RAM|TR2                            | $%02X-$%02X     |  1   |", TR2,TR2)
.out     .sprintf("|MEMMAP:RAM|TR3                            | $%02X-$%02X     |  1   |", TR3,TR3)
.out     .sprintf("|MEMMAP:RAM|TR4                            | $%02X-$%02X     |  1   |", TR4,TR4)
.out     .sprintf("|MEMMAP:RAM|TR5                            | $%02X-$%02X     |  1   |", TR5,TR5)
.out     .sprintf("|MEMMAP:RAM|TR6                            | $%02X-$%02X     |  1   |", TR6,TR6)
.out     .sprintf("|MEMMAP:RAM|TR7                            | $%02X-$%02X     |  1   |", TR7,TR7)
.out     .sprintf("|MEMMAP:RAM|DEFAFF                         | $%02X-$%02X     |  1   |",DEFAFF,DEFAFF)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $15-$16     |  2   |")
.out     .sprintf("|MEMMAP:RAM|ADDRESS_VECTOR_FOR_ADIOB       | $%02X-$%02X     |  2   |",ADDRESS_VECTOR_FOR_ADIOB,ADDRESS_VECTOR_FOR_ADIOB+1)
.out     .sprintf("|MEMMAP:RAM|work_channel                   | $%02X-$%02X     |  1   |",work_channel,work_channel)
.out     .sprintf("|MEMMAP:RAM|i_o_counter                    | $%02X-$%02X     |  2   |",i_o_counter,i_o_counter+1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $1C-$1C     |  1   |")
.out     .sprintf("|MEMMAP:RAM|GS                             | $1D-$1D     |  1   |")
.out     .sprintf("|MEMMAP:RAM|FREE                           | $1E-$1E     |  1   |")
.out     .sprintf("|MEMMAP:RAM|TOFIX                          | $1F-$1F     |  1   |")
.out     .sprintf("|MEMMAP:RAM|TOFIX                          | $20-$20     |  1   |")
.out     .sprintf("|MEMMAP:RAM|IRQSVA                         | $%02X-$%02X     |  1   |", IRQSVA,IRQSVA)
.out     .sprintf("|MEMMAP:RAM|IRQSVX                         | $%02X-$%02X     |  1   |", IRQSVX,IRQSVX)
.out     .sprintf("|MEMMAP:RAM|IRQSVY                         | $%02X-$%02X     |  1   |", IRQSVY,IRQSVY)
.out     .sprintf("|MEMMAP:RAM|IRQSVP                         | $%02X-$%02X     |  1   |", IRQSVP,IRQSVP)
.out     .sprintf("|MEMMAP:RAM|FIXME_PAGE0_0                  | $%02X-$%02X     |  1   |",FIXME_PAGE0_0,FIXME_PAGE0_0)
.out     .sprintf("|MEMMAP:RAM|ADSCR                          | $%02X-$%02X     |  2   |", ADSCR,ADSCR+1)
.out     .sprintf("|MEMMAP:RAM|SCRNB                          | $%02X-$%02X     |  2   |", SCRNB,SCRNB+1)
.out     .sprintf("|MEMMAP:RAM|ADKBD                          | $%02X-$%02X     |  2   |", ADKBD,ADKBD+1)
.out     .sprintf("|MEMMAP:RAM|PTR_READ_DEST                  | $%02X-$%02X     |  2   |", PTR_READ_DEST,PTR_READ_DEST+1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $%02X-$%02X     |      |", PTR_READ_DEST+2,ptr1-1)
.out     .sprintf("|MEMMAP:RAM|ptr1                           | $%02X-$%02X     |  2   |", ptr1,ptr1+1)
.out     .sprintf("|MEMMAP:RAM|tmp1                           | $%02X-$%02X     |  1   |", tmp1,tmp1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $%02X-$%02X     |      |", tmp1+1,ADCLK-1)
.out     .sprintf("|MEMMAP:RAM|ADCLK                          | $%02X-$%02X     |  2   |", ADCLK,ADCLK+1)
.out     .sprintf("|MEMMAP:RAM|TIMEUS                         | $%02X-$%02X     |  2   |", TIMEUS,TIMEUS+1)
.out     .sprintf("|MEMMAP:RAM|TIMEUD                         | $%02X-$%02X     |  2   |", TIMEUD,TIMEUD+1)
.out     .sprintf("|MEMMAP:RAM|HRSX                           | $%02X-$%02X     |  1   |", HRSX,HRSX)
.out     .sprintf("|MEMMAP:RAM|HRSY                           | $%02X-$%02X     |  1   |", HRSY,HRSY)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $48-$48     |  1   |")
.out     .sprintf("|MEMMAP:RAM|HRSX40                         | $%02X-$%02X     |  1   |", HRSX40,HRSX40)
.out     .sprintf("|MEMMAP:RAM|HRSX6                          | $%02X-$%02X     |  1   |", HRSX6,HRSX6)
.out     .sprintf("|MEMMAP:RAM|ADHRS                          | $%02X-$%02X     |  2   |", ADHRS,ADHRS+1)
.out     .sprintf("|MEMMAP:RAM|HRS1                           | $%02X-$%02X     |  2   |", HRS1,HRS1+1)
.out     .sprintf("|MEMMAP:RAM|HRS2                           | $%02X-$%02X     |  2   |", HRS2,HRS2+1)
.out     .sprintf("|MEMMAP:RAM|HRS3                           | $%02X-$%02X     |  2   |", HRS3,HRS3+1)
.out     .sprintf("|MEMMAP:RAM|HRS4                           | $%02X-$%02X     |  2   |", HRS4,HRS4+1)
.out     .sprintf("|MEMMAP:RAM|HRS5                           | $%02X-$%02X     |  2   |", HRS5,HRS5+1)
.out     .sprintf("|MEMMAP:RAM|HRSFB                          | $%02X-$%02X     |  1   |", HRSFB,HRSFB)
.out     .sprintf("|MEMMAP:RAM|VABPK1                         | $%02X-$%02X     |  1   |", VABKP1,VABKP1)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $59-$5A     |  2   |")
.out     .sprintf("|MEMMAP:RAM|INDRS                          | $%02X-$%02X     |  1   |", INDRS,INDRS)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $5C-$5F     |  2   |")
.out     .sprintf("|MEMMAP:RAM|RESG                           | $%02X-$%02X     |  2   |", RESG,RESG+1)

.out     .sprintf("|MEMMAP:RAM|FREE                           | $%02X-$FF     |  %d   |",VARLNG,$FF-VARLNG)

.out     .sprintf("|#MEMMAP: Page 2")
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
.out     .sprintf("|MEMMAP:RAM|KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM| $%04X-$%04X |  1   |", KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM, KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM)



.out     .sprintf("|MEMMAP:RAM|KEYBOARD_COUNTER               | $%04X-$%04X |  4   |", KEYBOARD_COUNTER, KEYBOARD_COUNTER+4)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $%04X-$%04X |  2   |", KOROM, KORAM)
.out     .sprintf("|MEMMAP:RAM|FREE                           | $%04X-$%04X |  2   |", KOROM, KORAM)

.out     .sprintf("|MEMMAP:RAM|TIMED                           | $%04X-$%04X |  1   |", TIMED, TIMED )
.out     .sprintf("|MEMMAP:RAM|TIMES                           | $%04X-$%04X |  1   |", TIMES, TIMES)
.out     .sprintf("|MEMMAP:RAM|TIMEM                           | $%04X-$%04X |  1   |", TIMEM , TIMEM)
.out     .sprintf("|MEMMAP:RAM|TIMEH                           | $%04X-$%04X |  1   |", TIMEH, TIMEH)

.out     .sprintf("|MEMMAP:RAM|FLGCLK                          | $%04X-$%04X |  1   |", FLGCLK, FLGCLK)

.out     .sprintf("|MEMMAP:RAM|ADSCRL                          | $%04X-$%04X |  4   |", ADSCRL,ADSCRL+4)
.out     .sprintf("|MEMMAP:RAM|ADSCRH                          | $%04X-$%04X |  4   |", ADSCRH,ADSCRH+4)
.out     .sprintf("|MEMMAP:RAM|KBDCOL                          | $%04X-$%04X |  8   |", KBDCOL,KBDCOL+8)


.out     .sprintf("|MEMMAP:RAM|KBDCTC                          | $%04X-$%04X |  1   |", KBDCTC,KBDCTC+1)
.out     .sprintf("|MEMMAP:RAM|FREE                            | $%04X-$%04X |  %d   |", KBDCTC+1,HRSPAT-1,HRSPAT-KBDCTC)



.out     .sprintf("|MEMMAP:RAM|IOTAB                          | $%04X-$%04X |  X   |", IOTAB, IOTAB+KERNEL_SIZE_IOTAB-1)
.out     .sprintf("|MEMMAP:RAM|KERNEL_ADIOB                   | $%04X-$%04X | %d   |", KERNEL_ADIOB,KERNEL_ADIOB+ADIODB_LENGTH-1,KERNEL_ADIOB+ADIODB_LENGTH-KERNEL_ADIOB)
.out     .sprintf("|MEMMAP:RAM|kernel_xmalloc_call            | $%04X-$%04X |      |", kernel_xmalloc_call,kernel_xmalloc_call+XMALLOC_ROUTINE_TO_RAM_OVERLAY)
.out     .sprintf("|MEMMAP:RAM|FLGSCR                         | $%04X-$%04X |  4   |", FLGSCR,FLGSCR+4) ; $248


.out     .sprintf("|MEMMAP:RAM|FREE                           | $%04X-$%04X | %d   |", KERNEL_ADIOB_END,FLGRST-1,FLGRST-KERNEL_ADIOB_END)

.out     .sprintf("|#MEMMAP: Page 3")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:IO |VIA1                           | $0300-$030F     |     |")

.out     .sprintf("|#MEMMAP: Page 4")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|page4 overlay_access       | $%04X-$%04X |  %d  |", $400+code_adress_419-code_adress_400,$400+code_adress_436-code_adress_400,code_adress_436-code_adress_400)

.out     .sprintf("|#MEMMAP: Page 5&6")
.out              "|MEMMAP:Type     | Name                          | Range       | Size |"
.out              "|MEMMAP: :------- |:----------------------------- |:----------- |:-----|"
.out     .sprintf("|MEMMAP:RAM|BUFNOM                         | $%04X-$%04X |  %d  |", BUFNOM, BUFNOM_END,BUFNOM_END-BUFNOM)
.out     .sprintf("|MEMMAP:RAM|Malloc table                   | $%04X-$%04X |  %d    |", kernel_malloc,kernel_malloc_end,kernel_malloc_end-kernel_malloc)
.out     .sprintf("|MEMMAP:RAM|main kernel process struct     | $%04X-$%04X |  %d    |", kernel_process,kernel_process_end,kernel_process_end-kernel_process)

.out     .sprintf("|MEMMAP:RAM|BUFEDT                         | $%04X-$%04X |   %d   |", BUFEDT, BUFEDT_END,BUFEDT_END-BUFEDT)
.out     .sprintf("|MEMMAP:RAM|KERNEL_MEMORY_DRIVER           | $%04X-$%04X |   %d   |", KERNEL_DRIVER_MEMORY,KERNEL_DRIVER_MEMORY_END,KERNEL_DRIVER_MEMORY_END-KERNEL_DRIVER_MEMORY)


.out     .sprintf("|#MEMMAP: Kernel bank 7")
.out              "|MEMMAP: Type      | Name                         | Range   | Size |"
.out              "|MEMMAP: :-------- |:---------------------------- |:------- |:-----|"

.out     .sprintf("|MEMMAP:ROM|FREE                         |$%x-$fff0|   %d   |", free_bytes,$fff0-free_bytes)

.out     .sprintf("|#MEMMAP:Bank 0")
.out              "|MEMMAP: Type      | Name                         | Range   | Size |"
.out              "|MEMMAP: :-------- |:---------------------------- |:------- |:-----|"
.out     .sprintf("|MEMMAP:BANK0|BUFBUF                        | $%x-$%x |     |", BUFBUF,BUFBUF+12*KERNEL_NUMBER_BUFFER)
.out     .sprintf("|MEMMAP:BANK0|BUFROU                        | $%x-$%x |     |", BUFROU,BUFROU+(end_BUFROU-data_to_define_4))
.out     .sprintf("|MEMMAP:BANK0|TELEMON_KEYBOARD_BUFFER_BEGIN | $%x-$%x |     |", TELEMON_KEYBOARD_BUFFER_BEGIN,TELEMON_KEYBOARD_BUFFER_END)
.out     .sprintf("|MEMMAP:BANK0|XMALLOC (copy from kernel)    | $%x-$%x |     |", ramoverlay_xmalloc,ramoverlay_xmalloc_end )
.out     .sprintf("|MEMMAP:BANK0|XFREE (copy from kernel)      | $%x-$%x |     |", ramoverlay_xfree,ramoverlay_xfree_end )



