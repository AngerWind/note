from datetime import timedelta

from celery import Celery
from celery.schedules import crontab


app = Celery('celery_demo',
             broker='redis://127.0.0.1:6379/1',
             backend='redis://127.0.0.1:6379/2',
             # 在include中要指定包含task的python
             # 语法就是 python中的import语法
             # 比如: package1.sub1.sub2.task01, 那么就会查找 根目录/package1/sub1/sub2/task01.py
             include=['_04_celery_scheduled_task.task']
             )


# 时区
app.conf.timezone = 'Asia/Shanghai'
# 是否使用UTC
app.conf.enable_utc = False


app.conf.beat_schedule = {
    # 任务的名字, 睡意
    'add-every-10-seconds': {
        # 要执行的任务
        'task': '_04_celery_scheduled_task.task.send_email',
        # 'schedule': 1.0, # 每隔1s执行一次
        'schedule': timedelta(seconds=10), # 每隔10s执行一次
        # 'schedule': timedelta(minutes=10), # 每隔10分钟执行一次
        # 'schedule': timedelta(hours=2),    # 每隔2小时执行一次
        # 'schedule': crontab(minute="*/1"), # 每分钟执行一次
        # "schedule": crontab(minute=30, hour=10), # 每天10:30执行任务
        # 'schedule': crontab(hour=9, minute=0, day_of_week="mon"), # 每周一早上9:00执行任务
        # 'schedule': crontab(minute=42, hour=8, day_of_month=11, month_of_year=4), # 每年4月11日8:42执行
        # 传递参数
        'args': ('张三',)
    },
}
