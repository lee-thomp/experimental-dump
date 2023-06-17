/*-*- mode:c;indent-tabs-mode:nil;c-basic-offset:4;tab-width:4;coding:utf-8 -*-│
├──────────────────────────────────────────────────────────────────────────────┤
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
└─────────────────────────────────────────────────────────────────────────────*/
#include "cosmopolitan.h"

/* Display whole code page (0-255) plus a terminating newline. */
#define TESTFILE_LENGTH_bytes (256u + 1u)


int main (int argc, char *argv[])
{
    FILE *fd;

    /* If no filename supplied, read input from stdin, else read first arg. */
    fd = (argc > 1) ? fopen(argv[1], "w") : stdout;

    if (NULL == fd)
    {
        /* Error out in case of bad cmdline file input. */
        fprintf(stderr, "ERROR: COULD NOT OPEN: %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    /* Grab a load of memory. */
    char *rangeBytes = (char *)malloc(TESTFILE_LENGTH_bytes * sizeof(char));

    /* Set the memory to the range 0 to 255. */
    for (int idx = 0; TESTFILE_LENGTH_bytes > idx; ++idx)
    {
		rangeBytes[idx] = idx;
    }

    /* Cap with newline. */
    rangeBytes[TESTFILE_LENGTH_bytes - 1] = '\n';

    /* Exit appropriately if the full length wasn't written. */
    int exitVal =
        (TESTFILE_LENGTH_bytes ==
         fwrite(rangeBytes, sizeof(char), TESTFILE_LENGTH_bytes, fd))
        ? EXIT_SUCCESS
        : EXIT_FAILURE;

    return exitVal;
}
