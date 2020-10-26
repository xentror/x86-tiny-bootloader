CC = nasm
CFLAGS = -f bin
SRC = boot.asm

all: hello-boot

hello-boot:
	${CC} ${CFLAGS} ${SRC} -o $@

run: hello-boot
	qemu-system-i386 -fda hello-boot

clean:
	${RM} hello-boot

.phony: clean all
