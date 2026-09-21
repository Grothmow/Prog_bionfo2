#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <query file> <subject file> <output file>" >&2
    exit 1
fi

query="$1"
subject="$2"
output="$3"

if [[ ! -f "$query" || ! -r "$query" || ! -f "$subject" || ! -r "$subject" ]]; then
    echo "Error: query and subject must be readable FASTA files." >&2
    exit 1
fi

if [[ "$output" -ef "$query" || "$output" -ef "$subject" ]]; then
    echo "Error: the output must not overwrite either input file." >&2
    exit 1
fi

if ! command -v tblastn >/dev/null 2>&1; then
    echo "Error: tblastn is not installed or is not on PATH." >&2
    exit 1
fi

tblastn -query "$query" -subject "$subject" -outfmt '6 std qlen' |
    awk -F '\t' '$3 > 30 && $4 > 0.90 * $13' > "$output"

wc -l < "$output"
