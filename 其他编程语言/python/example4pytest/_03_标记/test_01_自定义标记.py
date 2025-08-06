import pytest

from _01_hello_world import my_math



@pytest.mark.api
def test_add():
    assert my_math.add(1, 2) == 3


class TestAdd:
    @pytest.mark.web
    def test_add1(self):
        assert my_math.add(4, 2) == 6

    @pytest.mark.login
    def test_add1(self):
        assert my_math.add(4, 2) == 6