from celery import Celery


app = Celery('celery_demo',
             broker='redis://127.0.0.1:6379/1',
             backend='redis://127.0.0.1:6379/2',
             # 在include中要指定包含task的python
             # 语法就是 python中的import语法
             # 比如: package1.sub1.sub2.task01, 那么就会查找 根目录/package1/sub1/sub2/task01.py
             include=['_03_celery_exec_after_delay.task']
             )


# 时区
app.conf.timezone = 'Asia/Shanghai'
# 是否使用UTC
app.conf.enable_utc = False




