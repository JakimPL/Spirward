from typing import List


class OutputFormatter:
    def __init__(self, lines: List[str]) -> None:
        self.lines = lines

    def format(self) -> List[str]:
        formatted = []
        for line in self.lines:
            formatted.append(line)

        return formatted
