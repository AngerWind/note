from datetime import datetime
from typing import Any, Generator

import pytest


# 定义一个全局可用的fixtures, 他的共享范围是session
# 类似java中的@BeforeAll和@AfterAll
# 他会在当前文件的所有的使用了这个fixtures的测试用例执行之前, 之后执行
@pytest.fixture(scope="session")
def f1() -> Generator[list[object], Any, None]:
    print("开始执行函数1", datetime.now())
    yield []
    print("结束测试用例1", datetime.now())



def test_1(f1) -> None:
    f1.append(1)
    print(f1)
    pass

def test_2(f1) -> None:
    f1.append(2)
    print(f1)
    pass

def test_3(f1) -> None:
    f1.append(3)
    print(f1)
    pass