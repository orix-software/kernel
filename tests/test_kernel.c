#include <stdio.h>
#include <unistd.h>

void xvalues_get_free_ram_bank_routine();
unsigned char xvalues_get_free_ram_bank_routine_get_real_id();


main() {
    unsigned char id_bank;
    printf("Test_kernel\n");
    xvalues_get_free_ram_bank_routine();
    id_bank=xvalues_get_free_ram_bank_routine_get_real_id();
    printf("id_bank :%d\n",id_bank);
}