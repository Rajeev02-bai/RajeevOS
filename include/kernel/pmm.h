#ifndef KERNEL_PMM_H
#define KERNEL_PMM_H

#include <stdint.h>

#define PMM_BLOCK_SIZE 4096u   /* one physical frame */

/* Bitmap-based physical frame allocator.
 * `mem_size_bytes`     - total physical memory to manage (e.g. from a
 *                        multiboot/e820 map, or a fixed QEMU -m value).
 * `bitmap_phys_addr`   - physical address to place the allocator's own
 *                        bitmap at; should sit right after the kernel
 *                        image (see KERNEL_PHYS_END in kernel.c). */
void pmm_init(uint32_t mem_size_bytes, uint32_t bitmap_phys_addr);

void *pmm_alloc_block(void);
void  pmm_free_block(void *block);

uint32_t pmm_get_free_block_count(void);
uint32_t pmm_get_total_block_count(void);

#endif /* KERNEL_PMM_H */
