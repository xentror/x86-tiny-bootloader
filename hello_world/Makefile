CC = nasm
CFLAGS = -f bin
SRC = boot.asm

all: hello-boot

hello-boot:
	${CC} ${CFLAGS} ${SRC} -o $@.com

run: hello-boot
	qemu-system-i386 -fda hello-boot.com

clean:
	${RM} hello-boot.com

.phony: clean all
