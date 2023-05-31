MAIN=exd.c
BIN=exd.com
COSMO_SUBDIR=cosmopolitan
COSMO_MODE=tinylinux
COSMO_MAKE_ARGS=-j16 m=$(COSMO_MODE)

all: $(MAIN) cosmopolitan-libc
	@gcc -g -Os -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone \
	  -fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs \
	  -gdwarf-4 \
	  -o $(BIN).dbg $(MAIN) -fuse-ld=bfd -Wl,-T,$(COSMO_SUBDIR)/o/$(COSMO_MODE)/ape/ape.lds -Wl,--gc-sections \
	  -I$(COSMO_SUBDIR) \
	  -I$(COSMO_SUBDIR)/o \
	  -I$(COSMO_SUBDIR)/o/$(COSMO_MODE) \
	  -include	$(COSMO_SUBDIR)/o/cosmopolitan.h \
				$(COSMO_SUBDIR)/o/$(COSMO_MODE)/libc/crt/crt.o \
				$(COSMO_SUBDIR)/o/$(COSMO_MODE)/ape/ape-no-modify-self.o \
				$(COSMO_SUBDIR)/o/$(COSMO_MODE)/cosmopolitan.a
	objcopy -S -O binary $(BIN).dbg $(BIN)


cosmopolitan-libc:
	@cd $(COSMO_SUBDIR) && ./build/bootstrap/make.com $(COSMO_MAKE_ARGS) \
		o/cosmopolitan.h \
		o/$(COSMO_MODE)/libc/crt/crt.o \
		o/$(COSMO_MODE)/ape/ape-no-modify-self.o \
		o/$(COSMO_MODE)/cosmopolitan.a \
		o/$(COSMO_MODE)/ape/ape.lds

clean:
	rm $(BIN)
	rm $(BIN).dbg
	rm -r $(COSMO_SUBDIR)/o
