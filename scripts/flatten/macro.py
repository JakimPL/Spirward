from typing import Dict, List, Optional, Tuple

from flatten.constants import ENDMACRO, MACRO


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
