#ifndef KERNEL_ATA_H
#define KERNEL_ATA_H
 
#include <stdint.h>
 
/* Minimal ATA PIO driver (primary bus, master drive) -- enough to read/
 * write the sectors your simple filesystem sits on. Fine for QEMU's
 * emulated IDE disk; add LBA48/secondary-bus/IRQ support later if needed. */
void ata_init(void);
 
/* Returns 0 on success, negative on error. `buffer` must be at least
 * sector_count * 512 bytes. */
int ata_read_sectors(uint32_t lba, uint8_t sector_count, uint8_t *buffer);
int ata_write_sectors(uint32_t lba, uint8_t sector_count, const uint8_t *buffer);
 
#endif /* KERNEL_ATA_H */
