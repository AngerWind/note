import csv
from typing import List

import pytest

from _01_hello_world import my_math


def read_csv(path: str) -> List[List[str]]:
    with open(path) as csvfile:
        reader = list(csv.reader(csvfile))[1:]
        return reader

class TestDataDriverTest:

    @pytest.mark.parametrize("a,b,c", read_csv("data/data.csv"))
    def test_add1(self, a: str, b: str, c: str):
        assert my_math.add(int(a), int(b)) == int(c)