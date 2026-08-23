; ============================================================================
; stage2.asm - Stage 2 bootloader
;
; Loaded by boot.asm at linear address 0x7E00, still in 16-bit real mode.
; Responsibilities:
;   1. Enable the A20 line.
;   2. Load the kernel binary from disk into a low-memory scratch buffer
;      (real-mode BIOS disk I/O can't address above ~1MB directly).
;   3. Switch to 32-bit protected mode (see switch_pm.asm).
;   4. Copy the kernel image from the scratch buffer up to 0x100000 (1MB).
;   5. Jump to the kernel's entry point (entry32.asm's _start), which the
;      linker script should place at 0x100000.
; ============================================================================
 
BITS 16
ORG 0x7E00
 
KERNEL_LOAD_SEG   equ 0x1000     ; scratch buffer at linear 0x10000
KERNEL_LOAD_OFF   equ 0x0000
KERNEL_START_LBA  equ 9          ; 1 (MBR) + 8 (stage2 sectors) = LBA 9
KERNEL_SECTORS    equ 128        ; 128 * 512 = 64KB max kernel image.
                                  ; NOTE: grow this (and the disk image /
                                  ; Makefile layout) as your kernel grows.
                                  ; Some BIOSes cap a single INT13h/42h read
                                  ; at 127 sectors -- split into two reads
                                  ; if you hit that limit.
KERNEL_PHYS_ADDR  equ 0x100000   ; final kernel location: 1MB
 
start:
    mov [boot_drive], dl
 
    mov si, msg_stage2
    call print_string
 
    call enable_a20
 
    ; Load the kernel image into the low scratch buffer at 0x10000
    mov ah, 0x42
    mov dl, [boot_drive]
    mov si, kernel_dap
    int 0x13
    jc disk_error
 
    mov si, msg_pm
    call print_string
 
    %include "switch_pm.asm"
 
; ----------------------------------------------------------------------------
; Execution resumes here in 32-bit protected mode (jumped to from
; switch_pm.asm's init_pm once segments/stack are set up).
; ----------------------------------------------------------------------------
BITS 32
BEGIN_PM:
    ; Copy the kernel from the scratch buffer (0x10000) up to 1MB.
    mov esi, 0x10000
    mov edi, KERNEL_PHYS_ADDR
    mov ecx, (KERNEL_SECTORS * 512) / 4
    rep movsd
 
    jmp KERNEL_PHYS_ADDR         ; hand off to entry32.asm's _start
 
; ----------------------------------------------------------------------------
; 16-bit real-mode helpers (must stay before the %include switches to BITS 32
; only for the tail end of this file; these run earlier, still in real mode)
; ----------------------------------------------------------------------------
BITS 16
 
enable_a20:
    ; Fast A20 gate method (works under QEMU). Fall back to the keyboard
    ; controller method if you target real/older hardware.
    in al, 0x92
    or al, 2
    out 0x92, al
    ret
 
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
 
disk_error:
    mov si, msg_error
    call print_string
    jmp $
 
boot_drive: db 0
 
kernel_dap:
    db 0x10
    db 0
    dw KERNEL_SECTORS
    dw KERNEL_LOAD_OFF
    dw KERNEL_LOAD_SEG
    dq KERNEL_START_LBA
 
msg_stage2 db "stage2: running...", 13, 10, 0
msg_pm     db "stage2: entering protected mode...", 13, 10, 0
msg_error  db "stage2: disk read error!", 13, 10, 0
 
; Pad stage2 out to a fixed size matching STAGE2_SECTORS (8 * 512 = 4096)
; in boot.asm. Adjust both together if this file grows past that.
times 4096 - ($ - $$) db 0
