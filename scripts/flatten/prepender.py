from pathlib import Path
from typing import List


class HeaderPrepender:
    def __init__(self, header_file: Path) -> None:
        self.header_file = header_file

    def prepend(self, lines: List[str]) -> List[str]:
        if not self.header_file.exists():
            return lines

        header_content = self.header_file.read_text().splitlines()
        result = []
        result.extend(header_content)
        result.append("")
        result.extend(lines)

        return result
