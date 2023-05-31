/*-*- mode:c;indent-tabs-mode:nil;c-basic-offset:4;tab-width:4;coding:utf-8 -*-│
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2023 Lee Thompson                                                  │
│                                                                              │
│ Permission to use, copy, modify, and/or distribute this software for         │
│ any purpose with or without fee is hereby granted, provided that the         │
│ above copyright notice and this permission notice appear in all copies.      │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL                │
│ WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED                │
│ WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE             │
│ AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         │
│ DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR        │
│ PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER               │
│ TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR             │
│ PERFORMANCE OF THIS SOFTWARE.                                                │
╚─────────────────────────────────────────────────────────────────────────────*/
#include "cosmopolitan.h"
#include "libc/str/tab.internal.h"

/**
 * @fileoverview Code Page 437 Dump
 *
 * Written by Lee Thompson.
 *
 * Inspired by Justine Tunney <jtunney@gmail.com>
 * https://twitter.com/justinetunney
 *
 * See also `hexdump -C`.
 */


int main (int argc, char *argv[])
{
    size_t address;
    FILE *fd;

    /* Track if one or more 'rows' were filled with all-zeros. The first
       row of output is printed unconditionally even if it is all zeros. */
    bool rowWasZero = false;
    uint8_t zeroTestByte;

    /* Buffer (+ ptr) for displaying glyphs on right side of output. */
    wchar_t glyphs[17];
    wchar_t *glyphBufPtr;

    /* Buffer (+ ptr) for displaying bytes of binary in middle of output. */
    char hexBytes[50];
    char *hexBufPtr;

    /* If no filename supplied, read input from stdin, else read first arg. */
    fd = (argc > 1) ? fopen(argv[1], "r") : stdin;

    if (NULL == fd)
    {
        /* Error out in case of bad cmdline file input. */
        fprintf(stderr, "ERROR: COULD NOT OPEN: %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    /* Loop over binary bytes. */
    for (address = 0;;)
    {
        /* Read bytes from input file into buffer. */
        uint8_t rawBytes[16];
        int bytesRead = fread(rawBytes, sizeof(uint8_t), 16, fd);

        /* `fread` will return 0 bytes read on error/eof. */
        if (0 == bytesRead)
        {
            break;
        }

        /* Point to start of hex/glyph display buffers. */
        hexBufPtr   = hexBytes;
        glyphBufPtr = glyphs;

        zeroTestByte = 0;

        /* Iterate over chunk of bytes read in. */
        for (int rowIdx = 0; rowIdx < bytesRead; ++rowIdx)
        {
            /* Visual separator to break up 'words' in byte display */
            if (8 == rowIdx)
            {
                *hexBufPtr++ = ' ';
            }

            /* Format current byte into [0-9a-f] for display. */
            *hexBufPtr++ = "0123456789abcdef"[(rawBytes[rowIdx] & 0xF0) >> 4];
            *hexBufPtr++ = "0123456789abcdef"[(rawBytes[rowIdx] & 0x0F) >> 0];
            *hexBufPtr++ = ' ';

            /* Lookup glyph in table, copy into glyph buffer. */
            *glyphBufPtr++ = kCp437[rawBytes[rowIdx] & 255];

            /* This functions as a pseudo-popcount over the read in 'row'.
               If any byte in a row is non-zero, this byte will not be zero. */
            zeroTestByte |= rawBytes[rowIdx];
        }

        /* If line had non-zero content (or start of file was all-zero),
           reset buffer pointers and display row address/bytes/glyphs. */
        if ((0 != zeroTestByte) || (0 == address))
        {
            *hexBufPtr = 0;
            *glyphBufPtr = 0;
            rowWasZero = false;

            printf("%08x  %-49s │%ls│\n", address, hexBytes, glyphs);
        }
        else if (!rowWasZero)
        {
            /* If test byte was zero and not at start of file, record a
               zero-row and printf an asterisk indicator. If subsequent
               rows are all zero also another asterisk won't be printed*/
            rowWasZero = true;
            printf("*\n");
        }

        address += bytesRead;
    }

    /* Print address of eof. */
    if (0 != address)
    {
        printf("%08x\n", address);
    }

    /* If some error happened, the file descriptor's 'read head' won't be
       EOF. In this case, exit non-zero. */
    return (0 != feof(fd)) ? EXIT_SUCCESS : EXIT_FAILURE;
}
