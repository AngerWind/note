from datetime import datetime
from typing import Any, Generator

import pytest


@pytest.fixture
def f1() -> Generator[None, Any, None]:
    # 前置操作
    print("开始执行函数1", datetime.now())

    yield

    # 后置操作
    print("结束测试用例1", datetime.now())

@pytest.fixture
def f2() -> Generator[None, Any, None]:
    # 前置操作
    print("开始执行函数2", datetime.now())

    yield

    # 后置操作
    print("结束测试用例2", datetime.now())


# 先执行f1, 然后f2
def test_1(f1, f2) -> None:
    pass

# 先执行f2, 然后执行f1
@pytest.mark.usefixtures("f1")
@pytest.mark.usefixtures("f2")
def test_2() -> None:
    pass