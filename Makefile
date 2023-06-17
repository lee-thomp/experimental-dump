#═══╡ -*-mode:makefile-gmake;indent-tabs-mode:t;tab-width:8;coding:utf-8-*- ╞═══

COSMO_ROOT=$(shell pwd)/cosmopolitan
COSMO_MODE=tinylinux
COSMO_MAKE_ARGS=-j16 m=$(COSMO_MODE)

# Required for compile as per [[https://github.com/jart/cosmopolitan#getting-started]].
COSMO_REQUIRED=	$(COSMO_ROOT)/o/cosmopolitan.h \
		$(COSMO_ROOT)/o/$(COSMO_MODE)/libc/crt/crt.o \
		$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape-no-modify-self.o \
		$(COSMO_ROOT)/o/$(COSMO_MODE)/cosmopolitan.a \
		$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape.lds

# Makes source file #includes more ergonomic.
INCL_DIRS=	-I$(COSMO_ROOT) \
	  	-I$(COSMO_ROOT)/o \
	  	-I$(COSMO_ROOT)/o/$(COSMO_MODE) \
	  	-include $(COSMO_ROOT)/o/cosmopolitan.h

CFLAGS=	-g -Os -fno-omit-frame-pointer -fdata-sections -ffunction-sections \
		-fno-pie -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4

LDFLAGS=	-static -no-pie -nostdlib -fuse-ld=bfd -Wl,-melf_x86_64 \
		-Wl,--gc-sections -Wl,-z,max-page-size=0x1000 \
		-Wl,-T,$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape.lds \
			$(COSMO_ROOT)/o/$(COSMO_MODE)/ape/ape-no-modify-self.o \
			$(COSMO_ROOT)/o/$(COSMO_MODE)/libc/crt/crt.o

#════════════════════╡ Experimental Hexdump (Default Target) ╞══════════════════
exd.com: exd.com.dbg
	objcopy -S -O binary $< $@

exd.com.dbg: exd.o $(COSMO_REQUIRED)
	gcc $(CFLAGS) -o $@ $< $(LDFLAGS) $(INCL_DIRS) \
	  $(COSMO_ROOT)/o/$(COSMO_MODE)/cosmopolitan.a

exd.o: exd.c $(COSMO_ROOT)/o/cosmopolitan.h
	gcc -c $(CFLAGS) -o $@ $< $(INCL_DIRS)

$(COSMO_REQUIRED):
	cd cosmopolitan && \
	  ./build/bootstrap/make.com $(COSMO_MAKE_ARGS) \
	  $(patsubst $(COSMO_ROOT)/%,%,$@)

clean-exd:
	rm -f exd.o
	rm -f exd.com.dbg
	rm -f exd.com

#═════════════════════════════╡ Generate All-Zeros ╞════════════════════════════
gen-zeros: utils/gen-zeros.com

utils/gen-zeros.com: utils/gen-zeros/gen-zeros.com.dbg
	objcopy -S -O binary $< $@

utils/gen-zeros/gen-zeros.com.dbg: utils/gen-zeros/gen-zeros.o $(COSMO_REQUIRED) 
	gcc $(CFLAGS) -o $@ $< $(LDFLAGS) $(INCL_DIRS) \
	  $(COSMO_ROOT)/o/$(COSMO_MODE)/cosmopolitan.a

utils/gen-zeros/gen-zeros.o:	utils/gen-zeros/gen-zeros.c \
				$(COSMO_ROOT)/o/cosmopolitan.h
	gcc -c $(CFLAGS) -o $@ $< $(INCL_DIRS)

clean-gen-zeros:
	rm -f utils/gen-zeros/gen-zeros.o
	rm -f utils/gen-zeros/gen-zeros.com.dbg
	rm -f utils/gen-zeros.com

#══════════════════════════════╡ Clean Everything ╞═════════════════════════════
clean: clean-exd clean-gen-zeros
	rm -rf $(COSMO_ROOT)/o
