AS=ca65
CC=cl65
CFLAGS=-ttelestrat
ASFLAGS=-ttelestrat
LDFILES=

all : testkernel
.PHONY : all


testkernel:
	cl65 -ttelestrat test_kernel.c xvars_operation/_xvalues_get_free_ram_bank_routine.s
	cl65 -ttelestrat multiples_files_opened.c -o 1000 --start-addr 2048
	cl65 -ttelestrat multiples_files_opened.c -o 1256 --start-addr 2304
	orix-sdk/bin/relocbin.py3 -o kopened -2 1000 1256
