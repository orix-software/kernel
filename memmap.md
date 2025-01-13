kernel_end_of_variables_before_BUFNOM : 503
kernel_end_of_variables_before_BUFEDT : 58f
kernel_end_of_memory_for_kernel (malloc will start at this adress) : 6a1
==================================================================
File memory
==================================================================
_KERNEL_FILE size (One fp struct) : $38 bytes
kernel_one_process_struct size (struct for one process)  : $76 bytes
With all the parameter all process could use 494 bytes in memory, if it's allocated
KERNEL_MAX_PROCESS (Max process in the system)           : 4
KERNEL_MAX_FP_PER_PROCESS  (Max file pointer per process): 2
KERNEL_USERZP_SAVE_LENGTH                                : 16 bytes
KERNEL_LENGTH_MAX_CMDLINE                                : 37
kernel_process_struct size (struct init process)         : $16 bytes
int MALLOC_BUSY_SIZE_LOW = 0x570;
int MALLOC_BUSY_SIZE_HIGH = 0x567;
int MALLOC_BUSY_BEGIN_HIGH = 0x539;
int MALLOC_BUSY_END_HIGH = 0x54b;
int MALLOC_BUSY_BEGIN_LOW = 0x542;
int MALLOC_BUSY_END_LOW = 0x554;
int KERNEL_MAX_NUMBER_OF_MALLOC = 0x9;
int MALLOC_FREE_SIZE_HIGH =0x2ba;
int MALLOC_FREE_SIZE_LOW =0x2bf;
int MALLOC_FREE_BEGIN_HIGH=0x52a;
int MALLOC_FREE_BEGIN_LOW=0x525;
int MALLOC_FREE_END_HIGH=0x534;
int MALLOC_FREE_END_LOW=0x52f;
int KERNEL_MALLOC_FREE_CHUNK_MAX=0x5;
|#MEMMAP: Memmap
MEMMAP:
|##MEMMAP: Page 0
MEMMAP:
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|RES                            | $00-$01     |  2   |
|MEMMAP:RAM|RESB                           | $02-$03     |  2   |
|MEMMAP:RAM|RESC                           | $04-$05     |  2   |
|MEMMAP:RAM|RESD                           | $06-$07     |  2   |
|MEMMAP:RAM|RESE                           | $08-$09     |  2   |
|MEMMAP:RAM|RESF                           | $0A-$0B     |  2   |
|MEMMAP:RAM|RESG                           | $59-$5A     |  2   |
|MEMMAP:RAM|RESH                           | $60-$61     |  2   |
|MEMMAP:RAM|RESI                           | $62-$63     |  2   |
|MEMMAP:RAM|RESCONCAT                      | $64-$65     |  2   |
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
|MEMMAP:RAM|FREE                           | $2E-$14     |      |
|MEMMAP:RAM|ADDRESS_READ_BETWEEN_BANK      | $15-$16     |  2   |
|MEMMAP:RAM|BNKCIB_DOUBLON                 | $34-$34     |  1   |
|MEMMAP:RAM|FREE                           | $35-$3F     |      |
|MEMMAP:RAM|ADCLK                          | $40-$41     |  2   |
|MEMMAP:RAM|TIMEUS                         | $42-$43     |  2   |
|MEMMAP:RAM|TIMEUD (used in cc65 clock function)| $44-$45     |  2   |
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
|MEMMAP:RAM|FREE                           | $8C-$FF     |  115   |
|##MEMMAP: Page 2
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
|MEMMAP:RAM|KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM| $0208-$0209 |  1   |
|MEMMAP:RAM|FREE                           | $0209-$020C |  4   |
|MEMMAP:RAM|FLGTEL                          | $020D-$020D |  1   |
|MEMMAP:RAM|TIMED                           | $0210-$0210 |  1   |
|MEMMAP:RAM|TIMES                           | $0211-$0211 |  1   |
|MEMMAP:RAM|TIMEM                           | $0212-$0212 |  1   |
|MEMMAP:RAM|TIMEH                           | $0213-$0213 |  1   |
|MEMMAP:RAM|FLGCLK                          | $0214-$0214 |  1   |
|MEMMAP:RAM|FLGCLK_FLAG                     | $0215-$0215 |  1   |
|MEMMAP:RAM|FLGCUR                          | $0216-$0216 |  1   |
|MEMMAP:RAM|FLGCUR_STATE                         | $0217-$0217 |  1   |
|MEMMAP:RAM|ADSCRL                          | $0218-$021B |  4   |
|MEMMAP:RAM|ADSCRH                          | $021C-$021F |  4   |
|MEMMAP:RAM|SCRX                         | $0220-$0220 |  1   |
|MEMMAP:RAM|BUSY_BANK_TABLE_RAM             | $0221-$0224 |  3   |
|MEMMAP:RAM|SCRY                         | $0224-$0227 |  4   |
|MEMMAP:RAM|SCRDX                         | $0228-$0228 |  1   |
|MEMMAP:RAM|SCRFX                         | $022C-$022C |  1   |
|MEMMAP:RAM|SCRFY                         | $0234-$0234 |  1   |
|MEMMAP:RAM|SCRDY                         | $0230-$0230 |  1   |
|MEMMAP:RAM|SCRBAL                         | $0238-$0238 |  1   |
|MEMMAP:RAM|SCRBAH                         | $023C-$023C |  1   |
|MEMMAP:RAM|SCRCT                         | $0240-$0240 |  1   |
|MEMMAP:RAM|SCRCF                         | $0244-$0244 |  1   |
|MEMMAP:RAM|FIXME                          | $0248-$0220 |  80   |
|MEMMAP:RAM|FLGSCR                          | $0248-$024C |  4   |
|MEMMAP:RAM|CURSCR                          | $024C-$024D |  1   |
|MEMMAP:RAM|FREE                          | $024D-$0256 |  11   |
|MEMMAP:RAM|SCRTXT                          | $0256-$0260 |  4   |
|MEMMAP:RAM|SCRHIR  (not used)              | $025C-$0260 |  4   |
|MEMMAP:RAM|SCRTRA                          | $0262-$0266 |  6   |
|MEMMAP:RAM|KBDCOL                          | $0268-$0270 |  8   |
|MEMMAP:RAM|KBDFLG_KEY                      | $0270-$0272 |  2  |
|MEMMAP:RAM|KBDVRR                      | $0272-$0273 | 1   |
|MEMMAP:RAM|KBDVRL                      | $0273-$0275 | 2   |
|MEMMAP:RAM|FLGKBD                      | $0275-$0276 | 1   |
|MEMMAP:RAM|KBDFCT                      | $0276-$0277 | 1   |
|MEMMAP:RAM|KBDSHT                      | $0278-$0279 | 1   |
|MEMMAP:RAM|KBDKEY                       | $0279-$027E | 1   |
|MEMMAP:RAM|KBDCTC                          | $027E-$027F |  2   |
|MEMMAP:RAM|FREE                            | $027F-$02A5 |  40   |
|MEMMAP:RAM|KEYBOARD_COUNTER               | $02A6-$02A9 |  3   |
|MEMMAP:RAM|HRSPAT                            | $02AA-$02AA |  1   |
|MEMMAP:RAM|IOTAB                          | $02AE-$02B1 |  X   |
|MEMMAP:RAM|KERNEL_ADIOB                   | $02B2-$02B9 | 8   |
|MEMMAP:RAM|kernel_malloc_free_chunk_size                   | $02BA-$02C3 | 10   |
|MEMMAP:RAM|kernel_xmalloc_call            | $02C4-$02EB |    39  |
|MEMMAP:RAM|FLGRST                            | $02EE-$02EE |  1   |
|MEMMAP:RAM|CSRND                            | $02EF-$02EF |  1   |
|MEMMAP:RAM|FREE                           | $02EC-$02ED | 2   |
|MEMMAP:RAM|VNMI            | $02F4-$02F7 |   3   |
|MEMMAP:RAM|ADIODB_VECTOR            | $02F7-$02FA |   3   |
|MEMMAP:RAM|IRQVECTOR            | $02FA-$02FD |   3   |
|MEMMAP:RAM|VAPLIC            | $02FD-$0300 |   3   |
|##MEMMAP: Page 3
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:IO |VIA1                           | $0300-$030F     |     |
|##MEMMAP: Page 4
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|page4 ORIX_VECTOR_READ_VALUE_INTO_RAM_OVERLAY       | $0411-$0414 |  3  |
|##MEMMAP: Page 5&6
|MEMMAP:Type     | Name                          | Range       | Size |
|MEMMAP: :------- |:----------------------------- |:----------- |:-----|
|MEMMAP:RAM|FREE                         | $0517-$0525 |  14  |
|MEMMAP:RAM|Malloc table                   | $0525-$0579 |  84    |
|MEMMAP:RAM|main kernel process struct     | $0579-$058F |  22    |
|MEMMAP:RAM|BUFEDT                         | $0590-$05FE |   110   |
|MEMMAP:RAM|KERNEL_MEMORY_DRIVER           | $05FE-$06A1 |   163   |
