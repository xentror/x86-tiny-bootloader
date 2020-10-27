bits 16
org 0x7C00

; Declare GDT struct
; here access contain s16_19 and access ( 4 + 4 bits)
struc GDT_STR
    s0_15   resw    1
    b0_15   resw    1
    b16_23  resb    1
    flags   resb    1
    access  resb    1
    b24_31  resb    1
endstruc

; GDT initialization
gdt_start:
dq 0 ; Put the NULL struct at index 0
gdt_code istruc GDT_STR ; GDT code segment descriptor
    at s0_15,   dw  0xFFFF
    at b0_15,   dw  0x0
    at b16_23,  db  0x0
    at flags,   db  10011010b
    at access,  db  11001111b
    at b24_31,  db  0x0
iend
gdt_data istruc GDT_STR ; GDT data segment descriptor
    at s0_15,   dw  0xFFFF
    at b0_15,   dw  0x0
    at b16_23,  db  0x0
    at flags,   db  10010010b
    at access,  db  11001111b
    at b24_31,  db  0x0
iend
gdt_end:

; gdt size and pointer to load
gdt_descriptor:
    dw gdt_end - gdt_start
    dd gdt_start
CODE_SEGMENT equ gdt_code - gdt_start
DATA_SEGMENT equ gdt_data - gdt_start

_start:
    mov ax, 0x7C0
    mov ds, ax ; put data segment at same address as cs
    mov es, ax ; put extra segment at same address as cs
    mov ax, 0x7E0 ; create stack 512 bytes after cs -- next sector
    mov ss, ax

    mov sp, 0x2000 ; instanciante stack pointer

    call clear_window

    ; Enable A20 bits
    mov ax, 0x2401
    int 0x15

    ; load gdt descriptor in gdtr
    lgdt  [gdt_descriptor]
    ; set protected mode bit in cr0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    ; Jump to 32bit code - relatif to new code segment
    jmp CODE_SEGMENT:boot2

clear_window:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07
    xor al, al
    mov bh, 0x07
    mov ch, 0x0
    mov cl, 0x0
    mov dh, 0x18
    mov dl, 0x4f
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

msg: db "Vas niquer ta mere !"
msg_end: db 0

bits 32
boot2:
    ; Replace segment with correct entry in the gdt
    mov eax, DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    hlt

times  510-($-$$) db 0
dw 0xAA55