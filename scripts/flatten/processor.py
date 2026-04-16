from pathlib import Path
from typing import List, Optional

from flatten.constants import ELSE, ENDIF, IFDEF, IFNDEF, INCLUDE, Directive
from flatten.preprocessor import PreprocessorState


class AsmProcessor:
    def __init__(self, base_path: Path) -> None:
        self.base_path = base_path
        self.state = PreprocessorState()

    def resolve_path(self, include_path: str) -> Path:
        return self.base_path / include_path

    def get_directive(self, line: str) -> str:
        parts = line.split()
        return parts[0] if parts else ""

    def process_file(self, file_path: Path) -> List[str]:
        lines = file_path.read_text().splitlines()
        result = []

        for line in lines:
            processed = self.process_line(line)
            if processed is not None:
                result.extend(processed)

        return result

    def process_line(self, line: str) -> Optional[List[str]]:
        stripped = line.strip()
        directive = self.get_directive(stripped)

        match directive:
            case d if d.startswith(INCLUDE):
                return self.handle_include(stripped)
            case d if d.startswith(IFDEF):
                return self.handle_ifdef(stripped)
            case d if d.startswith(IFNDEF):
                return self.handle_ifndef(stripped)
            case d if d.startswith(ELSE):
                return self.handle_else()
            case d if d.startswith(ENDIF):
                return self.handle_endif()
            case _:
                return [line] if self.state.should_keep_line() else []

    def handle_include(self, line: str) -> List[str]:
        if not self.state.should_keep_line():
            return []

        parts = line.split('"')
        if len(parts) >= 2:
            include_path = parts[1]
            full_path = self.resolve_path(include_path)
            if full_path.exists():
                return self.process_file(full_path)

        return []

    def handle_ifdef(self, line: str) -> List[str]:
        parts = line.split()
        symbol = parts[1] if len(parts) > 1 else ""
        self.state.push_block(Directive.IFDEF, symbol)
        return []

    def handle_ifndef(self, line: str) -> List[str]:
        parts = line.split()
        symbol = parts[1] if len(parts) > 1 else ""
        self.state.push_block(Directive.IFNDEF, symbol)
        return []

    def handle_else(self) -> List[str]:
        self.state.handle_else()
        return []

    def handle_endif(self) -> List[str]:
        self.state.pop_block()
        return []
