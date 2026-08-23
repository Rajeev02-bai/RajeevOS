[BITS 16]
[ORG 0x7c00]
 
KERNEL_OFFSET equ 0x1000   ; memory address where the kernel will be loaded
 
start:
    cli
    mov [BOOT_DRIVE], dl   ; BIOS puts boot drive number in dl -- save it NOW
                            ; before it gets overwritten by anything below
 
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
 
    mov si, msg_loading
    call print_string
 
    ; --- load kernel from disk into memory at KERNEL_OFFSET ---
    mov bx, KERNEL_OFFSET   ; ES:BX = destination (ES is 0 from above)
    mov dh, 1               ; number of sectors to read (adjust to kernel size)
    mov dl, [BOOT_DRIVE]      ; which drive to read from
    call disk_load
 
    mov si, msg_jumping
    call print_string
 
    jmp KERNEL_OFFSET         ; hand control over to the kernel
 
print_string:
    mov ah, 0x0E
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

disk_load:
    push dx             ; save DH (sectors requested) to compare after read
 
    mov ah, 0x02        ; BIOS: read sectors function
    mov al, dh          ; number of sectors to read
    mov ch, 0x00         ; cylinder 0
    mov dh, 0x00         ; head 0
    mov cl, 0x02          ; start reading from sector 2 (sector 1 = bootloader)
    int 0x13
 
    jc disk_error         ; carry flag set -> BIOS reported an error
 
    pop dx
    cmp al, dh              ; did we read as many sectors as requested?
    jne disk_error
 
    ret
 
disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $                    ; freeze here so the error is visible
 
; -----------------------------------------------------------
; data
; -----------------------------------------------------------
BOOT_DRIVE:     db 0
msg_loading:    db "Loading kernel...", 0
msg_jumping:    db "Booting kernel...", 0
msg_disk_error: db "Disk read error!", 0
 
; -----------------------------------------------------------
; padding + boot signature
; -----------------------------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
