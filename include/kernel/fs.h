#ifndef KERNEL_FS_H
#define KERNEL_FS_H

#include <stdint.h>
#include <stddef.h>

/* Deliberately minimal flat filesystem: a fixed-size directory table of
 * named extents (start LBA + size) sitting on top of ata.c. No
 * subdirectories, no free-space bitmap yet -- enough for a shell that
 * can `ls`/`cat`/`write` a handful of files. Replace with something
 * richer (FAT, ext2, a real superblock) once this is proven out. */

#define FS_MAX_NAME  32
#define FS_MAX_FILES 64

typedef struct {
    char     name[FS_MAX_NAME];
    uint32_t start_lba;
    uint32_t size_bytes;
    uint8_t  used;
} fs_entry_t;

/* Reads (or, if absent/invalid, formats) the directory table from disk
 * via ata_read_sectors/ata_write_sectors. */
void fs_init(void);

/* Copies up to max_entries used entries into out_entries, returns count. */
int fs_list(fs_entry_t *out_entries, int max_entries);

/* Returns bytes read, or negative on error (not found / buffer too small). */
int fs_read(const char *name, uint8_t *buffer, size_t buffer_size);

/* Creates or overwrites `name` with `data`. Returns 0 on success. */
int fs_write(const char *name, const uint8_t *data, size_t size);

#endif /* KERNEL_FS_H */
