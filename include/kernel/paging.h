#ifndef KERNEL_PAGING_H
#define KERNEL_PAGING_H

#include <stdint.h>

#define PAGE_PRESENT 0x1u
#define PAGE_RW      0x2u
#define PAGE_USER    0x4u

/* Sets up an identity-mapped page directory/tables covering the first
 * `mem_size_bytes` of physical memory, registers a page-fault handler
 * (int 14, via register_interrupt_handler), and enables paging (CR0.PG). */
void paging_init(uint32_t mem_size_bytes);

void paging_map_page(uint32_t virt_addr, uint32_t phys_addr, uint32_t flags);
void paging_unmap_page(uint32_t virt_addr);

#endif /* KERNEL_PAGING_H */
