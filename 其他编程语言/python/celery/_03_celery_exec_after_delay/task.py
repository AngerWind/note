import time
from _02_celery_mutil_task_struction.celery import app



@app.task
def send_email(res):
    print("完成向%s发送邮件任务"%res)
    time.sleep(5)
    return "邮件完成！"

@app.task
def send_msg(name):
    print("完成向%s发送短信任务"%name)
    time.sleep(5)
    return "短信完成！"