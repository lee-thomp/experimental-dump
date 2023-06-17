/*bin/echo '-*- mode:sh-mode;indent-tabs-mode:nil;tab-width:4;coding:utf-8  -*-│
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

: "     I use this script to grab the output of the current branch/commit
        I'm working on. This script of course relies on gnome term being
        installed, so if you don't use gnome you'll have to make your own
        script. The resulting screenshot will be dumped into the repo's
        images directory.
"
USAGE=" Usage: (from repo root)
            ./utils/screengrab-example.sh [<command>] [<name-suffix>] \
"

# Images are organised according to working branch. If a different suffix isn't
# specified, the short hash will be used.
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HASH="$(git rev-parse --short HEAD)"

# Set command to run and output file suffix depending on args given:
#   - If no args given, run default demo command with short hash suffix.
#   - If one arg given, assume it's the command to run.
#   - If two args given, run command and replace hash with suffix.
#   - If too many args given, show usage and exit.
case $# in

    0)
        COMMAND='./exd.com ./exd.com | head -n 20'
        SUFFIX=$HASH
        ;;
    1)
        COMMAND=$1
        SUFFIX=$HASH
        ;;
    2)
        COMMAND=$1
        SUFFIX=$2
        ;;
    *)
        echo "$USAGE"
        exit 1
        ;;
esac

# Assemble output filename from branch and hash/suffix. This has the benefit
# that output is automatically dumped into a folder according to the branch
# name 'prefix'.
OUTNAME=./images/screenshots/${BRANCH}-${SUFFIX}.png

# Open a new term with desired geometry, runs program, and captures output.
# `printf`s are required to simulate the look of the program being run from
# the command line, and the prompt left after running the command. I preferred
# the visual look of the command and subsequent output, but also wanted
# automation.
gnome-terminal --geometry=96x24 \
                    -- /usr/bin/sh -c \
                    "printf '$ %s\n' '${COMMAND}'; \
                    ${COMMAND}; \
                    printf '$ '; \
                    gnome-screenshot -w -f \
                    ${OUTNAME}"

# If you don't have your prompt configured to tell you what branch you're on
# (like I do,) it can be useful to echo the location of the generated image.
printf '%s\n' "${OUTNAME}"
