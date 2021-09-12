
.out          "BANK    LABEL                         BEGIN:END" 
.out .sprintf("BANK 0  BUFBUF                           : $%x : $%x", BUFBUF,BUFBUF+12*KERNEL_NUMBER_BUFFER)
.out .sprintf("BANK 0  BUFROU                           : $%x : $%x", BUFROU,BUFROU+(end_BUFROU-data_to_define_4))
.out .sprintf("BANK 0  TELEMON_KEYBOARD_BUFFER_BEGIN    : $%x : $%x", TELEMON_KEYBOARD_BUFFER_BEGIN,TELEMON_KEYBOARD_BUFFER_END)
.out .sprintf("BANK 0  TELEMON_ACIA_BUFFER_INPUT_BEGIN  : $%x : $%x", TELEMON_ACIA_BUFFER_INPUT_BEGIN ,TELEMON_ACIA_BUFFER_INPUT_END)
.out .sprintf("BANK 0  TELEMON_ACIA_BUFFER_OUTPUT_BEGIN : $%x : $%x", TELEMON_ACIA_BUFFER_OUTPUT_BEGIN ,TELEMON_ACIA_BUFFER_OUTPUT_END)
.out .sprintf("BANK 0  TELEMON_PRINTER_BUFFER_BEGIN     : $%x : $%x", TELEMON_PRINTER_BUFFER_BEGIN,TELEMON_PRINTER_BUFFER_END)





.out   .sprintf("MEMMAP:BANK7:FREE=%x-%x:size=2", KOROM, KORAM)
.out   .sprintf("MEMMAP:BANK7:IOTAB=%x-%x", IOTAB, IOTAB+KERNEL_SIZE_IOTAB-1)
.out   .sprintf("MEMMAP:BANK7:KERNEL_ADIOB=%x-%x:size=%d", KERNEL_ADIOB,KERNEL_ADIOB+ADIODB_LENGTH-1,KERNEL_ADIOB+ADIODB_LENGTH-KERNEL_ADIOB)
.out   .sprintf("MEMMAP:BANK7:FREE=%x-%x:size=%d", KERNEL_ADIOB_END,FLGRST-1,FLGRST-KERNEL_ADIOB_END)

.out     .sprintf("MEMMAP:RAM:Malloc table begin : %x",kernel_malloc)
.out     .sprintf("MEMMAP:RAM:ORIX_ARGV=%x", ORIX_ARGV)
.out     .sprintf("MEMMAP:RAM:ORIX_ARGC=%x", ORIX_ARGC)

