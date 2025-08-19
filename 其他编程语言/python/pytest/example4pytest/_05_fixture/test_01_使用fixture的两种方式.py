from datetime import datetime
from typing import Any, Generator

import pytest


@pytest.fixture
def f() -> Generator[None, Any, None]:
    # 前置操作
    print("开始执行函数", datetime.now())

    yield

    # 后置操作
    print("结束测试用例", datetime.now())


# 通过参数来指定需要使用的fixture
def test_1(f) -> None:
    pass

# 或者通过装饰器来指定要使用的fixture
@pytest.mark.usefixtures("f")
def test_2() -> None:
    pass