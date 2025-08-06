from datetime import datetime
from typing import Generator, Any

import pytest


# 定义一个全局可用的fixtures, 他的共享范围是session
# 他会在所有的测试用例之前和之后开始执行
@pytest.fixture(scope="session")
def f1() -> Generator[list[object], Any, None]:
    print("开始执行函数1", datetime.now())
    yield []
    print("结束测试用例1", datetime.now())

# 定义一个全局可用的fixtures, 他的共享范围是function
# 只要测试用例使用了这个fixtures, 那么他会在每个测试用例之前和之后都执行一遍
@pytest.fixture()
def f2() -> Generator[list[object], Any, None]:
    print("开始执行函数1", datetime.now())
    yield []
    print("结束测试用例1", datetime.now())