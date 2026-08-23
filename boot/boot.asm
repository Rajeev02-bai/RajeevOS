; ============================================================================
; boot.asm - Stage 1 bootloader (Master Boot Record)
;
; Loaded by the BIOS at 0x0000:0x7C00 in 16-bit real mode. Its only job is
; to load Stage 2 from disk (the sectors immediately following this one)
; and jump to it. Must fit in 512 bytes and end with the 0xAA55 signature.
;
; Assumes disk access via INT13h extensions (LBA), which QEMU's virtual
; BIOS supports for both floppy and hard-disk-style images.
; ============================================================================
 
BITS 16
ORG 0x7C00
 
STAGE2_LOAD_SEG   equ 0x0000
STAGE2_LOAD_OFF   equ 0x7E00     ; stage2 is loaded right after this sector
STAGE2_START_LBA  equ 1          ; LBA 0 = this MBR sector, so stage2 starts at LBA 1
STAGE2_SECTORS    equ 8          ; 8 sectors = 4KB reserved for stage2
                                  ;must match STAGE2_SECTORS in stage2.asm
                                  ; and however your Makefile lays out the disk image.
 
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
 
    mov [boot_drive], dl         ; BIOS passes boot drive number in DL
 
    mov si, msg_loading
    call print_string
 
    ; Load stage2 using INT13h extended read (LBA-based)
    mov ah, 0x42
    mov dl, [boot_drive]
    mov si, dap
    int 0x13
    jc disk_error
 
    mov si, msg_jump
    call print_string
 
    jmp STAGE2_LOAD_SEG:STAGE2_LOAD_OFF
 
; ----------------------------------------------------------------------------
disk_error:
    mov si, msg_error
    call print_string
    jmp $
 
; ----------------------------------------------------------------------------
; print_string - prints a null-terminated string via BIOS teletype (INT10h)
; in:  SI = pointer to string
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp print_string
.done:
    ret
 
; ----------------------------------------------------------------------------
boot_drive: db 0
 
; Disk Address Packet (DAP) for INT13h/AH=42h extended read
dap:
    db 0x10                       ; size of packet
    db 0                          ; reserved
    dw STAGE2_SECTORS             ; number of sectors to read
    dw STAGE2_LOAD_OFF            ; destination offset
    dw STAGE2_LOAD_SEG            ; destination segment
    dq STAGE2_START_LBA           ; starting LBA
 
msg_loading db "boot: loading stage2...", 13, 10, 0
msg_jump    db "boot: jumping to stage2", 13, 10, 0
msg_error   db "boot: disk read error!", 13, 10, 0
 
times 510 - ($ - $$) db 0
dw 0xAA55
