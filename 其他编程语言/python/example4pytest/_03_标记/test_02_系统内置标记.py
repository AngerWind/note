import pytest

from _01_hello_world import my_math



class TestAdd:
    @pytest.mark.skip
    @pytest.mark.web
    def test_add0(self):
        assert my_math.add(4, 2) == 6

    @pytest.mark.skipif(1 == 2, reason="不符合条件, 跳过")
    @pytest.mark.login
    def test_add1(self):
        assert my_math.add(4, 2) == 6

    @pytest.mark.xfail
    @pytest.mark.pay
    def test_add2(self):
        assert my_math.add(4, 3) == 6

    @pytest.mark.xfail
    @pytest.mark.pay
    def test_add3(self):
        assert my_math.add(4, 2) == 6