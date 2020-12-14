bits 16

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

    ; calculate the physical address of gdt
    xor eax, eax
    mov ax, ds ; load the ds content
    shl eax, 4 ; mult by 16, convert to physical addr -> shift of 4
    add ax, gdt_start
    mov [gdt_ptr], eax

    ; load gdt descriptor in gdtr
    lgdt  [gdt_descriptor]
    ; set protected mode bit in cr0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Jump to 32bit code - relatif to new code segment
    jmp CODE_SEGMENT: 0x7c00 + boot2

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
gdt_ptr dd 0 ; pointeur to start of gdt -> will be update later
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
    mov edx, msg + 0x7c00

    ; write a char to vga text buffer
print_msg:
    mov al, [edx]
    or al, al
    jz halte

    mov ah, 0x02
    mov word [ebx], ax
    add edx, 1
    add ebx, 2
    jmp print_msg

halte:
    cli
    hlt

msg: db "Hey You ! :)"
msg_end: db 0

times  510-($-$$) db 0
dw 0xAA55
