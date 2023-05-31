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
    long address;
    FILE *fd;

    int rowWasZero;
    int zeroTestByte;
    int rowIdx;
    int bytesRead;

    wchar_t glyphs[17];
    wchar_t *glyphBufPtr;

    char rawBytes[16];

    char hexBytes[50];
    char *hexBufPtr;

    fd = argc > 1 ? fopen(argv[1], "r") : stdin;

    if (NULL == fd)
    {
        fprintf(stderr, "ERROR: COULD NOT OPEN: %s\n", argv[1]);
        return 1;
    }

    rowWasZero = 0;
    for (address = 0;;)
    {
        bytesRead = fread(rawBytes, 1, 16, fd);

        if (0 == bytesRead)
        {
            break;
        }

        hexBufPtr = hexBytes;
        glyphBufPtr = glyphs;


        zeroTestByte = 0;
        for (rowIdx = 0; rowIdx < bytesRead; ++rowIdx)
        {
            if (8 == rowIdx)
            {
                *hexBufPtr++ = ' ';
            }

            *hexBufPtr++ = "0123456789abcdef"[(rawBytes[rowIdx] & 0xF0) >> 4];
            *hexBufPtr++ = "0123456789abcdef"[(rawBytes[rowIdx] & 0x0F) >> 0];
            *hexBufPtr++ = ' ';

            *glyphBufPtr++ = kCp437[rawBytes[rowIdx] & 255];
            zeroTestByte |= rawBytes[rowIdx];
        }

        if ((0 != zeroTestByte) || (0 == address))
        {
            *hexBufPtr = 0;
            *glyphBufPtr = 0;
            rowWasZero = 0;

            printf("%08x  %-49s │%ls│\n", address, hexBytes, glyphs);
        }
        else if (!rowWasZero)
        {
            rowWasZero = 1;
            printf("*\n");
        }

        address += bytesRead;
    }

    if (0 != address)
    {
        printf("%08x\n", address);
    }

    return (0 != feof(fd)) ? EXIT_SUCCESS : EXIT_FAILURE;
}
