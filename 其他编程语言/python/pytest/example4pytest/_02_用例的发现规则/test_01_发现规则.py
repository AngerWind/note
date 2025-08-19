from _01_hello_world import my_math


# 以test_开头的函数, 是测试用例
def test_add():
    assert my_math.add(1, 2) == 3


def add1():
    assert my_math.add(4, 2) == 6

# 以test_开头的变量, 并且是可调用的, 是测试用例
test_add1 = add1

# 以Test开头的类, 他的以test_开头的方法, 是测试用例
class TestAdd:
    def test_add1(self):
        assert my_math.add(4, 2) == 6