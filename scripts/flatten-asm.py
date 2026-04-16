#!/usr/bin/env python3

from flatten.constants import BASE_PATH, INPUT_FILE, MACROS_TO_INLINE, OUTPUT_FILE
from flatten.formatter import OutputFormatter
from flatten.macro import MacroInliner
from flatten.processor import AsmProcessor


def main() -> None:
    processor = AsmProcessor(BASE_PATH)
    result = processor.process_file(INPUT_FILE)

    inliner = MacroInliner(MACROS_TO_INLINE)
    inlined = inliner.process_lines(result)

    formatter = OutputFormatter(inlined)
    formatted = formatter.format()

    OUTPUT_FILE.write_text("\n".join(formatted) + "\n")
    print(f"Generated {OUTPUT_FILE} ({len(formatted)} lines)")


if __name__ == "__main__":
    main()
