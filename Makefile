COSMO_ROOT=$(shell pwd)/cosmopolitan
COSMO_MODE=tinylinux
COSMO_MAKE_ARGS=-j16 m=$(COSMO_MODE)

# Everything required for compile, link etc.
COSMO_REQUIRED=	$(COSMO_ROOT)/o/cosmopolitan.h \
				$(COSMO_ROOT)/o/$(COSMO_MODE)/libc/crt/crt.o \
				$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape-no-modify-self.o \
				$(COSMO_ROOT)/o/$(COSMO_MODE)/cosmopolitan.a \
				$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape.lds

# Required for compile as per [[https://github.com/jart/cosmopolitan#getting-started]].
INCL_REQUIRED=	$(COSMO_ROOT)/o/cosmopolitan.h \
				$(COSMO_ROOT)/o/$(COSMO_MODE)/cosmopolitan.a

# Useful for file-level includes.
INCL_DIRS=	-I$(COSMO_ROOT) \
	  		-I$(COSMO_ROOT)/o \
	  		-I$(COSMO_ROOT)/o/$(COSMO_MODE) \
	  		-include $(INCL_REQUIRED)

CFLAGS=-g -Os -fno-omit-frame-pointer -fdata-sections -ffunction-sections -fno-pie -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4

LDFLAGS=-static -no-pie -nostdlib -fuse-ld=bfd -Wl,-melf_x86_64 -Wl,--gc-sections -Wl,-z,max-page-size=0x1000 -Wl,-T,$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape.lds $(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape-no-modify-self.o $(COSMO_ROOT)/o/$(COSMO_MODE)/libc/crt/crt.o


exd.com: exd.com.dbg
	objcopy -S -O binary $< $@

exd.com.dbg: exd.c $(COSMO_REQUIRED)
	gcc $(CFLAGS) -o $@ $< $(LDFLAGS) $(INCL_DIRS)

$(COSMO_REQUIRED):
	cd cosmopolitan && \
	  ./build/bootstrap/make.com $(COSMO_MAKE_ARGS) \
	  $(patsubst $(COSMO_ROOT)/%,%,$@)

clean:
	rm -rf $(COSMO_ROOT)/o
	rm -f *.com
	rm -f *.com.dbg
