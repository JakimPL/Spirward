from typing import List, Optional

from flatten.constants import ENDMACRO, MACRO


class CodeSection:
    def __init__(self) -> None:
        self.constants: List[str] = []
        self.macros: List[str] = []
        self.defines: List[str] = []
        self.org_directive: Optional[str] = None
        self.rest: List[str] = []


class AsmReorganizer:
    def __init__(self) -> None:
        self.section = CodeSection()
        self.in_macro = False

    def is_constant(self, line: str) -> bool:
        stripped = line.strip()
        return " equ " in stripped or "\tequ " in stripped

    def is_define(self, line: str) -> bool:
        stripped = line.strip()
        return stripped.startswith("%define")

    def is_macro_start(self, line: str) -> bool:
        stripped = line.strip()
        parts = stripped.split()
        return parts[0].startswith(MACRO) if parts else False

    def is_macro_end(self, line: str) -> bool:
        stripped = line.strip()
        parts = stripped.split()
        return parts[0].startswith(ENDMACRO) if parts else False

    def is_section_text(self, line: str) -> bool:
        stripped = line.strip()
        return stripped == "section .text"

    def is_org_directive(self, line: str) -> bool:
        stripped = line.strip()
        return stripped.startswith("org ")

    def categorize_line(self, line: str) -> None:
        if self.is_org_directive(line):
            self.section.org_directive = line
        
        elif self.is_section_text(line):
            pass
        
        elif self.is_macro_start(line):
            self.in_macro = True
            self.section.macros.append(line)
        
        elif self.is_macro_end(line):
            self.section.macros.append(line)
            self.in_macro = False
        
        elif self.in_macro:
            self.section.macros.append(line)
        
        elif self.is_constant(line):
            self.section.constants.append(line)
        
        elif self.is_define(line):
            self.section.defines.append(line)
        
        else:
            self.section.rest.append(line)

    def reorganize(self, lines: List[str]) -> List[str]:
        for line in lines:
            self.categorize_line(line)

        result: List[str] = []

        if self.section.constants:
            result.extend(self.section.constants)
            result.append("")

        if self.section.macros or self.section.defines:
            result.extend(self.section.macros)
            result.extend(self.section.defines)
            result.append("")

        result.append("    section .text")
        if self.section.org_directive:
            result.append(self.section.org_directive)
            result.append("")

        result.extend(self.section.rest)

        return result
