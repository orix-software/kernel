



.out     .sprintf("# Main memory")
.out     .sprintf("MEMMAP:RAM:FREE                            : $%x-$%x:size=2", KOROM, KORAM)
.out     .sprintf("MEMMAP:RAM:IOTAB                           : $%x-$%x", IOTAB, IOTAB+KERNEL_SIZE_IOTAB-1)
.out     .sprintf("MEMMAP:RAM:KERNEL_ADIOB                    : $%x-$%x:size=%d", KERNEL_ADIOB,KERNEL_ADIOB+ADIODB_LENGTH-1,KERNEL_ADIOB+ADIODB_LENGTH-KERNEL_ADIOB)
.out     .sprintf("MEMMAP:RAM:kernel_xmalloc_call             : $%x-$%x",kernel_xmalloc_call,kernel_xmalloc_call+XMALLOC_ROUTINE_TO_RAM_OVERLAY)

.out     .sprintf("MEMMAP:RAM:FREE                            : $%x-$%x:size=%d", KERNEL_ADIOB_END,FLGRST-1,FLGRST-KERNEL_ADIOB_END)

.out     .sprintf("MEMMAP:RAM:BUFNOM                          : $%x-$%x", BUFNOM, BUFNOM_END)
.out     .sprintf("MEMMAP:RAM:Malloc table                    : $%x-$%x",kernel_malloc,kernel_malloc_end)
.out     .sprintf("MEMMAP:RAM:main kernel process struct      : $%x-$%x",kernel_process,kernel_process_end)

.out     .sprintf("MEMMAP:RAM:BUFEDT                          : $%x-$%x", BUFEDT, BUFEDT_END)
.out     .sprintf("MEMMAP:RAM:KERNEL_MEMORY_DRIVER            : $%x-$%x",KERNEL_DRIVER_MEMORY,KERNEL_DRIVER_MEMORY_END)


.out     .sprintf("#MEMMAP:Bank 7")
.out     .sprintf("MEMMAP:BANK7:free_bytes                    : $%x-$fff0", free_bytes)

.out     .sprintf("#MEMMAP:Bank 0")
.out     .sprintf("MEMMAP:BANK0:BUFBUF                        : $%x-$%x", BUFBUF,BUFBUF+12*KERNEL_NUMBER_BUFFER)
.out     .sprintf("MEMMAP:BANK0:BUFROU                        : $%x-$%x", BUFROU,BUFROU+(end_BUFROU-data_to_define_4))
.out     .sprintf("MEMMAP:BANK0:TELEMON_KEYBOARD_BUFFER_BEGIN : $%x-$%x", TELEMON_KEYBOARD_BUFFER_BEGIN,TELEMON_KEYBOARD_BUFFER_END)
.out     .sprintf("MEMMAP:BANK0:XMALLOC (copy from kernel)    : $%x-$%x", ramoverlay_xmalloc,ramoverlay_xmalloc_end )
.out     .sprintf("MEMMAP:BANK0:XFREE (copy from kernel)      : $%x-$%x", ramoverlay_xfree,ramoverlay_xfree_end )



