import argparse
import math
from dataclasses import dataclass, field
from typing import Final, Tuple

I_MIN: Final[int] = 40
I_MAX: Final[int] = 200
FOCAL_LENGTH: Final[float] = 180.0

MIN_VALUE: Final[float] = 1.0
MAX_VALUE: Final[float] = 12.0  # 255 / 5


@dataclass
class Constants:
    i_min: int = I_MIN
    i_max: int = I_MAX
    focal_length: float = FOCAL_LENGTH

    u_min: float = field(init=False)
    u_max: float = field(init=False)

    def calculate_u(self, i: int) -> float:
        return math.pi / i * self.focal_length

    def __post_init__(self) -> None:
        self.u_min = self.calculate_u(self.i_max)
        self.u_max = self.calculate_u(self.i_min)
        print(f"Calculated constants:\nu_min: {self.u_min}\nu_max: {self.u_max}")

    def calculate_attenuation_factors(
        self,
        min_value: float,
        max_value: float,
    ) -> Tuple[float, float]:
        difference = 1 / min_value - 1 / max_value
        b = (self.u_max - self.u_min) / difference
        a = b / min_value - self.u_max
        return a, b


def parse_arguments() -> Tuple[Constants, float, float]:
    parser = argparse.ArgumentParser(
        description="Calculate constants for the spiral program.",
    )
    parser.add_argument(
        "min_value",
        type=float,
        help="Minimum value for attenuation calculation",
    )
    parser.add_argument(
        "max_value",
        type=float,
        help="Maximum value for attenuation calculation",
    )

    parser.add_argument("--i_min", type=int, default=I_MIN, help="Minimum value of i")
    parser.add_argument("--i_max", type=int, default=I_MAX, help="Maximum value of i")
    parser.add_argument(
        "--focal_length",
        type=float,
        default=FOCAL_LENGTH,
        help="Focal length",
    )

    args = parser.parse_args()
    constants = Constants(
        i_min=args.i_min,
        i_max=args.i_max,
        focal_length=args.focal_length,
    )

    return constants, args.min_value, args.max_value


def main() -> Tuple[float, float]:
    constants, min_value, max_value = parse_arguments()
    return constants.calculate_attenuation_factors(
        min_value,
        max_value,
    )


if __name__ == "__main__":
    a, b = main()
    print(f"Attenuation factors:\na: {a}\nb: {b}")
