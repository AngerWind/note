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

# 通过在fixture上添加参数, 来指定fixture使用的fixture
# 这样任何的测试用例, 只要使用了f2这个fixture, 都会自动先执行f1, 然后执行f2
@pytest.fixture
def f2(f1) -> Generator[None, Any, None]:
    # 前置操作
    print("开始执行函数2", datetime.now())

    yield

    # 后置操作
    print("结束测试用例2", datetime.now())



def test_1(f2) -> None:
    pass
