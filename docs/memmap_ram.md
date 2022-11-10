# Page 0
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|RAM|RES                            | $00-$01     |  2   |
|RAM|RESB                           | $02-$03     |  2   |
|RAM|RESC                           | $04-$05     |  2   |
|RAM|RESD                           | $06-$07     |  2   |
|RAM|RESE                           | $08-$09     |  2   |
|RAM|RESF                           | $0A-$0B     |  2   |
|RAM|TR0                            | $0C-$0C     |  1   |
|RAM|TR1                            | $0D-$0D     |  1   |
|RAM|TR2                            | $0E-$0E     |  1   |
|RAM|TR3                            | $0F-$0F     |  1   |
|RAM|TR4                            | $10-$10     |  1   |
|RAM|TR5                            | $11-$11     |  1   |
|RAM|TR6                            | $12-$12     |  1   |
|RAM|TR7                            | $13-$13     |  1   |
|RAM|DEFAFF                         | $14-$14     |  1   |
|RAM|<span style="color:green">FREE</span>                           | $15-$16     |  2   |
|RAM|ADDRESS_VECTOR_FOR_ADIOB       | $17-$18     |  2   |
|RAM|work_channel                   | $19-$19     |  1   |
|RAM|i_o_counter                    | $1A-$1B     |  2   |
|RAM|<span style="color:green">FREE</span>                           | $1C-$1C     |  1   |
|RAM|GS                             | $1D-$1D     |  1   |
|RAM|<span style="color:green">FREE</span>                           | $1E-$1E     |  1   |
|RAM|TOFIX                          | $1F-$1F     |  1   |
|RAM|TOFIX                          | $20-$20     |  1   |
|RAM|IRQSVA                         | $21-$21     |  1   |
|RAM|IRQSVX                         | $22-$22     |  1   |
|RAM|IRQSVY                         | $23-$23     |  1   |
|RAM|IRQSVP                         | $24-$24     |  1   |
|RAM|FIXME_PAGE0_0                  | $25-$25     |  1   |
|RAM|ADSCR                          | $26-$27     |  2   |
|RAM|SCRNB                          | $28-$29     |  2   |
|RAM|ADKBD                          | $2A-$2B     |  2   |
|RAM|PTR_READ_DEST                  | $2C-$2D     |  2   |
|RAM|<span style="color:green">FREE</span>                           | $2E-$31     |      |
|RAM|ptr1                           | $32-$33     |  2   |
|RAM|tmp1                           | $34-$34     |  1   |
|RAM|<span style="color:green">FREE</span>                           | $35-$3F     |      |
|RAM|ADCLK                          | $40-$41     |  2   |
|RAM|TIMEUS                         | $42-$43     |  2   |
|RAM|TIMEUD                         | $44-$45     |  2   |
|RAM|HRSX                           | $46-$46     |  1   |
|RAM|HRSY                           | $47-$47     |  1   |
|RAM|<span style="color:green">FREE</span>                           | $48-$48     |  1   |
|RAM|HRSX40                         | $49-$49     |  1   |
|RAM|HRSX6                          | $4A-$4A     |  1   |
|RAM|ADHRS                          | $4B-$4C     |  2   |
|RAM|HRS1                           | $4D-$4E     |  2   |
|RAM|HRS2                           | $4F-$50     |  2   |
|RAM|HRS3                           | $51-$52     |  2   |
|RAM|HRS4                           | $53-$54     |  2   |
|RAM|HRS5                           | $55-$56     |  2   |
|RAM|HRSFB                          | $57-$57     |  1   |
|RAM|VABPK1                         | $58-$58     |  1   |
|RAM|<span style="color:green">FREE</span>                           | $59-$5A     |  2   |
|RAM|INDRS                          | $5B-$5B     |  1   |
|RAM|<span style="color:green">FREE</span>                           | $5C-$5F     |  2   |
|RAM|RESG                           | $6E-$6F     |  2   |
|RAM|<span style="color:green">FREE</span>                           | $8C-$FF     |  115   |
# Page 2
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|RAM|KERNEL_ERRNO                   | $0200-$0200 |  1   |
|RAM|KERNEL_CH376_MOUNT             | $0201-$0201 |  1   |
|RAM|KERNEL_X<span style="color:green">FREE</span>_TMP             | $0202-$0202 |  1   |
|RAM|KERNEL_XKERNEL_CREATE_PROCESS_TMP| $0203-$0203 |  1   |
|RAM|KERNEL_TMP_XEXEC             | $0204-$0204 |  1   |
|RAM|KERNEL_KERNEL_XEXEC_BNKOLD   | $0205-$0205 |  1   |
|RAM|KERNEL_MALLOC_TYPE           | $0206-$0206 |  1   |
|RAM|KERNEL_SAVE_XEXEC_CURRENT_SET| $0207-$0207 |  1   |
|RAM|KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM| $0208-$0208 |  1   |
|RAM|<span style="color:green">FREE</span>                           | $020E-$020F |  2   |
|RAM|<span style="color:green">FREE</span>                           | $020E-$020F |  2   |
|RAM|TIMED                           | $0210-$0210 |  1   |
|RAM|TIMES                           | $0211-$0211 |  1   |
|RAM|TIMEM                           | $0212-$0212 |  1   |
|RAM|TIMEH                           | $0213-$0213 |  1   |
|RAM|FLGCLK                          | $0214-$0214 |  1   |
|RAM|ADSCRL                          | $0218-$021C |  4   |
|RAM|ADSCRH                          | $021C-$0220 |  4   |
|RAM|FIXME                          | $0220-$0220 |  80   |
|RAM|FLGSCR                          | $0248-$024C |  4   |
|RAM|KBDCOL                          | $0268-$0270 |  8   |
|RAM|KBDCTC                          | $027E-$027F |  1   |
|RAM|<span style="color:green">FREE</span>                            | $027F-$02A9 |  44   |
|RAM|KEYBOARD_COUNTER               | $02A6-$02AA |  4   |
|RAM|IOTAB                          | $02AE-$02B1 |  X   |
|RAM|KERNEL_ADIOB                   | $02B2-$02B9 | 8   |
|RAM|kernel_malloc_free_chunk_size_low                   | $02BA-$02C3 | 10   |
|RAM|kernel_xmalloc_call            | $02C4-$02EB |      |
|RAM|VNMI            | $02F4-$02F7 |   3   |
|RAM|<span style="color:green">FREE</span>                           | $02EC-$02ED | 2   |
# Page 3
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|IO |VIA1                           | $0300-$030F     |     |
# Page 4
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|RAM|page4 overlay_access       | $0419-$0436 |  54  |
# Page 5&6
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|RAM|BUFNOM                         | $0517-$0525 |  14  |
|RAM|Malloc table                   | $0525-$0579 |  84    |
|RAM|main kernel process struct     | $0579-$058F |  22    |
|RAM|BUFEDT                         | $0590-$05FE |   110   |
|RAM|KERNEL_MEMORY_DRIVER           | $05FE-$06A1 |   163   |
# Kernel bank 7
| Type      | Name                         | Range   | Size |
| :-------- |:---------------------------- |:------- |:-----|
|ROM|<span style="color:green">FREE</span>                         |$fbdc-$fff0|   1044   |
#Bank 0
| Type      | Name                         | Range   | Size |
| :-------- |:---------------------------- |:------- |:-----|
|BANK0|BUFBUF                        | $c080-$c0b6 |     |
|BANK0|BUFROU                        | $c500-$c54e |     |
|BANK0|TELEMON_KEYBOARD_BUFFER_BEGIN | $c5c4-$c680 |     |
|BANK0|XMALLOC (copy from kernel)    | $f898-$f944 |     |
|BANK0|X<span style="color:green">FREE</span> (copy from kernel)      | $f944-$fbc4 |     |
