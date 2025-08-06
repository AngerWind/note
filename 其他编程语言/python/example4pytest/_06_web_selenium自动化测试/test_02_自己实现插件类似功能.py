import time

import pytest
from selenium import webdriver

@pytest.fixture
def use_selenium():
    d = webdriver.Firefox()
    yield d
    d.quit()

def test_example(use_selenium):
    use_selenium.get('http://www.baidu.com')
    print(use_selenium.title)
    print(use_selenium.current_url)
    # 还可以执行元素的定位, 元素的交互
    # 截图, 文件上传
    time.sleep(1)