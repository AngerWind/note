from datetime import datetime
from typing import Any, Generator

import pytest



@pytest.fixture(scope="session")
def f1() -> Generator[list[object], Any, None]:
    print("开始执行函数1", datetime.now())
    yield []
    print("结束测试用例1", datetime.now())



def test_1(f1) -> None:
    print(f1)
    f1+=1
    pass

def test_2(f1) -> None:
    print(f1)
    f1+=2
    pass

def test_3(f1) -> None:
    print(f1)
    pass