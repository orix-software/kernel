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
|RAM|KERNEL_XKERNEL_CREATE_PROCESS_TMP | $0203-$0203 |  1   |
|RAM|<span style="color:green">FREE</span>                           | $020E-$020F |  2   |
|RAM|IOTAB                          | $02AE-$02B1 |  X   |
|RAM|KERNEL_ADIOB                   | $02B2-$02B9 | 8   |
|RAM|kernel_xmalloc_call            | $02C8-$02EF |      |
|RAM|KBDCOL                          | $0268-$0270 |  8   |
|RAM|ADSCRL                          | $0218-$021C |  4   |
|RAM|ADSCRH                          | $021C-$0220 |  4   |
|RAM|<span style="color:green">FREE</span>                           | $02F0-$02ED | -2   |
# Page 3
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|IO |VIA1                           | $0300-$030F     |     |
# Page 4
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
# Page 5&6
|Type     | Name                          | Range       | Size |
| :------- |:----------------------------- |:----------- |:-----|
|RAM|BUFNOM                         | $0517-$0525 |      |
|RAM|Malloc table                   | $0525-$0579 |      |
|RAM|main kernel process struct     | $0579-$058F |      |
|RAM|BUFEDT                         | $0590-$05FE |      |
|RAM|KERNEL_MEMORY_DRIVER           | $05FE-$06A3 |      |
#Kernel bank7
|ROM|<span style="color:green">FREE</span>                         |$f958-$fff0|   1688   |
#Bank 0
|BANK0|BUFBUF                        | $c080-$c0b6 |     |
|BANK0|BUFROU                        | $c500-$c54e |     |
|BANK0|TELEMON_KEYBOARD_BUFFER_BEGIN | $c5c4-$c680 |     |
|BANK0|XMALLOC (copy from kernel)    | $f6ce-$f77a |     |
|BANK0|X<span style="color:green">FREE</span> (copy from kernel)      | $f77a-$f940 |     |
