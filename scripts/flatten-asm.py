#!/usr/bin/env python3

from enum import Enum
from pathlib import Path
from typing import Final, List, Optional

BASE_PATH: Final[Path] = Path(__file__).parent.parent
INPUT_FILE: Final[Path] = BASE_PATH / "main.asm"
OUTPUT_FILE: Final[Path] = BASE_PATH / "spirward.asm"


class Directive(Enum):
    IFDEF = "ifdef"
    IFNDEF = "ifndef"
    ELSE = "else"
    ENDIF = "endif"


class PreprocessorBlock:
    def __init__(self, directive: Directive, symbol: str, parent_active: bool) -> None:
        self.directive = directive
        self.symbol = symbol
        self.parent_active = parent_active
        self.in_else = False
        self.was_active = self.compute_active()

    def compute_active(self) -> bool:
        if not self.parent_active:
            return False

        is_defined = self.symbol in {"COM", "DOS"}

        match self.directive:
            case Directive.IFDEF:
                return is_defined
            case Directive.IFNDEF:
                return not is_defined
            case _:
                return False

    def get_active(self) -> bool:
        if self.in_else:
            return self.parent_active and not self.was_active

        return self.was_active


class PreprocessorState:
    def __init__(self) -> None:
        self.block_stack: List[PreprocessorBlock] = []

    def should_keep_line(self) -> bool:
        for block in self.block_stack:
            if not block.get_active():
                return False

        return True

    def push_block(self, directive: Directive, symbol: str) -> None:
        parent_active = self.should_keep_line()
        block = PreprocessorBlock(directive, symbol, parent_active)
        self.block_stack.append(block)

    def handle_else(self) -> None:
        if self.block_stack:
            self.block_stack[-1].in_else = True

    def pop_block(self) -> None:
        if self.block_stack:
            self.block_stack.pop()


class AsmProcessor:
    def __init__(self, base_path: Path) -> None:
        self.base_path = base_path
        self.state = PreprocessorState()

    def resolve_path(self, include_path: str) -> Path:
        return self.base_path / include_path

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

        match True:
            case _ if stripped.startswith("%include"):
                return self.handle_include(stripped)
            case _ if stripped.startswith("%ifdef"):
                return self.handle_ifdef(stripped)
            case _ if stripped.startswith("%ifndef"):
                return self.handle_ifndef(stripped)
            case _ if stripped.startswith("%else"):
                return self.handle_else()
            case _ if stripped.startswith("%endif"):
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


class OutputFormatter:
    def __init__(self, lines: List[str]) -> None:
        self.lines = lines

    def format(self) -> List[str]:
        formatted = []
        for line in self.lines:
            formatted.append(line)

        return formatted


def main() -> None:
    processor = AsmProcessor(BASE_PATH)
    result = processor.process_file(INPUT_FILE)

    formatter = OutputFormatter(result)
    formatted = formatter.format()

    OUTPUT_FILE.write_text("\n".join(formatted) + "\n")
    print(f"Generated {OUTPUT_FILE} ({len(formatted)} lines)")


if __name__ == "__main__":
    main()
