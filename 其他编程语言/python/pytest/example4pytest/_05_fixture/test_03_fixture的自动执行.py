from datetime import datetime
from typing import Any, Generator

import pytest


@pytest.fixture(autouse=True)
def f1() -> Generator[None, Any, None]:
    # 前置操作
    print("开始执行函数1", datetime.now())

    yield

    # 后置操作
    print("结束测试用例1", datetime.now())


def test_1() -> None:
    pass

def test_2() -> None:
    pass