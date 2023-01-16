// elf bootloader

#include <peridot_sdif_pff.h>

int main(void)
{
	// Boot file name (specify in uppercase in 8.3 DOS-format)
	pf_boot("/BOOT.ELF");

	return 0;
}
