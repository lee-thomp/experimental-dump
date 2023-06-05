MAIN=exd.c
BIN=exd.com
COSMO_SUBDIR=cosmopolitan
COSMO_MODE=tinylinux
COSMO_MAKE_ARGS=-j16 m=$(COSMO_MODE)

# Required for build as per [[https://github.com/jart/cosmopolitan#getting-started]].
INCL_REQUIRED=	cosmopolitan/o/cosmopolitan.h \
				cosmopolitan/o/$(COSMO_MODE)/cosmopolitan.a

# Useful for file-level includes.
INCL_DIRS=	-Icosmopolitan \
	  		-Icosmopolitan/o \
	  		-Icosmopolitan/o/$(COSMO_MODE) \
	  		-include $(INCL_REQUIRED)

CFLAGS=-g -Os -fno-omit-frame-pointer -fdata-sections -ffunction-sections -fno-pie -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4

LDFLAGS=-static -no-pie -nostdlib -fuse-ld=bfd -Wl,-melf_x86_64 -Wl,--gc-sections -Wl,-z,max-page-size=0x1000 -Wl,-T,cosmopolitan/o/$(COSMO_MODE)/ape/ape.lds cosmopolitan/o/$(COSMO_MODE)/ape/ape-no-modify-self.o cosmopolitan/o/$(COSMO_MODE)/libc/crt/crt.o

all: $(MAIN) cosmopolitan-libc
	@gcc $(CFLAGS) -o $(BIN).dbg $(MAIN) $(LDFLAGS) $(INCL_DIRS)
	objcopy -S -O binary $(BIN).dbg $(BIN)

cosmopolitan-libc:
	@cd cosmopolitan && ./build/bootstrap/make.com $(COSMO_MAKE_ARGS) \
		o/cosmopolitan.h \
		o/$(COSMO_MODE)/libc/crt/crt.o \
		o/$(COSMO_MODE)/ape/ape-no-modify-self.o \
		o/$(COSMO_MODE)/cosmopolitan.a \
		o/$(COSMO_MODE)/ape/ape.lds

clean:
	rm $(BIN)
	rm $(BIN).dbg
	rm -r cosmopolitan/o
