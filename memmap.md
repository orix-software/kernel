KERNEL_MAX_PATH_LENGTH                                   : 49 bytes 
KERNEL_MAX_PROCESS (Max process in the system)           : 4
KERNEL_MAX_FP_PER_PROCESS  (Max file pointer per process): 2
KERNEL_USERZP_SAVE_LENGTH                                : 16 bytes
KERNEL_LENGTH_MAX_CMDLINE                                : 58
kernel_process_struct size (struct init process)         : 22 bytes
kernel_one_process_struct size (struct for one process)  : 139 bytes
With all the parameter all process could use 578 bytes in memory, if it's allocated
==================================================================
Memory
==================================================================
KERNEL_MAX_NUMBER_OF_MALLOC (max malloc for all process) : 7
kernel_malloc_struct size (malloc table)                 : 84 bytes
==================================================================
File memory
==================================================================
_KERNEL_FILE size (One fp struct) : $38 bytes
==================================================================
Resume
==================================================================
System will need almost 662 bytes in memory, if we reached KERNEL_MAX_PROCESS, KERNEL_MAX_NUMBER_OF_MALLOC and KERNEL_MALLOC_FREE_CHUNK_MAX allocated
kernel_malloc_busy_begin : 2ba
kernel_end_of_variables_before_BUFNOM : 503
kernel_end_of_variables_before_BUFEDT : 58f
kernel_end_of_memory_for_kernel (malloc will start at this adress) : 6a4
|MODIFY:RES:_create_file_pointer
|MODIFY:KERNEL_ERRNO:_create_file_pointer
|CALL:XMALLOC:_create_file_pointer
|MODIFY:RES:checking_fp_exists
|MODIFY:RESB:checking_fp_exists
|MODIFY:TR5:checking_fp_exists
|MODIFY:RES:_set_to_value_seek_file
|MODIFY:RES:kernel_create_process
|MODIFY:RESB:kernel_create_process
|MODIFY:TR4:kernel_create_process
|MODIFY:TR5:kernel_create_process
|MODIFY:KERNEL_ERRNO:kernel_create_process
|MODIFY:KERNEL_MALLOC_TYPE:kernel_create_process
|MODIFY:KERNEL_XKERNEL_CREATE_PROCESS_TMP:kernel_create_process
|MODIFY:RES:kernel_kill_process
|MODIFY:TR5:kernel_kill_process via XFREE_ROUTINE
|MODIFY:RES:kernel_kill_process via XFREE_ROUTINE
|MODIFY:RESB:XCLOSE_ROUTINE
|MODIFY:TR7:XCLOSE_ROUTINE
|MODIFY:PTR_READ_DEST:XREADBYTES_ROUTINE
|MODIFY:RES:XREADBYTES_ROUTINE
|MODIFY:TR0:XREADBYTES_ROUTINE
|MODIFY:RESB:XGETCWD_ROUTINE
|MODIFY:RES:XPUTCWD_ROUTINE
|MODIFY:RESB:XPUTCWD_ROUTINE
|MODIFY:PTR_READ_DEST:XWRITEBYTES_ROUTINE
|MODIFY:RES:XWRITEBYTES_ROUTINE
|MODIFY:RESB:XWRITEBYTES_ROUTINE
|MODIFY:TR0:XFSEEK_ROUTINE
|MODIFY:TR7:XFSEEK_ROUTINE
|MODIFY:TR4:XFSEEK_ROUTINE
|MODIFY:RESB:XFSEEK_ROUTINE
|MODIFY:RES:XFSEEK_ROUTINE
|MODIFY:RES:XMKDIR_ROUTINE
|MODIFY:ptr1:XMKDIR_ROUTINE
|MODIFY:TR7:XMKDIR_ROUTINE
|MODIFY:RES:XRM_ROUTINE
CALL:_ch376_file_erase:XRM_ROUTINE
CALL:XCLOSE:XRM_ROUTINE
CALL:XOPEN:XRM_ROUTINE
|MODIFY:RES:XOPENDIR
|MODIFY:RESB:XOPENDIR
|MODIFY:RESC:XOPENDIR
|MODIFY:TR0:XOPENDIR
|MODIFY:TR7:XOPENDIR
|MODIFY:RES:_XEXEC
|MODIFY:TR0:_XEXEC
|MODIFY:TR1:_XEXEC
|MODIFY:BUFEDT:_XEXEC
|MODIFY:BNKOLD:_XEXEC
|MODIFY:BNK_TO_SWITCH:_XEXEC
|MODIFY:RES:_XFORK
|MODIFY:TR0:_XFORK
|MODIFY:TR1:_XFORK
|MODIFY:RES:_XFORK via kernel_create_process
|MODIFY:RESB:_XFORK via kernel_create_process
|MODIFY:TR4:_XFORK via kernel_create_process
|MODIFY:TR5:_XFORK via kernel_create_process
|MODIFY:RESB:getFileLength
|MODIFY:RES:kernel_try_to_find_command_in_bin_path
|MODIFY:RESB:kernel_try_to_find_command_in_bin_path
|MODIFY:RESC:kernel_try_to_find_command_in_bin_path
|MODIFY:RESD:kernel_try_to_find_command_in_bin_path
|MODIFY:RESE:kernel_try_to_find_command_in_bin_path
|MODIFY:RESF:kernel_try_to_find_command_in_bin_path
|MODIFY:PTR_READ_DEST:kernel_try_to_find_command_in_bin_path
|MODIFY:RESG:kernel_try_to_find_command_in_bin_path
|MODIFY:RES:XOPEN_ROUTINE
|MODIFY:TR7:XMALLOC_ROUTINE
|MODIFY:KERNEL_ERRNO:XMALLOC_ROUTINE
|MODIFY:RES:XFREE_ROUTINE
|MODIFY:KERNEL_XFREE_TMP:XFREE_ROUTINE
|#MEMMAP: Page 0
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|RES                            | $00-$01     |  2   |
|MEMMAP:RAM|RESB                           | $02-$03     |  2   |
|MEMMAP:RAM|RESC                           | $04-$05     |  2   |
|MEMMAP:RAM|RESD                           | $06-$07     |  2   |
|MEMMAP:RAM|RESE                           | $08-$09     |  2   |
|MEMMAP:RAM|RESF                           | $0A-$0B     |  2   |
|MEMMAP:RAM|TR0                            | $0C-$0C     |  1   |
|MEMMAP:RAM|TR1                            | $0D-$0D     |  1   |
|MEMMAP:RAM|TR2                            | $0E-$0E     |  1   |
|MEMMAP:RAM|TR3                            | $0F-$0F     |  1   |
|MEMMAP:RAM|TR4                            | $10-$10     |  1   |
|MEMMAP:RAM|TR5                            | $11-$11     |  1   |
|MEMMAP:RAM|TR6                            | $12-$12     |  1   |
|MEMMAP:RAM|TR7                            | $13-$13     |  1   |
|MEMMAP:RAM|DEFAFF                         | $14-$14     |  1   |
|MEMMAP:RAM|FREE                           | $15-$16     |  2   |
|MEMMAP:RAM|ADDRESS_VECTOR_FOR_ADIOB       | $17-$18     |  2   |
|MEMMAP:RAM|work_channel                   | $19-$19     |  1   |
|MEMMAP:RAM|i_o_counter                    | $1A-$1B     |  2   |
|MEMMAP:RAM|FREE                           | $1C-$1C     |  1   |
|MEMMAP:RAM|GS                             | $1D-$1D     |  1   |
|MEMMAP:RAM|FREE                           | $1E-$1E     |  1   |
|MEMMAP:RAM|TOFIX                          | $1F-$1F     |  1   |
|MEMMAP:RAM|TOFIX                          | $20-$20     |  1   |
|MEMMAP:RAM|IRQSVA                         | $21-$21     |  1   |
|MEMMAP:RAM|IRQSVX                         | $22-$22     |  1   |
|MEMMAP:RAM|IRQSVY                         | $23-$23     |  1   |
|MEMMAP:RAM|IRQSVP                         | $24-$24     |  1   |
|MEMMAP:RAM|FIXME_PAGE0_0                  | $25-$25     |  1   |
|MEMMAP:RAM|ADSCR                          | $26-$27     |  2   |
|MEMMAP:RAM|SCRNB                          | $28-$29     |  2   |
|MEMMAP:RAM|ADKBD                          | $2A-$2B     |  2   |
|MEMMAP:RAM|PTR_READ_DEST                  | $2C-$2D     |  2   |
|MEMMAP:RAM|FREE                           | $2E-$31     |      |
|MEMMAP:RAM|ptr1                           | $32-$33     |  2   |
|MEMMAP:RAM|tmp1                           | $34-$34     |  1   |
|MEMMAP:RAM|FREE                           | $35-$3F     |      |
|MEMMAP:RAM|ADCLK                          | $40-$41     |  2   |
|MEMMAP:RAM|TIMEUS                         | $42-$43     |  2   |
|MEMMAP:RAM|TIMEUD                         | $44-$45     |  2   |
|MEMMAP:RAM|HRSX                           | $46-$46     |  1   |
|MEMMAP:RAM|HRSY                           | $47-$47     |  1   |
|MEMMAP:RAM|FREE                           | $48-$48     |  1   |
|MEMMAP:RAM|HRSX40                         | $49-$49     |  1   |
|MEMMAP:RAM|HRSX6                          | $4A-$4A     |  1   |
|MEMMAP:RAM|ADHRS                          | $4B-$4C     |  2   |
|MEMMAP:RAM|HRS1                           | $4D-$4E     |  2   |
|MEMMAP:RAM|HRS2                           | $4F-$50     |  2   |
|MEMMAP:RAM|HRS3                           | $51-$52     |  2   |
|MEMMAP:RAM|HRS4                           | $53-$54     |  2   |
|MEMMAP:RAM|HRS5                           | $55-$56     |  2   |
|MEMMAP:RAM|HRSFB                          | $57-$57     |  1   |
|MEMMAP:RAM|VABPK1                         | $58-$58     |  1   |
|MEMMAP:RAM|FREE                           | $59-$5A     |  2   |
|MEMMAP:RAM|INDRS                          | $5B-$5B     |  1   |
|MEMMAP:RAM|FREE                           | $5C-$5F     |  2   |
|MEMMAP:RAM|RESG                           | $6E-$6F     |  2   |
|MEMMAP:RAM|FREE                           | $8C-$FF     |  115   |
|#MEMMAP: Page 2
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|KERNEL_ERRNO                   | $0200-$0200 |  1   |
|MEMMAP:RAM|KERNEL_CH376_MOUNT             | $0201-$0201 |  1   |
|MEMMAP:RAM|KERNEL_XFREE_TMP             | $0202-$0202 |  1   |
|MEMMAP:RAM|KERNEL_XKERNEL_CREATE_PROCESS_TMP| $0203-$0203 |  1   |
|MEMMAP:RAM|KERNEL_TMP_XEXEC             | $0204-$0204 |  1   |
|MEMMAP:RAM|KERNEL_KERNEL_XEXEC_BNKOLD   | $0205-$0205 |  1   |
|MEMMAP:RAM|KERNEL_MALLOC_TYPE           | $0206-$0206 |  1   |
|MEMMAP:RAM|KERNEL_SAVE_XEXEC_CURRENT_SET| $0207-$0207 |  1   |
|MEMMAP:RAM|KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM| $0208-$0208 |  1   |
|MEMMAP:RAM|KEYBOARD_COUNTER               | $02A6-$02AA |  4   |
|MEMMAP:RAM|FREE                           | $020E-$020F |  2   |
|MEMMAP:RAM|FREE                           | $020E-$020F |  2   |
|MEMMAP:RAM|IOTAB                          | $02AE-$02B1 |  X   |
|MEMMAP:RAM|KERNEL_ADIOB                   | $02B2-$02B9 | 8   |
|MEMMAP:RAM|kernel_xmalloc_call            | $02C8-$02EF |      |
|MEMMAP:RAM|KBDCOL                          | $0268-$0270 |  8   |
|MEMMAP:RAM|ADSCRL                          | $0218-$021C |  4   |
|MEMMAP:RAM|ADSCRH                          | $021C-$0220 |  4   |
|MEMMAP:RAM|FLGSCR                          | $0248-$024C |  4   |
|MEMMAP:RAM|FREE                           | $02F0-$02ED | -2   |
|#MEMMAP: Page 3
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:IO |VIA1                           | $0300-$030F     |     |
|#MEMMAP: Page 4
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|page4 overlay_access       | $0419-$0436 |  54  |
|#MEMMAP: Page 5&6
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|BUFNOM                         | $0517-$0525 |      |
|MEMMAP:RAM|Malloc table                   | $0525-$0579 |      |
|MEMMAP:RAM|main kernel process struct     | $0579-$058F |      |
|MEMMAP:RAM|BUFEDT                         | $0590-$05FE |      |
|MEMMAP:RAM|KERNEL_MEMORY_DRIVER           | $05FE-$06A4 |      |
|#MEMMAP: Kernel bank 7
| Type      | Name                         | Range   | Size |
| :-------- |:---------------------------- |:------- |:-----|
|MEMMAP:ROM|FREE                         |$fb83-$fff0|   1133   |
|#MEMMAP:Bank 0
| Type      | Name                         | Range   | Size |
| :-------- |:---------------------------- |:------- |:-----|
|MEMMAP:BANK0|BUFBUF                        | $c080-$c0b6 |     |
|MEMMAP:BANK0|BUFROU                        | $c500-$c54e |     |
|MEMMAP:BANK0|TELEMON_KEYBOARD_BUFFER_BEGIN | $c5c4-$c680 |     |
|MEMMAP:BANK0|XMALLOC (copy from kernel)    | $f83f-$f8eb |     |
|MEMMAP:BANK0|XFREE (copy from kernel)      | $f8eb-$fb6b |     |
