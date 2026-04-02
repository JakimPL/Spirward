#!/bin/bash
# Parse NASM listing file and add instruction sizes

if [ -z "$1" ]; then
    echo "Usage: $0 <listing-file>"
    exit 1
fi

# Process the file and save to temp, then replace original
awk '
{
    # Match lines with line number in first field
    if ($1 ~ /^[0-9]+$/ || $1 ~ /^<[0-9]+>$/) {
        linenum = $1

        # Check if this line has offset and machine code
        # Machine code can contain hex digits and square brackets for addresses
        if ($2 ~ /^[0-9A-F]{8}$/ && $3 ~ /^[0-9A-F\[\]]+$/) {
            # Check if field 3 is not a tag like <1>
            if ($3 !~ /^<.*>$/) {
                # Line with instruction
                offset = $2
                machinecode = $3

                # Calculate size from all hex digits (remove brackets but keep the hex inside)
                hexonly = machinecode
                gsub(/[\[\]]/, "", hexonly)
                size = length(hexonly) / 2

                # Extract source code (everything after machine code)
                source = ""
                for (i = 4; i <= NF; i++) {
                    source = source (i > 4 ? " " : "") $i
                }

                printf "%6s %3d  %s  %-20s  %s\n", linenum, size, offset, machinecode, source
                next
            }
        }

        # Line with offset but no machine code (label or directive)
        if ($2 ~ /^[0-9A-F]{8}$/) {
            offset = $2
            source = ""
            for (i = 3; i <= NF; i++) {
                source = source (i > 3 ? " " : "") $i
            }
            printf "%6s   -  %s  %-20s  %s\n", linenum, offset, "", source
        }
        else {
            # Line with no offset (directive, comment, blank)
            rest = ""
            for (i = 2; i <= NF; i++) {
                rest = rest (i > 2 ? " " : "") $i
            }
            printf "%6s   -  %-10s%-20s  %s\n", linenum, "", "", rest
        }
    }
    else {
        # Non-numbered lines - print as-is
        print
    }
}
' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
