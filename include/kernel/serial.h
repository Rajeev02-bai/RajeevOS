#ifndef KERNEL_SERIAL_H
#define KERNEL_SERIAL_H

/* Debug/log output over COM1 (0x3F8) -- invaluable with QEMU's
 * `-serial stdio` / `-serial file:...` for logging before VGA is up
 * and for tracing crashes. */

void serial_init(void);
void serial_write(char c);
void serial_write_string(const char *str);
int  serial_received(void);   /* 1 if a byte is waiting to be read */
int  serial_read(void);       /* blocking read of one byte */

#endif /* KERNEL_SERIAL_H */
