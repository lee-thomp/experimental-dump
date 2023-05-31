MAIN=exd.c
BIN=exd.com
COSMO_SUBDIR=cosmopolitan
COSMO_MODE=tinylinux
COSMO_MAKE_ARGS=-j16 m=${COSMO_MODE}

cosmopolitan.h:
	cd ${COSMO_SUBDIR} && ./build/bootstrap/make.com ${COSMO_MAKE_ARGS} o/cosmopolitan.h

cosmopolitan.a:
	cd ${COSMO_SUBDIR} && ./build/bootstrap/make.com ${COSMO_MAKE_ARGS} o/${COSMO_MODE}/cosmopolitan.a

ape.lds:
	cd ${COSMO_SUBDIR} && ./build/bootstrap/make.com ${COSMO_MAKE_ARGS} o/${COSMO_MODE}/ape/ape.lds

ape-no-modify-self.o:
	cd ${COSMO_SUBDIR} && ./build/bootstrap/make.com ${COSMO_MAKE_ARGS} o/${COSMO_MODE}/ape/ape-no-modify-self.o

crt.o:
	cd ${COSMO_SUBDIR} && ./build/bootstrap/make.com ${COSMO_MAKE_ARGS} o/${COSMO_MODE}/libc/crt/crt.o

all: ${MAIN} cosmopolitan.h cosmopolitan.a ape.lds ape-no-modify-self.o crt.o
	gcc -g -Os -static -nostdlib -nostdinc -fno-pie -no-pie -mno-red-zone \
	  -fno-omit-frame-pointer -pg -mnop-mcount -mno-tls-direct-seg-refs -gdwarf-4 \
	  -o ${BIN}.dbg ${MAIN} -fuse-ld=bfd -Wl,-T,${COSMO_SUBDIR}/o/${COSMO_MODE}/ape/ape.lds -Wl,--gc-sections \
	  -I${COSMO_SUBDIR} \
	  -I${COSMO_SUBDIR}/o \
	  -I${COSMO_SUBDIR}/o/${COSMO_MODE} \
	  -include ${COSMO_SUBDIR}/o/cosmopolitan.h \
		${COSMO_SUBDIR}/o/${COSMO_MODE}/libc/crt/crt.o \
		${COSMO_SUBDIR}/o/${COSMO_MODE}/ape/ape-no-modify-self.o \
		${COSMO_SUBDIR}/o/${COSMO_MODE}/cosmopolitan.a 
	objcopy -S -O binary ${BIN}.dbg ${BIN}

clean:
	rm ${BIN}
	rm ${BIN}.dbg
	rm -r ${COSMO_SUBDIR}/o
