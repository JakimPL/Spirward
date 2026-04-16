#!/usr/bin/env python3

from flatten.constants import BASE_PATH, HEADER_FILE, INPUT_FILE, MACROS_TO_INLINE, OUTPUT_FILE
from flatten.formatter import OutputFormatter
from flatten.macro import MacroInliner
from flatten.prepender import HeaderPrepender
from flatten.processor import AsmProcessor
from flatten.reorganizer import AsmReorganizer


def main() -> None:
    processor = AsmProcessor(BASE_PATH)
    result = processor.process_file(INPUT_FILE)

    inliner = MacroInliner(MACROS_TO_INLINE)
    inlined = inliner.process_lines(result)

    reorganizer = AsmReorganizer()
    reorganized = reorganizer.reorganize(inlined)

    formatter = OutputFormatter(reorganized)
    formatted = formatter.format()

    prepender = HeaderPrepender(HEADER_FILE)
    final = prepender.prepend(formatted)

    OUTPUT_FILE.write_text("\n".join(final) + "\n")
    print(f"Generated {OUTPUT_FILE} ({len(final)} lines)")


if __name__ == "__main__":
    main()
