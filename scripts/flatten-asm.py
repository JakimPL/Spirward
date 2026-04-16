#!/usr/bin/env python3

from enum import Enum
from pathlib import Path
from typing import Dict, Final, List, Optional, Tuple

BASE_PATH: Final[Path] = Path(__file__).parent.parent
INPUT_FILE: Final[Path] = BASE_PATH / "main.asm"
OUTPUT_FILE: Final[Path] = BASE_PATH / "spirward.asm"
MACROS_TO_INLINE: Final[Tuple[str, ...]] = ()

INCLUDE: Final[str] = "%include"
IFDEF: Final[str] = "%ifdef"
IFNDEF: Final[str] = "%ifndef"
ELSE: Final[str] = "%else"
ENDIF: Final[str] = "%endif"
MACRO: Final[str] = "%macro"
ENDMACRO: Final[str] = "%endmacro"


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


class OutputFormatter:
    def __init__(self, lines: List[str]) -> None:
        self.lines = lines

    def format(self) -> List[str]:
        formatted = []
        for line in self.lines:
            formatted.append(line)

        return formatted


class MacroDefinition:
    def __init__(self, name: str, param_count: int) -> None:
        self.name = name
        self.param_count = param_count
        self.body: List[str] = []

    def add_line(self, line: str) -> None:
        self.body.append(line)

    def expand(self, args: List[str]) -> List[str]:
        expanded = []
        for line in self.body:
            expanded_line = line
            for i, arg in enumerate(args, start=1):
                expanded_line = expanded_line.replace(f"%{i}", arg)
            expanded.append(expanded_line)

        return expanded


class MacroInliner:
    def __init__(self, macros_to_inline: Tuple[str, ...]) -> None:
        self.macros_to_inline = set(macros_to_inline)
        self.macros: Dict[str, MacroDefinition] = {}
        self.current_macro: Optional[MacroDefinition] = None

    def get_directive(self, line: str) -> str:
        parts = line.split()
        return parts[0] if parts else ""

    def process_lines(self, lines: List[str]) -> List[str]:
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
            case d if d.startswith(MACRO):
                return self.handle_macro_start(stripped)
            case d if d.startswith(ENDMACRO):
                return self.handle_macro_end()
            case _ if self.current_macro is not None:
                return self.handle_macro_body(line)
            case _:
                return self.handle_macro_invocation(line)

    def handle_macro_start(self, line: str) -> Optional[List[str]]:
        parts = line.split()
        if len(parts) >= 3:
            macro_name = parts[1]
            param_count = int(parts[2])

            if macro_name in self.macros_to_inline:
                self.current_macro = MacroDefinition(macro_name, param_count)
                return []

        return [line]

    def handle_macro_end(self) -> Optional[List[str]]:
        if self.current_macro is not None:
            self.macros[self.current_macro.name] = self.current_macro
            self.current_macro = None
            return []

        return [ENDMACRO]

    def handle_macro_body(self, line: str) -> Optional[List[str]]:
        if self.current_macro is not None:
            self.current_macro.add_line(line)
            return []

        return [line]

    def handle_macro_invocation(self, line: str) -> Optional[List[str]]:
        stripped = line.strip()

        for macro_name, macro_def in self.macros.items():
            if stripped.startswith(macro_name):
                args = self.parse_macro_args(stripped, macro_name)
                if len(args) == macro_def.param_count:
                    return macro_def.expand(args)

        return [line]

    def parse_macro_args(self, line: str, macro_name: str) -> List[str]:
        rest = line[len(macro_name) :].strip()
        if not rest:
            return []

        args = [arg.strip() for arg in rest.split(",")]
        return args


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
