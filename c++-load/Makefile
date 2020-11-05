# VAR

ASSEMBLER = nasm
NASMFLAGS = -f elf
ASM = boot.asm
ASM_OBJS = boot.o

CC = gcc
CFLAGS = -m32 -nostdlib -fno-pic
LDFLAGS = -T linker.ld
C_OBJS = print_hello.o

OBJS = ${C_OBJS} ${ASM_OBJS}

# RULES

all: cpp-load

cpp-load: ${C_OBJS}
	${ASSEMBLER} ${NASMFLAGS} ${ASM} -o boot.o
	${CC} ${CFLAGS} ${LDFLAGS} ${OBJS} -o $@.com

run: cpp-load
	qemu-system-i386 -fda cpp-load.com

clean:
	${RM} cpp-load.com ${OBJS}

.phony: clean all run
