/*bin/echo '-*- mode:sh-mode;indent-tabs-mode:nil;tab-width:8;coding:utf-8  -*-│
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
└────────────────────────────────────────────────────────────────'>/dev/null #*/

: "	I use this script to grab the output of the current branch/commit
	I'm working on. This script of course relies on gnome term being
	installed, so if you don't use gnome you'll have to make your own
	script. The resulting screenshot will be dumped into the repo's
	images directory.

	Usage: (from repo root)
		./utils/screengrab-example.sh
"

COMMAND="./exd.com ./exd.com | head -n 20"

gnome-terminal --geometry=96x24 \
			   -- /usr/bin/sh -c "echo '$ ${COMMAND}'; \
${COMMAND}; \
echo $; \
gnome-screenshot -w -f ./images/$(git rev-parse --short HEAD)-output.png"
