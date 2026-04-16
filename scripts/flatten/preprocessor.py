from typing import List

from flatten.constants import Directive


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
