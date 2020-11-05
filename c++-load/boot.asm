section .boot
bits 16

global boot
extern print_hello
boot:
    ; load second sector in memory -- 0x7e00
    mov ah, 0x02
    mov al, 0x6
    mov ch, 0x0
    mov cl, 0x2
    mov dh, 0x0
    mov bx, second_sector ; write at 512 bytes after 0x7c00
    int 0x13
    jmp second_sector

times  510-($-$$) db 0
dw 0xAA55

second_sector:
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
    jmp CODE_SEGMENT: boot2

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
gdt_descriptor dw gdt_end - gdt_start
gdt_ptr dd gdt_start ; pointeur to start of gdt
CODE_SEGMENT equ gdt_code - gdt_start
DATA_SEGMENT equ gdt_data - gdt_start

bits 32

boot2:
    ; Replace segment with correct entry in the gdt
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebx, 0xB8000
    mov edx, msg

    ; write a char to vga text buffer
print_msg:
    mov al, [edx]
    or al, al
    jz call_kernel

    mov ah, 0x02
    mov word [ebx], ax
    add edx, 1
    add ebx, 2
    jmp print_msg

call_kernel:
    mov esp, kernel_stack_top
    call print_hello

halte:
    cli
    hlt

msg: db "Vas niquer ta mere !"
msg_end: db 0

times 1024 - ($-$$) db 0

section .bss
align 4
kernel_stack_bottom: equ $
     resb 0x1000
kernel_stack_top:
