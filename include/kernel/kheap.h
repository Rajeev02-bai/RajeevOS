#ifndef KERNEL_KHEAP_H
#define KERNEL_KHEAP_H

#include <stddef.h>
#include <stdint.h>

/* Simple kmalloc/kfree heap built on top of pmm/paging.
 * `start_addr`     - virtual address the heap begins at.
 * `initial_size`   - bytes to reserve/map up front (heap can grow later
 *                    by mapping more pages via paging_map_page). */
void kheap_init(uint32_t start_addr, uint32_t initial_size);

void *kmalloc(size_t size);
void *kmalloc_a(size_t size);   /* page-aligned allocation */
void  kfree(void *ptr);

#endif /* KERNEL_KHEAP_H */
