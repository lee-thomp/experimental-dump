MAIN=exd.c
BIN=exd.com

all: ${MAIN}
	gcc -g -Os -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone \
	  -fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4 \
	  -o ${BIN}.dbg ${MAIN} -fuse-ld=bfd -Wl,-T,cosmopolitan/o/tinylinux/ape/ape.lds -Wl,--gc-sections \
	  -Icosmopolitan \
	  -include cosmopolitan/o/cosmopolitan.h \
		cosmopolitan/o/tinylinux/libc/crt/crt.o \
		cosmopolitan/o/tinylinux/ape/ape-no-modify-self.o \
		cosmopolitan/o/tinylinux/cosmopolitan.a 
	objcopy -S -O binary ${BIN}.dbg ${BIN}
