import time


def test_example(selenium):
    selenium.get('http://www.baidu.com')
    print(selenium.title)
    print(selenium.current_url)
    # 还可以执行元素的定位, 元素的交互
    # 截图, 文件上传
    time.sleep(1)