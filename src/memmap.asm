



.out     .sprintf("# Main memory")
.out     .sprintf("MEMMAP:RAM:FREE                            : $%x-$%x:size=2", KOROM, KORAM)
.out     .sprintf("MEMMAP:RAM:IOTAB                           : $%x-$%x", IOTAB, IOTAB+KERNEL_SIZE_IOTAB-1)
.out     .sprintf("MEMMAP:RAM:KERNEL_ADIOB                    : $%x$-$%x:size=%d", KERNEL_ADIOB,KERNEL_ADIOB+ADIODB_LENGTH-1,KERNEL_ADIOB+ADIODB_LENGTH-KERNEL_ADIOB)
.out     .sprintf("MEMMAP:RAM:FREE                            : $%x-$%x:size=%d", KERNEL_ADIOB_END,FLGRST-1,FLGRST-KERNEL_ADIOB_END)
.out     .sprintf("MEMMAP:RAM:kernel_xmalloc_call             : $%x-$%x",kernel_xmalloc_call,kernel_xmalloc_call+XMALLOC_ROUTINE_TO_RAM_OVERLAY)
.out     .sprintf("MEMMAP:RAM:Malloc table begin              : $%x",kernel_malloc)

.out     .sprintf("# Bank 7")
.out     .sprintf("MEMMAP:BANK7:free_bytes                    : $%x-$fff0", free_bytes)

.out     .sprintf("# Bank 0")
.out     .sprintf("MEMMAP:BANK0:XMALLOC (copy from kernel)    : $%x-$%x", ramoverlay_xmalloc,ramoverlay_xmalloc_end )
.out     .sprintf("MEMMAP:BANK0:XFREE (copy from kernel)      : $%x-$%x", ramoverlay_xfree,ramoverlay_xfree_end )
.out     .sprintf("MEMMAP:BANK0:BUFBUF                        : $%x-$%x", BUFBUF,BUFBUF+12*KERNEL_NUMBER_BUFFER)
.out     .sprintf("MEMMAP:BANK0:BUFROU                        : $%x-$%x", BUFROU,BUFROU+(end_BUFROU-data_to_define_4))
.out     .sprintf("MEMMAP:BANK0:TELEMON_KEYBOARD_BUFFER_BEGIN : $%x-$%x", TELEMON_KEYBOARD_BUFFER_BEGIN,TELEMON_KEYBOARD_BUFFER_END)


