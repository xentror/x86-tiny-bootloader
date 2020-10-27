CC = nasm
CFLAGS = -f bin
SRC = boot.asm

all: hello-protected

hello-protected:
	${CC} ${CFLAGS} ${SRC} -o $@.com

run: hello-protected
	qemu-system-i386 -fda hello-protected.com

clean:
	${RM} hello-protected.com

.phony: clean all run
