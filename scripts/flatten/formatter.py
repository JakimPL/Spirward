from typing import List

from flatten.constants import GLOBAL


class OutputFormatter:
    def __init__(self, lines: List[str]) -> None:
        self.lines = lines

    def should_keep_line(self, line: str) -> bool:
        stripped = line.strip()
        if not stripped:
            return True

        first_word = stripped.split()[0] if stripped.split() else ""
        return first_word != GLOBAL

    def is_label(self, line: str) -> bool:
        stripped = line.strip()
        return stripped.endswith(":")

    def is_empty_line(self, line: str) -> bool:
        return not line.strip()

    def format(self) -> List[str]:
        formatted = []
        previous_was_label = False

        for line in self.lines:
            if not self.should_keep_line(line):
                previous_was_label = False
                continue

            if self.is_empty_line(line) and previous_was_label:
                continue

            formatted.append(line)
            previous_was_label = self.is_label(line)

        return formatted
